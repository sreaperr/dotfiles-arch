#!/bin/bash
#==========================
# SCRIPT DE CAMBIO DE TEMA
# Lee los temas desde ~/.config/themes/
#==========================

source "$(dirname "${BASH_SOURCE[0]}")/lib/theme-functions.sh"

# ── Generar lista de temas disponibles desde la carpeta centralizada ─────────
declare -A THEME_MAP   # DISPLAY_NAME → nombre de carpeta

for dir in "$THEMES_DIR"/*/; do
    [[ -f "$dir/meta.sh" ]] || continue
    dir_name=$(basename "$dir")
    # Cargar solo DISPLAY_NAME en subshell para no contaminar el entorno
    display=$(bash -c "source \"$dir/meta.sh\"; echo \"\${DISPLAY_NAME:-$dir_name}\"")
    THEME_MAP["$display"]="$dir_name"
done

# Construir lista para rofi (ordenada)
TEMAS=$(printf '%s\n' "${!THEME_MAP[@]}" | sort)

SELECTED=$(printf '%s\n' "$TEMAS" | rofi -dmenu \
    -p "  Tema" \
    -theme ~/.config/rofi/selector.rasi \
    -no-custom)

[ -z "$SELECTED" ] && exit 0

THEME="${THEME_MAP[$SELECTED]}"
[ -z "$THEME" ] && exit 1

# ── Cargar metadatos del tema seleccionado ───────────────────────────────────
source "$THEMES_DIR/$THEME/meta.sh"

# ── Aplicar symlinks de todos los componentes ────────────────────────────────
apply_theme_symlinks "$THEME"

# ── Btop ─────────────────────────────────────────────────────────────────────
sed -i "s/^color_theme = .*/color_theme = \"$BTOP_THEME\"/" \
    "$HOME/.config/btop/btop.conf"

# ── GTK ──────────────────────────────────────────────────────────────────────
gsettings set org.gnome.desktop.interface gtk-theme  "$GTK_THEME"
gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME"
apply_gtk_cursor "$GTK_THEME" "$ICON_THEME" "$CURSOR" "$CURSOR_SIZE"

# ── Papirus folders ───────────────────────────────────────────────────────────
papirus-folders -C "$PAPIRUS_COLOR" --theme Papirus-Dark 2>/dev/null || true

# ── Cursor ────────────────────────────────────────────────────────────────────
hyprctl setcursor "$CURSOR" $CURSOR_SIZE
gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR"
gsettings set org.gnome.desktop.interface cursor-size  $CURSOR_SIZE
mkdir -p "$HOME/.icons/default"
printf '[Icon Theme]\nName=Default\nComment=Default Cursor Theme\nInherits=%s\n' \
    "$CURSOR" > "$HOME/.icons/default/index.theme"
sed -i "s/^env = XCURSOR_THEME,.*/env = XCURSOR_THEME,$CURSOR/" \
    "$HOME/.config/hypr/hyprland.conf"
echo "$CURSOR" > "$HOME/.config/.current-cursor"

# ── Guardar tema activo ───────────────────────────────────────────────────────
echo "$THEME" > "$HOME/.config/.current-theme"

# ── Kitty: recargar en todas las ventanas abiertas ───────────────────────────
pkill -SIGUSR1 kitty 2>/dev/null || true

# ── Tmux: recargar tema en sesiones abiertas ──────────────────────────────────
tmux source-file "$HOME/.config/tmux/theme.conf" 2>/dev/null || true

# ── Nvim: actualizar instancias abiertas en vivo ─────────────────────────────
for sock in "$XDG_RUNTIME_DIR"/nvim.*.0; do
    [ -S "$sock" ] && nvim --server "$sock" \
        --remote-send ":colorscheme ${NVIM_SCHEME:-$THEME}<CR>" 2>/dev/null &
done

# ── Wallpaper ─────────────────────────────────────────────────────────────────
# Prioridad: 1) wallpaper guardado para este tema  2) DEFAULT_WALLPAPER de meta.sh
SAVED_WALLPAPER_FILE="$HOME/.config/.wallpaper-$THEME"
if [[ -f "$SAVED_WALLPAPER_FILE" ]]; then
    THEME_WALLPAPER=$(cat "$SAVED_WALLPAPER_FILE")
else
    THEME_WALLPAPER="$DEFAULT_WALLPAPER"
fi

if [[ -n "$THEME_WALLPAPER" && -f "$THEME_WALLPAPER" ]]; then
    swww img "$THEME_WALLPAPER" \
        --transition-type fade \
        --transition-duration 1.5 \
        --transition-fps 60
    echo "$THEME_WALLPAPER" > "$HOME/.config/.current-wallpaper"
    echo "$THEME_WALLPAPER" > "$HOME/.config/.wallpaper-$THEME"
fi

# ── Recargar entorno ──────────────────────────────────────────────────────────
hyprctl reload
systemctl --user restart waybar
pkill swaync && swaync &

notify-send "Tema activado" "$DISPLAY_NAME" -i preferences-desktop-theme
