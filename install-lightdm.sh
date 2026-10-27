#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
LIGHTDM_DIR="/etc/lightdm"
CONFIG_DEST="$LIGHTDM_DIR/lightdm-gtk-greeter.conf"

if [[ ! -d "$LIGHTDM_DIR" ]]; then
  echo "LightDM configuration directory $LIGHTDM_DIR does not exist. Is LightDM installed?" >&2
  exit 1
fi

if [[ ! -r /dev/tty || ! -w /dev/tty ]]; then
  if [[ -z "${ITSUKI_LIGHTDM_PROFILE:-}" || -z "${ITSUKI_LIGHTDM_WALLPAPER:-}" ]]; then
    echo "An interactive terminal is required, or set ITSUKI_LIGHTDM_PROFILE and ITSUKI_LIGHTDM_WALLPAPER." >&2
    exit 2
  fi
fi

if [[ -n "${ITSUKI_LIGHTDM_PROFILE:-}" ]]; then
  PROFILE="$ITSUKI_LIGHTDM_PROFILE"
else
  printf '\nItsuki LightDM greeter — choose a profile\n'
  printf '  1) Debian\n'
  printf '  2) Arch Linux\n'
  printf '  3) Gentoo\n'
  printf '  4) Neutral (no distro logo)\n\n'
  while true; do
    if ! IFS= read -r -p "Choose profile [1-4]: " choice </dev/tty; then
      echo "No profile selected; cancelled." >&2
      exit 2
    fi
    case "$choice" in
      1) PROFILE="debian"; break ;;
      2) PROFILE="arch"; break ;;
      3) PROFILE="gentoo"; break ;;
      4) PROFILE="neutral"; break ;;
      *) echo "Invalid choice. Enter 1, 2, 3, or 4." >&2 ;;
    esac
  done
fi

if [[ -n "${ITSUKI_LIGHTDM_WALLPAPER:-}" ]]; then
  WALLPAPER_STYLE="$ITSUKI_LIGHTDM_WALLPAPER"
else
  printf '\nChoose the greeter background\n'
  printf '  1) With Itsuki\n'
  printf '  2) Without Itsuki\n\n'
  while true; do
    if ! IFS= read -r -p "Choose background [1-2]: " choice </dev/tty; then
      echo "No background selected; cancelled." >&2
      exit 2
    fi
    case "$choice" in
      1) WALLPAPER_STYLE="character"; break ;;
      2) WALLPAPER_STYLE="clean"; break ;;
      *) echo "Invalid choice. Enter 1 or 2." >&2 ;;
    esac
  done
fi

case "$PROFILE" in
  debian)
    PROFILE_LABEL="Debian"
    CONFIG_SRC="$ROOT/configs/lightdm/lightdm-gtk-greeter.conf"
    if [[ "$WALLPAPER_STYLE" == "character" ]]; then
      WALLPAPER_SRC="$ROOT/wallpaper/itsuki_debian_wallpaper_v2_1600x900.png"
      WALLPAPER_DEST="/usr/share/backgrounds/itsuki-lightdm-debian-character.png"
    elif [[ "$WALLPAPER_STYLE" == "clean" ]]; then
      WALLPAPER_SRC="$ROOT/wallpaper/debian-rice.jpg"
      WALLPAPER_DEST="/usr/share/backgrounds/itsuki-lightdm-debian.jpg"
    else
      echo "Unknown wallpaper style '$WALLPAPER_STYLE' (use character or clean)." >&2
      exit 2
    fi
    ;;
  arch)
    PROFILE_LABEL="Arch Linux"
    CONFIG_SRC="$ROOT/configs/lightdm/lightdm-gtk-greeter-arch.conf"
    if [[ "$WALLPAPER_STYLE" == "character" ]]; then
      WALLPAPER_SRC="$ROOT/wallpaper/itsuki-arch2.png"
      WALLPAPER_DEST="/usr/share/backgrounds/itsuki-lightdm-arch-character.png"
    elif [[ "$WALLPAPER_STYLE" == "clean" ]]; then
      WALLPAPER_SRC="$ROOT/wallpaper/itsuki-arch.png"
      WALLPAPER_DEST="/usr/share/backgrounds/itsuki-lightdm-arch.png"
    else
      echo "Unknown wallpaper style '$WALLPAPER_STYLE' (use character or clean)." >&2
      exit 2
    fi
    ;;
  gentoo)
    PROFILE_LABEL="Gentoo"
    CONFIG_SRC="$ROOT/configs/lightdm/lightdm-gtk-greeter-gentoo.conf"
    if [[ "$WALLPAPER_STYLE" == "character" ]]; then
      WALLPAPER_SRC="$ROOT/wallpaper/itsuki-gentoo2.png"
      WALLPAPER_DEST="/usr/share/backgrounds/itsuki-lightdm-gentoo-character.png"
    elif [[ "$WALLPAPER_STYLE" == "clean" ]]; then
      WALLPAPER_SRC="$ROOT/wallpaper/itsuki-gentoo.png"
      WALLPAPER_DEST="/usr/share/backgrounds/itsuki-lightdm-gentoo.png"
    else
      echo "Unknown wallpaper style '$WALLPAPER_STYLE' (use character or clean)." >&2
      exit 2
    fi
    ;;
  neutral)
    PROFILE_LABEL="Neutral"
    CONFIG_SRC="$ROOT/configs/lightdm/lightdm-gtk-greeter-neutral.conf"
    if [[ "$WALLPAPER_STYLE" == "character" ]]; then
      WALLPAPER_SRC="$ROOT/wallpaper/itsuki-neutral2.png"
      WALLPAPER_DEST="/usr/share/backgrounds/itsuki-lightdm-neutral-character.png"
    elif [[ "$WALLPAPER_STYLE" == "clean" ]]; then
      WALLPAPER_SRC="$ROOT/wallpaper/itsuki-neutral.png"
      WALLPAPER_DEST="/usr/share/backgrounds/itsuki-lightdm-neutral.png"
    else
      echo "Unknown wallpaper style '$WALLPAPER_STYLE' (use character or clean)." >&2
      exit 2
    fi
    ;;
  *)
    echo "Unknown profile '$PROFILE'. Use debian, arch, gentoo, or neutral." >&2
    exit 2
    ;;
esac

if [[ ! -f "$CONFIG_SRC" ]]; then
  echo "Missing LightDM greeter profile: $CONFIG_SRC" >&2
  exit 1
fi
if [[ ! -f "$WALLPAPER_SRC" ]]; then
  echo "Wallpaper not found: $WALLPAPER_SRC" >&2
  echo "No LightDM settings have been changed." >&2
  exit 1
fi
if ! grep -q '^background=' "$CONFIG_SRC"; then
  echo "The greeter profile has no background= setting: $CONFIG_SRC" >&2
  exit 1
fi
if [[ "$EUID" -ne 0 ]] && ! command -v sudo >/dev/null 2>&1; then
  echo "sudo is required to install LightDM settings (or run this script as root)." >&2
  exit 1
fi

TEMP_CONFIG="$(mktemp)"
cleanup() {
  rm -f -- "$TEMP_CONFIG"
}
trap cleanup EXIT

# The profile supplies the common GTK greeter styling. The chosen image path
# is substituted so character/clean selections never point at the wrong file.
sed "s|^background=.*|background=$WALLPAPER_DEST|" "$CONFIG_SRC" > "$TEMP_CONFIG"
if ! grep -Fxq "background=$WALLPAPER_DEST" "$TEMP_CONFIG"; then
  echo "Failed to prepare the selected LightDM greeter config." >&2
  exit 1
fi

STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$LIGHTDM_DIR/itsuki-backup-$STAMP"

printf '\nSelected LightDM profile: %s\n' "$PROFILE_LABEL"
printf 'Wallpaper style: %s\n' "$([[ "$WALLPAPER_STYLE" == "character" ]] && echo "with Itsuki" || echo "without Itsuki")"
printf 'Background image: %s\n' "$WALLPAPER_SRC"
printf '\nThis will update %s and install the selected background.\n' "$CONFIG_DEST"
printf 'It will not switch display managers or restart LightDM.\n'

read -r -p "Continue? [y/N] " answer </dev/tty
case "$answer" in
  y|Y|yes|YES) ;;
  *) echo "Cancelled."; exit 0 ;;
esac

as_root() {
  if [[ "$EUID" -eq 0 ]]; then
    "$@"
  else
    sudo "$@"
  fi
}

as_root install -d -m 0700 "$BACKUP_DIR"
if [[ -e "$CONFIG_DEST" || -L "$CONFIG_DEST" ]]; then
  as_root cp -a "$CONFIG_DEST" "$BACKUP_DIR/lightdm-gtk-greeter.conf"
fi
if [[ -e "$WALLPAPER_DEST" || -L "$WALLPAPER_DEST" ]]; then
  as_root cp -a "$WALLPAPER_DEST" "$BACKUP_DIR/$(basename "$WALLPAPER_DEST")"
fi

as_root install -D -m 0644 "$TEMP_CONFIG" "$CONFIG_DEST"
as_root install -D -m 0644 "$WALLPAPER_SRC" "$WALLPAPER_DEST"

echo "LightDM greeter profile installed: $PROFILE_LABEL."
echo "Config: $CONFIG_DEST"
echo "Background: $WALLPAPER_DEST"
echo "Backup: $BACKUP_DIR"
echo "The greeter will use these settings at the next login screen. LightDM was not restarted."
