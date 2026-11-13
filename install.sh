#!/usr/bin/env bash
# Point Ghostty at a light/dark theme pair so it follows the system appearance.
set -euo pipefail

LIGHT="${GHOSTTY_LIGHT_THEME:-Builtin Light}"
DARK="${GHOSTTY_DARK_THEME:-Builtin Dark}"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty/config.ghostty"

if ! command -v ghostty >/dev/null 2>&1; then
  echo "ghostty not found in PATH" >&2
  exit 1
fi

mkdir -p "$(dirname "$CONFIG")"
[ -e "$CONFIG" ] || : > "$CONFIG"
if [ ! -e "$CONFIG.bak" ] && [ ! -L "$CONFIG.bak" ]; then
  cp -- "$CONFIG" "$CONFIG.bak"
fi

LIGHT="$LIGHT" DARK="$DARK" CONFIG="$CONFIG" python3 - <<'PY'
import os
import re

path = os.environ["CONFIG"]
line = "theme = light:{},dark:{}".format(os.environ["LIGHT"], os.environ["DARK"])

with open(path, encoding="utf-8") as fh:
    text = fh.read()

new, hits = re.subn(r"(?m)^[ \t]*theme[ \t]*=.*$", lambda _: line, text)
if hits == 0:
    if text and not text.endswith("\n"):
        text += "\n"
    new = text + line + "\n"

with open(path, "w", encoding="utf-8") as fh:
    fh.write(new)

print(line)
PY

ghostty +validate-config
echo "wrote $CONFIG (original backup preserved: $CONFIG.bak)"
echo "running windows: reload with Ctrl+Shift+, or open a new window"
