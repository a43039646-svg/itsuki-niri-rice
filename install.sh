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
case "$DISTRO" in
  debian) DISTRO_ICON=''; DISTRO_LABEL='Debian'; WALLPAPER_FILE='itsuki_debian_wallpaper_v2_1600x900.png'; CONFIG_SOURCE="$ROOT/configs" ;;
  arch) DISTRO_ICON=''; DISTRO_LABEL='Arch Linux'; WALLPAPER_FILE='itsuki-arch.png'; CONFIG_SOURCE="$ROOT/configs/arch" ;;
  gentoo) DISTRO_ICON=''; DISTRO_LABEL='Gentoo'; WALLPAPER_FILE='itsuki-gentoo.png'; CONFIG_SOURCE="$ROOT/configs/gentoo" ;;
  neutral) DISTRO_ICON=''; DISTRO_LABEL='Itsuki Niri Rice'; WALLPAPER_FILE='itsuki-neutral.png'; CONFIG_SOURCE="$ROOT/configs" ;;
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

BACKUP="$HOME/.config/itsuki-niri-backup/$DISTRO/$STAMP"
mkdir -p "$BACKUP" "$HOME/.local/bin" "$HOME/Pictures/Wallpapers" "$CONFIG_HOME/waybar" "$CONFIG_HOME/kitty" "$CONFIG_HOME/fuzzel" "$CONFIG_HOME/dunst" "$CONFIG_HOME/fetch" "$CONFIG_HOME/xdg-desktop-portal" "$CONFIG_HOME/niri"
backup() { local path="$1" rel="$2"; if [[ -f "$path" ]]; then mkdir -p "$BACKUP/$(dirname "$rel")"; cp -a "$path" "$BACKUP/$rel"; fi; }
for rel in niri/config.kdl waybar/config waybar/style.css kitty/kitty.conf fuzzel/fuzzel.ini dunst/dunstrc fetch/config xdg-desktop-portal/niri-portals.conf; do backup "$CONFIG_HOME/$rel" "$rel"; done
for current_wallpaper in "$HOME/Pictures/Wallpapers/itsuki.png" "$HOME/Pictures/Wallpapers/itsuki.jpg"; do
  if [[ -f "$current_wallpaper" ]]; then
    backup "$current_wallpaper" "wallpaper/$(basename "$current_wallpaper")"
  fi
done
install -m 0644 "$WALLPAPER_SOURCE" "$HOME/Pictures/Wallpapers/itsuki.png"
for rel in waybar/config waybar/style.css kitty/kitty.conf fuzzel/fuzzel.ini dunst/dunstrc fetch/config xdg-desktop-portal/niri-portals.conf; do cp "$CONFIG_SOURCE/$rel" "$CONFIG_HOME/$rel"; done
install -m 755 "$ROOT/scripts/niri-power-menu" "$HOME/.local/bin/niri-power-menu"
SLIDER_SOURCE="$ROOT/scripts/itsuki-slider.py"
if [[ -f "$CONFIG_SOURCE/scripts/itsuki-slider.py" ]]; then SLIDER_SOURCE="$CONFIG_SOURCE/scripts/itsuki-slider.py"; fi
install -m 755 "$SLIDER_SOURCE" "$HOME/.local/bin/itsuki-slider.py"
install -m 755 "$ROOT/scripts/itsuki-wifi-menu.py" "$HOME/.local/bin/itsuki-wifi-menu.py"
SHELL_NAME="$(basename "${SHELL:-bash}")"
case "$SHELL_NAME" in bash) SHELL_RC="$HOME/.bashrc" ;; zsh) SHELL_RC="$HOME/.zshrc" ;; *) SHELL_RC="" ;; esac
if [[ -n "$SHELL_RC" ]] && ! grep -q 'ITSUKI_FETCH_AUTOSTART' "$SHELL_RC" 2>/dev/null; then
  cat >> "$SHELL_RC" <<'FETCHRC'
# ITSUKI_FETCH_AUTOSTART: show animated system info in interactive terminals.
if [[ $- == *i* ]] && command -v fetch >/dev/null 2>&1; then
    fetch
fi
FETCHRC
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
if any(backlight.iterdir()):
    if 'backlight' not in right: right.insert(0,'backlight')
    cfg['backlight']={'format':' {percent}%','tooltip':True,'on-click':f'python3 {bin / "itsuki-slider.py"} brightness','on-scroll-up':'brightnessctl -c backlight set +5%','on-scroll-down':'brightnessctl -c backlight set 5%-'}
network=cfg.setdefault('network',{}); network.update({'format-wifi':' {signalStrength}%','format-ethernet':' LAN','format-disconnected':' offline','on-click':f'python3 {bin / "itsuki-wifi-menu.py"}'})
sound=cfg.setdefault('pulseaudio',{}); sound.update({'format':' {volume}%','format-muted':' muted','on-click':f'python3 {bin / "itsuki-slider.py"} volume','on-click-right':'wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle','scroll-step':5})
tray=cfg.setdefault('tray',{}); tray.update({'icon-size':18,'spacing':8,'show-passive-items':True,'tooltip':True})
p.write_text(json.dumps(cfg,indent=2,ensure_ascii=False)+'\n')
PYWAYBAR

if [[ ! -f "$CONFIG_HOME/niri/config.kdl" ]]; then echo "Niri config not found: $CONFIG_HOME/niri/config.kdl; stopping before modifying Niri." >&2; exit 1; fi
cp "$CONFIG_HOME/niri/config.kdl" "$BACKUP/niri-config.pre-patch.kdl"
python3 - "$CONFIG_HOME/niri/config.kdl" "$HOME" <<'PYNIRI'
from pathlib import Path
import re,sys
p=Path(sys.argv[1]); home=sys.argv[2]; text=p.read_text()
text=re.sub(r'(?m)^\s*spawn-at-startup\s+"waybar"[^\n]*(?:\n|$)','',text)
text=re.sub(r'(?m)^\s*spawn-at-startup\s+"dunst"\s*(?:\n|$)','',text)
text=re.sub(r'(?m)^\s*spawn-at-startup\s+"swaybg"[^\n]*\n?','',text)
startup='\n'.join(['spawn-at-startup "dunst"','spawn-at-startup "waybar"',f'spawn-at-startup "swaybg" "-i" "{home}/Pictures/Wallpapers/itsuki.png" "-m" "fill"'])+'\n'
m=re.search(r'(?m)^binds\s*\{',text)
if m: text=text[:m.start()]+startup+'\n'+text[m.start():]
else: text=startup+'\n'+text
lines=text.splitlines(); out=[]
for line in lines:
    s=line.strip()
    if re.match(r'^(?:Mod|Super)\+D\b',s) or re.match(r'^Mod\+Return\b',s) or re.match(r'^Super\+E\b',s): continue
    out.append(line)
text='\n'.join(out)+'\n'
m=re.search(r'(?m)^binds\s*\{',text)
if not m: raise SystemExit('No binds block found; your backup is safe, but Niri shortcuts were not added.')
ins=('    Mod+D hotkey-overlay-title="Application Launcher: Fuzzel" { spawn "fuzzel"; }\n'
     '    Mod+Return hotkey-overlay-title="Terminal: Kitty" { spawn "kitty"; }\n'
     f'    Super+E hotkey-overlay-title="Itsuki Power Menu" {{ spawn "{home}/.local/bin/niri-power-menu"; }}\n')
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
echo "Installed Itsuki Niri Rice ($DISTRO_LABEL variant). Backups: $BACKUP"
echo "Wallpaper installed to $HOME/Pictures/Wallpapers/itsuki.png if present in the package."
echo "No system display-manager or LightDM settings were changed."
