#!/bin/bash
#================================
# APLICAR TEMA GUARDADO AL ARRANCAR
#================================

source "$(dirname "${BASH_SOURCE[0]}")/lib/theme-functions.sh"

THEME=$(cat "$HOME/.config/.current-theme" 2>/dev/null || echo "tokyonight")

case "$THEME" in
    "gruvbox")
        GTK_THEME="Gruvbox-Material-Dark"
        ICON_THEME="Papirus-Dark"
        CURSOR="Bibata-Modern-Amber"
        CURSOR_SIZE=24
        ;;
    "kali")
        GTK_THEME="Adwaita-dark"
        ICON_THEME="Papirus-Dark"
        CURSOR="Bibata-Modern-Classic"
        CURSOR_SIZE=24
        ;;
    *)
        GTK_THEME="Tokyonight-Dark"
        ICON_THEME="Papirus-Dark"
        CURSOR="Bibata-Modern-Ice"
        CURSOR_SIZE=24
        ;;
esac

apply_theme_symlinks "$THEME"

gsettings set org.gnome.desktop.interface gtk-theme    "$GTK_THEME"
gsettings set org.gnome.desktop.interface icon-theme   "$ICON_THEME"
gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR"
gsettings set org.gnome.desktop.interface cursor-size  "$CURSOR_SIZE"
apply_gtk_cursor "$GTK_THEME" "$ICON_THEME" "$CURSOR" "$CURSOR_SIZE"

# Wallpaper del tema (esperar a que awww esté listo)
THEME_WALLPAPER_FILE="$HOME/.config/.wallpaper-$THEME"
if [ -f "$THEME_WALLPAPER_FILE" ]; then
    THEME_WALLPAPER=$(cat "$THEME_WALLPAPER_FILE")
    if [ -f "$THEME_WALLPAPER" ]; then
        TRIES=0
        until awww query &>/dev/null; do
            sleep 0.2
            TRIES=$((TRIES + 1))
            [ $TRIES -ge 25 ] && break
        done
        awww img "$THEME_WALLPAPER" --transition-type fade --transition-duration 1
        echo "$THEME_WALLPAPER" > "$HOME/.config/.current-wallpaper"
    fi
fi
