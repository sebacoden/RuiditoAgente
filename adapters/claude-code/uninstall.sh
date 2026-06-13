#!/usr/bin/env bash
# Quita el hook de sonido de notificacion de Claude Code (macOS / Linux).

set -euo pipefail

SETTINGS_PATH="${1:-$HOME/.claude/settings.json}"

if [ ! -f "$SETTINGS_PATH" ]; then
    echo "No se encontro $SETTINGS_PATH. Nada que quitar."
    exit 0
fi

SETTINGS_PATH="$SETTINGS_PATH" python3 <<'PY'
import json, os

path = os.environ["SETTINGS_PATH"]
with open(path) as f:
    settings = json.load(f)

hooks = settings.get("hooks", {})
notification = hooks.get("Notification", [])

def is_ours(entry):
    return any("core/notify.sh" in h.get("command", "")
               for h in entry.get("hooks", []))

filtered = [e for e in notification if not is_ours(e)]
if filtered:
    hooks["Notification"] = filtered
elif "Notification" in hooks:
    del hooks["Notification"]

with open(path, "w") as f:
    json.dump(settings, f, indent=2)
    f.write("\n")
print("Hook de sonido quitado. Reinicia Claude Code.")
PY
