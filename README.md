# Itsuki Niri Rice

A lightweight, universal Niri desktop rice inspired by the colors of the bundled Itsuki wallpaper: deep ocean blue, clear sky blue, warm ivory and coral red.

The profile uses the **Minimal Rail** Waybar, Fuzzel launcher and **SwayNotificationCenter (SwayNC)**. It provides one shared configuration for all distributions, an Itsuki desktop wallpaper and a separate LightDM login-screen wallpaper.

## Wallpapers

### Desktop wallpaper

![Itsuki Niri desktop wallpaper](wallpapers/itsuki.png)

### LightDM login-screen wallpaper

![Itsuki LightDM login wallpaper](wallpapers/lightdm-itsuki.png)

The installer copies `wallpapers/itsuki.png` to `~/.local/share/itsuki-niri-rice/wallpapers/itsuki.png` and starts it with `swaybg` whenever Niri starts.

When LightDM with **LightDM GTK Greeter** or **Slick Greeter** is already installed, the installer also installs `wallpapers/lightdm-itsuki.png` under `/usr/share/backgrounds/itsuki-lightdm/` and updates only the active greeter's background. With LightDM GTK Greeter, the login form is centered using `position=50%,center 50%,center`, and per-user backgrounds are disabled so the selected Itsuki image remains in use. The installer backs up the previous greeter configuration and wallpaper. It does not install or switch display managers, and it does not restart LightDM. Slick Greeter keeps its own layout defaults.

## Color palette

| Role | Color |
| --- | --- |
| Deep ocean background | `#102B38` |
| Dark panel / notification surface | `#0D2430` |
| Coral red accent and window borders | `#D95F58` |
| Sky blue secondary accent | `#78BFD0` |
| Warm ivory text | `#F4EBDD` |
| Muted blue-gray | `#426B7A` |

The focused Niri window border and the Waybar outline use the coral accent. Inactive window borders use muted ocean blue. Fuzzel, Kitty and SwayNC share the same palette.

## Requirements

Install and configure Niri before using this rice. The installer configures the desktop applications; it does not install Niri or application packages.

### Required packages on Debian 13

```bash
sudo apt update
sudo apt install git waybar kitty fuzzel sway-notification-center swaybg brightnessctl python3 python3-tk wireplumber pipewire-pulse xdg-desktop-portal xdg-desktop-portal-gtk fonts-jetbrains-mono fonts-font-awesome fonts-fork-awesome
```

| Package / tool | Purpose |
| --- | --- |
| `waybar` | Minimal Rail panel, workspaces, clock, network, audio, battery and tray |
| `kitty` | Terminal used by the keybinding and Wi-Fi helper |
| `fuzzel` | Application launcher, power menu and Wi-Fi picker |
| `sway-notification-center` | SwayNC notification daemon and control center |
| `swaybg` | Desktop wallpaper |
| `brightnessctl` | Brightness module and slider |
| `python3`, `python3-tk` | Installer helpers, Wi-Fi menu and slider windows |
| `wireplumber`, `pipewire-pulse` | `wpctl` volume controls and Waybar's PulseAudio-compatible module |
| `xdg-desktop-portal`, `xdg-desktop-portal-gtk` | Desktop portal and GTK file chooser backend |
| `fonts-jetbrains-mono` | Main font for Kitty, Fuzzel, SwayNC and Waybar |
| `fonts-font-awesome`, `fonts-fork-awesome` | Icons used by Waybar and the rice |

The installer checks that both `swaync` and `swaync-client` are available before changing your configuration. It replaces the rice-managed Dunst startup with SwayNC, and stops a running Dunst instance when applying the rice. It does not remove Dunst or change unrelated notification settings outside the managed Niri startup entry.

Niri itself must already be installed and running. Keep your existing working audio stack; the audio packages above are needed when you use the provided PipeWire/WirePlumber controls.

### Optional packages and features

Install these only for the features you use:

```bash
sudo apt install network-manager libnotify-bin swaylock
```

- **NetworkManager (`nmcli`):** required by the optional Wi-Fi picker at `~/.local/bin/itsuki-wifi-menu.py`.
- **`libnotify-bin` (`notify-send`):** notifications from the Wi-Fi helper and reload shortcut.
- **`swaylock`:** used for the lock-screen action in the power menu. Without it, the helper falls back to `loginctl lock-session`.
- **Fetch / Fastfetch:** neither program is bundled. During installation, the installer checks the active Bash or Zsh startup file for an existing `fetch` or `fastfetch` command. If one is already configured, it leaves that startup file unchanged. If no autostart exists and one of the commands is installed, it adds one guarded interactive-shell entry. If neither command is installed, it skips this step.
- **LightDM:** to use the login-screen wallpaper, LightDM and one supported greeter must already be installed. On Debian, the GTK option is:
  ```bash
  sudo apt install lightdm lightdm-gtk-greeter
  ```
  Installing LightDM may ask which display manager should be the default. The rice installer itself does not switch display managers. It also supports an existing Slick Greeter installation.
- **`sudo`:** needed by the LightDM helper to write files under `/etc/lightdm` and `/usr/share/backgrounds`.

The package names above are for Debian 13. On other distributions, install the equivalent packages with that distribution's package manager.

## Install

```bash
git clone https://github.com/a43039646-svg/itsuki-niri-rice.git
cd itsuki-niri-rice
bash install.sh
```

The installer:

1. Checks required files, tools, SwayNC and the existing Niri config before installing.
2. Backs up the existing rice-related configuration under `~/.config/itsuki-niri-backup/<timestamp>/`.
3. Installs the Itsuki color profile for Waybar, Kitty, Fuzzel and SwayNC.
4. Patches your existing `~/.config/niri/config.kdl` with the coral window border and managed startup/reload entries; it does not replace your whole Niri configuration.
5. Installs and applies the desktop wallpaper.
6. Configures the LightDM login wallpaper when a supported LightDM greeter is detected.
7. Adds Fetch/Fastfetch autostart only when no existing invocation is found.

If LightDM is not installed, or its greeter is not supported, the login-screen wallpaper step is skipped. The Niri rice installation can still be used normally.

## Included

- **Waybar Minimal Rail:** dark ocean panel with a coral-red outline, coral active-workspace underline, centered clock, sky-blue indicators and a SwayNC bell (left-click opens the control center; right-click toggles Do Not Disturb).
- **Niri window borders:** coral focused border, muted blue inactive border and coral urgent border.
- **Kitty:** matching colors, JetBrains Mono, translucent background and Niri blur integration on Niri 26.04 or newer.
- **Fuzzel:** matching dark-blue launcher with coral selection and outline.
- **SwayNC:** matching notifications and control center with coral outlines and sky-blue details.
- **Wallpapers:** separate Itsuki images for the Niri desktop and LightDM login screen.
- **Helpers:** power menu, Wi-Fi menu, volume/brightness sliders, blur setup and reload shortcut.
- **Fetch config:** optional terminal system information; Fetch and Fastfetch themselves are not bundled.

## Keybindings

| Binding | Action |
| --- | --- |
| `Mod+D` | Open Fuzzel |
| `Mod+Return` | Open Kitty |
| `Super+E` | Open the Itsuki power menu |
| `Super+Shift+B` | Reload Niri, Waybar, SwayNC and the Itsuki wallpaper |

The SwayNC bell in Waybar opens the notification center with a left-click and toggles Do Not Disturb with a right-click. SwayNC can also be controlled with `swaync-client`; see `swaync-client --help` for available actions.

## Kitty transparency and Niri blur

On Niri **26.04 or newer**, the installer configures Kitty transparency and Niri's background blur integration. Kitty's default background opacity is `0.78`; set it closer to `1.0` for a less transparent terminal.

The helper can also be run separately:

```bash
python3 scripts/enable-kitty-blur.py
```

## Update and validate

```bash
cd itsuki-niri-rice
git pull
bash scripts/validate-profiles.sh
bash install.sh
```

The validation script checks the Waybar and SwayNC JSON, theme files, wallpaper assets and helper syntax. It does not replace testing in a live Niri session.

## Repository layout

- `configs/waybar/` — Minimal Rail config and CSS.
- `configs/kitty/` — Kitty color profile.
- `configs/fuzzel/` — Fuzzel launcher colors.
- `configs/swaync/` — SwayNC settings and style.
- `configs/fetch/` — optional Fetch config.
- `wallpapers/itsuki.png` — default Niri desktop wallpaper.
- `wallpapers/lightdm-itsuki.png` — LightDM login-screen wallpaper.
- `scripts/` — power, Wi-Fi, slider, reload, blur and LightDM helpers.
- `install.sh` — universal installer with no interactive selection.
