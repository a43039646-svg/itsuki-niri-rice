# Itsuki Niri Rice

A lightweight, universal Niri desktop rice with a rose-and-cream palette and the **Minimal Rail** Waybar layout.

This repository contains **one shared configuration** for every distribution. It does not bundle wallpapers, distro-specific editions, or LightDM themes. The installer leaves your existing wallpaper setup untouched.

## Requirements

Install Niri first and log into a Niri session once. The rice configures applications; it does not install packages.

On Debian 13, the main dependencies can be installed with:

```bash
sudo apt update
sudo apt install git curl waybar fuzzel kitty dunst brightnessctl python3 python3-tk xdg-desktop-portal-gtk pipewire-pulse wireplumber fonts-font-awesome fonts-fork-awesome fonts-jetbrains-mono
```

Keep your existing audio stack if it already works. The optional Wi-Fi helper uses NetworkManager (`nmcli`).

## Install

```bash
git clone https://github.com/a43039646-svg/itsuki-niri-rice.git
cd itsuki-niri-rice
bash install.sh
```

There are no distro or wallpaper selection prompts. The installer backs up the existing rice files under `~/.config/itsuki-niri-backup/<timestamp>/`, patches your existing `~/.config/niri/config.kdl`, and installs the shared rose profile. It does not replace your full Niri config or change your wallpaper.

## Included

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

The validation script checks the shared Waybar JSON, required files, and helper syntax. It does not replace testing in a live Niri session.

## Repository layout

- `configs/` — the single universal rose profile.
- `scripts/` — power, Wi-Fi, slider, reload, and blur helpers.
- `install.sh` — universal installer; it leaves wallpaper management to the user.
