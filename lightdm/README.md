# LightDM GTK Greeter

The uploaded system archive identifies `/usr/sbin/lightdm` as the active display manager and `lightdm-gtk-greeter` as the configured greeter. The supplied settings were retained: Adwaita-dark theme, Adwaita icons, top panel, clock, language/session/power indicators and centered login layout.

The greeter background uses `itsuki-debian-niri-rice.jpg`, installed to `/usr/share/backgrounds/itsuki-debian-niri-rice.jpg`.

Run `bash install-lightdm.sh` from the full ZIP to install this part separately. If cloning the GitHub source tree, first place an image at `wallpaper/itsuki-debian-niri-rice.jpg`. The script asks for confirmation, backs up the existing greeter config and any existing target wallpaper, and does not switch display managers or restart LightDM in the current session. The theme appears on the next login screen.
