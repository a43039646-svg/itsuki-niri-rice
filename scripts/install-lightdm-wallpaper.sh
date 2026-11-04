#!/usr/bin/env bash
set -euo pipefail

WALLPAPER_SOURCE="${1:-}"
if [[ -z "$WALLPAPER_SOURCE" || ! -f "$WALLPAPER_SOURCE" ]]; then
  echo "LightDM wallpaper is missing: ${WALLPAPER_SOURCE:-<not supplied>}" >&2
  exit 1
fi

find_command() {
  local name="$1" path
  path="$(command -v "$name" 2>/dev/null || true)"
  if [[ -n "$path" ]]; then
    printf '%s\n' "$path"
    return 0
  fi
  for path in "/usr/sbin/$name" "/usr/bin/$name" "/usr/local/sbin/$name" \
              "/usr/lib/lightdm/$name" "/usr/lib/slick-greeter/$name"; do
    if [[ -x "$path" ]]; then
      printf '%s\n' "$path"
      return 0
    fi
  done
  return 1
}

LIGHTDM_BIN="$(find_command lightdm || true)"
LIGHTDM_DIR="/etc/lightdm"
if [[ ! -d "$LIGHTDM_DIR" || -z "$LIGHTDM_BIN" ]]; then
  echo "LightDM is not installed; skipping its login-screen wallpaper."
  exit 0
fi

# Ask LightDM for its merged configuration first. Fall back to reading the
# standard config locations for installations where --show-config is absent.
GREETER_SESSION="$("$LIGHTDM_BIN" --show-config 2>/dev/null | awk -F= '
  /^[[:space:]]*greeter-session[[:space:]]*=/ {
    value=$2
    sub(/^[[:space:]]+/, "", value)
    sub(/[[:space:]]+$/, "", value)
  }
  END { print value }
' || true)"

if [[ -z "$GREETER_SESSION" ]]; then
  for config in /usr/share/lightdm/lightdm.conf.d/*.conf \
                "$LIGHTDM_DIR"/lightdm.conf.d/*.conf \
                "$LIGHTDM_DIR/lightdm.conf"; do
    [[ -f "$config" ]] || continue
    value="$(awk -F= '
      /^[[:space:]]*#/ { next }
      /^[[:space:]]*greeter-session[[:space:]]*=/ {
        v=$2
        sub(/^[[:space:]]+/, "", v)
        sub(/[[:space:]]+$/, "", v)
        print v
      }
    ' "$config" | tail -n 1)"
    [[ -n "$value" ]] && GREETER_SESSION="$value"
  done
fi

case "$GREETER_SESSION" in
  lightdm-gtk-greeter*)
    GREETER_CONFIG="$LIGHTDM_DIR/lightdm-gtk-greeter.conf"
    GREETER_SECTION="greeter"
    GREETER_LABEL="LightDM GTK Greeter"
    ;;
  slick-greeter*)
    GREETER_CONFIG="$LIGHTDM_DIR/slick-greeter.conf"
    GREETER_SECTION="Greeter"
    GREETER_LABEL="Slick Greeter"
    ;;
  *)
    # If no explicit session was found, use an installed supported greeter.
    GTK_GREETER_BIN="$(find_command lightdm-gtk-greeter || true)"
    SLICK_GREETER_BIN="$(find_command slick-greeter || true)"
    if [[ -n "$GTK_GREETER_BIN" ]]; then
      GREETER_CONFIG="$LIGHTDM_DIR/lightdm-gtk-greeter.conf"
      GREETER_SECTION="greeter"
      GREETER_LABEL="LightDM GTK Greeter"
    elif [[ -n "$SLICK_GREETER_BIN" ]]; then
      GREETER_CONFIG="$LIGHTDM_DIR/slick-greeter.conf"
      GREETER_SECTION="Greeter"
      GREETER_LABEL="Slick Greeter"
    else
      echo "LightDM greeter '$GREETER_SESSION' is not supported by the automatic wallpaper setup; skipping."
      exit 0
    fi
    ;;
esac

if [[ "$EUID" -ne 0 ]] && ! command -v sudo >/dev/null 2>&1; then
  echo "sudo is required to configure the LightDM login wallpaper; skipping LightDM."
  exit 0
fi

as_root() {
  if [[ "$EUID" -eq 0 ]]; then
    "$@"
  else
    sudo "$@"
  fi
}

if [[ "$EUID" -ne 0 ]]; then
  if ! sudo -v; then
    echo "Could not obtain administrator permission; skipping LightDM wallpaper setup."
    exit 0
  fi
fi

WALLPAPER_DEST="/usr/share/backgrounds/itsuki-lightdm/lightdm-itsuki.png"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$LIGHTDM_DIR/itsuki-backup-$STAMP"
TEMP_CONFIG="$(mktemp)"
cleanup() {
  rm -f -- "$TEMP_CONFIG"
}
trap cleanup EXIT

# Update only the active greeter's background key; preserve every other
# setting and comment in the existing configuration file.
python3 - "$GREETER_CONFIG" "$TEMP_CONFIG" "$GREETER_SECTION" "$WALLPAPER_DEST" <<'PYLIGHTDM'
from pathlib import Path
import re
import sys

source = Path(sys.argv[1])
target = Path(sys.argv[2])
section_name = sys.argv[3].casefold()
wallpaper = sys.argv[4]

try:
    lines = source.read_text().splitlines() if source.exists() else []
except OSError as exc:
    print(f"Cannot read {source}: {exc}", file=sys.stderr)
    raise SystemExit(1)

header = re.compile(r"^\s*\[([^]]+)\]\s*(?:[#;].*)?$")
start = None
for i, line in enumerate(lines):
    match = header.match(line)
    if match and match.group(1).strip().casefold() == section_name:
        start = i
        break

if start is None:
    if lines and lines[-1].strip():
        lines.append("")
    lines.append(f"[{sys.argv[3]}]")
    start = len(lines) - 1

def section_end():
    for i in range(start + 1, len(lines)):
        if header.match(lines[i]):
            return i
    return len(lines)

def set_section_value(name, value):
    end = section_end()
    setting_re = re.compile(r"^\s*" + re.escape(name) + r"\s*=", re.IGNORECASE)
    matches = [i for i in range(start + 1, end)
               if setting_re.match(lines[i]) and not lines[i].lstrip().startswith(("#", ";"))]
    if matches:
        lines[matches[0]] = f"{name}={value}"
        for i in reversed(matches[1:]):
            del lines[i]
    else:
        lines.insert(end, f"{name}={value}")

set_section_value("background", wallpaper)

# LightDM GTK Greeter supports centering the login window with position.
# Keep the selected Itsuki background instead of using per-user wallpapers.
if section_name == "greeter":
    set_section_value("position", "50%,center 50%,center")
    set_section_value("user-background", "false")

target.write_text("\n".join(lines).rstrip() + "\n")
PYLIGHTDM

as_root install -d -m 0700 "$BACKUP_DIR"
if [[ -e "$GREETER_CONFIG" || -L "$GREETER_CONFIG" ]]; then
  as_root cp -a "$GREETER_CONFIG" "$BACKUP_DIR/$(basename "$GREETER_CONFIG")"
fi
if [[ -e "$WALLPAPER_DEST" || -L "$WALLPAPER_DEST" ]]; then
  as_root cp -a "$WALLPAPER_DEST" "$BACKUP_DIR/lightdm-itsuki.png"
fi

# Install the image before changing the greeter configuration to point at it.
as_root install -D -m 0644 "$WALLPAPER_SOURCE" "$WALLPAPER_DEST"
as_root install -D -m 0644 "$TEMP_CONFIG" "$GREETER_CONFIG"

echo "$GREETER_LABEL configured with the Itsuki login wallpaper."
echo "Background: $WALLPAPER_DEST"
echo "Backup: $BACKUP_DIR"
echo "The login screen will use it next time LightDM starts; the installer does not restart LightDM."
