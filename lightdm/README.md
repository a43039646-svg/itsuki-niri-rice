# LightDM GTK Greeter

This optional part configures the **LightDM GTK Greeter** with the same four visual profiles as the desktop rice: Debian, Arch Linux, Gentoo, and Neutral. It is separate from the main Niri installer.

Run this from the full repository checkout:

```bash
bash install-lightdm.sh
```

The installer asks for a profile and then a background style (with or without Itsuki). It uses the matching config under `configs/lightdm/` and the corresponding image under `wallpaper/`. The Debian clean background uses `wallpaper/debian-rice.jpg`; the Arch, Gentoo, and Neutral profiles use their matching wallpapers.

The installer backs up the existing `/etc/lightdm/lightdm-gtk-greeter.conf` and any existing target background to `/etc/lightdm/itsuki-backup-<timestamp>/` before replacing anything. It asks for confirmation and does not install LightDM, switch display managers, enable services, or restart LightDM. Changes appear the next time the greeter is shown.

For automated use, set `ITSUKI_LIGHTDM_PROFILE` (`debian`, `arch`, `gentoo`, or `neutral`), `ITSUKI_LIGHTDM_WALLPAPER` (`character` or `clean`), and explicitly set `ITSUKI_LIGHTDM_CONFIRM=yes`. Without that confirmation flag or an interactive terminal confirmation, it makes no system changes.
