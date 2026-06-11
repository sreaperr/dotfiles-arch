#!/bin/bash
#==========================
# SCRIPT DE CAMBIO DE TEMA
# Aplica kitty, prompt, fastfetch, rofi/waybar/swaync, nvim,
# calcurse y wallpaper. Si el tema es parcial (PARTIAL_THEME=true)
# se dejan hypr/hyprlock/yazi/tmux/swayosd sin tocar.
#==========================

source "$(dirname "${BASH_SOURCE[0]}")/lib/theme-functions.sh"

# ── Generar lista de temas ────────────────────────────────────────────────────
declare -A THEME_MAP

for dir in "$THEMES_DIR"/*/; do
    [[ -f "$dir/meta.sh" ]] || continue
    dir_name=$(basename "$dir")
    display=$(bash -c "source \"$dir/meta.sh\"; echo \"\${DISPLAY_NAME:-$dir_name}\"")
    THEME_MAP["$display"]="$dir_name"
done

TEMAS=$(printf '%s\n' "${!THEME_MAP[@]}" | sort)

SELECTED=$(printf '%s\n' "$TEMAS" | rofi -dmenu \
    -p "  Tema" \
    -theme ~/.config/rofi/selector.rasi \
    -no-custom)

[ -z "$SELECTED" ] && exit 0

THEME="${THEME_MAP[$SELECTED]}"
[ -z "$THEME" ] && exit 1

source "$THEMES_DIR/$THEME/meta.sh"

echo "$THEME" > "$HOME/.config/.current-theme"

# ── Aplicar tema (completo o parcial según PARTIAL_THEME) ─────────────────────
if [[ "${PARTIAL_THEME:-false}" == "true" ]]; then
    apply_partial_theme_symlinks "$THEME"
else
    apply_theme_symlinks "$THEME"
    hyprctl reload &>/dev/null || true
fi

# ── GTK + iconos + cursor (todos los temas, incluidos los parciales) ──────────
gsettings set org.gnome.desktop.interface gtk-theme    "$GTK_THEME"
gsettings set org.gnome.desktop.interface icon-theme   "$ICON_THEME"
gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR"
gsettings set org.gnome.desktop.interface cursor-size  "$CURSOR_SIZE"
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
apply_gtk_cursor "$GTK_THEME" "$ICON_THEME" "$CURSOR" "$CURSOR_SIZE"

pkill -SIGUSR1 kitty 2>/dev/null || true
rm -f "$HOME/.cache/oh-my-posh/"*.omp.cache 2>/dev/null || true
tmux source-file "$HOME/.config/tmux/theme.conf" 2>/dev/null || true

# ── Wallpaper (con persistencia por tema y monitor) ───────────────────────────
mapfile -t MONITORS < <(hyprctl monitors -j 2>/dev/null | \
    python3 -c "import sys,json; [print(m['name']) for m in json.load(sys.stdin)]" 2>/dev/null)

if [[ ${#MONITORS[@]} -gt 0 ]]; then
    for _mon in "${MONITORS[@]}"; do
        saved="$HOME/.config/.wallpaper-$THEME-$_mon"
        if [[ -f "$saved" ]]; then
            wp=$(cat "$saved")
        else
            wp="${DEFAULT_WALLPAPER:-}"
        fi
        [[ -n "$wp" && -f "$wp" ]] || continue
        awww img "$wp" \
            --outputs "$_mon" \
            --transition-type fade \
            --transition-duration 1.5 \
            --transition-fps 60
        echo "$wp" > "$HOME/.config/.current-wallpaper"
    done
fi

notify-send "Tema activado" "$DISPLAY_NAME" -i preferences-desktop-theme
