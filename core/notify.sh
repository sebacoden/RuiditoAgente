#!/usr/bin/env bash
# RuiditoAgentes - nucleo de notificacion (macOS / Linux).
#
# Reproduce un sonido (cualquier formato: wav, mp3, ogg, flac, m4a...) y, de
# forma opcional, muestra una notificacion de texto. Pensado para que cualquier
# agente de IA lo ejecute cuando pide permiso o tu atencion.
#
# Configuracion (precedencia: opciones > variables de entorno > config.json > defaults):
#   -m / --message <txt>   texto del aviso   (RUIDITO_MESSAGE)
#   -s / --sound <ruta>    archivo de audio  (RUIDITO_SOUND)
#   --no-sound             no reproducir audio  (RUIDITO_NO_SOUND=1)
#   --no-text              no mostrar texto     (RUIDITO_NO_TEXT=1)

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG="$REPO_ROOT/config.json"

# --- Defaults / opciones por argumento ---
MESSAGE=""; SOUND=""; PLAY_SOUND=1; SHOW_TEXT=1
while [ $# -gt 0 ]; do
    case "$1" in
        -m|--message) MESSAGE="$2"; shift 2 ;;
        -s|--sound)   SOUND="$2";   shift 2 ;;
        --no-sound)   PLAY_SOUND=0; shift ;;
        --no-text)    SHOW_TEXT=0;  shift ;;
        *) shift ;;
    esac
done

# --- Leer config.json (si hay python3) ---
cfg() {
    [ -f "$CONFIG" ] || return 0
    command -v python3 >/dev/null 2>&1 || return 0
    CONFIG="$CONFIG" python3 -c "import json,os,sys;d=json.load(open(os.environ['CONFIG']));v=d.get('$1');print('' if v is None else v)" 2>/dev/null
}

[ -n "$MESSAGE" ] || MESSAGE="${RUIDITO_MESSAGE:-$(cfg message)}"
[ -n "$MESSAGE" ] || MESSAGE="Tu agente necesita tu atencion"
[ -n "$SOUND" ]   || SOUND="${RUIDITO_SOUND:-$(cfg sound)}"
[ -n "$SOUND" ]   || SOUND="$REPO_ROOT/sounds/notify.wav"
# Ruta relativa -> relativa al repo
case "$SOUND" in /*) : ;; *) SOUND="$REPO_ROOT/$SOUND" ;; esac

[ "${RUIDITO_NO_SOUND:-0}" = "1" ] && PLAY_SOUND=0
[ "${RUIDITO_NO_TEXT:-0}"  = "1" ] && SHOW_TEXT=0
[ "$(cfg playSound)" = "False" ] && PLAY_SOUND=0
[ "$(cfg showText)"  = "False" ] && SHOW_TEXT=0

# --- Notificacion de texto ---
show_text() {
    if command -v osascript >/dev/null 2>&1; then        # macOS
        osascript -e "display notification \"$MESSAGE\" with title \"RuiditoAgentes\"" >/dev/null 2>&1
    elif command -v notify-send >/dev/null 2>&1; then     # Linux (libnotify)
        notify-send "RuiditoAgentes" "$MESSAGE" >/dev/null 2>&1
    fi
}

# --- Audio (cualquier formato) ---
play_audio() {
    if [ ! -f "$SOUND" ]; then printf '\a'; return; fi
    if command -v ffplay >/dev/null 2>&1; then            # ffmpeg: reproduce todo
        ffplay -nodisp -autoexit -loglevel quiet "$SOUND"
    elif command -v afplay >/dev/null 2>&1; then          # macOS: wav/mp3/m4a/aac
        afplay "$SOUND"
    elif command -v mpg123 >/dev/null 2>&1 && [[ "$SOUND" == *.mp3 ]]; then
        mpg123 -q "$SOUND"
    elif command -v paplay >/dev/null 2>&1; then          # Linux PulseAudio: wav/ogg/flac
        paplay "$SOUND"
    elif command -v aplay >/dev/null 2>&1; then            # Linux ALSA: wav
        aplay -q "$SOUND"
    else
        printf '\a'
    fi
}

[ "$SHOW_TEXT" = "1" ]  && show_text
[ "$PLAY_SOUND" = "1" ] && play_audio
