#!/bin/bash
swww-daemon &

# Esperar a que el daemon esté listo
until swww query &>/dev/null; do
    sleep 0.2
done

WALLPAPER=$(cat ~/.config/.current-wallpaper 2>/dev/null)

if [ -z "$WALLPAPER" ] || [ ! -f "$WALLPAPER" ]; then
    WALLPAPER="$HOME/.config/.wallpaper/wallpaper_pc.png"
fi

swww img "$WALLPAPER" --transition-type fade --transition-duration 1
