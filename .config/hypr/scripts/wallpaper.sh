#!/bin/bash
#==========================
# SCRIPT DE CAMBIO DE FONDO
#==========================

WALLPAPER_DIR="$HOME/.config/.wallpaper"

if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "Wallpaper" "Directorio no encontrado: $WALLPAPER_DIR" -i dialog-error
    exit 1
fi

# Listar imágenes disponibles
SELECTED=$(ls "$WALLPAPER_DIR" | rofi -dmenu \
    -p "  Fondo" \
    -theme ~/.config/rofi/theme.rasi \
    -theme-str 'window { location: center; anchor: center; width: 220px; }' \
    -i -no-custom)

# Salir si no se seleccionó nada
[ -z "$SELECTED" ] && exit 0

WALLPAPER="$WALLPAPER_DIR/$SELECTED"

if [ ! -f "$WALLPAPER" ]; then
    notify-send "Wallpaper" "Archivo no encontrado: $SELECTED" -i dialog-error
    exit 1
fi

# Transiciones disponibles
TRANSITIONS=(fade wipe slide grow outer)
TRANSITION=${TRANSITIONS[$RANDOM % ${#TRANSITIONS[@]}]}

# Aplicar fondo con awww
awww img "$WALLPAPER" \
    --transition-type "$TRANSITION" \
    --transition-duration 1.5 \
    --transition-fps 60

# Guardar fondo activo
echo "$WALLPAPER" > "$HOME/.config/.current-wallpaper"

# Notificación
notify-send "Fondo aplicado" "$SELECTED" -i "$WALLPAPER"
