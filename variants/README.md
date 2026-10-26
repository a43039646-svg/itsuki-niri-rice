# Itsuki Niri Rice variants

The same rice can use different branding without creating separate repositories.

| Variant | Waybar icon | Installer |
|---|---|---|
| Debian | Debian mark | `variants/debian/install.sh` |
| Arch Linux | Arch mark | `variants/arch/install.sh` |
| Gentoo | Gentoo mark | `variants/gentoo/install.sh` |
| Neutral | No icon | `variants/neutral/install.sh` |

Debian and Neutral use the red/rose base config set. Arch selects `configs/arch/` (blue accents), and Gentoo selects `configs/gentoo/` (violet accents). The separate profiles each contain Waybar, Fuzzel, Kitty, Dunst, Fetch, portal preferences, and a matching color version of the brightness/audio slider. Each installer also selects its matching wallpaper. Neutral has no distro mark and uses a logo-free wallpaper. The Niri patch, Wi-Fi menu and power-menu logic remain shared.

The icons use Unicode/Nerd-Font glyphs. If a distro logo is not available in the selected font, the rest of the rice still works; install a Nerd Font if you want the logo glyphs rendered.
