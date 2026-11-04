# Itsuki Niri Rice

A lightweight, universal Niri desktop rice with a rose-and-cream palette and the **Minimal Rail** Waybar layout.

The repository provides one shared configuration for all distributions, an Itsuki desktop wallpaper, and a separate LightDM login-screen wallpaper. The installer has no distro, profile, or wallpaper selection menus.

## Wallpapers

### Desktop wallpaper

![Itsuki Niri desktop wallpaper](wallpapers/itsuki.png)

### LightDM login-screen wallpaper

![Itsuki LightDM login wallpaper](wallpapers/lightdm-itsuki.png)

The installer copies `wallpapers/itsuki.png` to `~/.local/share/itsuki-niri-rice/wallpapers/itsuki.png` and starts it with `swaybg` in fill mode whenever Niri starts.

When LightDM with **LightDM GTK Greeter** or **Slick Greeter** is already installed, the same installer also installs `wallpapers/lightdm-itsuki.png` under `/usr/share/backgrounds/itsuki-lightdm/` and updates only the active greeter's background setting. It backs up the previous greeter configuration and wallpaper first. It does not install or switch display managers, and it does not restart LightDM.

## Requirements

Install and configure Niri before using this rice. The installer configures the desktop applications; it does not install Niri or the application packages for you.

### Required packages on Debian 13

```bash
sudo apt update
sudo apt install git waybar kitty fuzzel dunst swaybg brightnessctl python3 python3-tk wireplumber pipewire-pulse xdg-desktop-portal xdg-desktop-portal-gtk fonts-jetbrains-mono fonts-font-awesome fonts-fork-awesome
```

What these packages are used for:

| Package / tool | Purpose |
| --- | --- |
| `waybar` | Minimal Rail panel, workspaces, clock, network, audio, battery and tray |
| `kitty` | Terminal used by the keybinding and Wi-Fi helper |
| `fuzzel` | Application launcher, power menu and Wi-Fi network picker |
| `dunst` | Notification daemon |
| `swaybg` | Starts the bundled desktop wallpaper |
| `brightnessctl` | Brightness module and brightness slider |
| `python3`, `python3-tk` | Installer helpers, Wi-Fi menu and slider windows |
| `wireplumber`, `pipewire-pulse` | `wpctl` volume controls and Waybar's PulseAudio-compatible audio module |
| `xdg-desktop-portal`, `xdg-desktop-portal-gtk` | Desktop portal and GTK file chooser/settings backend |
| `fonts-jetbrains-mono` | Main font used by Kitty, Fuzzel and Dunst |
| `fonts-font-awesome`, `fonts-fork-awesome` | Icons used by Waybar and the rice |

Niri itself must already be installed and running. Keep your existing working audio stack; the audio packages above are needed when you use the provided PipeWire/WirePlumber controls.

### Optional packages and features

Install these only for the features you use:

```bash
sudo apt install network-manager libnotify-bin swaylock
```

- **NetworkManager (`nmcli`):** required by the optional Wi-Fi picker at `~/.local/bin/itsuki-wifi-menu.py`.
- **`libnotify-bin` (`notify-send`):** notifications from the Wi-Fi helper and reload shortcut.
- **`swaylock`:** used for the lock-screen action in the power menu. Without it, the helper falls back to `loginctl lock-session`.
- **Fetch:** not bundled. The installer adds a guarded shell startup entry; it runs only when a `fetch` command is already installed.
- **LightDM:** to use the login-screen wallpaper, LightDM and one supported greeter must already be installed. On Debian, the GTK option is:
  ```bash
  sudo apt install lightdm lightdm-gtk-greeter
  ``
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

1. Checks for the required files and tools before applying the rice.
2. Backs up the existing rice-related configuration under `~/.config/itsuki-niri-backup/<timestamp>/`.
3. Installs the universal rose profile and patches your existing `~/.config/niri/config.kdl`; it does not replace your whole Niri configuration.
4. Installs and configures the desktop wallpaper.
5. Configures the LightDM login wallpaper when a supported LightDM greeter is detected.
6. Adds the Itsuki keybindings and startup entries without duplicating its managed block on repeated installs.

If LightDM is not installed, or its greeter is not supported, the login-screen wallpaper step is skipped. The Niri rice installation can still be used normally.

## Included

- **Waybar Minimal Rail:** transparent top rail, thin rose underline, underlined active workspace, centered clock and unboxed system indicators.
- **Kitty:** coordinated colors, JetBrains Mono, translucent background and Niri blur integration on Niri 26.04 or newer.
- **Fuzzel:** matching application launcher and menus.
- **Dunst:** matching notifications.
- **Wallpapers:** separate Itsuki images for the Niri desktop and LightDM login screen.
- **Helpers:** power menu, Wi-Fi menu, volume/brightness sliders, blur setup and reload shortcut.
- **Fetch config:** optional animated terminal system information; the Fetch program is not bundled.

## Keybindings

| Binding | Action |
| --- | --- |
| `Mod+D` | Open Fuzzel |
| `Mod+Return` | Open Kitty |
| `Super+E` | Open the Itsuki power menu |
| `Super+Shift+B` | Reload Niri and restart Waybar and Dunst |

## Kitty transparency and Niri blur

On Niri **26.04 or newer**, the installer configures Kitty transparency and Niri's background blur integration. Kitty's default background opacity is `0.68`; set it closer to `1.0` for a less transparent terminal.

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

The validation script checks the universal Waybar JSON, both wallpaper assets, required files and helper syntax. It does not replace testing in a live Niri session.

## Repository layout

- `configs/` — the single universal rose profile.
- `wallpapers/itsuki.png` — default Niri desktop wallpaper.
- `wallpapers/lightdm-itsuki.png` — LightDM login-screen wallpaper.
- `scripts/` — power, Wi-Fi, slider, reload, blur and LightDM helpers.
- `install.sh` — universal installer with no interactive selection.
