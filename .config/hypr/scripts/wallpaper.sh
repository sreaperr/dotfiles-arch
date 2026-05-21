#!/bin/bash
#==========================
# SELECTOR DE FONDO CON PREVIEW
# Muestra miniaturas reales de los wallpapers en rofi
#==========================

WALLPAPER_DIR="$HOME/.config/.wallpaper"

if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "Wallpaper" "Directorio no encontrado: $WALLPAPER_DIR" -i dialog-error
    exit 1
fi

# Generar lista con icono de preview para cada imagen
# Formato rofi: "nombre\0icon\x1f/ruta/completa"
ENTRIES=$(for f in "$WALLPAPER_DIR"/*.{jpg,jpeg,png,gif,webp} 2>/dev/null; do
    [ -f "$f" ] && printf "%s\x00icon\x1f%s\n" "$(basename "$f")" "$f"
done)

[ -z "$ENTRIES" ] && { notify-send "Wallpaper" "No hay imágenes en $WALLPAPER_DIR"; exit 1; }

SELECTED=$(echo -e "$ENTRIES" | rofi -dmenu \
    -p "  Fondo" \
    -theme ~/.config/rofi/theme.rasi \
    -theme-str 'window { location: center; anchor: center; width: 400px; } element-icon { size: 44px; } listview { lines: 6; }' \
    -show-icons \
    -i -no-custom)

[ -z "$SELECTED" ] && exit 0

# Extraer solo el nombre de archivo (rofi devuelve el texto sin los metadatos de icono)
WALLPAPER="$WALLPAPER_DIR/$SELECTED"

if [ ! -f "$WALLPAPER" ]; then
    notify-send "Wallpaper" "Archivo no encontrado: $SELECTED" -i dialog-error
    exit 1
fi

# Transición aleatoria
TRANSITIONS=(fade wipe slide grow outer)
TRANSITION=${TRANSITIONS[$RANDOM % ${#TRANSITIONS[@]}]}

# Guardar wallpaper del tema anterior
PREV_THEME=$(cat "$HOME/.config/.current-theme" 2>/dev/null)
[ -n "$PREV_THEME" ] && echo "$WALLPAPER" > "$HOME/.config/.wallpaper-$PREV_THEME"

# Aplicar fondo
swww img "$WALLPAPER" \
    --transition-type "$TRANSITION" \
    --transition-duration 1.5 \
    --transition-fps 60

# Guardar fondo activo
echo "$WALLPAPER" > "$HOME/.config/.current-wallpaper"

notify-send "Fondo aplicado" "$SELECTED" -i "$WALLPAPER"
