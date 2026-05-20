#!/bin/bash
mouse_x=$(hyprctl cursorpos 2>/dev/null | awk -F',' '{print int($1)}')
[ -z "$mouse_x" ] && mouse_x=960
x_offset=$((mouse_x - 150))
[ $x_offset -lt 0 ] && x_offset=0

player=$(playerctl -l 2>/dev/null | grep -i spotify | head -1)

if [ -z "$player" ]; then
    notify-send "Spotify" "Abriendo Spotify..." -i spotify
    spotify &
    exit 0
fi

st=$(playerctl -p "$player" status 2>/dev/null)
title=$(playerctl -p "$player" metadata title 2>/dev/null)
artist=$(playerctl -p "$player" metadata artist 2>/dev/null)
[ -n "$artist" ] && mesg="$title  —  $artist" || mesg="${title:-Sin reproducción activa}"
[ "$st" = "Playing" ] && toggle="⏸  Pausar" || toggle="▶  Reproducir"

selected=$(printf '%s\n' "⏮  Anterior" "$toggle" "⏭  Siguiente" | \
    rofi -dmenu \
    -p "󰓇  Spotify" \
    -mesg "$mesg" \
    -no-show-icons \
    -theme ~/.config/rofi/dropdown-right.rasi \
    -theme-str "window { x-offset: ${x_offset}px; y-offset: 0px; location: northwest; anchor: northwest; }")

[ -z "$selected" ] && exit 0

case "$selected" in
    "⏮  Anterior")   playerctl -p "$player" previous ;;
    "▶  Reproducir")  playerctl -p "$player" play ;;
    "⏸  Pausar")      playerctl -p "$player" pause ;;
    "⏭  Siguiente")  playerctl -p "$player" next ;;
esac
