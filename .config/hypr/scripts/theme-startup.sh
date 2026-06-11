#!/bin/bash
#================================
# APLICAR TEMA GUARDADO AL ARRANCAR
#================================

source "$(dirname "${BASH_SOURCE[0]}")/lib/theme-functions.sh"

THEME=$(cat "$HOME/.config/.current-theme" 2>/dev/null || echo "desktop")

# Comprobar que el tema existe; si no, usar el primero disponible
if [[ ! -d "$THEMES_DIR/$THEME" ]]; then
    THEME=$(ls "$THEMES_DIR" | head -1)
fi

# Cargar metadatos del tema
source "$THEMES_DIR/$THEME/meta.sh"

# Aplicar symlinks de todos los componentes
apply_theme_symlinks "$THEME"

# GTK + cursor
gsettings set org.gnome.desktop.interface gtk-theme    "$GTK_THEME"
gsettings set org.gnome.desktop.interface icon-theme   "$ICON_THEME"
gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR"
gsettings set org.gnome.desktop.interface cursor-size  "$CURSOR_SIZE"
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
apply_gtk_cursor "$GTK_THEME" "$ICON_THEME" "$CURSOR" "$CURSOR_SIZE"

# Recargar tmux si hay sesiones activas
tmux source-file "$HOME/.config/tmux/theme.conf" 2>/dev/null || true

# ── Wallpaper del tema (esperar a que swww esté listo) ────────────────────────
SAVED_WALLPAPER_FILE="$HOME/.config/.wallpaper-$THEME"
THEME_WALLPAPER=""

if [[ -f "$SAVED_WALLPAPER_FILE" ]]; then
    THEME_WALLPAPER=$(cat "$SAVED_WALLPAPER_FILE")
else
    THEME_WALLPAPER="$DEFAULT_WALLPAPER"
fi

if [[ -n "$THEME_WALLPAPER" && -f "$THEME_WALLPAPER" ]]; then
    if ! awww query &>/dev/null; then
        awww-daemon &
    fi

    TRIES=0
    until awww query &>/dev/null; do
        sleep 0.2
        TRIES=$((TRIES + 1))
        [[ $TRIES -ge 25 ]] && break
    done
    awww img "$THEME_WALLPAPER" --transition-type fade --transition-duration 1
    echo "$THEME_WALLPAPER" > "$HOME/.config/.current-wallpaper"
fi
