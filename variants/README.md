# Itsuki Niri Rice variants

Use the variant that matches the look you want. All variants share the same Niri integration and common power/Wi-Fi menu scripts, but the visual configs and wallpaper can differ.

| Variant | Waybar mark | Palette | Config source | Installer |
|---|---|---|---|---|
| Debian | Debian mark | Red / rose | `configs/` | `variants/debian/install.sh` |
| Arch Linux | Arch mark | Navy / blue | `configs/arch/` | `variants/arch/install.sh` |
| Gentoo | Gentoo mark | Dark plum / violet | `configs/gentoo/` | `variants/gentoo/install.sh` |
| Neutral | No distro mark | Red / rose | `configs/` | `variants/neutral/install.sh` |

Arch and Gentoo each have a separate copy of the Waybar config and stylesheet, Fuzzel, Kitty, Dunst, Fetch config, the XDG desktop-portal preference, and the brightness/audio slider. Debian and Neutral use the red/rose base configs. Neutral's wallpaper has no large distro logo or star.

Run one installer from the repository root:

```bash
bash variants/debian/install.sh
bash variants/arch/install.sh
bash variants/gentoo/install.sh
bash variants/neutral/install.sh
```

The installer expects an existing, working `~/.config/niri/config.kdl`. It backs up the current user configs, copies the selected profile, chooses the matching desktop wallpaper, and adds the rice's Niri startup entries and shortcuts. It does not install Niri or system packages.

The distro marks may require a Nerd Font with suitable glyphs. If a logo is missing, the rest of the theme still works.
