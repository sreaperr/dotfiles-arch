#!/bin/bash
#
# spotify-ctl.sh — Controlador de acciones de Spotify para Waybar
# Uso: spotify-ctl.sh <play-pause|previous|next|open>
#

action=${1:-play-pause}
player=$(playerctl -l 2>/dev/null | grep -i spotify | head -1)

if [ -z "$player" ]; then
    [ "$action" = "open" ] && spotify & disown
    exit 0
fi

playerctl -p "$player" "$action" 2>/dev/null
