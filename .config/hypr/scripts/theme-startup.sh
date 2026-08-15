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

# ── Wallpaper del tema por monitor (esperar a que swww esté listo) ───────────
mapfile -t MONITORS < <(hyprctl monitors -j 2>/dev/null | \
    python3 -c "import sys,json; [print(m['name']) for m in json.load(sys.stdin)]" 2>/dev/null)

[[ ${#MONITORS[@]} -eq 0 ]] && MONITORS=("")

FIRST_WP=""
for _mon in "${MONITORS[@]}"; do
    # Fondo fijo por monitor (ignora el tema)
    fixed_file="$HOME/.config/.wallpaper-fixed${_mon:+-$_mon}"
    if [[ -n "$_mon" && -f "$fixed_file" ]]; then
        FIXED_WP=$(cat "$fixed_file")
        if [[ -f "$FIXED_WP" ]]; then
            awww query &>/dev/null || { awww-daemon &; sleep 1; }
            awww img "$FIXED_WP" --outputs "$_mon" --transition-type none
            [[ -z "$FIRST_WP" ]] && FIRST_WP="$FIXED_WP"
            continue
        fi
    fi

    saved="$HOME/.config/.wallpaper-$THEME${_mon:+-$_mon}"
    THEME_WALLPAPER=""
    if [[ -f "$saved" ]]; then
        THEME_WALLPAPER=$(cat "$saved")
        if [[ "$THEME_WALLPAPER" != we:* && ! -f "$THEME_WALLPAPER" ]]; then
            rm -f "$saved"
            THEME_WALLPAPER="$DEFAULT_WALLPAPER"
        fi
    else
        THEME_WALLPAPER="$DEFAULT_WALLPAPER"
    fi
    [[ -n "$THEME_WALLPAPER" && ( "$THEME_WALLPAPER" == we:* || -f "$THEME_WALLPAPER" ) ]] || continue
    [[ -z "$FIRST_WP" ]] && FIRST_WP="$THEME_WALLPAPER"

    if ! awww query &>/dev/null; then
        awww-daemon &
        TRIES=0
        until awww query &>/dev/null; do
            sleep 0.2
            TRIES=$((TRIES + 1))
            [[ $TRIES -ge 25 ]] && break
        done
    fi

    if [[ "$THEME_WALLPAPER" == we:* ]]; then
        WE_ID="${THEME_WALLPAPER#we:}"
        pkill -f linux-wallpaperengine 2>/dev/null; sleep 0.2
        if [[ -n "$_mon" ]]; then
            linux-wallpaperengine --layer background --screen-root "$_mon" --bg "$WE_ID" --silent &
            # Re-aplicar tras ~4s para sobrevivir la reconfiguración de kanshi
            (sleep 4 && pkill -f linux-wallpaperengine 2>/dev/null; sleep 0.3 \
                && linux-wallpaperengine --layer background --screen-root "$_mon" --bg "$WE_ID" --silent) &
        else
            linux-wallpaperengine --layer background --bg "$WE_ID" --silent &
            (sleep 4 && pkill -f linux-wallpaperengine 2>/dev/null; sleep 0.3 \
                && linux-wallpaperengine --layer background --bg "$WE_ID" --silent) &
        fi
    else
        if [[ -n "$_mon" ]]; then
            awww img "$THEME_WALLPAPER" --outputs "$_mon" \
                --transition-type fade --transition-duration 1
        else
            awww img "$THEME_WALLPAPER" --transition-type fade --transition-duration 1
        fi
    fi
done

[[ -n "$FIRST_WP" ]] && echo "$FIRST_WP" > "$HOME/.config/.current-wallpaper"
