#!/bin/bash
# volume.sh — control de volumen con feedback visual via swaync
# Uso: volume.sh up | down | mute | mic-mute

ACTION="${1:-mute}"

case "$ACTION" in
    up)
        wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+
        ;;
    down)
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
        ;;
    mute)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        ;;
    mic-mute)
        wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
        RAW=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@)
        MUTED=$(echo "$RAW" | grep -q MUTED && echo "1" || echo "0")
        if [ "$MUTED" = "1" ]; then
            notify-send -h string:x-canonical-private-synchronous:micvolume \
                -t 1500 "🎙️ Micro" "Silenciado"
        else
            notify-send -h string:x-canonical-private-synchronous:micvolume \
                -t 1500 "🎙️ Micro" "Activo"
        fi
        exit 0
        ;;
esac

# Leer estado del sink principal
RAW=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
VOL=$(echo "$RAW" | awk '{printf "%d", $2 * 100}')
MUTED=$(echo "$RAW" | grep -q MUTED && echo "1" || echo "0")

if [ "$MUTED" = "1" ]; then
    ICON="󰝟"
    TITULO="Silenciado"
    BARRA="░░░░░░░░░░"
else
    # Elegir icono según nivel
    if   [ "$VOL" -ge 66 ]; then ICON="󰕾"
    elif [ "$VOL" -ge 33 ]; then ICON="󰖀"
    else                         ICON="󰕿"
    fi
    TITULO="Volumen  ${VOL}%"
    # Barra de 10 bloques
    LLENOS=$(( VOL / 10 ))
    BARRA=""
    for i in $(seq 1 10); do
        if [ "$i" -le "$LLENOS" ]; then BARRA="${BARRA}█"
        else                            BARRA="${BARRA}░"
        fi
    done
fi

notify-send \
    -h string:x-canonical-private-synchronous:volume \
    -t 1500 \
    "$ICON $TITULO" \
    "$BARRA"
