#!/bin/bash
if ! command -v swww &>/dev/null; then
    notify-send "Wallpaper" "swww no instalado. Instala con: sudo pacman -S swww" 2>/dev/null
    exit 1
fi

swww-daemon &

# Esperar a que el daemon esté listo (máx 5 segundos)
TRIES=0
until swww query &>/dev/null; do
    sleep 0.2
    TRIES=$((TRIES + 1))
    [ $TRIES -ge 25 ] && exit 1
done

WALLPAPER=$(cat ~/.config/.current-wallpaper 2>/dev/null)

if [ -z "$WALLPAPER" ] || [ ! -f "$WALLPAPER" ]; then
    WALLPAPER="$HOME/.config/.wallpaper/wallpaper_pc.png"
fi

swww img "$WALLPAPER" --transition-type fade --transition-duration 1
