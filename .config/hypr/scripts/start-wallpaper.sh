#!/bin/bash
if ! command -v awww &>/dev/null; then
    notify-send "Wallpaper" "awww no instalado. Instala con: paru -S awww" 2>/dev/null
    exit 1
fi

awww-daemon &

# Esperar a que el daemon esté listo (máx 5 segundos)
TRIES=0
until awww query &>/dev/null; do
    sleep 0.2
    TRIES=$((TRIES + 1))
    [ $TRIES -ge 25 ] && exit 1
done

WALLPAPER=$(cat ~/.config/.current-wallpaper 2>/dev/null)

if [ -z "$WALLPAPER" ] || [ ! -f "$WALLPAPER" ]; then
    WALLPAPER="$HOME/.config/.wallpaper/retro.webp"
fi

# Aplicar fondo en todos los monitores conectados
awww img "$WALLPAPER" --transition-type fade --transition-duration 1

# Dar tiempo a kanshi para posicionar los monitores y cubrir los que se añadan después
(sleep 3 && awww img "$WALLPAPER" --transition-type none) &
