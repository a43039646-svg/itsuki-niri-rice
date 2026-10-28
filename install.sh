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
# repository so the selected profile's configs and wallpaper are available.
if [[ ! -d "$ROOT/configs" || ! -d "$ROOT/wallpaper" ]]; then
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

if [[ ! -d "$ROOT/configs" || ! -d "$ROOT/wallpaper" ]]; then
  echo "The Itsuki Niri Rice repository is incomplete: configs/ or wallpaper/ is missing." >&2
  exit 1
fi
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
STAMP="$(date +%Y%m%d-%H%M%S)"
if [[ -n "${ITSUKI_DISTRO:-}" ]]; then
  DISTRO="$ITSUKI_DISTRO"
else
  printf '\nItsuki Niri Rice — choose a theme\n'
  printf '  1) Itsuki only (neutral, no distro logo)\n'
  printf '  2) Itsuki + Arch Linux\n'
  printf '  3) Itsuki + Debian\n'
  printf '  4) Itsuki + Gentoo\n\n'

  if [[ ! -r /dev/tty || ! -w /dev/tty ]]; then
    echo "No interactive terminal found. Run a variants/*/install.sh script or set ITSUKI_DISTRO." >&2
    exit 2
  fi

  while true; do
    if ! IFS= read -r -p "Choose [1-4]: " choice </dev/tty; then
      echo "No selection received; installation cancelled." >&2
      exit 2
    fi
    case "$choice" in
      1) DISTRO='neutral'; break ;;
      2) DISTRO='arch'; break ;;
      3) DISTRO='debian'; break ;;
      4) DISTRO='gentoo'; break ;;
      *) echo "Invalid choice. Enter 1, 2, 3, or 4." >&2 ;;
    esac
  done
fi

# Main installer offers a choice of the same theme with or without the character.
# Filenames ending in "2" are the character versions; filenames without "2" are clean.
if [[ -n "${ITSUKI_WALLPAPER_STYLE:-}" ]]; then
  WALLPAPER_STYLE="$ITSUKI_WALLPAPER_STYLE"
elif [[ -n "${ITSUKI_DISTRO:-}" ]]; then
  # Direct variant entry points keep their familiar default: include Itsuki.
  WALLPAPER_STYLE="character"
else
  printf '\nWallpaper style\n'
  printf '  1) With Itsuki (wallpaper filename includes 2)\n'
  printf '  2) Without Itsuki (clean wallpaper, no 2 in filename)\n\n'

  while true; do
    if ! IFS= read -r -p "Choose wallpaper style [1-2]: " wallpaper_choice </dev/tty; then
      echo "No wallpaper style received; installation cancelled." >&2
      exit 2
    fi
    case "$wallpaper_choice" in
      1) WALLPAPER_STYLE="character"; break ;;
      2) WALLPAPER_STYLE="clean"; break ;;
      *) echo "Invalid choice. Enter 1 or 2." >&2 ;;
    esac
  done
fi
case "$WALLPAPER_STYLE" in
  character|clean) ;;
  *) echo "Unknown ITSUKI_WALLPAPER_STYLE: $WALLPAPER_STYLE (use character or clean)." >&2; exit 2 ;;
esac

case "$DISTRO" in
  debian)
    DISTRO_ICON=''; DISTRO_LABEL='Debian'; CONFIG_SOURCE="$ROOT/configs"
    if [[ "$WALLPAPER_STYLE" == "character" ]]; then
      WALLPAPER_FILE='itsuki_debian_wallpaper_v2_1600x900.png'
    else
      # There is no Debian-specific clean wallpaper yet; use the matching red neutral background.
      WALLPAPER_FILE='itsuki-neutral.png'
    fi
    ;;
  arch)
    DISTRO_ICON=''; DISTRO_LABEL='Arch Linux'; CONFIG_SOURCE="$ROOT/configs/arch"
    if [[ "$WALLPAPER_STYLE" == "character" ]]; then WALLPAPER_FILE='itsuki-arch2.png'; else WALLPAPER_FILE='itsuki-arch.png'; fi
    ;;
  gentoo)
    DISTRO_ICON=''; DISTRO_LABEL='Gentoo'; CONFIG_SOURCE="$ROOT/configs/gentoo"
    if [[ "$WALLPAPER_STYLE" == "character" ]]; then WALLPAPER_FILE='itsuki-gentoo2.png'; else WALLPAPER_FILE='itsuki-gentoo.png'; fi
    ;;
  neutral)
    DISTRO_ICON=''; DISTRO_LABEL='Itsuki Niri Rice'; CONFIG_SOURCE="$ROOT/configs"
    if [[ "$WALLPAPER_STYLE" == "character" ]]; then WALLPAPER_FILE='itsuki-neutral2.png'; else WALLPAPER_FILE='itsuki-neutral.png'; fi
    ;;
  *) echo "Unknown ITSUKI_DISTRO: $DISTRO (use debian, arch, gentoo or neutral)." >&2; exit 2 ;;
esac

WALLPAPER_SOURCE="$ROOT/wallpaper/$WALLPAPER_FILE"
for rel in waybar/config waybar/style.css kitty/kitty.conf fuzzel/fuzzel.ini dunst/dunstrc fetch/config xdg-desktop-portal/niri-portals.conf; do
  if [[ ! -f "$CONFIG_SOURCE/$rel" ]]; then
    echo "Required profile file is missing: $CONFIG_SOURCE/$rel" >&2
    exit 1
  fi
done
for rel in scripts/niri-power-menu scripts/itsuki-wifi-menu.py; do
  if [[ ! -f "$ROOT/$rel" ]]; then
    echo "Required shared script is missing: $ROOT/$rel" >&2
    exit 1
  fi
done
if [[ ! -f "$WALLPAPER_SOURCE" ]]; then
  echo "Wallpaper for the '$DISTRO' variant was not found: $WALLPAPER_SOURCE" >&2
  echo "No changes were made. Check that the selected wallpaper is included in wallpaper/." >&2
  exit 1
fi

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

BACKUP="$CONFIG_HOME/itsuki-niri-backup/$DISTRO/$STAMP"
mkdir -p "$BACKUP" "$HOME/.local/bin" "$HOME/Pictures/Wallpapers" "$CONFIG_HOME/waybar" "$CONFIG_HOME/kitty" "$CONFIG_HOME/fuzzel" "$CONFIG_HOME/dunst" "$CONFIG_HOME/fetch" "$CONFIG_HOME/xdg-desktop-portal" "$CONFIG_HOME/niri"
backup() {
  local path="$1" rel="$2"
  if [[ -f "$path" || -L "$path" ]]; then
    mkdir -p "$BACKUP/$(dirname "$rel")"
    cp -a "$path" "$BACKUP/$rel"
  fi
}
for rel in niri/config.kdl waybar/config waybar/style.css kitty/kitty.conf fuzzel/fuzzel.ini dunst/dunstrc fetch/config xdg-desktop-portal/niri-portals.conf; do
  backup "$CONFIG_HOME/$rel" "$rel"
done

# Waybar can use config.json/config.jsonc instead of config. Back them up too,
# then remove only those known competing filenames so the selected config wins.
for rel in waybar/config.json waybar/config.jsonc; do
  backup "$CONFIG_HOME/$rel" "$rel"
done

for current_wallpaper in "$HOME/Pictures/Wallpapers/itsuki.png" "$HOME/Pictures/Wallpapers/itsuki.jpg"; do
  if [[ -f "$current_wallpaper" ]]; then
    backup "$current_wallpaper" "wallpaper/$(basename "$current_wallpaper")"
  fi
done

# Remove competing Waybar config aliases only after they have been backed up.
rm -f "$CONFIG_HOME/waybar/config.json" "$CONFIG_HOME/waybar/config.jsonc"
install -m 0644 "$WALLPAPER_SOURCE" "$HOME/Pictures/Wallpapers/itsuki.png"
for rel in waybar/config waybar/style.css kitty/kitty.conf fuzzel/fuzzel.ini dunst/dunstrc fetch/config xdg-desktop-portal/niri-portals.conf; do cp "$CONFIG_SOURCE/$rel" "$CONFIG_HOME/$rel"; done
install -m 755 "$ROOT/scripts/niri-power-menu" "$HOME/.local/bin/niri-power-menu"
SLIDER_SOURCE="$ROOT/scripts/itsuki-slider.py"
if [[ -f "$CONFIG_SOURCE/scripts/itsuki-slider.py" ]]; then SLIDER_SOURCE="$CONFIG_SOURCE/scripts/itsuki-slider.py"; fi
install -m 755 "$SLIDER_SOURCE" "$HOME/.local/bin/itsuki-slider.py"
install -m 755 "$ROOT/scripts/itsuki-wifi-menu.py" "$HOME/.local/bin/itsuki-wifi-menu.py"
SHELL_NAME="$(basename "${SHELL:-bash}")"
case "$SHELL_NAME" in bash) SHELL_RC="$HOME/.bashrc" ;; zsh) SHELL_RC="$HOME/.zshrc" ;; *) SHELL_RC="" ;; esac
if [[ -n "$SHELL_RC" ]]; then
  # Back up the shell startup file before creating or updating our managed block.
  backup "$SHELL_RC" "$(basename "$SHELL_RC")"
  python3 - "$SHELL_RC" <<'PYFETCHRC'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
marker = "# ITSUKI_FETCH_AUTOSTART:"
block = """# ITSUKI_FETCH_AUTOSTART: show animated system info in interactive terminals.
if [[ $- == *i* ]] && command -v fetch >/dev/null 2>&1; then
    fetch --box --shading-mode sextants
fi"""
try:
    text = path.read_text() if path.exists() else ""
except OSError as exc:
    print(f"Could not read {path}: {exc}", file=sys.stderr)
    raise SystemExit(1)

pattern = re.compile(r"(?ms)^# ITSUKI_FETCH_AUTOSTART:[^\n]*\n.*?^fi[ \t]*(?:\n|$)")
if marker in text:
    match = pattern.search(text)
    if match is None:
        print(f"Found {marker} in {path}, but could not safely update its block.", file=sys.stderr)
        raise SystemExit(1)
    text = text[:match.start()] + block + "\n" + text[match.end():]
else:
    if text and not text.endswith("\n"):
        text += "\n"
    if text and not text.endswith("\n\n"):
        text += "\n"
    text += block + "\n"

path.write_text(text)
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
    if 'backlight' not in right: right.insert(0,'backlight')
    cfg['backlight']={'format':' {percent}%','tooltip':True,'on-click':f'python3 {bin / "itsuki-slider.py"} brightness','on-scroll-up':'brightnessctl -c backlight set +5%','on-scroll-down':'brightnessctl -c backlight set 5%-'}
network=cfg.setdefault('network',{}); network.update({'format-wifi':' {signalStrength}%','format-ethernet':' LAN','format-disconnected':' offline'})
sound=cfg.setdefault('pulseaudio',{}); sound.update({'format':' {volume}%','format-muted':' muted','on-click':f'python3 {bin / "itsuki-slider.py"} volume','on-click-right':'wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle','scroll-step':5})
tray=cfg.setdefault('tray',{}); tray.update({'icon-size':18,'spacing':8,'show-passive-items':True,'tooltip':True})
p.write_text(json.dumps(cfg,indent=2,ensure_ascii=False)+'\n')
PYWAYBAR

cp "$CONFIG_HOME/niri/config.kdl" "$BACKUP/niri-config.pre-patch.kdl"
python3 - "$CONFIG_HOME/niri/config.kdl" "$HOME" <<'PYNIRI'
from pathlib import Path
import re,sys
p=Path(sys.argv[1]); home=sys.argv[2]; text=p.read_text()
# Remove previous Niri startup entries for rice-managed apps, including legacy
# shell wrappers that launch Waybar. Otherwise a stale wrapper can race with
# the single Waybar instance added below.
text=re.sub(
    r'(?m)^[ \t]*(?:spawn-at-startup|spawn-sh-at-startup)\b[^\n]*\b(?:waybar|dunst|swaybg)\b[^\n]*(?:\n|$)',
    '',
    text,
)
startup='\n'.join(['spawn-at-startup "dunst"','spawn-at-startup "waybar"',f'spawn-at-startup "swaybg" "-i" "{home}/Pictures/Wallpapers/itsuki.png" "-m" "fill"'])+'\n'
m=re.search(r'(?m)^[ \t]*binds\s*\{',text)
if m: text=text[:m.start()]+startup+'\n'+text[m.start():]
else: text=startup+'\n'+text
lines=text.splitlines(); out=[]
for line in lines:
    s=line.strip()
    if (re.match(r'^(?:Mod|Super)\+D\b',s)
            or re.match(r'^Mod\+Return\b',s)
            or re.match(r'^Super\+E\b',s)
            or re.match(r'^(?:Mod|Super)\+Shift\+B\b',s)):
        continue
    out.append(line)
text='\n'.join(out)+'\n'
m=re.search(r'(?m)^[ \t]*binds\s*\{',text)
if not m: raise SystemExit('No binds block found; your backup is safe, but Niri shortcuts were not added.')
config_path=str(p).replace("\\", "\\\\").replace('"', '\\"')
ins=('    Mod+D hotkey-overlay-title="Application Launcher: Fuzzel" { spawn "fuzzel"; }\n'
     '    Mod+Return hotkey-overlay-title="Terminal: Kitty" { spawn "kitty"; }\n'
     f'    Super+E hotkey-overlay-title="Itsuki Power Menu" {{ spawn "{home}/.local/bin/niri-power-menu"; }}\n'
     f'    Super+Shift+B hotkey-overlay-title="Reload Niri configuration" {{ spawn "niri" "msg" "action" "load-config-file" "--path" "{config_path}"; }}\n')
text=text[:m.end()]+'\n'+ins+text[m.end():]
p.write_text(text)
PYNIRI
python3 -m json.tool "$CONFIG_HOME/waybar/config" >/dev/null
if command -v niri >/dev/null 2>&1; then niri validate; fi
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

# LightDM is optional. If it is present, offer the matching greeter setup after
# the desktop rice is installed; the dedicated script handles backups/consent.
if [[ -d /etc/lightdm ]]; then
  printf '\nLightDM GTK Greeter was detected.\n'
  if [[ -r /dev/tty && -w /dev/tty ]]; then
    read -r -p "Also configure the LightDM login screen with this theme? [y/N] " configure_lightdm </dev/tty || configure_lightdm=""
    case "$configure_lightdm" in
      y|Y|yes|YES)
        if [[ -f "$ROOT/install-lightdm.sh" ]]; then
          ITSUKI_LIGHTDM_PROFILE="$DISTRO" \
          ITSUKI_LIGHTDM_WALLPAPER="$WALLPAPER_STYLE" \
            bash "$ROOT/install-lightdm.sh"
        else
          echo "install-lightdm.sh was not found; skipping LightDM setup." >&2
        fi
        ;;
      *) echo "Skipping optional LightDM setup." ;;
    esac
  else
    echo "No interactive terminal; skipping optional LightDM setup."
  fi
else
  echo "LightDM config directory /etc/lightdm was not found; skipping optional greeter setup."
fi

echo "Installed Itsuki Niri Rice ($DISTRO_LABEL variant). Backups: $BACKUP"
echo "Wallpaper installed to $HOME/Pictures/Wallpapers/itsuki.png if present in the package."
echo "LightDM was left unchanged unless you explicitly accepted its separate setup prompt."
