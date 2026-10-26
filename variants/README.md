# Itsuki Niri Rice variants

The same rice can use different branding without creating separate repositories.

| Variant | Waybar icon | Installer |
|---|---|---|
| Debian | Debian mark | `variants/debian/install.sh` |
| Arch Linux | Arch mark | `variants/arch/install.sh` |
| Gentoo | Gentoo mark | `variants/gentoo/install.sh` |
| Neutral | No icon | `variants/neutral/install.sh` |

All four variants use the same Niri, Waybar, Kitty, Fuzzel, Dunst, Fetch and power-menu configuration. Debian, Arch and Gentoo show their respective marks; Neutral shows no distro mark and has no dedicated wallpaper. The backup namespace remains variant-specific.

The icons use Unicode/Nerd-Font glyphs. If a distro logo is not available in the selected font, the rest of the rice still works; install a Nerd Font if you want the logo glyphs rendered.
