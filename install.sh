#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPOSITORY_URL="https://github.com/a43039646-svg/itsuki-niri-rice.git"
TEMP_SOURCE_DIR=""
cleanup_temp_source() {
  if [[ -n "$TEMP_SOURCE_DIR" && -d "$TEMP_SOURCE_DIR" ]]; then
    rm -rf -- "$TEMP_SOURCE_DIR"
  fi
}
trap cleanup_temp_source EXIT

# If only install.sh was downloaded (for example, via curl | bash), fetch the
# repository so the shared config files are available.
if [[ ! -d "$ROOT/configs" || ! -d "$ROOT/scripts" ]]; then
  TEMP_SOURCE_DIR="$(mktemp -d)"
  if command -v git >/dev/null 2>&1 && git clone --depth 1 --quiet "$REPOSITORY_URL" "$TEMP_SOURCE_DIR/repo"; then
    ROOT="$TEMP_SOURCE_DIR/repo"
  elif command -v curl >/dev/null 2>&1 && command -v tar >/dev/null 2>&1; then
    rm -rf -- "$TEMP_SOURCE_DIR/repo"
    curl -fsSL "https://github.com/a43039646-svg/itsuki-niri-rice/archive/refs/heads/main.tar.gz" -o "$TEMP_SOURCE_DIR/repo.tar.gz"
    tar -xzf "$TEMP_SOURCE_DIR/repo.tar.gz" -C "$TEMP_SOURCE_DIR"
    ROOT="$TEMP_SOURCE_DIR/itsuki-niri-rice-main"
  else
    echo "Could not download the rice files. Install git, or curl and tar, and try again." >&2
    exit 1
  fi
fi

if [[ ! -d "$ROOT/configs" || ! -d "$ROOT/scripts" ]]; then
  echo "The Itsuki Niri Rice repository is incomplete: configs/ or scripts/ is missing." >&2
  exit 1
fi
WALLPAPER_SOURCE="$ROOT/wallpapers/itsuki.png"
LIGHTDM_WALLPAPER_SOURCE="$ROOT/wallpapers/lightdm-itsuki.png"
WALLPAPER_AVAILABLE=0
LIGHTDM_WALLPAPER_AVAILABLE=0
SWAYBG_BIN=""
if [[ -f "$WALLPAPER_SOURCE" ]]; then
  WALLPAPER_AVAILABLE=1
  if ! command -v swaybg >/dev/null 2>&1; then
    echo "swaybg is required when wallpapers/itsuki.png is present. Install swaybg and run the installer again." >&2
    exit 1
  fi
  SWAYBG_BIN="$(command -v swaybg)"
else
  echo "No desktop PNG is bundled yet; skipping the desktop wallpaper setup."
fi
if [[ -f "$LIGHTDM_WALLPAPER_SOURCE" ]]; then
  LIGHTDM_WALLPAPER_AVAILABLE=1
else
  echo "No LightDM PNG is bundled yet; skipping the LightDM wallpaper setup."
fi
for command_name in swaync swaync-client; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "SwayNotificationCenter is required. On Debian install it with: sudo apt install sway-notification-center" >&2
    exit 1
  fi
done
WALLPAPER_DIR="$HOME/.local/share/itsuki-niri-rice/wallpapers"
WALLPAPER_DEST="$WALLPAPER_DIR/itsuki.png"
WALLPAPER_STATE="$WALLPAPER_DIR/.wallpaper-enabled"

CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
STAMP="$(date +%Y%m%d-%H%M%S)"
DISTRO="universal"
DISTRO_ICON=""
DISTRO_LABEL="Itsuki"
CONFIG_SOURCE="$ROOT/configs"

for rel in waybar/config waybar/style.css kitty/kitty.conf fuzzel/fuzzel.ini swaync/config.json swaync/style.css fetch/config xdg-desktop-portal/niri-portals.conf; do
  if [[ ! -f "$CONFIG_SOURCE/$rel" ]]; then
    echo "Required config file is missing: $CONFIG_SOURCE/$rel" >&2
    exit 1
  fi
done
for rel in scripts/niri-power-menu scripts/itsuki-wifi-menu.py scripts/itsuki-reload-rice scripts/enable-kitty-blur.py scripts/install-lightdm-wallpaper.sh; do
  if [[ ! -f "$ROOT/$rel" ]]; then
    echo "Required helper script is missing: $ROOT/$rel" >&2
    exit 1
  fi
done

# Verify the existing Niri config before touching any installed files.
# The rice patches this file rather than replacing the user's whole Niri setup.
if ! command -v python3 >/dev/null 2>&1; then
  echo "Python 3 is required by the installer. No changes were made." >&2
  exit 1
fi
if ! python3 - "$CONFIG_HOME/niri/config.kdl" <<'PREFLIGHT_NIRI'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
if not path.is_file():
    print(f"Niri config not found: {path}; no files were changed.", file=sys.stderr)
    raise SystemExit(1)
try:
    text = path.read_text()
except OSError as exc:
    print(f"Cannot read Niri config {path}: {exc}; no files were changed.", file=sys.stderr)
    raise SystemExit(1)
if not re.search(r"(?m)^[ \t]*binds\s*\{", text):
    print(f"No top-level binds block found in {path}; no files were changed.", file=sys.stderr)
    raise SystemExit(1)
PREFLIGHT_NIRI
then
  exit 1
fi

BACKUP="$CONFIG_HOME/itsuki-niri-backup/$STAMP"
mkdir -p "$BACKUP" "$HOME/.local/bin" "$CONFIG_HOME/waybar" "$CONFIG_HOME/kitty" "$CONFIG_HOME/fuzzel" "$CONFIG_HOME/swaync" "$CONFIG_HOME/fetch" "$CONFIG_HOME/xdg-desktop-portal" "$CONFIG_HOME/niri"
backup() {
  local path="$1" rel="$2"
  if [[ -f "$path" || -L "$path" ]]; then
    mkdir -p "$BACKUP/$(dirname "$rel")"
    cp -a "$path" "$BACKUP/$rel"
  fi
}
for rel in niri/config.kdl waybar/config waybar/style.css kitty/kitty.conf fuzzel/fuzzel.ini swaync/config.json swaync/style.css fetch/config xdg-desktop-portal/niri-portals.conf; do
  backup "$CONFIG_HOME/$rel" "$rel"
done
backup "$WALLPAPER_DEST" "wallpapers/itsuki.png"
backup "$HOME/.local/bin/miku-reload-rice" "local-bin/miku-reload-rice"

# Waybar can use config.json/config.jsonc instead of config. Back them up too,
# then remove only those known competing filenames so the selected config wins.
for rel in waybar/config.json waybar/config.jsonc; do
  backup "$CONFIG_HOME/$rel" "$rel"
done

# Remove competing Waybar config aliases only after they have been backed up.
rm -f "$CONFIG_HOME/waybar/config.json" "$CONFIG_HOME/waybar/config.jsonc"
mkdir -p "$WALLPAPER_DIR"
if [[ "$WALLPAPER_AVAILABLE" == "1" ]]; then
  install -m 0644 "$WALLPAPER_SOURCE" "$WALLPAPER_DEST"
  : > "$WALLPAPER_STATE"
else
  rm -f "$WALLPAPER_STATE"
fi
for rel in waybar/config waybar/style.css kitty/kitty.conf fuzzel/fuzzel.ini swaync/config.json swaync/style.css fetch/config xdg-desktop-portal/niri-portals.conf; do
  mkdir -p "$CONFIG_HOME/$(dirname "$rel")"
  cp "$CONFIG_SOURCE/$rel" "$CONFIG_HOME/$rel"
done
python3 - "$CONFIG_HOME/swaync/config.json" <<'PYSWAYNC'
import json
from pathlib import Path
import sys

path = Path(sys.argv[1])
config = json.loads(path.read_text())
backlight_root = Path("/sys/class/backlight")
devices = sorted(item.name for item in backlight_root.iterdir()) if backlight_root.is_dir() else []
widgets = config.setdefault("widgets", [])
if devices:
    config.setdefault("widget-config", {}).setdefault("backlight", {})["device"] = devices[0]
    config["widget-config"]["backlight"].setdefault("subsystem", "backlight")
    if "backlight" not in widgets:
        widgets.insert(1, "backlight")
else:
    config["widgets"] = [widget for widget in widgets if widget != "backlight"]
path.write_text(json.dumps(config, ensure_ascii=False, indent=2) + "\n")
PYSWAYNC
install -m 755 "$ROOT/scripts/niri-power-menu" "$HOME/.local/bin/niri-power-menu"
install -m 755 "$ROOT/scripts/itsuki-reload-rice" "$HOME/.local/bin/itsuki-reload-rice"
# Retire the stale Miku reload helper after backing it up; its old shortcut reset miku.png.
rm -f "$HOME/.local/bin/miku-reload-rice"
SLIDER_SOURCE="$ROOT/scripts/itsuki-slider.py"
if [[ -f "$CONFIG_SOURCE/scripts/itsuki-slider.py" ]]; then SLIDER_SOURCE="$CONFIG_SOURCE/scripts/itsuki-slider.py"; fi
install -m 755 "$SLIDER_SOURCE" "$HOME/.local/bin/itsuki-slider.py"
install -m 755 "$ROOT/scripts/itsuki-wifi-menu.py" "$HOME/.local/bin/itsuki-wifi-menu.py"
SHELL_NAME="$(basename "${SHELL:-bash}")"
case "$SHELL_NAME" in bash) SHELL_RC="$HOME/.bashrc" ;; zsh) SHELL_RC="$HOME/.zshrc" ;; *) SHELL_RC="" ;; esac
if [[ -n "$SHELL_RC" ]]; then
  backup "$SHELL_RC" "$(basename "$SHELL_RC")"
  FETCH_COMMAND=""
  if command -v fastfetch >/dev/null 2>&1; then
    FETCH_COMMAND="fastfetch"
  elif command -v fetch >/dev/null 2>&1; then
    FETCH_COMMAND="fetch --box --shading-mode sextants"
  fi
  python3 - "$SHELL_RC" "$FETCH_COMMAND" <<'PYFETCHRC'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
command = sys.argv[2]
marker = "# ITSUKI_FETCH_AUTOSTART:"
managed_pattern = re.compile(
    r"(?ms)^# ITSUKI_FETCH_AUTOSTART:[^\n]*\n.*?^fi[ \t]*(?:\n|$)"
)

try:
    original = path.read_text() if path.exists() else ""
except OSError as exc:
    print(f"Could not read {path}: {exc}", file=sys.stderr)
    raise SystemExit(1)

managed_matches = list(managed_pattern.finditer(original))
if marker in original and not managed_matches:
    print(f"Found an incomplete Itsuki Fetch marker in {path}; leaving it unchanged.", file=sys.stderr)
    raise SystemExit(0)

# Strip only our own previous block while checking for a user's existing command.
text = managed_pattern.sub("", original)
active_lines = [
    line for line in text.splitlines()
    if not line.lstrip().startswith("#")
]
has_fetch_autostart = False
for line in active_lines:
    # Ignore command-presence probes; only a real fetch/fastfetch invocation counts.
    invocation = re.sub(
        r"\b(?:command\s+-v|which)\s+(?:fastfetch|fetch)\b",
        "",
        line,
        flags=re.IGNORECASE,
    )
    if re.search(r"\b(?:fastfetch|fetch)\b", invocation, re.IGNORECASE):
        has_fetch_autostart = True
        break

if has_fetch_autostart:
    if managed_matches:
        path.write_text(text)
        print("Found an existing Fetch/Fastfetch autostart; removed the duplicate Itsuki block.")
    else:
        print("Existing Fetch/Fastfetch autostart detected; not adding another one.")
    raise SystemExit(0)

if not command:
    if managed_matches:
        path.write_text(text)
    print("Neither fastfetch nor fetch is installed; no terminal autostart was added.")
    raise SystemExit(0)

binary = "fastfetch" if command == "fastfetch" else "fetch"
block = (
    marker + " run only in interactive shells.\n"
    "if [[ $- == *i* ]] && command -v " + binary + " >/dev/null 2>&1; then\n"
    "    " + command + "\n"
    "fi"
)
if text and not text.endswith("\n"):
    text += "\n"
if text and not text.endswith("\n\n"):
    text += "\n"
path.write_text(text + block + "\n")
print(f"Configured one terminal autostart for {command}.")
PYFETCHRC
fi

python3 - "$CONFIG_HOME/waybar/config" "$HOME/.local/bin" "$DISTRO_ICON" "$DISTRO_LABEL" <<'PYWAYBAR'
import json,sys
from pathlib import Path
p=Path(sys.argv[1]); bin=Path(sys.argv[2]); icon=sys.argv[3]; label=sys.argv[4]
cfg=json.loads(p.read_text())
left=cfg.setdefault('modules-left',[])
if 'custom/distro' in left: left.remove('custom/distro')
if 'custom/debian' in left: left.remove('custom/debian')
cfg.pop('custom/debian', None)
if icon:
    left.insert(0,'custom/distro')
    cfg['custom/distro']={'format':icon,'tooltip':label,'on-click':'fuzzel'}
else:
    cfg.pop('custom/distro', None)
right=cfg.setdefault('modules-right',[])
if 'tray' not in right: right.append('tray')
backlight=Path('/sys/class/backlight')
if backlight.is_dir() and any(backlight.iterdir()):
    if 'backlight' not in right:
        position = right.index('battery') if 'battery' in right else len(right)
        right.insert(position, 'backlight')
    cfg['backlight']={'format':'  {percent}%','tooltip':True,'on-click':f'python3 {bin / "itsuki-slider.py"} brightness','on-scroll-up':'brightnessctl -c backlight set +5%','on-scroll-down':'brightnessctl -c backlight set 5%-'}
network=cfg.setdefault('network',{}); network.update({'format-wifi':' {signalStrength}%','format-ethernet':' LAN','format-disconnected':' offline'})
sound=cfg.setdefault('pulseaudio',{}); sound.update({'format':' {volume}%','format-muted':' muted','on-click':f'python3 {bin / "itsuki-slider.py"} volume','on-click-right':'wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle','scroll-step':5})
tray=cfg.setdefault('tray',{}); tray.update({'icon-size':18,'spacing':8,'show-passive-items':True,'tooltip':True})
p.write_text(json.dumps(cfg,indent=2,ensure_ascii=False)+'\n')
PYWAYBAR

cp "$CONFIG_HOME/niri/config.kdl" "$BACKUP/niri-config.pre-patch.kdl"
python3 - "$CONFIG_HOME/niri/config.kdl" "$HOME" "$SWAYBG_BIN" "$WALLPAPER_DEST" "$WALLPAPER_AVAILABLE" <<'PYNIRI'
from pathlib import Path
import json,re,sys

p = Path(sys.argv[1])
home = sys.argv[2]
text = p.read_text()

# Replace the rice-managed startup block on every run so installs stay idempotent.
text = re.sub(
    r"(?ms)^// BEGIN ITSUKI RICE STARTUP\n.*?^// END ITSUKI RICE STARTUP[ \t]*(?:\n|$)",
    "",
    text,
)
# Remove old panel/background startup lines that this rice now manages itself.
text = re.sub(
    r'(?m)^[ \t]*(?:spawn-at-startup|spawn-sh-at-startup)\b[^\n]*(?:\bwaybar\b|\bdunst\b|\bswaync\b|\bswaybg\b|\bswww\b|\bawww\b|\bmpvpaper\b|\bhyprpaper\b)[^\n]*(?:\n|$)',
    "",
    text,
)

def kdl_string(value):
    return json.dumps(str(value), ensure_ascii=False)

wallpaper_startup = ""
if sys.argv[5] == "1":
    wallpaper_startup = (
        f"spawn-at-startup {kdl_string(sys.argv[3])} \"-i\" {kdl_string(sys.argv[4])} \"-m\" \"fill\"\n"
    )
startup = (
    "// BEGIN ITSUKI RICE STARTUP\n"
    f"spawn-at-startup {kdl_string('swaync')}\n"
    f"spawn-at-startup {kdl_string('waybar')}\n"
    + wallpaper_startup +
    "// END ITSUKI RICE STARTUP\n"
)
# Replace any Miku/previous rice Meta+Shift+B binding with the Itsuki reload helper.
# The old Miku helper explicitly restored ~/Pictures/Wallpapers/miku.png.
text = re.sub(
    r'(?m)^[ \t]*(?:Mod|Super)\+Shift\+B\b[^\n]*(?:\n|$)',
    '',
    text,
)

match = re.search(r"(?m)^[ \t]*binds\s*\{", text)
if not match:
    raise SystemExit("No top-level binds block found; existing config was not written.")
text = text[:match.start()] + startup + "\n" + text[match.start():]
match = re.search(r"(?m)^[ \t]*binds\s*\{", text)
reload_binding = (
    f'    Super+Shift+B hotkey-overlay-title="Reload Niri and Itsuki Rice services" '
    f'{{ spawn "{home}/.local/bin/itsuki-reload-rice"; }}\n'
)
text = text[:match.end()] + "\n" + reload_binding + text[match.end():]

p.write_text(text)
PYNIRI

# Set matching Itsuki window borders while preserving the rest of the user's layout.
python3 - "$CONFIG_HOME/niri/config.kdl" <<'PYCOLORS'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
text = path.read_text()

def matching_brace(source, opening):
    depth = 0
    quoted = False
    escaped = False
    line_comment = False
    i = opening
    while i < len(source):
        ch = source[i]
        if line_comment:
            if ch == "\n":
                line_comment = False
        elif quoted:
            if escaped:
                escaped = False
            elif ch == "\\":
                escaped = True
            elif ch == '"':
                quoted = False
        elif ch == "/" and source[i:i + 2] == "//":
            line_comment = True
            i += 1
        elif ch == '"':
            quoted = True
        elif ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth == 0:
                return i
        i += 1
    raise SystemExit("Unclosed Niri config block; no color changes were written.")

def update_flag(block, flag):
    opening = block.find("{")
    body = block[opening + 1:-1]
    body = re.sub(r"(?m)^[ \t]*(?:on|off)[ \t]*(?:\n|$)", "", body)
    return block[:opening + 1] + "\n        " + flag + "\n" + body.lstrip("\n") + "}"

def update_value(block, name, value):
    pattern = re.compile(r"(?m)^([ \t]*)" + re.escape(name) + r"(?:[ \t]+[^\n]*)?[ \t]*$")
    matches = list(pattern.finditer(block))
    if matches:
        first = matches[0]
        block = block[:first.start()] + first.group(1) + name + " " + value + block[first.end():]
        for match in reversed(matches[1:]):
            block = block[:match.start()] + block[match.end():]
    else:
        close = block.rfind("}")
        block = block[:close] + "        " + name + " " + value + "\n    " + block[close:]
    return block

def update_section(layout_body, name, flag, settings):
    match = re.search(r"(?m)^([ \t]*)" + re.escape(name) + r"[ \t]*\{", layout_body)
    if match:
        opening = layout_body.find("{", match.start())
        closing = matching_brace(layout_body, opening)
        block = layout_body[match.start():closing + 1]
        block = update_flag(block, flag)
        if name == "border":
            # Niri gradients override the solid color properties. Remove old
            # user gradients so the wallpaper-matched coral border is visible.
            block = re.sub(
                r"(?m)^[ \\t]*(?:active|inactive|urgent)-gradient\\b[^\\n]*(?:\\n|$)",
                "",
                block,
            )
        for key, value in settings.items():
            block = update_value(block, key, value)
        return layout_body[:match.start()] + block + layout_body[closing + 1:]
    lines = [f"    {name} {{", f"        {flag}"]
    lines.extend(f"        {key} {value}" for key, value in settings.items())
    lines.append("    }")
    return layout_body.rstrip() + "\n\n" + "\n".join(lines) + "\n"

layout_match = re.search(r"(?m)^layout[ \t]*\{", text)
if layout_match:
    layout_open = text.find("{", layout_match.start())
    layout_close = matching_brace(text, layout_open)
    body = text[layout_open + 1:layout_close]
else:
    layout_open = layout_close = -1
    body = ""

# Leave the user's layout background untouched; only patch window-border colors.
body = update_section(
    body,
    "focus-ring",
    "off",
    {},
)
body = update_section(
    body,
    "border",
    "on",
    {
        "width": "2",
        "active-color": '"#D95F58"',
        "inactive-color": '"#426B7A"',
        "urgent-color": '"#F07868"',
    },
)

if layout_open >= 0:
    text = text[:layout_open + 1] + body + text[layout_close:]
else:
    marker = re.search(r"(?m)^binds[ \t]*\{", text)
    new_block = "layout {\n" + body + "}\n\n"
    text = text[:marker.start()] + new_block + text[marker.start():] if marker else new_block + text

# Remove the one exact invalid setting introduced by the earlier Itsuki installer.
# It may be nested in any KDL block, so do not assume it is under layout/struts.
text = re.sub(
    r'(?m)^[ \t]*background-color[ \t]+"#0D2430"[ \t]*(?:\n|$)',
    "",
    text,
)
path.write_text(text)
PYCOLORS

# Validate the Niri config before changing blur/Kitty settings. If the rice
# patch is rejected, restore the exact pre-install config created above.
if command -v niri >/dev/null 2>&1; then
  if ! niri validate; then
    cp -a "$BACKUP/niri-config.pre-patch.kdl" "$CONFIG_HOME/niri/config.kdl"
    echo "Niri validation failed after applying Itsuki window borders; restored the pre-install config from $BACKUP." >&2
    exit 1
  fi
fi

# Apply the desktop wallpaper immediately when installing from the active Niri session.
# The startup entry above keeps the same wallpaper after future logins.
if [[ "$WALLPAPER_AVAILABLE" == "1" && -n "${NIRI_SOCKET:-}" && -n "${WAYLAND_DISPLAY:-}" ]]; then
  pkill -x swaybg >/dev/null 2>&1 || true
  nohup "$SWAYBG_BIN" -i "$WALLPAPER_DEST" -m fill >/dev/null 2>&1 </dev/null &
fi

# Apply the optional Kitty transparency and Niri 26.04+ blur profile.
python3 "$ROOT/scripts/enable-kitty-blur.py" "$CONFIG_HOME/niri/config.kdl" "$CONFIG_HOME/kitty/kitty.conf"
python3 -m json.tool "$CONFIG_HOME/waybar/config" >/dev/null
if command -v niri >/dev/null 2>&1; then niri validate; fi

# Reload Waybar in the active Niri session so the new opaque stylesheet is visible immediately.
if [[ -n "${NIRI_SOCKET:-}" && -n "${WAYLAND_DISPLAY:-}" ]]; then
  pkill -x waybar >/dev/null 2>&1 || true
  nohup waybar >/dev/null 2>&1 </dev/null &
  pkill -x dunst >/dev/null 2>&1 || true
  pkill -x swaync >/dev/null 2>&1 || true
  nohup swaync >/dev/null 2>&1 </dev/null &
fi

# Niri is the single source of Waybar startup. Remove the old systemd dependency
# written by earlier versions of this installer, plus any enabled user Waybar unit.
if command -v systemctl >/dev/null 2>&1; then
  SYSTEMD_USER_CONFIG="$CONFIG_HOME/systemd/user"
  OLD_WAYBAR_WANT="$SYSTEMD_USER_CONFIG/niri.service.wants/waybar.service"
  if [[ -L "$OLD_WAYBAR_WANT" ]]; then
    rm -f "$OLD_WAYBAR_WANT"
    rmdir "$SYSTEMD_USER_CONFIG/niri.service.wants" 2>/dev/null || true
  fi
  if systemctl --user cat waybar.service >/dev/null 2>&1; then
    systemctl --user disable --now waybar.service >/dev/null 2>&1 || true
  fi
  systemctl --user daemon-reload >/dev/null 2>&1 || true
fi

if [[ "$LIGHTDM_WALLPAPER_AVAILABLE" == "1" ]]; then
  bash "$ROOT/scripts/install-lightdm-wallpaper.sh" "$LIGHTDM_WALLPAPER_SOURCE"
fi

echo "Installed Itsuki Niri Rice (universal profile). Backups: $BACKUP"
if [[ "$WALLPAPER_AVAILABLE" != "1" ]]; then
  echo "Desktop wallpaper skipped: add wallpapers/itsuki.png when your new image is ready."
fi
if [[ "$LIGHTDM_WALLPAPER_AVAILABLE" != "1" ]]; then
  echo "LightDM wallpaper skipped: add wallpapers/lightdm-itsuki.png when your new image is ready."
fi
