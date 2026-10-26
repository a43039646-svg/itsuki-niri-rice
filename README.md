# Itsuki Debian Niri Rice

An Itsuki-inspired dark navy / rose-pink desktop rice for Debian 13 using Niri, Waybar, Fuzzel, Kitty, Dunst and the `areofyl/fetch` terminal animation. Includes themed quick controls for brightness, audio and Wi-Fi.

> This is a configuration pack, not a Debian distribution.

## Features
- Niri integration that preserves most existing settings and creates a dated backup.
- Waybar with Niri workspaces, clock, network, volume, battery, tray and brightness where supported.
- Pink Debian launcher, Fuzzel, Dunst and Kitty theme.
- Click brightness/volume for a themed slider; right-click volume toggles mute. Click Wi-Fi to list NetworkManager networks.
- `Super+E` opens a Fuzzel power menu (lock, log out, suspend, reboot, power off); `Super+D` launches apps; `Super+Return` opens Kitty.
- Fetch config without forced recoloring of distro logo.
- GTK portal preference included for systems where GNOME portal fails under Niri.
- Optional LightDM GTK Greeter background matching the Itsuki desktop wallpaper.

## Install on Debian 13
1. Extract the ZIP or clone the repository.
2. Run `bash install.sh` to install user configuration and the included wallpaper.
3. Review the printed backup path, then log out and select Niri if needed.
4. To theme the LightDM GTK greeter too, run `bash install-lightdm.sh` separately and confirm when prompted.

The main installer backs up user configs, installs the bundled wallpaper to `~/Pictures/Wallpapers/itsuki.jpg`, validates Niri after modifying it, and avoids changing system display-manager settings. The separate LightDM script backs up `/etc/lightdm/lightdm-gtk-greeter.conf` and any existing target wallpaper before installing the greeter theme. It does not switch display managers or restart LightDM while a session is running.

## Dependencies
Typical Debian packages: `waybar fuzzel kitty dunst swaybg swaylock python3 python3-tk brightnessctl network-manager-gnome fonts-font-awesome fonts-fork-awesome fonts-jetbrains-mono`. Niri and `fetch` are installed separately.

## Shortcuts
| Shortcut | Action |
|---|---|
| `Super+D` | Fuzzel application launcher |
| `Super+Return` | Kitty terminal |
| `Super+E` | Fuzzel power menu |
| `Super+Q` | Close focused window if present in existing Niri config |

## Notes
- The system tray shows only apps that publish compatible tray icons.
- Brightness control appears only if `/sys/class/backlight` has a device.
- Wi-Fi menu requires NetworkManager (`nmcli`).
- Kitty background opacity depends on compositor support.
- Install `areofyl/fetch` separately; copy `configs/fetch/config` to `~/.config/fetch/config`.
- LightDM theming is optional and separate from the main user rice installer. The bundled JPEG wallpaper is included in this repository.

## Backups
User config backups are stored under `~/.config/itsuki-debian-niri-backup/<timestamp>/`. LightDM backups are stored under `/etc/lightdm/itsuki-backup-<timestamp>/`.

## License
Configuration and scripts in this repository are offered under MIT. Third-party applications, fonts, and artwork keep their own licenses.
