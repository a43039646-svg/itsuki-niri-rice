# Itsuki Niri Rice

A themed desktop configuration pack for **Niri on Wayland**, inspired by Itsuki. It includes Waybar, Fuzzel, Kitty, Dunst, Fetch settings, quick controls for brightness/audio/Wi-Fi, and matching wallpapers.

> This is a configuration pack, not a Linux distribution. It does not install Niri or system packages for you.

## Themes

| Variant | Colors | Waybar mark | Wallpaper | Config source |
|---|---|---|---|---|
| Debian | Red / rose | Debian | [View wallpaper](wallpaper/itsuki_debian_wallpaper_v2_1600x900.png) | `configs/` |
| Arch Linux | Navy / blue | Arch | [View wallpaper](wallpaper/itsuki-arch.png) | `configs/arch/` |
| Gentoo | Dark plum / violet | Gentoo | [View wallpaper](wallpaper/itsuki-gentoo.png) | `configs/gentoo/` |
| Neutral | Red / rose | No distro mark | [View wallpaper](wallpaper/itsuki-neutral.png) | `configs/` |

Arch and Gentoo have their own themed copies of Waybar, Fuzzel, Kitty, Dunst, Fetch, the XDG desktop-portal preference, and the brightness/audio slider. Each of Arch, Gentoo, and Neutral has two wallpaper files: the filename with a trailing `2` includes Itsuki; the filename without `2` is the clean version.

## Installation

**Requirements:** a working Niri session and an existing `~/.config/niri/config.kdl`. Install the dependencies for your distribution before running the installer; package names vary.

Clone or download the repository, open a terminal in the repository directory, and run the main installer:

```bash
bash install.sh
```

The installer asks you to choose a theme:

1. **Itsuki only** — neutral theme with no distro logo.
2. **Itsuki + Arch Linux** — blue profile and Arch wallpaper.
3. **Itsuki + Debian** — red/rose profile and Debian wallpaper.
4. **Itsuki + Gentoo** — violet profile and Gentoo wallpaper.

Enter `1`, `2`, `3`, or `4` to select the profile, then choose a wallpaper style: **with Itsuki** (filename includes `2`) or **without Itsuki** (filename does not include `2`). The installer validates the selected files, backs up existing configs, and applies the matching wallpaper and profile. For direct installation without the profile menu, the individual scripts in `variants/` remain available; they use the Itsuki wallpaper by default. For scripted use, set `ITSUKI_DISTRO=arch|debian|gentoo|neutral` and optionally `ITSUKI_WALLPAPER_STYLE=character|clean`.

The installer:
- Creates a dated backup under `~/.config/itsuki-niri-backup/<variant>/<timestamp>/`.
- Copies the selected color profile into `~/.config/`.
- Installs the matching wallpaper as `~/Pictures/Wallpapers/itsuki.png`.
- Adds the rice's Niri startup entries and shortcuts while preserving the rest of the existing Niri config as much as possible.
- Installs the shared power-menu, optional Wi-Fi-menu, and slider scripts under `~/.local/bin/`. The Wi-Fi helper is not bound to the Waybar network indicator by default, so it does not duplicate an existing network-manager UI.
- Adds or updates a managed Fetch autostart block in interactive Bash/Zsh shells, running `fetch --box --shading-mode sextants` when the `fetch` command is installed. Existing shell startup files are backed up before the managed block is changed.

After installation, log out and log back into Niri so the startup changes and wallpaper take effect. Review the backup path printed by the installer if you need to restore a previous config.

### Validate the repository

Before applying an updated rice, run the read-only profile and syntax checks from the repository root:

```bash
bash scripts/validate-profiles.sh
```

The script checks the Neutral, Debian, Arch, and Gentoo configuration files, Waybar JSON/module lists, Kitty palettes, Dunst/Fuzzel settings, installer shell syntax, Python helper syntax, and the bundled LightDM GTK theme mappings. It does not change your installed desktop configuration. GitHub Actions also runs these checks on pushes and pull requests.

### Important

The installer expects the existing Niri config at `~/.config/niri/config.kdl` (or under `$XDG_CONFIG_HOME/niri/config.kdl`). It does **not** install Niri, Waybar, Fuzzel, Kitty, Dunst, Fetch, or system packages. Install `areofyl/fetch` separately if you want the terminal animation.

Typical Debian package names for the UI dependencies are:

```bash
sudo apt install waybar fuzzel kitty dunst swaybg swaylock python3 python3-tk brightnessctl fonts-font-awesome fonts-fork-awesome fonts-jetbrains-mono
```

The distro-logo glyphs may require a Nerd Font with Linux symbols (for example, Symbols Nerd Font Mono or JetBrainsMono Nerd Font); the regular JetBrains Mono package does not guarantee those glyphs. The CSS also includes FontAwesome/ForkAwesome fallbacks for supported icons. Niri and Fetch are separate prerequisites. On Arch and Gentoo, use the corresponding package manager and package names for your installation.

## Features and shortcuts

- Waybar workspaces and clock, audio/network/battery indicators, system tray, and brightness where hardware supports it.
- Click the brightness or volume module to open the themed slider; right-click volume to mute/unmute.
- The network module is a status indicator by default; it does not launch a second network manager. The optional Wi-Fi helper remains available at `~/.local/bin/itsuki-wifi-menu.py` if you choose to launch it manually.
- `Super+D` — open the Fuzzel application launcher.
- `Super+Return` — open Kitty.
- `Super+E` — open the power menu (lock, log out of Niri, suspend, reboot, or power off).
- Fetch runs as `fetch --box --shading-mode sextants` in new interactive Bash/Zsh terminals when installed and enabled by the installer.

Waybar's system tray only shows applications that expose compatible tray icons. The brightness module only appears when `/sys/class/backlight` contains a backlight device. The optional Wi-Fi helper requires NetworkManager's `nmcli`, Kitty, and Fuzzel; install the `network-manager` package only if NetworkManager is not already present.

## Optional LightDM greeter

After installing the desktop rice, the main installer detects `/etc/lightdm` and optionally asks whether to configure the LightDM GTK Greeter with the same profile and wallpaper style. It does not touch LightDM unless you accept that prompt.

To configure LightDM later, run the separate installer:

```bash
bash install-lightdm.sh
```

It lets you choose Debian, Arch Linux, Gentoo, or Neutral and then a background with or without Itsuki. It installs the matching GTK accent theme (rose for Debian/Neutral, blue for Arch, violet for Gentoo), including entry-field styling. The script backs up the current greeter config, any existing target image, and any existing bundled-theme files under `/etc/lightdm/itsuki-backup-<timestamp>/`, asks for confirmation before writing system files, and does not switch display managers or restart LightDM. The selected appearance is used at the next login screen.

## Repository layout

- `configs/` — red/rose base profile for Debian and Neutral.
- `configs/arch/` — blue Arch profile.
- `configs/gentoo/` — violet Gentoo profile.
- `variants/<name>/install.sh` — small entry point for each variant.
- `wallpaper/` — desktop wallpaper images and their notes.
- `scripts/` — shared power, Wi-Fi, and control scripts.

## License

See [LICENSE](LICENSE).
