#!/bin/bash
#==========================
# SCRIPT DE GRABACIÓN DE PANTALLA
#==========================

VIDEOS_DIR="$HOME/Vídeos/grabaciones"
mkdir -p "$VIDEOS_DIR"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT="$VIDEOS_DIR/grabacion_$TIMESTAMP.mp4"
PIDFILE="${XDG_RUNTIME_DIR:-$HOME/.cache}/wf-recorder.pid"

if pgrep -x wf-recorder > /dev/null; then
    # Si ya está grabando, detener
    pkill wf-recorder
    rm -f "$PIDFILE"
    notify-send "Grabación detenida" "Guardada en $VIDEOS_DIR" -i video-x-generic
else
    # Preguntar modo con rofi
    MODOS="󰍹  Pantalla completa\n  Seleccionar región"
    MODO=$(printf '%b' "$MODOS" | rofi -dmenu \
        -p "  Grabar" \
        -theme ~/.config/rofi/selector.rasi \
        -no-custom)

    [ -z "$MODO" ] && exit 0

    notify-send "Grabando..." "Pulsa SUPER+R para detener" -i video-x-generic

    case "$MODO" in
        *"Pantalla completa"*)
            wf-recorder -f "$OUTPUT" &
            ;;
        *"Seleccionar región"*)
            REGION=$(slurp)
            [ -z "$REGION" ] && exit 0
            wf-recorder -g "$REGION" -f "$OUTPUT" &
            ;;
    esac

    echo $! > "$PIDFILE"
fi
