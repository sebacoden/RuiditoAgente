#!/usr/bin/env bash
# RuiditoAgentes - instala el hook de notificacion en Claude Code (macOS / Linux).
#
# Agrega un hook "Notification" a ~/.claude/settings.json que reproduce un
# sonido (y muestra un aviso de texto) cuando Claude Code pide permiso o tu atencion.
# Fusiona la configuracion: respeta cualquier otro hook que ya tengas.

set -euo pipefail

ADAPTER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$ADAPTER_DIR/../.." && pwd)"
NOTIFY_SCRIPT="$REPO_DIR/core/notify.sh"
SETTINGS_PATH="${1:-$HOME/.claude/settings.json}"
COMMAND="bash \"$NOTIFY_SCRIPT\" --message \"Claude Code necesita tu atencion\""

chmod +x "$NOTIFY_SCRIPT"

echo "Instalando hook de RuiditoAgentes en Claude Code..."
echo "  Nucleo:        $NOTIFY_SCRIPT"
echo "  settings.json: $SETTINGS_PATH"

if ! command -v python3 >/dev/null 2>&1; then
    echo "Error: se requiere python3 para fusionar settings.json de forma segura." >&2
    exit 1
fi

mkdir -p "$(dirname "$SETTINGS_PATH")"

# Backup si ya existe
if [ -f "$SETTINGS_PATH" ]; then
    cp "$SETTINGS_PATH" "$SETTINGS_PATH.bak"
    echo "  Backup creado:    $SETTINGS_PATH.bak"
fi

SETTINGS_PATH="$SETTINGS_PATH" COMMAND="$COMMAND" python3 <<'PY'
import json, os

path = os.environ["SETTINGS_PATH"]
command = os.environ["COMMAND"]

try:
    with open(path) as f:
        content = f.read().strip()
    settings = json.loads(content) if content else {}
except FileNotFoundError:
    settings = {}

hooks = settings.setdefault("hooks", {})
notification = hooks.setdefault("Notification", [])

# Quitar entradas previas de este proyecto (evita duplicados)
def is_ours(entry):
    return any("core/notify.sh" in h.get("command", "")
               for h in entry.get("hooks", []))

notification = [e for e in notification if not is_ours(e)]
notification.append({
    "matcher": "",
    "hooks": [{"type": "command", "command": command}],
})
hooks["Notification"] = notification

with open(path, "w") as f:
    json.dump(settings, f, indent=2)
    f.write("\n")
PY

echo ""
echo "Listo. Reinicia Claude Code para que tome el cambio."
echo "Para cambiar el sonido, reemplaza: $REPO_DIR/sounds/notify.wav (o usa config.json)"
