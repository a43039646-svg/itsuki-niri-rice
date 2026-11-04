# Itsuki Niri Rice

A lightweight, universal Niri desktop rice with a rose-and-cream palette and the **Minimal Rail** Waybar layout.

This repository contains one shared configuration for every distribution and installs the bundled Itsuki wallpaper automatically. There are no distro or wallpaper selection prompts.

## Requirements

Install Niri first and log into a Niri session once. The rice configures applications; it does not install packages. The installer requires `swaybg` to display the bundled wallpaper.

On Debian 13, the main dependencies can be installed with:

```bash
sudo apt update
sudo apt install git curl waybar fuzzel kitty dunst swaybg brightnessctl python3 python3-tk xdg-desktop-portal-gtk pipewire-pulse wireplumber fonts-font-awesome fonts-fork-awesome fonts-jetbrains-mono
```

Keep your existing audio stack if it already works. The optional Wi-Fi helper uses NetworkManager (`nmcli`).

## Install

```bash
git clone https://github.com/a43039646-svg/itsuki-niri-rice.git
cd itsuki-niri-rice
bash install.sh
```

The installer has no interactive choices. It backs up the existing rice files under `~/.config/itsuki-niri-backup/<timestamp>/`, patches your existing `~/.config/niri/config.kdl`, and installs the shared rose profile. It does not replace your full Niri config.

The wallpaper `wallpapers/itsuki.png` is copied to `~/.local/share/itsuki-niri-rice/wallpapers/itsuki.png` and started automatically with `swaybg` in fill mode every time Niri starts. The installer replaces older Niri startup lines for Waybar, Dunst, and common wallpaper tools that it manages, and keeps one marked startup block so running the installer again does not duplicate entries. The separate `lightdm-itsuki.png` image is not installed or applied.

## Included

- **Wallpaper:** bundled Itsuki background, automatically installed and started by Niri.
- **Waybar Minimal Rail:** transparent top rail, thin rose underline, underlined active workspace, centered clock, and unboxed system indicators.
- **Kitty:** coordinated colors, JetBrains Mono, translucent background, and Niri blur integration on Niri 26.04 or newer.
- **Fuzzel:** matching application launcher and menus.
- **Dunst:** matching notifications.
- **Helpers:** power menu, Wi-Fi menu, volume/brightness sliders, and reload shortcut.
- **Fetch:** optional animated terminal system information; it is not bundled.

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

The validation script checks the shared Waybar JSON, wallpaper asset, required files, and helper syntax. It does not replace testing in a live Niri session.

## Repository layout

- `configs/` — the single universal rose profile.
- `wallpapers/itsuki.png` — default desktop wallpaper installed by the installer.
- `wallpapers/lightdm-itsuki.png` — separate image, currently not configured by this installer.
- `scripts/` — power, Wi-Fi, slider, reload, and blur helpers.
- `install.sh` — universal installer with no interactive selection.
