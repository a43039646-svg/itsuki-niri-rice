#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SRC="$ROOT/configs/lightdm/lightdm-gtk-greeter.conf"
WALLPAPER_SRC="$ROOT/wallpaper/debian-rice.jpg"
CONFIG_DEST="/etc/lightdm/lightdm-gtk-greeter.conf"
WALLPAPER_DEST="/usr/share/backgrounds/debian-rice.jpg"

if [[ ! -f "$CONFIG_SRC" ]]; then echo "Missing $CONFIG_SRC" >&2; exit 1; fi
if [[ ! -f "$WALLPAPER_SRC" ]]; then
    echo "Wallpaper not found in this package: $WALLPAPER_SRC" >&2
    echo "Use the full Itsuki Debian Niri Rice ZIP or copy your own wallpaper there." >&2
    exit 1
fi
if [[ ! -e /etc/lightdm ]]; then
    echo "LightDM configuration directory /etc/lightdm does not exist. Is LightDM installed?" >&2
    exit 1
fi
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="/etc/lightdm/itsuki-backup-$STAMP"
echo "This will update the LightDM GTK greeter background and greeter settings."
echo "It will not switch display managers or restart LightDM right now."
read -r -p "Continue? [y/N] " answer
case "$answer" in y|Y|yes|YES) ;; *) echo "Cancelled."; exit 0 ;; esac
sudo install -d -m 0700 "$BACKUP_DIR"
if [[ -f "$CONFIG_DEST" ]]; then sudo cp -a "$CONFIG_DEST" "$BACKUP_DIR/lightdm-gtk-greeter.conf"; fi
if [[ -f "$WALLPAPER_DEST" ]]; then sudo cp -a "$WALLPAPER_DEST" "$BACKUP_DIR/debian-rice.jpg"; fi
sudo install -D -m 0644 "$CONFIG_SRC" "$CONFIG_DEST"
sudo install -D -m 0644 "$WALLPAPER_SRC" "$WALLPAPER_DEST"
echo "LightDM greeter theme installed. Backup: $BACKUP_DIR"
echo "It takes effect on the next login screen; no display-manager restart was performed."
