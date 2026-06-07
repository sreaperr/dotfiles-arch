#!/bin/bash
# apply-theme — cambia el tema activo y recarga waybar, swaync e hyprland
# Uso: apply-theme [nombre]    ej: apply-theme desktop
#      apply-theme             (sin arg: re-aplica el tema guardado)

THEMES_DIR="$HOME/.config/themes"
CURRENT_FILE="$HOME/.config/.current-theme"

THEME="${1:-$(cat "$CURRENT_FILE" 2>/dev/null || echo "desktop")}"
THEME_DIR="$THEMES_DIR/$THEME"

[[ ! -d "$THEME_DIR" ]] && { echo "Tema no encontrado: $THEME_DIR"; exit 1; }

source "$THEME_DIR/meta.sh"

# cp seguro: elimina symlinks antes de copiar para no corromper el archivo de destino
safe_cp() { [[ -L "$2" ]] && rm -f "$2"; cp -f "$1" "$2"; }

# Copiar archivos de colores
safe_cp "$THEME_DIR/waybar.css"  "$HOME/.config/waybar/theme.css"
safe_cp "$THEME_DIR/rofi.rasi"   "$HOME/.config/rofi/theme.rasi"
safe_cp "$THEME_DIR/swaync.css"  "$HOME/.config/swaync/theme.css"
safe_cp "$THEME_DIR/hypr.conf"   "$HOME/.config/hypr/theme.conf"
[[ -f "$THEME_DIR/hyprlock.conf" ]] && \
    safe_cp "$THEME_DIR/hyprlock.conf" "$HOME/.config/hypr/hyprlock-theme.conf"

# Unificar colores de rofi
safe_cp "$HOME/.config/rofi/theme.rasi" "$HOME/.config/rofi/colors/current.rasi"

# Guardar tema activo
echo "$THEME" > "$CURRENT_FILE"

# Recargar apps
systemctl --user restart waybar 2>/dev/null
pkill -x swaync 2>/dev/null
swaync &>/dev/null &
hyprctl reload 2>/dev/null

# Fondo: solo cambiar si el tema tiene DEFAULT_WALLPAPER y el archivo existe
if [[ -n "${DEFAULT_WALLPAPER:-}" && -f "$DEFAULT_WALLPAPER" ]]; then
    awww img "$DEFAULT_WALLPAPER" --transition-type fade --transition-duration 1 2>/dev/null
    echo "$DEFAULT_WALLPAPER" > "$HOME/.config/.current-wallpaper"
fi

notify-send "Tema: $DISPLAY_NAME" "Colores y apps recargados" -t 3000 2>/dev/null
