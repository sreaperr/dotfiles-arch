#!/bin/bash
#==========================
# SELECTOR DE FONDO CON PREVIEW
# - desktop: abre selector rofi
# - auditory: fondo fijo, no se puede cambiar desde aquí
#==========================

WALLPAPER_DIR="$HOME/.config/.wallpaper"
CURRENT_THEME=$(cat "$HOME/.config/.current-theme" 2>/dev/null || echo "desktop")

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

# ── Paso 1: elegir monitor ────────────────────────────────────────────
mapfile -t MONITOR_NAMES < <(hyprctl monitors -j 2>/dev/null | \
    python3 -c "import sys,json; [print(m['name']) for m in json.load(sys.stdin)]" 2>/dev/null)
[[ ${#MONITOR_NAMES[@]} -eq 0 ]] && exit 1

MONITOR_MENU=$(printf '%s\n' "${MONITOR_NAMES[@]}"; echo "󰿉  Todos los monitores")

MONITOR_SEL=$(printf '%s\n' "${MONITOR_NAMES[@]}" "󰿉  Todos los monitores" | rofi -dmenu \
    -p "  Monitor" \
    -theme ~/.config/rofi/launchers/type-2/style-4.rasi \
    -theme-str "window { location: center; anchor: center; width: 600px; } listview { lines: $((${#MONITOR_NAMES[@]} + 1)); }" \
    -no-custom)

[ -z "$MONITOR_SEL" ] && exit 0

case "$MONITOR_SEL" in
    *"Todos"*) OUTPUTS="" ;;
    *)         OUTPUTS="$MONITOR_SEL" ;;
esac

# ── Paso 2: elegir fondo ──────────────────────────────────────────────
SELECTED=$(
    for f in "$WALLPAPER_DIR"/*.jpg "$WALLPAPER_DIR"/*.jpeg "$WALLPAPER_DIR"/*.png "$WALLPAPER_DIR"/*.gif "$WALLPAPER_DIR"/*.webp; do
        [ -f "$f" ] || continue
        [ "$f" = "$AUDITORY_WP" ] && continue
        printf "%s\0icon\x1f%s\n" "$(basename "$f")" "$f"
    done | rofi -dmenu \
        -p "  Fondo" \
        -theme ~/.config/rofi/launchers/type-2/style-4.rasi \
        -theme-str 'window { location: center; anchor: center; width: 600px; } element-icon { size: 60px; } listview { lines: 6; }' \
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

# Aplicar fondo al monitor seleccionado (o a ambos si OUTPUTS está vacío)
if [ -n "$OUTPUTS" ]; then
    awww img "$WALLPAPER" \
        --outputs "$OUTPUTS" \
        --transition-type "$TRANSITION" \
        --transition-duration 1.5 \
        --transition-fps 60
else
    awww img "$WALLPAPER" \
        --transition-type "$TRANSITION" \
        --transition-duration 1.5 \
        --transition-fps 60
fi

# Guardar fondo activo por tema y por monitor
if [ -n "$OUTPUTS" ]; then
    echo "$WALLPAPER" > "$HOME/.config/.wallpaper-$CURRENT_THEME-$OUTPUTS"
else
    echo "$WALLPAPER" > "$HOME/.config/.current-wallpaper"
    for _mon in "${MONITOR_NAMES[@]}"; do
        echo "$WALLPAPER" > "$HOME/.config/.wallpaper-$CURRENT_THEME-$_mon"
    done
fi

notify-send "Fondo aplicado" "$SELECTED" -i "$WALLPAPER"
