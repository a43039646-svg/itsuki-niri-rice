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
| Neutral | No distro icon |

The variants use separate app-config copies for their visual theme: Debian and Neutral keep the red/rose base theme, Arch uses blue accents, and Gentoo uses violet accents. Each installer selects its matching wallpaper. Arch and Gentoo config copies live under `configs/arch/` and `configs/gentoo/`.

Install a variant with one of these commands from the repository root:

```bash
bash variants/debian/install.sh
bash variants/arch/install.sh
bash variants/gentoo/install.sh
bash variants/neutral/install.sh
```

The distro logos use Nerd-Font/Unicode glyphs. If a logo is missing in your font, install a Nerd Font; the rest of the rice is unaffected.

## Features
- Niri integration that preserves most existing settings, starts Waybar once from Niri, and creates a dated backup.
- Waybar with Niri workspaces, clock, network, volume, battery, tray and brightness where supported.
- Variant-specific Debian, Arch and Gentoo branding plus matching wallpapers; Neutral has no distro icon and uses its own logo-free wallpaper.
- Separate Fuzzel, Dunst, Kitty, Waybar, Fetch and slider configs for Arch (blue) and Gentoo (violet); Debian and Neutral retain the red/rose theme.
- Click brightness/volume for a themed slider; right-click volume toggles mute. Click Wi-Fi to list NetworkManager networks.
- `Super+E` opens a Fuzzel power menu (lock, log out, suspend, reboot, power off); `Super+D` launches apps; `Super+Return` opens Kitty.
- Fetch config without forced recoloring of distro logo.
- GTK portal preference included for systems where GNOME portal fails under Niri.
- Optional LightDM GTK Greeter theme using the original dark Debian-logo wallpaper, separate from the Itsuki desktop wallpaper.

## Install
1. Extract the ZIP or clone the repository.
2. Choose one variant from `variants/`.
3. The repository includes separate Debian, Arch, Gentoo and Neutral desktop wallpapers in `wallpaper/`; the selected installer chooses the matching image automatically.
4. Review the printed backup path, then log out and select Niri if needed.
5. LightDM theming is optional and separate; run `bash install-lightdm.sh` only if you want the Debian-logo login background.

The main installer backs up existing configs and wallpaper files, selects the matching config set for the chosen variant, and copies its wallpaper to `~/Pictures/Wallpapers/itsuki.png` for Niri. The optional LightDM greeter config remains a separate Debian-themed component. The optional LightDM script installs the separate dark Debian-logo background at `/usr/share/backgrounds/debian-rice.jpg`. It backs up the current greeter config and target wallpaper, does not switch display managers, and does not restart LightDM while a session is running.

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
- Waybar is launched with one `spawn-at-startup "waybar"` entry in Niri; the installer removes duplicate entries and cleans up the older systemd startup method. Log out and back in after installing to apply the startup change.
- The system tray shows only apps that publish compatible tray icons.
- Brightness control appears only if `/sys/class/backlight` has a device.
- Wi-Fi menu requires NetworkManager (`nmcli`).
- Kitty background opacity depends on compositor support.
- Install `areofyl/fetch` separately; copy `configs/fetch/config` to `~/.config/fetch/config`.
- LightDM theming is optional and separate from the main user rice installer. The GitHub repository includes the four desktop wallpaper variants. The separate dark Debian-logo LightDM wallpaper (`wallpaper/debian-rice.jpg`) is not included in the source tree; provide it yourself only if you use the optional LightDM installer.

## Backups
User config backups are stored under `~/.config/itsuki-niri-backup/<variant>/<timestamp>/`. LightDM backups are stored under `/etc/lightdm/itsuki-backup-<timestamp>/`.

## License
Configuration and scripts in this repository are offered under GNU. 
