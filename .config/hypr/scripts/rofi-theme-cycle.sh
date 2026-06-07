#!/bin/bash
# Menú Rofi para elegir tema de color (rofi + waybar)

COLORS_DIR="$HOME/.config/rofi/colors"
WAYBAR_THEMES="$HOME/.config/waybar/themes"
CURRENT_LINK="$COLORS_DIR/current.rasi"
WAYBAR_LINK="$HOME/.config/waybar/theme.css"
BRIDGE="$HOME/.config/rofi/colors-bridge.rasi"
ROFI_THEME_LINK="$HOME/.config/rofi/theme.rasi"

# Lista de temas ordenada (excluye current.rasi)
mapfile -t THEMES < <(find "$COLORS_DIR" -maxdepth 1 -name "*.rasi" ! -name "current.rasi" \
    -printf "%f\n" | sed 's/\.rasi$//' | sort)

[[ ${#THEMES[@]} -eq 0 ]] && exit 1

# Tema activo (para marcarlo en el menú)
current_file=$(readlink "$CURRENT_LINK" 2>/dev/null)
current_name=$(basename "$current_file" .rasi)
current_cap=$(echo "$current_name" | sed 's/./\u&/')

# Mostrar menú Rofi — primera letra en mayúscula, tema activo marcado con *
selected=$(printf '%s\n' "${THEMES[@]}" \
    | sed 's/./\u&/' \
    | sed "s/^${current_cap}$/* ${current_cap}/" \
    | rofi -dmenu \
        -p "  Color theme" \
        -theme "$HOME/.config/rofi/selector.rasi" \
        -no-custom \
        -format 'i' \
        -selected-row 0)

[[ -z "$selected" ]] && exit 0

chosen="${THEMES[$selected]}"

# Actualizar symlinks de color
ln -sf "$COLORS_DIR/${chosen}.rasi" "$CURRENT_LINK"
ln -sf "$BRIDGE" "$ROFI_THEME_LINK"

# Actualizar tema de waybar si existe el CSS correspondiente
waybar_css="$WAYBAR_THEMES/${chosen}.css"
if [[ -f "$waybar_css" ]]; then
    ln -sf "$waybar_css" "$WAYBAR_LINK"
fi

# Actualizar colores de swaync si existe el CSS correspondiente
swaync_css="$HOME/.config/swaync/colors/${chosen}.css"
if [[ -f "$swaync_css" ]]; then
    ln -sf "$swaync_css" "$HOME/.config/swaync/theme.css"
    swaync-client --reload-css
fi

# Reiniciar waybar
pkill -x waybar 2>/dev/null
sleep 0.3
systemctl --user start waybar 2>/dev/null || waybar &

# Reaplicar wallpaper en todos los monitores (el reinicio de waybar puede dejarlos en negro)
sleep 0.5 && awww restore &

notify-send "  Color theme" "$chosen" -t 2000
