#!/bin/bash
# set-wallpaper — aplica un fondo y guarda la ruta como activa
WALL="${1:-}"
[[ -z "$WALL" ]] && { echo "Uso: set-wallpaper <ruta>"; exit 1; }
WALL="$(realpath "$WALL")"
[[ ! -f "$WALL" ]] && { echo "Archivo no encontrado: $WALL"; exit 1; }

if ! command -v awww &>/dev/null; then
    notify-send "Wallpaper" "awww no instalado" 2>/dev/null
    exit 1
fi

awww img "$WALL" --transition-type fade --transition-duration 1
echo "$WALL" > "$HOME/.config/.current-wallpaper"
