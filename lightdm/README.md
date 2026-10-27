# LightDM GTK Greeter

This optional part configures the **LightDM GTK Greeter** with matching color profiles for Debian, Arch Linux, Gentoo, and Neutral. It is separate from the main Niri installer.

Run this from the full repository checkout:

```bash
bash install-lightdm.sh
```

The installer asks for a profile and then a background style (with or without Itsuki). It uses the matching config under `configs/lightdm/`, wallpaper under `wallpaper/`, and bundled GTK theme under `lightdm/themes/`. Debian and Neutral use the rose accent theme; Arch uses blue; Gentoo uses violet. The GTK theme styles the greeter's entry fields and buttons as well as its general widget colors.

The installer backs up the existing `/etc/lightdm/lightdm-gtk-greeter.conf`, any existing target background, and any pre-existing files at the selected `/usr/share/themes/Itsuki-*/` paths to `/etc/lightdm/itsuki-backup-<timestamp>/` before replacing anything. It asks for confirmation and does not install LightDM, switch display managers, enable services, or restart LightDM. Changes appear the next time the greeter is shown.

For automated use, set `ITSUKI_LIGHTDM_PROFILE` (`debian`, `arch`, `gentoo`, or `neutral`), `ITSUKI_LIGHTDM_WALLPAPER` (`character` or `clean`), and explicitly set `ITSUKI_LIGHTDM_CONFIRM=yes`. Without that confirmation flag or an interactive terminal confirmation, it makes no system changes.
