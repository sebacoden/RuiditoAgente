#!/usr/bin/env bash
# Imprime el comando de RuiditoAgentes para pegar en cualquier agente (macOS/Linux).
# No modifica nada: solo muestra el comando exacto a configurar en tu agente.

set -euo pipefail

MESSAGE="${1:-Tu agente necesita tu atencion}"
ADAPTER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$ADAPTER_DIR/../.." && pwd)"
NOTIFY="$REPO_DIR/core/notify.sh"

chmod +x "$NOTIFY" 2>/dev/null || true

echo "Configura este comando en el evento de notificacion de tu agente:"
echo
echo "  bash \"$NOTIFY\" --message \"$MESSAGE\""
echo
echo "Consejos:"
echo "  - Cambia el sonido reemplazando $REPO_DIR/sounds/notify.wav (cualquier formato) o via config.json."
echo "  - Para fusionarlo automaticamente en un settings.json/toml/yaml, usa lib/merge-config.py."
