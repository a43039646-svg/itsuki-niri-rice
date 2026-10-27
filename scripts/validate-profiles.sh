#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

profiles=(neutral arch debian gentoo)

for profile in "${profiles[@]}"; do
    case "$profile" in
        arch|gentoo) source="$ROOT/configs/$profile" ;;
        debian|neutral) source="$ROOT/configs" ;;
    esac

    printf '[%s] checking config files... ' "$profile"
    for rel in waybar/config waybar/style.css kitty/kitty.conf fuzzel/fuzzel.ini dunst/dunstrc fetch/config xdg-desktop-portal/niri-portals.conf; do
        [[ -f "$source/$rel" ]] || { echo "MISSING: $source/$rel"; exit 1; }
    done

    python3 - "$source/waybar/config" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
cfg = json.loads(path.read_text())

for key in ("modules-left", "modules-center", "modules-right"):
    if key not in cfg or not isinstance(cfg[key], list):
        raise SystemExit(f"{path}: missing/invalid {key}")

if cfg["modules-right"].count("tray") != 1:
    raise SystemExit(f"{path}: tray must occur exactly once")
PY
    echo 'OK'
done

printf '\n[Waybar] checking distro styles... '
for profile in neutral arch gentoo; do
    [[ -f "$ROOT/configs/waybar/style.css" || -f "$ROOT/configs/$profile/waybar/style.css" ]] || exit 1
done
echo 'OK'

echo 'All four profiles passed the static configuration checks.'
