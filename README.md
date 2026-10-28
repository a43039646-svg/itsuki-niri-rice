# Itsuki Niri Rice

A themed desktop setup for the [Niri](https://github.com/niri-wm/niri) Wayland compositor. It includes coordinated Waybar, Kitty, Fuzzel, Dunst and Fetch settings, an Itsuki wallpaper, and small helper scripts.

**Important:** This repository configures an existing Niri installation. It does not install Niri or system packages for you. Install Niri first, log into a Niri session at least once, and then install this rice.

![Itsuki Niri Rice wallpaper preview](wallpaper/itsuki-neutral2.png)

## Theme profiles

| Installer choice | Accent | Waybar distro logo |
| --- | --- | --- |
| Neutral — Itsuki only | Rose | None |
| Arch Linux | Blue | Arch Linux |
| Debian | Rose | Debian |
| Gentoo | Violet | Gentoo |

Neutral and Debian intentionally share the rose color palette. The installer also asks whether to use a wallpaper with Itsuki or a clean wallpaper without the character. A dedicated clean Debian wallpaper is not included yet, so that choice uses the neutral background.

## 1. Install Niri

Use the installation method recommended for your distribution. The upstream project keeps current instructions in the [Niri Getting Started guide](https://github.com/niri-wm/niri/wiki/Getting-Started).

### Debian 13 (Trixie)

First check whether your configured Debian repositories provide Niri:

```bash
apt-cache policy niri
```

If the output shows a real version under `Candidate`, install it with `sudo apt install niri` and skip the Pacstall steps below. If the candidate is `(none)`, a community-maintained option is Pacstall. Pacstall is a third-party package manager, not part of Debian; its Niri package builds Niri from source and can take a while. Check the [Niri package recipe](https://github.com/pacstall/pacstall-programs/blob/master/packages/niri/niri.pacscript) and [Pacstall's Debian compatibility note](https://github.com/pacstall/pacstall/wiki/FAQ) before using it.

```bash
sudo apt update
sudo apt install curl wget ca-certificates
sudo bash -c "$(curl -fsSL https://pacstall.dev/q/install || wget -q https://pacstall.dev/q/install -O -)"
sudo pacstall -I niri
```

If Pacstall or the package build fails, stop and read the error rather than trying random dependency commands. Check the upstream Niri guide for other installation/build methods.

### Arch Linux

Niri is available as a distribution package. Install it with:

```bash
sudo pacman -Syu niri
```

### Gentoo and other distributions

Package availability and build steps vary. Use the [upstream Niri installation guide](https://github.com/niri-wm/niri/wiki/Getting-Started) and check the current package/overlay status for your distribution. Selecting the Gentoo theme in this repository changes the rice configuration; it does not install Niri or add a Gentoo overlay.

## 2. Install the rice dependencies

The rice installer does not install Waybar, Kitty, Fuzzel, Dunst, swaybg, fonts, or audio/brightness tools. Install the packages you do not already have using your distribution's package manager.

On Debian 13, the following covers the main desktop components:

```bash
sudo apt update
sudo apt install git curl waybar fuzzel kitty dunst swaybg brightnessctl python3 python3-tk xdg-desktop-portal-gtk pipewire-pulse wireplumber fonts-font-awesome fonts-fork-awesome fonts-jetbrains-mono
```

Some systems may already use a different audio stack; keep your working audio setup rather than replacing it just for this rice. The optional Wi-Fi helper needs NetworkManager (`nmcli`), Kitty and Fuzzel. The main Waybar network indicator does not launch a second network-manager window.

### Optional: fix missing distro-logo glyphs

The Arch, Debian and Gentoo logos use Nerd Font symbols. Font Awesome by itself, and regular JetBrains Mono by itself, may not contain those glyphs. You can install JetBrainsMono Nerd Font for your user from the [official Nerd Fonts releases](https://github.com/ryanoasis/nerd-fonts/releases):

```bash
mkdir -p ~/.local/share/fonts/JetBrainsMonoNerdFont
curl -fL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz -o /tmp/JetBrainsMonoNerdFont.tar.xz
tar -xf /tmp/JetBrainsMonoNerdFont.tar.xz -C ~/.local/share/fonts/JetBrainsMonoNerdFont
fc-cache -f ~/.local/share/fonts
```

After installing a font, log out and back in (or reboot) so Waybar can reload the font cache.

## 3. Start Niri once before installing the rice

Log out of your current desktop, choose **Niri** from your login screen's session menu, and log in. This first launch lets Niri create its user configuration at `~/.config/niri/config.kdl`. The rice installer expects that file to exist and contain a top-level `binds` block. If Niri is already installed and you have logged into it before, you can skip this step.

## 4. Download and install Itsuki Niri Rice

Open a terminal and run:

```bash
git clone https://github.com/a43039646-svg/itsuki-niri-rice.git
cd itsuki-niri-rice
bash install.sh
```

Choose the profile that matches the look you want:

1. **Neutral** — rose theme, no distro logo.
2. **Arch Linux** — blue theme and Arch logo.
3. **Debian** — rose theme and Debian logo.
4. **Gentoo** — violet theme and Gentoo logo.

Then choose a wallpaper with Itsuki or the clean wallpaper without the character. Review the prompts before confirming anything. If LightDM is detected, the installer may offer to configure its GTK greeter; this is optional and only applies if you use LightDM GTK Greeter.

The installer backs up existing rice configuration files before replacing them. Backups are stored under `~/.config/itsuki-niri-backup/<profile>/<timestamp>/`. It also saves the original Niri config before patching it and backs up the shell startup file before updating the managed Fetch block.

## 5. Reboot after installation

**When the installer finishes, reboot your computer.** This ensures Niri starts with the updated configuration, Waybar, Dunst and wallpaper commands.

```bash
sudo reboot
```

At the login screen, select **Niri** as the desktop session and log in. If you use a display manager with a session selector, it is usually shown by a gear or session menu near the password field.

## Features and shortcuts

- Waybar with workspaces, clock, network, audio, battery, system tray and backlight controls when supported by the hardware.
- Click the distro logo at the left of Waybar to open Fuzzel. The Neutral profile intentionally has no distro logo.
- `Super + D` — open Fuzzel.
- `Super + Enter` — open Kitty.
- `Super + E` — open the Itsuki power menu.
- `Super + Shift + B` — reload Niri's config and restart the rice-managed Waybar, Dunst and wallpaper processes. Fuzzel uses its config the next time it opens; Kitty is not closed.
- Dunst notifications and a wallpaper loaded through `swaybg`.
- Fetch runs in new interactive Bash/Zsh terminals as `fetch --box --shading-mode sextants` when the `fetch` command is installed.
- Profile-specific Fuzzel, Kitty, Dunst and Waybar colors.

Fetch is a separate application and is not downloaded by this repository. See the [Fetch project](https://github.com/areofyl/fetch) if you want the terminal animation.

## Optional LightDM greeter theme

The main installer offers the LightDM setup if `/etc/lightdm` exists. You can also run the separate installer:

```bash
bash install-lightdm.sh
```

This only themes LightDM GTK Greeter after confirmation. It does not install LightDM, switch display managers, enable services or restart LightDM. More detail is in [`lightdm/README.md`](lightdm/README.md).

## Updating and validation

To download the latest repository changes and reapply the profile:

```bash
cd itsuki-niri-rice
git pull
bash install.sh
```

Review the installer prompts and keep the backup directory until you have confirmed everything looks right. To run the repository's read-only checks before installing, from the repository root use:

```bash
bash scripts/validate-profiles.sh
```

The checks cover the Neutral, Debian, Arch and Gentoo configuration files, Waybar JSON/module lists, Kitty palettes, Fuzzel and Dunst settings, shell syntax, Python helper syntax, and LightDM GTK theme mappings. These static checks do not replace testing the rice in a live Niri session.

## Update only the reload shortcut

If you only want to fix `Super + Shift + B` without rerunning the full rice installer, run:

```bash
curl -fsSL https://raw.githubusercontent.com/a43039646-svg/itsuki-niri-rice/main/scripts/install-reload-shortcut.sh | bash
```

This makes a timestamped backup of `~/.config/niri/config.kdl`, installs the reload helper, replaces only the `Mod/Super + Shift + B` binding, and validates the Niri config. The shortcut reloads Niri's configuration and restarts Waybar, Dunst and swaybg. It does not close Kitty terminals or restart the entire compositor session.

## Troubleshooting

- **The distro logo appears as a box or numbers:** install a Nerd Font as described above, then restart the session.
- **Colors do not match the selected profile:** rerun `bash install.sh` from the latest repository and choose the intended profile.
- **Waybar starts twice:** reboot after installing and check that you have not separately added another Waybar autostart command to your Niri config or desktop startup.
- **The installer says the Niri config is missing:** log into Niri once, then run the installer again.
- **A change causes trouble:** use the backup path printed by the installer to restore your previous files.

## Repository layout

- `configs/` — rose base profile used by Debian and Neutral.
- `configs/arch/` — Arch blue profile.
- `configs/gentoo/` — Gentoo violet profile.
- `configs/lightdm/` and `lightdm/themes/` — optional LightDM GTK Greeter profiles and themes.
- `wallpaper/` — included wallpapers.
- `scripts/` — power menu and optional Wi-Fi helper.
- `variants/` — convenience installer entry points for each theme.
- `scripts/validate-profiles.sh` — read-only profile and syntax checks.

## Links

- [Niri project](https://github.com/niri-wm/niri)
- [Niri installation guide](https://github.com/niri-wm/niri/wiki/Getting-Started)
- [Pacstall](https://github.com/pacstall/pacstall)
- [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts)
- [Itsuki Niri Rice repository](https://github.com/a43039646-svg/itsuki-niri-rice)
