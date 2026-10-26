#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
STAMP="$(date +%Y%m%d-%H%M%S)"
DISTRO="${ITSUKI_DISTRO:-debian}"
case "$DISTRO" in
  debian) DISTRO_ICON=''; DISTRO_LABEL='Debian' ;;
  arch) DISTRO_ICON=''; DISTRO_LABEL='Arch Linux' ;;
  gentoo) DISTRO_ICON=''; DISTRO_LABEL='Gentoo' ;;
  neutral) DISTRO_ICON='★'; DISTRO_LABEL='Itsuki Niri Rice' ;;
  *) echo "Unknown ITSUKI_DISTRO: $DISTRO (use debian, arch, gentoo or neutral)." >&2; exit 2 ;;
esac
BACKUP="$HOME/.config/itsuki-niri-backup/$DISTRO/$STAMP"
mkdir -p "$BACKUP" "$HOME/.local/bin" "$HOME/Pictures/Wallpapers" "$CONFIG_HOME/waybar" "$CONFIG_HOME/kitty" "$CONFIG_HOME/fuzzel" "$CONFIG_HOME/dunst" "$CONFIG_HOME/fetch" "$CONFIG_HOME/xdg-desktop-portal" "$CONFIG_HOME/niri"
backup() { local path="$1" rel="$2"; if [[ -f "$path" ]]; then mkdir -p "$BACKUP/$(dirname "$rel")"; cp -a "$path" "$BACKUP/$rel"; fi; }
for rel in niri/config.kdl waybar/config waybar/style.css kitty/kitty.conf fuzzel/fuzzel.ini dunst/dunstrc fetch/config xdg-desktop-portal/niri-portals.conf; do backup "$CONFIG_HOME/$rel" "$rel"; done
if [[ -f "$ROOT/wallpaper/itsuki-niri-rice.jpg" ]]; then
  if [[ -f "$HOME/Pictures/Wallpapers/itsuki.jpg" ]]; then
    mkdir -p "$BACKUP/wallpaper"
    cp -a "$HOME/Pictures/Wallpapers/itsuki.jpg" "$BACKUP/wallpaper/itsuki.jpg"
  fi
  install -m 0644 "$ROOT/wallpaper/itsuki-niri-rice.jpg" "$HOME/Pictures/Wallpapers/itsuki.jpg"
elif [[ -f "$ROOT/wallpaper/itsuki-debian-niri-rice.jpg" ]]; then
  install -m 0644 "$ROOT/wallpaper/itsuki-debian-niri-rice.jpg" "$HOME/Pictures/Wallpapers/itsuki.jpg"
fi
for rel in waybar/config waybar/style.css kitty/kitty.conf fuzzel/fuzzel.ini dunst/dunstrc fetch/config xdg-desktop-portal/niri-portals.conf; do cp "$ROOT/configs/$rel" "$CONFIG_HOME/$rel"; done
install -m 755 "$ROOT/scripts/niri-power-menu" "$HOME/.local/bin/niri-power-menu"
install -m 755 "$ROOT/scripts/itsuki-slider.py" "$HOME/.local/bin/itsuki-slider.py"
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
left.insert(0,'custom/distro')
cfg['custom/distro']={'format':icon,'tooltip':label,'on-click':'fuzzel'}
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
cat >> "$CONFIG_HOME/waybar/style.css" <<'CSSITSUKI'

/* Itsuki Niri Rice controls */
#custom-distro { font-family: "JetBrains Mono", "Symbols Nerd Font", sans-serif; font-size: 19px; color: #ff477f; padding: 0 12px; margin: 5px 3px 5px 8px; background: rgba(255,71,127,.13); border: 1px solid rgba(255,71,127,.32); border-radius: 9px; }
#backlight, #network, #pulseaudio { padding: 0 10px; margin: 5px 3px; background: rgba(17,19,34,.88); border: 1px solid rgba(255,71,127,.22); border-radius: 9px; }
#backlight { color: #ff9abb; } #network { color: #d7b8ff; } #network.disconnected { color: #ff477f; }
#pulseaudio { color: #f4b5cd; } #pulseaudio.muted { color: #9b91a7; }
#tray { padding: 0 8px; margin: 5px 8px 5px 3px; background: rgba(17,19,34,.88); border: 1px solid rgba(255,71,127,.32); border-radius: 9px; }
#tray > .passive { opacity: .72; } #tray > .needs-attention { background: rgba(255,71,127,.20); border-radius: 6px; }
CSSITSUKI
if [[ ! -f "$CONFIG_HOME/niri/config.kdl" ]]; then echo "Niri config not found: $CONFIG_HOME/niri/config.kdl; stopping before modifying Niri." >&2; exit 1; fi
cp "$CONFIG_HOME/niri/config.kdl" "$BACKUP/niri-config.pre-patch.kdl"
python3 - "$CONFIG_HOME/niri/config.kdl" "$HOME" <<'PYNIRI'
from pathlib import Path
import re,sys
p=Path(sys.argv[1]); home=sys.argv[2]; text=p.read_text()
text=re.sub(r'(?m)^\s*spawn-at-startup\s+"waybar"[^\n]*(?:\n|$)','',text)
text=re.sub(r'(?m)^\s*spawn-at-startup\s+"dunst"\s*(?:\n|$)','',text)
text=re.sub(r'(?m)^\s*spawn-at-startup\s+"swaybg"[^\n]*\n?','',text)
startup='\n'.join(['spawn-at-startup "dunst"','spawn-at-startup "waybar"',f'spawn-at-startup "swaybg" "-i" "{home}/Pictures/Wallpapers/itsuki.jpg" "-m" "fill"'])+'\n'
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
echo "Wallpaper installed to $HOME/Pictures/Wallpapers/itsuki.jpg if present in the package."
echo "No system display-manager or LightDM settings were changed."
