#!/bin/bash
#==========================
# SELECTOR DE FONDO CON PREVIEW
# - tokyonight / tokyonight-neon: abre selector rofi
# - auditory: fondo fijo, no se puede cambiar desde aquí
#==========================

WALLPAPER_DIR="$HOME/.config/.wallpaper"
CURRENT_THEME=$(cat "$HOME/.config/.current-theme" 2>/dev/null || echo "tokyonight")

# ── Auditory: fondo bloqueado ─────────────────────────────────────────
if [ "$CURRENT_THEME" = "auditory" ]; then
    notify-send "Fondo bloqueado" "El tema Auditory usa un fondo fijo" \
        -i dialog-information -t 2000
    exit 0
fi

# ── tokyonight / tokyonight-neon: selector ───────────────────────────
if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "Wallpaper" "Directorio no encontrado: $WALLPAPER_DIR" -i dialog-error
    exit 1
fi

# Excluir el fondo fijo de auditory del selector
AUDITORY_WP="$HOME/.config/.wallpaper/auditory.png"

# Verificar que hay imágenes
HAS_IMAGES=0
for f in "$WALLPAPER_DIR"/*.jpg "$WALLPAPER_DIR"/*.jpeg "$WALLPAPER_DIR"/*.png "$WALLPAPER_DIR"/*.gif "$WALLPAPER_DIR"/*.webp; do
    [ -f "$f" ] && [ "$f" != "$AUDITORY_WP" ] && { HAS_IMAGES=1; break; }
done
[ "$HAS_IMAGES" -eq 0 ] && { notify-send "Wallpaper" "No hay imágenes en $WALLPAPER_DIR"; exit 1; }

# Pasar directamente al rofi para preservar los bytes nulos de los iconos
SELECTED=$(
    for f in "$WALLPAPER_DIR"/*.jpg "$WALLPAPER_DIR"/*.jpeg "$WALLPAPER_DIR"/*.png "$WALLPAPER_DIR"/*.gif "$WALLPAPER_DIR"/*.webp; do
        [ -f "$f" ] || continue
        [ "$f" = "$AUDITORY_WP" ] && continue
        printf "%s\0icon\x1f%s\n" "$(basename "$f")" "$f"
    done | rofi -dmenu \
        -p "  Fondo" \
        -theme ~/.config/rofi/runner.rasi \
        -theme-str 'window { location: center; anchor: center; width: 400px; } element-icon { size: 44px; } listview { lines: 6; }' \
        -show-icons \
        -i -no-custom
)

[ -z "$SELECTED" ] && exit 0

WALLPAPER="$WALLPAPER_DIR/$SELECTED"

if [ ! -f "$WALLPAPER" ]; then
    notify-send "Wallpaper" "Archivo no encontrado: $SELECTED" -i dialog-error
    exit 1
fi

# Transición aleatoria
TRANSITIONS=(fade wipe slide grow outer)
TRANSITION=${TRANSITIONS[$RANDOM % ${#TRANSITIONS[@]}]}

# Aplicar fondo
awww img "$WALLPAPER" \
    --transition-type "$TRANSITION" \
    --transition-duration 1.5 \
    --transition-fps 60

# Guardar fondo activo (general y por tema)
echo "$WALLPAPER" > "$HOME/.config/.current-wallpaper"
echo "$WALLPAPER" > "$HOME/.config/.wallpaper-$CURRENT_THEME"

notify-send "Fondo aplicado" "$SELECTED" -i "$WALLPAPER"
