# Itsuki Niri Rice variants

The same rice can use different branding without creating separate repositories.

| Variant | Waybar icon | Installer |
|---|---|---|
| Debian | Debian mark | `variants/debian/install.sh` |
| Arch Linux | Arch mark | `variants/arch/install.sh` |
| Gentoo | Gentoo mark | `variants/gentoo/install.sh` |
| Neutral | ★ | `variants/neutral/install.sh` |

All four variants use the same Niri, Waybar, Kitty, Fuzzel, Dunst, Fetch and power-menu configuration. The only variant-specific part is the left-side Waybar branding and backup namespace.

The icons use Unicode/Nerd-Font glyphs. If a distro logo is not available in the selected font, the rest of the rice still works; install a Nerd Font if you want the logo glyphs rendered.
