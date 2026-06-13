#!/usr/bin/env bash
# RuiditoAgentes - prueba la notificacion (macOS / Linux).
#
# Dispara la notificacion (sonido + texto) para comprobar que todo funciona,
# sin necesidad de un agente. Acepta los mismos parametros que core/notify.sh.
#
# Ejemplos:
#   bash test-notification.sh
#   bash test-notification.sh --sound sounds/otro.mp3
#   bash test-notification.sh --no-text          # solo sonido

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NOTIFY="$SCRIPT_DIR/core/notify.sh"

# Mensaje por defecto si el usuario no pasa --message
case " $* " in
    *" -m "*|*" --message "*) ARGS=("$@") ;;
    *) ARGS=(--message "Notificacion de prueba de RuiditoAgentes" "$@") ;;
esac

echo "Probando notificacion de RuiditoAgentes..."
echo "  Deberias escuchar un sonido y ver un aviso de texto."

chmod +x "$NOTIFY" 2>/dev/null || true
bash "$NOTIFY" "${ARGS[@]}"

echo
echo "Si lo escuchaste/viste, funciona. Si no:"
echo "  - Subi el volumen y revisa que el archivo de sonido exista."
echo "  - En Linux instala 'ffmpeg'/'pulseaudio-utils' (sonido) y 'libnotify-bin' (texto)."
echo "  - Consulta la seccion 'Solucion de problemas' del README."
