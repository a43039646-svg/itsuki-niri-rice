#!/usr/bin/env bash
set -euo pipefail

BASE_URL="https://raw.githubusercontent.com/a43039646-svg/itsuki-niri-rice/main"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
CONFIG="${NIRI_CONFIG:-$CONFIG_HOME/niri/config.kdl}"
BIN_DIR="$HOME/.local/bin"
RELOAD_HELPER="$BIN_DIR/itsuki-reload-rice"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$CONFIG.backup-$STAMP"

if [[ ! -f "$CONFIG" ]]; then
  echo "Niri config not found: $CONFIG" >&2
  exit 1
fi
for tool in curl python3 niri; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "Required command not found: $tool" >&2
    exit 1
  fi
done

mkdir -p "$BIN_DIR"
TMP_HELPER="$RELOAD_HELPER.tmp"
curl -fsSL "$BASE_URL/scripts/itsuki-reload-rice" -o "$TMP_HELPER"
chmod 755 "$TMP_HELPER"
mv "$TMP_HELPER" "$RELOAD_HELPER"

cp -a "$CONFIG" "$BACKUP"
python3 - "$CONFIG" "$RELOAD_HELPER" <<'PY'
from pathlib import Path
import re
import sys

config_path = Path(sys.argv[1])
helper_path = str(Path(sys.argv[2])).replace("\\", "\\\\").replace('"', '\\"')
text = config_path.read_text()

# Replace only the Win/Super + Shift + B binding. Leave every other binding intact.
pattern = re.compile(r'(?m)^[ \t]*(?:Mod|Super)\+Shift\+B\b[^\n]*(?:\n|$)')
binding = (
    f'    Super+Shift+B hotkey-overlay-title="Reload Niri and Itsuki Rice services" '
    f'{{ spawn "{helper_path}"; }}\n'
)
matches = len(pattern.findall(text))
if matches:
    text = pattern.sub(binding, text)
else:
    block = re.search(r'(?m)^(?P<indent>[ \t]*)binds\s*\{', text)
    if not block:
        raise SystemExit(f"No top-level binds block found in {config_path}; nothing changed.")
    text = text[:block.end()] + "\n" + binding + text[block.end():]

config_path.write_text(text)
print(f"Updated Win+Shift+B (replaced {matches} existing binding(s)).")
PY

if ! NIRI_CONFIG="$CONFIG" niri validate; then
  cp -a "$BACKUP" "$CONFIG"
  echo "Niri validation failed; restored original config from $BACKUP" >&2
  exit 1
fi

echo "Done. Backup: $BACKUP"
echo "Win+Shift+B now reloads Niri config and restarts Waybar, Dunst and swaybg."
echo "Logs: ${XDG_CACHE_HOME:-$HOME/.cache}/itsuki-niri-rice/reload.log"
