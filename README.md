# Itsuki Niri Rice

An Itsuki-inspired dark navy / rose-pink desktop rice for Niri using Waybar, Fuzzel, Kitty, Dunst and the `areofyl/fetch` terminal animation. Includes themed quick controls for brightness, audio and Wi-Fi.

> This is a configuration pack, not a Linux distribution.

## Variants
The repository contains four branding variants without needing separate repositories:

| Variant | Waybar left icon |
|---|---|
| Debian | Debian logo |
| Arch Linux | Arch logo |
| Gentoo | Gentoo logo |
| Neutral | ★ Itsuki star |

The variants share the same rice. Only the left-side branding and backup namespace change.

Install a variant with one of these commands from the repository root:

```bash
bash variants/debian/install.sh
bash variants/arch/install.sh
bash variants/gentoo/install.sh
bash variants/neutral/install.sh
```

The distro logos use Nerd-Font/Unicode glyphs. If a logo is missing in your font, install a Nerd Font; the rest of the rice is unaffected.

## Features
- Niri integration that preserves most existing settings and creates a dated backup.
- Waybar with Niri workspaces, clock, network, volume, battery, tray and brightness where supported.
- Variant-specific Debian, Arch, Gentoo or neutral-star launcher branding.
- Fuzzel, Dunst and Kitty theme.
- Click brightness/volume for a themed slider; right-click volume toggles mute. Click Wi-Fi to list NetworkManager networks.
- `Super+E` opens a Fuzzel power menu (lock, log out, suspend, reboot, power off); `Super+D` launches apps; `Super+Return` opens Kitty.
- Fetch config without forced recoloring of distro logo.
- GTK portal preference included for systems where GNOME portal fails under Niri.
- Optional LightDM GTK Greeter theme using the original dark Debian-logo wallpaper, separate from the Itsuki desktop wallpaper.

## Install
1. Extract the ZIP or clone the repository.
2. Choose one variant from `variants/`.
3. If using the full ZIP, the wallpaper is included. If cloning the GitHub source directly, put your image at `wallpaper/itsuki-niri-rice.jpg` before running the selected installer.
4. Review the printed backup path, then log out and select Niri if needed.
5. LightDM theming is optional and separate; run `bash install-lightdm.sh` only if you want the Debian-logo login background.

The main installer backs up user configs and copies the Itsuki wallpaper to `~/Pictures/Wallpapers/itsuki.jpg` for Niri. The optional LightDM script installs the separate dark Debian-logo background at `/usr/share/backgrounds/debian-rice.jpg`. It backs up the current greeter config and target wallpaper, does not switch display managers, and does not restart LightDM while a session is running.

## Dependencies
Typical Debian packages: `waybar fuzzel kitty dunst swaybg swaylock python3 python3-tk brightnessctl network-manager-gnome fonts-font-awesome fonts-fork-awesome fonts-jetbrains-mono`. Niri and `fetch` are installed separately. Other distributions may use different package names.

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
- LightDM theming is optional and separate from the main user rice installer. The full downloadable ZIP should contain both images: the Itsuki desktop wallpaper and the original dark Debian-logo LightDM wallpaper. The GitHub source tree omits binary artwork; provide `wallpaper/debian-rice.jpg` yourself when installing from a Git clone.

## Backups
User config backups are stored under `~/.config/itsuki-niri-backup/<variant>/<timestamp>/`. LightDM backups are stored under `/etc/lightdm/itsuki-backup-<timestamp>/`.

## License
Configuration and scripts in this repository are offered under MIT. Third-party applications, fonts, and artwork keep their own licenses.
