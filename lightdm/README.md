# LightDM GTK Greeter

The uploaded system archive identifies `/usr/sbin/lightdm` as the active display manager and `lightdm-gtk-greeter` as the configured greeter. The original config used `/usr/share/backgrounds/debian-rice.png`; the full rice ZIP contains the provided dark Debian-logo wallpaper as `wallpaper/debian-rice.jpg`, and the themed config points to `/usr/share/backgrounds/debian-rice.jpg`.

The original settings were retained: Adwaita-dark theme, Adwaita icons, top panel, clock, language/session/power indicators and centered login layout. The desktop itself keeps the separate Itsuki wallpaper.

Run `bash install-lightdm.sh` from the full ZIP to install this part separately. If using a Git clone, provide `wallpaper/debian-rice.jpg` first. The script asks for confirmation, backs up the existing greeter config and any existing target JPEG, and does not switch display managers or restart LightDM in the current session. The theme appears on the next login screen.
