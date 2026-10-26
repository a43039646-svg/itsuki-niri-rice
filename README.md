# Itsuki Debian Niri Rice

An Itsuki-inspired dark navy / rose-pink desktop rice for Debian 13 using Niri, Waybar, Fuzzel, Kitty, Dunst and the `areofyl/fetch` terminal animation. Includes themed quick controls for brightness, audio and Wi-Fi.

This is a configuration pack, not a Debian distribution.

## Features
- Niri integration that preserves most existing settings and creates a dated backup.
- Waybar with Niri workspaces, clock, network, volume, battery, tray and brightness where supported.
- Pink Debian launcher, Fuzzel, Dunst and Kitty theme.
- Click brightness/volume for a themed slider; right-click volume toggles mute. Click Wi-Fi to list NetworkManager networks.
- `Super+E` opens a Fuzzel power menu; `Super+D` launches apps; `Super+Return` opens Kitty.
- Fetch config without forced recoloring of distro logo.
- GTK portal preference included for systems where GNOME portal fails under Niri.

## Install on Debian 13
1. Download the ZIP or clone this repository.
2. Put your own wallpaper at `~/Pictures/Wallpapers/itsuki.png`. The wallpaper is intentionally not bundled.
3. Review `install.sh`, then run `bash install.sh`.
4. Check the printed backup path. Log out and select Niri if needed.

The installer backs up user configs before changes and does not alter the system display manager or `/etc/lightdm`.

## Dependencies
Typical Debian packages: `waybar fuzzel kitty dunst swaybg swaylock python3 python3-tk brightnessctl network-manager-gnome fonts-font-awesome fonts-fork-awesome fonts-jetbrains-mono`. Niri and `fetch` are installed separately.

## Shortcuts
| Shortcut | Action |
|---|---|
| `Super+D` | Fuzzel application launcher |
| `Super+Return` | Kitty terminal |
| `Super+E` | Fuzzel power menu |

## Notes
- The system tray only shows apps that publish compatible tray icons.
- Brightness control appears only if `/sys/class/backlight` has a device.
- Wi-Fi menu requires NetworkManager (`nmcli`).
- Kitty background opacity depends on compositor support.
- Install `areofyl/fetch` separately; copy `configs/fetch/config` to `~/.config/fetch/config`.
- LightDM is optional and deliberately not modified by the installer.

## Backups
User config backups are stored under `~/.config/itsuki-debian-niri-backup/<timestamp>/`.

## License
Configuration and scripts are offered under MIT. Third-party apps, fonts and wallpapers retain their own licenses.
