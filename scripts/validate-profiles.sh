#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

profiles=(neutral debian arch gentoo)

for profile in "${profiles[@]}"; do
    case "$profile" in
        arch|gentoo) source="$ROOT/configs/$profile" ;;
        debian|neutral) source="$ROOT/configs" ;;
    esac

    printf '[%s] checking profile files... ' "$profile"
    for rel in waybar/config waybar/style.css kitty/kitty.conf fuzzel/fuzzel.ini dunst/dunstrc fetch/config xdg-desktop-portal/niri-portals.conf; do
        [[ -f "$source/$rel" ]] || { echo "MISSING: $source/$rel"; exit 1; }
    done

    python3 - "$profile" "$source/waybar/config" "$source/kitty/kitty.conf" "$source/fuzzel/fuzzel.ini" "$source/dunst/dunstrc" <<'PY'
import json
import re
import sys
from pathlib import Path

profile, waybar_path, kitty_path, fuzzel_path, dunst_path = sys.argv[1:]
waybar_path, kitty_path, fuzzel_path, dunst_path = map(Path, (waybar_path, kitty_path, fuzzel_path, dunst_path))
cfg = json.loads(waybar_path.read_text())

modules = []
for key in ("modules-left", "modules-center", "modules-right"):
    value = cfg.get(key)
    if not isinstance(value, list):
        raise SystemExit(f"{waybar_path}: missing/invalid {key}")
    if len(value) != len(set(value)):
        raise SystemExit(f"{waybar_path}: duplicate module entry in {key}")
    modules.extend(value)

if cfg["modules-right"].count("tray") != 1:
    raise SystemExit(f"{waybar_path}: tray must occur exactly once")
if len(modules) != len(set(modules)):
    raise SystemExit(f"{waybar_path}: a module is assigned to more than one position")
network = cfg.get("network", {})
if "itsuki-wifi-menu.py" in str(network.get("on-click", "")):
    raise SystemExit(f"{waybar_path}: network indicator should not launch a duplicate Wi-Fi manager by default")

# Make sure every Waybar custom module referenced by the lists has a definition.
for module in modules:
    if module.startswith("custom/") and module not in cfg:
        raise SystemExit(f"{waybar_path}: {module} is listed but not configured")

kitty = kitty_path.read_text()
ansi = re.findall(r"(?m)^color(?:[0-9]|1[0-5])\s+#?[0-9a-fA-F]{6}\s*$", kitty)
if len(ansi) != 16:
    raise SystemExit(f"{kitty_path}: expected all 16 ANSI colors, found {len(ansi)}")

fuzzel = fuzzel_path.read_text()
for setting in ("background=", "text=", "match=", "selection=", "selection-text=", "selection-match=", "border="):
    if setting not in fuzzel:
        raise SystemExit(f"{fuzzel_path}: missing color setting {setting}")

dunst = dunst_path.read_text()
for section in ("[global]", "[urgency_low]", "[urgency_normal]", "[urgency_critical]"):
    if section not in dunst:
        raise SystemExit(f"{dunst_path}: missing section {section}")
if "corner_radius" in dunst and "corners = all" not in dunst:
    raise SystemExit(f"{dunst_path}: corner_radius is set without an explicit corners setting")
PY
    echo 'OK'
done

printf '\n[Waybar] checking icon font fallbacks... '
for style in "$ROOT/configs/waybar/style.css" "$ROOT/configs/arch/waybar/style.css" "$ROOT/configs/gentoo/waybar/style.css"; do
    grep -q 'ForkAwesome' "$style"
    grep -q 'Symbols Nerd Font' "$style"
done
echo 'OK'

printf '[Installer] checking shell syntax... '
for script in "$ROOT/install.sh" "$ROOT/install-lightdm.sh" "$ROOT/variants/neutral/install.sh" "$ROOT/variants/debian/install.sh" "$ROOT/variants/arch/install.sh" "$ROOT/variants/gentoo/install.sh"; do
    bash -n "$script"
done
echo 'OK'

printf '[Python helpers] checking syntax... '
python3 - "$ROOT/scripts/itsuki-wifi-menu.py" "$ROOT/scripts/itsuki-slider.py" "$ROOT/configs/arch/scripts/itsuki-slider.py" "$ROOT/configs/gentoo/scripts/itsuki-slider.py" <<'PY'
import sys
from pathlib import Path
for name in sys.argv[1:]:
    path = Path(name)
    compile(path.read_text(), str(path), "exec")
PY
echo 'OK'

printf '[LightDM] checking profile configs and GTK themes... '
grep -Fxq 'theme-name=Itsuki-Rose' "$ROOT/configs/lightdm/lightdm-gtk-greeter.conf"
grep -Fxq 'theme-name=Itsuki-Rose' "$ROOT/configs/lightdm/lightdm-gtk-greeter-neutral.conf"
grep -Fxq 'theme-name=Itsuki-Arch' "$ROOT/configs/lightdm/lightdm-gtk-greeter-arch.conf"
grep -Fxq 'theme-name=Itsuki-Gentoo' "$ROOT/configs/lightdm/lightdm-gtk-greeter-gentoo.conf"
for theme in Itsuki-Rose Itsuki-Arch Itsuki-Gentoo; do
    [[ -f "$ROOT/lightdm/themes/$theme/gtk-3.0/gtk.css" ]]
    [[ -f "$ROOT/lightdm/themes/$theme/index.theme" ]]
    grep -q 'entry:focus' "$ROOT/lightdm/themes/$theme/gtk-3.0/gtk.css"
done
for conf in "$ROOT/configs/lightdm/lightdm-gtk-greeter.conf" "$ROOT/configs/lightdm/lightdm-gtk-greeter-arch.conf" "$ROOT/configs/lightdm/lightdm-gtk-greeter-gentoo.conf" "$ROOT/configs/lightdm/lightdm-gtk-greeter-neutral.conf"; do
    grep -q '^background=' "$conf"
    grep -q '^theme-name=' "$conf"
done
echo 'OK'

echo
echo 'Static checks passed for Neutral, Debian, Arch, Gentoo, and the LightDM GTK themes.'
