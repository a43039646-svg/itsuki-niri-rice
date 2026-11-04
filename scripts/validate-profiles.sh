#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG="$ROOT/configs"

printf '[Files] checking the universal Itsuki profile and wallpaper... '
for rel in waybar/config waybar/style.css kitty/kitty.conf fuzzel/fuzzel.ini dunst/dunstrc fetch/config xdg-desktop-portal/niri-portals.conf; do
  [[ -f "$CONFIG/$rel" ]] || { echo "MISSING: $CONFIG/$rel"; exit 1; }
done
[[ -f "$ROOT/wallpapers/itsuki.png" ]] || { echo "MISSING: $ROOT/wallpapers/itsuki.png"; exit 1; }
[[ -f "$ROOT/wallpapers/lightdm-itsuki.png" ]] || { echo "MISSING: $ROOT/wallpapers/lightdm-itsuki.png"; exit 1; }
[[ -f "$ROOT/scripts/install-lightdm-wallpaper.sh" ]] || { echo "MISSING: LightDM wallpaper helper"; exit 1; }
echo OK

printf '[Waybar] checking JSON and module layout... '
python3 - "$CONFIG/waybar/config" <<'PY'
import json, sys
from pathlib import Path
path = Path(sys.argv[1])
cfg = json.loads(path.read_text())
modules = []
for key in ("modules-left", "modules-center", "modules-right"):
    value = cfg.get(key)
    if not isinstance(value, list):
        raise SystemExit(f"Invalid or missing {key}")
    if len(value) != len(set(value)):
        raise SystemExit(f"Duplicate module in {key}")
    modules.extend(value)
if len(modules) != len(set(modules)):
    raise SystemExit("A Waybar module appears in more than one position")
if cfg.get("modules-right", []).count("tray") != 1:
    raise SystemExit("Tray must appear exactly once")
if "clock" not in cfg.get("modules-center", []):
    raise SystemExit("Clock must be centered")
if "niri/workspaces" not in cfg.get("modules-left", []):
    raise SystemExit("Niri workspaces module is missing")
for module in modules:
    if module.startswith("custom/") and module not in cfg:
        raise SystemExit(f"Missing definition for {module}")
print("OK")
PY

printf '[Shell] checking installer and helper syntax... '
for script in "$ROOT/install.sh" "$ROOT/scripts/itsuki-reload-rice" "$ROOT/scripts/niri-power-menu" "$ROOT/scripts/install-lightdm-wallpaper.sh"; do
  bash -n "$script"
done
grep -q 'WALLPAPER_SOURCE="$ROOT/wallpapers/itsuki.png"' "$ROOT/install.sh"
grep -q 'swaybg is required to set the Niri wallpaper' "$ROOT/install.sh"
grep -q 'BEGIN ITSUKI RICE STARTUP' "$ROOT/install.sh"
grep -q 'install-lightdm-wallpaper.sh' "$ROOT/install.sh"
echo OK

printf '[Python] checking helper syntax... '
python3 - "$ROOT/scripts/itsuki-wifi-menu.py" "$ROOT/scripts/itsuki-slider.py" "$ROOT/scripts/enable-kitty-blur.py" <<'PY'
import sys
from pathlib import Path
for filename in sys.argv[1:]:
    path = Path(filename)
    compile(path.read_text(), str(path), "exec")
PY
echo OK

grep -q 'border-bottom: 1px solid' "$CONFIG/waybar/style.css"
grep -q 'Itsuki Minimal Rail' "$CONFIG/waybar/style.css"
echo "All universal Itsuki Niri Rice checks passed."
