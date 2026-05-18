#!/bin/bash
#==========================
# SCRIPT DE CAMBIO DE TEMA
#==========================

source "$(dirname "${BASH_SOURCE[0]}")/lib/theme-functions.sh"

SELECTED=$(echo -e "Gruvbox\nTokyo Night\nKali" | rofi -dmenu \
    -p "  Tema" \
    -theme ~/.config/rofi/theme.rasi \
    -theme-str 'window { location: center; anchor: center; width: 220px; }' \
    -i -no-custom)

# Guardar wallpaper del tema actual antes de cambiar
PREV_THEME=$(cat "$HOME/.config/.current-theme" 2>/dev/null)
CURRENT_WALLPAPER=$(cat "$HOME/.config/.current-wallpaper" 2>/dev/null)
[ -n "$PREV_THEME" ] && [ -n "$CURRENT_WALLPAPER" ] && echo "$CURRENT_WALLPAPER" > "$HOME/.config/.wallpaper-$PREV_THEME"

[ -z "$SELECTED" ] && exit 0

case "$SELECTED" in
    "Gruvbox")
        THEME="gruvbox"
        CURSOR="Bibata-Modern-Amber"
        CURSOR_SIZE=24
        BTOP_THEME="gruvbox_dark_v2"
        GTK_THEME="Gruvbox-Material-Dark"
        ICON_THEME="Papirus-Dark"
        PAPIRUS_COLOR="orange"
        ;;
    "Tokyo Night")
        THEME="tokyonight"
        CURSOR="Bibata-Modern-Ice"
        CURSOR_SIZE=24
        BTOP_THEME="tokyo-night"
        GTK_THEME="Tokyonight-Dark"
        ICON_THEME="Papirus-Dark"
        PAPIRUS_COLOR="cyan"
        ;;
    "Kali")
        THEME="kali"
        CURSOR="Bibata-Modern-Classic"
        CURSOR_SIZE=24
        BTOP_THEME="dracula"
        GTK_THEME="Adwaita-dark"
        ICON_THEME="Papirus-Dark"
        PAPIRUS_COLOR="red"
        ;;
    *)
        exit 1
        ;;
esac

apply_theme_symlinks "$THEME"

# Btop
sed -i "s/^color_theme = .*/color_theme = \"$BTOP_THEME\"/" "$HOME/.config/btop/btop.conf"

# GTK
gsettings set org.gnome.desktop.interface gtk-theme  "$GTK_THEME"
gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME"
apply_gtk_cursor "$GTK_THEME" "$ICON_THEME" "$CURSOR" "$CURSOR_SIZE"

# Papirus
papirus-folders -C "$PAPIRUS_COLOR" --theme Papirus-Dark

# Cursor
hyprctl setcursor "$CURSOR" $CURSOR_SIZE
gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR"
gsettings set org.gnome.desktop.interface cursor-size  $CURSOR_SIZE
mkdir -p "$HOME/.icons/default"
printf '[Icon Theme]\nName=Default\nComment=Default Cursor Theme\nInherits=%s\n' "$CURSOR" \
    > "$HOME/.icons/default/index.theme"
sed -i "s/^env = XCURSOR_THEME,.*/env = XCURSOR_THEME,$CURSOR/" "$HOME/.config/hypr/hyprland.conf"
echo "$CURSOR" > "$HOME/.config/.current-cursor"

# Guardar tema activo
echo "$THEME" > "$HOME/.config/.current-theme"

# Wallpaper del nuevo tema (si hay uno guardado para él)
THEME_WALLPAPER_FILE="$HOME/.config/.wallpaper-$THEME"
if [ -f "$THEME_WALLPAPER_FILE" ]; then
    THEME_WALLPAPER=$(cat "$THEME_WALLPAPER_FILE")
    if [ -f "$THEME_WALLPAPER" ]; then
        awww img "$THEME_WALLPAPER" \
            --transition-type fade \
            --transition-duration 1.5 \
            --transition-fps 60
        echo "$THEME_WALLPAPER" > "$HOME/.config/.current-wallpaper"
    fi
fi

hyprctl reload
systemctl --user restart waybar
pkill swaync && swaync &

notify-send "Tema activado" "$SELECTED" -i preferences-desktop-theme
