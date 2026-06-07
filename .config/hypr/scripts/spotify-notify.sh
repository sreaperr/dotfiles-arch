#!/bin/bash
#==========================
# SPOTIFY NOTIFY — notifica al cambiar canción via SwayNC
# Lanzado por exec-once en hyprland.conf
#==========================

ART_CACHE="/tmp/spotify-art.jpg"
PREV_TITLE=""

wait_for_spotify() {
    while ! playerctl -l 2>/dev/null | grep -qi spotify; do
        sleep 5
    done
}

notify_track() {
    local status="$1" title="$2" artist="$3" arturl="$4"

    # Ignorar si es pausa o si la canción no cambió
    [ "$status" != "Playing" ] && return
    [ "$title" = "$PREV_TITLE" ] && return
    PREV_TITLE="$title"

    # Descargar portada del álbum si hay URL
    local icon="spotify"
    if [ -n "$arturl" ]; then
        if curl -sf "$arturl" -o "$ART_CACHE" 2>/dev/null; then
            icon="$ART_CACHE"
        fi
    fi

    notify-send \
        --app-name "Spotify" \
        --icon "$icon" \
        --expire-time 5000 \
        --urgency low \
        "$title" \
        "$artist"
}

# Bucle principal: espera a Spotify y escucha cambios
while true; do
    wait_for_spotify

    playerctl --player=spotify --follow metadata \
        --format '{{status}}	{{title}}	{{artist}}	{{mpris:artUrl}}' 2>/dev/null | \
    while IFS=$'\t' read -r status title artist arturl; do
        notify_track "$status" "$title" "$artist" "$arturl"
    done

    # Si playerctl termina (Spotify cerrado), espera antes de reintentar
    sleep 10
done
