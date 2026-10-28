#!/usr/bin/env python3
"""Enable Kitty transparency and Niri 26.04+ background blur for Itsuki Rice."""
from __future__ import annotations

from datetime import datetime
from pathlib import Path
import re
import shutil
import subprocess
import sys

CONFIG_HOME = Path.home() / ".config"
NIRI_CONFIG = Path(sys.argv[1]).expanduser() if len(sys.argv) > 1 else CONFIG_HOME / "niri/config.kdl"
KITTY_CONFIG = Path(sys.argv[2]).expanduser() if len(sys.argv) > 2 else CONFIG_HOME / "kitty/kitty.conf"
STAMP = datetime.now().strftime("%Y%m%d-%H%M%S")

if not NIRI_CONFIG.is_file():
    raise SystemExit(f"Niri config not found: {NIRI_CONFIG}")

def get_niri_version() -> tuple[int, int] | None:
    try:
        proc = subprocess.run(["niri", "--version"], text=True, capture_output=True, check=False)
    except FileNotFoundError:
        return None
    text = (proc.stdout + "\n" + proc.stderr).strip()
    match = re.search(r"\bniri\s+(\d+)\.(\d+)", text, re.IGNORECASE)
    if not match:
        match = re.search(r"\b(\d+)\.(\d+)", text)
    if not match:
        return None
    return int(match.group(1)), int(match.group(2))

def closing_brace(source: str, opening: int) -> int:
    """Return the matching close brace while ignoring strings and KDL comments."""
    depth = 0
    i = opening
    in_string = False
    escaped = False
    in_line_comment = False
    in_block_comment = False
    while i < len(source):
        ch = source[i]
        nxt = source[i + 1] if i + 1 < len(source) else ""
        if in_line_comment:
            if ch == "\n":
                in_line_comment = False
            i += 1
            continue
        if in_block_comment:
            if ch == "*" and nxt == "/":
                in_block_comment = False
                i += 2
            else:
                i += 1
            continue
        if in_string:
            if escaped:
                escaped = False
            elif ch == "\\":
                escaped = True
            elif ch == '"':
                in_string = False
            i += 1
            continue
        if ch == "/" and nxt == "/":
            in_line_comment = True
            i += 2
            continue
        if ch == "/" and nxt == "*":
            in_block_comment = True
            i += 2
            continue
        if ch == '"':
            in_string = True
        elif ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth == 0:
                return i
        i += 1
    raise ValueError("Unmatched brace in Niri config")

def patch_settings_block(block: str, values: dict[str, str]) -> str:
    block = re.sub(r"(?m)^[ \t]*off[ \t]*(?:\n|$)", "", block)
    for key, value in values.items():
        pattern = re.compile(rf"(?m)^([ \t]*){re.escape(key)}[ \t]+[^\n]*$")
        if pattern.search(block):
            block = pattern.sub(lambda m, v=value, k=key: f"{m.group(1)}{k} {v}", block, count=1)
        else:
            close = block.rfind("}")
            if close < 0:
                raise ValueError(f"Can't add {key}: malformed block")
            block = block[:close].rstrip() + f"\n    {key} {value}\n" + block[close:]
    return block

def patch_global_blur(text: str) -> str:
    hits = list(re.finditer(r"(?m)^([ \t]*)blur[ \t]*\{[ \t]*$", text))
    if len(hits) > 1:
        raise ValueError("More than one active global blur block found; leaving config unchanged.")
    values = {"passes": "3", "offset": "5.0", "noise": "0.02", "saturation": "0.9"}
    if not hits:
        return text.rstrip() + """

// ITSUKI_GLOBAL_BLUR
blur {
    passes 3
    offset 5.0
    noise 0.02
    saturation 0.9
}
"""
    hit = hits[0]
    opening = text.find("{", hit.start())
    end = closing_brace(text, opening)
    block = text[hit.start():end + 1]
    block = patch_settings_block(block, values)
    return text[:hit.start()] + block + text[end + 1:]

def patch_prefer_no_csd(text: str) -> str:
    if re.search(r"(?m)^[ \t]*prefer-no-csd(?:[ \t]*(?://.*)?)?$", text):
        return text
    return text.rstrip() + "\n\n// Helps avoid tinted borders behind transparent windows.\nprefer-no-csd\n"

def patch_kitty_rule(text: str) -> str:
    begin = "// ITSUKI_KITTY_BLUR_BEGIN"
    end_marker = "// ITSUKI_KITTY_BLUR_END"
    block = """// ITSUKI_KITTY_BLUR_BEGIN
window-rule {
    match app-id="^kitty$"
    background-effect {
        blur true
        xray true
        noise 0.02
        saturation 0.9
    }
}
// ITSUKI_KITTY_BLUR_END"""
    if begin in text and end_marker in text:
        start = text.index(begin)
        end = text.index(end_marker, start) + len(end_marker)
        return text[:start] + block + text[end:]
    return text.rstrip() + "\n\n" + block + "\n"

def patch_kitty_config(path: Path) -> str | None:
    existed = path.is_file()
    current = path.read_text() if existed else ""
    pattern = re.compile(r"(?m)^[ \t]*background_opacity[ \t]+\S+[ \t]*$")
    matches = list(pattern.finditer(current))
    if len(matches) > 1:
        raise ValueError(f"Multiple background_opacity settings in {path}; not changing it.")
    if matches:
        current = pattern.sub("background_opacity 0.68", current, count=1)
    else:
        current = current.rstrip() + "\n\n# Itsuki Rice: Kitty transparency for Niri blur\nbackground_opacity 0.68\n"
    return current

niri_text = NIRI_CONFIG.read_text()
version = get_niri_version()
supports_blur = version is not None and version >= (26, 4)

if supports_blur:
    updated_niri = patch_prefer_no_csd(niri_text)
    updated_niri = patch_global_blur(updated_niri)
    updated_niri = patch_kitty_rule(updated_niri)
else:
    updated_niri = niri_text

updated_kitty = patch_kitty_config(KITTY_CONFIG)

# Back up both files immediately before changing them.
niri_backup = NIRI_CONFIG.with_name(NIRI_CONFIG.name + f".bak-itsuki-blur-{STAMP}")
kitty_backup = KITTY_CONFIG.with_name(KITTY_CONFIG.name + f".bak-itsuki-blur-{STAMP}")
shutil.copy2(NIRI_CONFIG, niri_backup)
if KITTY_CONFIG.exists():
    shutil.copy2(KITTY_CONFIG, kitty_backup)
else:
    KITTY_CONFIG.parent.mkdir(parents=True, exist_ok=True)

NIRI_CONFIG.write_text(updated_niri)
KITTY_CONFIG.write_text(updated_kitty)

# If using the default active Niri config, validate and roll back if it fails.
default_niri = (CONFIG_HOME / "niri/config.kdl").resolve()
if NIRI_CONFIG.resolve() == default_niri and shutil.which("niri"):
    result = subprocess.run(["niri", "validate"], text=True, capture_output=True, check=False)
    if result.returncode != 0:
        shutil.copy2(niri_backup, NIRI_CONFIG)
        if kitty_backup.exists():
            shutil.copy2(kitty_backup, KITTY_CONFIG)
        elif KITTY_CONFIG.exists():
            KITTY_CONFIG.unlink()
        print(result.stdout, end="")
        print(result.stderr, end="", file=sys.stderr)
        raise SystemExit("Niri validation failed; original config files restored.")

if supports_blur:
    print(f"Niri {version[0]}.{version[1]}: global blur and Kitty window rule installed.")
else:
    shown = f"{version[0]}.{version[1]}" if version else "unknown"
    print(f"Niri version {shown} is below 26.04 or could not be detected.")
    print("Only Kitty transparency was set; Niri window blur requires Niri 26.04+.")

print(f"Kitty background_opacity set to 0.68: {KITTY_CONFIG}")
print(f"Backups: {niri_backup}" + (f", {kitty_backup}" if kitty_backup.exists() else ""))
print("Restart Kitty after this change. Restart the Niri session after enabling prefer-no-csd for all app decorations.")
