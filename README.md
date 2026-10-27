# Itsuki Niri Rice

A themed setup for the [Niri Wayland compositor](https://github.com/niri-wm/niri), with matching Waybar, Fuzzel, Kitty, Dunst, wallpapers, and optional Fetch startup.

![Itsuki wallpaper preview](wallpaper/itsuki-neutral2.png)

## Themes

- **Neutral** — rose colors, no distro logo.
- **Debian** — rose colors and Debian logo.
- **Arch Linux** — blue colors and Arch logo.
- **Gentoo** — violet colors and Gentoo logo.

The installer also lets you choose a wallpaper with Itsuki or a clean version when one is available.

## 1. Install Niri first

This rice does **not** install Niri. Follow the [official Niri Getting Started guide](https://github.com/niri-wm/niri/wiki/Getting-Started) for your distribution.

**Debian 13:** check whether Niri is available from your configured APT repositories:

```bash
apt-cache policy niri
```

If `Candidate` shows a version, install it with:

```bash
sudo apt update
sudo apt install niri
```

If the candidate is `(none)`, use the installation options linked from the [Niri guide](https://github.com/niri-wm/niri/wiki/Getting-Started). It lists community-maintained packages for Debian-based systems, including Pacstall. Pacstall is third-party software, not part of Debian, so review its instructions before installing it.

**Arch Linux:**

```bash
sudo pacman -Syu niri
```

For other distributions, use the [official guide](https://github.com/niri-wm/niri/wiki/Getting-Started).

Before running the rice installer, make sure `~/.config/niri/config.kdl` already exists and contains a `binds { }` block. If you have never configured Niri, follow its configuration guide first.

## 2. Install the rice dependencies

On Debian, install the main components if they are not already installed:

```bash
sudo apt update
sudo apt install git waybar fuzzel kitty dunst swaybg brightnessctl python3 python3-tk fonts-font-awesome fonts-fork-awesome fonts-jetbrains-mono
```

Keep your existing working audio setup. The optional Wi-Fi helper requires NetworkManager (`nmcli`), Kitty, and Fuzzel.

The distro logos may need a Nerd Font. If you see a box instead of a logo, install a [Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases) and restart your session. Font Awesome alone may not include these logos.

## 3. Download and install

```bash
git clone https://github.com/a43039646-svg/itsuki-niri-rice.git
cd itsuki-niri-rice
bash install.sh
```

Choose a theme and wallpaper when prompted. The installer backs up existing rice files to `~/.config/itsuki-niri-backup/` and saves the Niri config before editing it. If LightDM is detected, setting up its login-screen theme is optional.

## 4. Reboot after installation

**When the installer has finished, reboot the computer:**

```bash
sudo reboot
```

At the login screen, choose **Niri** as your session and log in.

## Shortcuts and notes

- `Super + D` — open Fuzzel.
- `Super + Enter` — open Kitty.
- `Super + E` — open the power menu.
- Fetch starts in new interactive Bash/Zsh terminals as `fetch --box --shading-mode sextants`, if Fetch is installed. This repository does not install Fetch itself.
- The Waybar network indicator shows status and does not open a second network-manager window.

## Checks and troubleshooting

Run the static checks from the repository directory before installing:

```bash
bash scripts/validate-profiles.sh
```

If Waybar appears twice, check that you have not configured another Waybar startup elsewhere. If a change causes trouble, restore the relevant file from the backup under `~/.config/itsuki-niri-backup/`.

## Optional LightDM theme

The main installer offers this option when LightDM is detected. You can also run:

```bash
bash install-lightdm.sh
```

This is only for LightDM GTK Greeter; it does not install LightDM or switch your display manager.
