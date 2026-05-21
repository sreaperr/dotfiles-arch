#!/bin/bash
#==========================
# MENÚ DE SPOTIFY CON PLAYERCTL
#==========================

# Posición horizontal del menú según el cursor
mouse_x=$(hyprctl cursorpos 2>/dev/null | awk -F',' '{print int($1)}')
[ -z "$mouse_x" ] && mouse_x=960
x_offset=$((mouse_x - 170))
[ $x_offset -lt 0 ] && x_offset=0

# Detectar instancia de Spotify activa
player=$(playerctl -l 2>/dev/null | grep -i spotify | head -1)

if [ -z "$player" ]; then
    notify-send "Spotify" "Abriendo Spotify..." -i spotify
    spotify &
    exit 0
fi

# --- METADATA ---
status=$(playerctl -p "$player" status 2>/dev/null)
title=$(playerctl -p "$player" metadata title 2>/dev/null | cut -c1-38)
artist=$(playerctl -p "$player" metadata artist 2>/dev/null | cut -c1-30)
album=$(playerctl -p "$player" metadata album 2>/dev/null | cut -c1-35)
shuffle=$(playerctl -p "$player" shuffle 2>/dev/null)
loop=$(playerctl -p "$player" loop 2>/dev/null)

# --- CABECERA: canción y álbum ---
[ -n "$artist" ] && header="${title}  —  ${artist}" || header="${title:-Sin reproducción activa}"
[ -n "$album" ] && header="${header}"$'\n'"󰀥  ${album}"

# --- ETIQUETAS DE OPCIONES ---
[ "$status" = "Playing" ] && toggle="⏸  Pausar" || toggle="▶  Reproducir"

[ "$shuffle" = "On" ] \
    && shuffle_label="󰒝  Shuffle: Activado" \
    || shuffle_label="󰒞  Shuffle: Desactivado"

case "$loop" in
    "Track")    loop_label="󰕠  Repeat: Canción" ;;
    "Playlist") loop_label="󰑖  Repeat: Lista" ;;
    *)          loop_label="󰑗  Repeat: Desactivado" ;;
esac

# --- MENÚ ---
selected=$(printf '%s\n' \
    "⏮  Anterior" \
    "$toggle" \
    "⏭  Siguiente" \
    "$shuffle_label" \
    "$loop_label" | \
    rofi -dmenu \
    -p "󰓇  Spotify" \
    -mesg "$header" \
    -no-show-icons \
    -theme ~/.config/rofi/dropdown-right.rasi \
    -theme-str "window { x-offset: ${x_offset}px; y-offset: 0px; location: northwest; anchor: northwest; }")

[ -z "$selected" ] && exit 0

# --- ACCIONES ---
case "$selected" in
    "⏮  Anterior")     playerctl -p "$player" previous ;;
    "▶  Reproducir")    playerctl -p "$player" play ;;
    "⏸  Pausar")       playerctl -p "$player" pause ;;
    "⏭  Siguiente")    playerctl -p "$player" next ;;
    *"Shuffle"*)
        [ "$shuffle" = "On" ] \
            && playerctl -p "$player" shuffle Off \
            || playerctl -p "$player" shuffle On
        ;;
    *"Repeat"*)
        case "$loop" in
            "None")     playerctl -p "$player" loop Track ;;
            "Track")    playerctl -p "$player" loop Playlist ;;
            "Playlist") playerctl -p "$player" loop None ;;
        esac
        ;;
esac
