#!/bin/bash
#==========================
# SCRIPT DE CAMBIO DE TEMA
#==========================

source "$(dirname "${BASH_SOURCE[0]}")/lib/theme-functions.sh"

TEMAS="Tokyo Night\nTokyo Night Storm\nTokyo Night Neon\nAuditory"
SELECTED=$(printf '%b' "$TEMAS" | rofi -dmenu \
    -p "  Tema" \
    -theme ~/.config/rofi/selector.rasi \
    -no-custom)

[ -z "$SELECTED" ] && exit 0

case "$SELECTED" in
    "Tokyo Night")
        THEME="tokyonight"
        CURSOR="Bibata-Modern-Ice"
        CURSOR_SIZE=24
        BTOP_THEME="tokyo-night"
        GTK_THEME="MacTahoe-Dark"
        ICON_THEME="WhiteSur-grey-dark"
        PAPIRUS_COLOR="cyan"
        DEFAULT_WALLPAPER="$HOME/.config/.wallpaper/wp16267603-retro-desktop-4k-wallpapers.webp"
        ;;
    "Tokyo Night Storm")
        THEME="tokyonight-storm"
        CURSOR="Bibata-Modern-Ice"
        CURSOR_SIZE=24
        BTOP_THEME="tokyo-night"
        GTK_THEME="MacTahoe-Dark"
        ICON_THEME="WhiteSur-grey-dark"
        PAPIRUS_COLOR="cyan"
        DEFAULT_WALLPAPER="$HOME/.config/.wallpaper/wp16267603-retro-desktop-4k-wallpapers.webp"
        ;;
    "Tokyo Night Neon")
        THEME="tokyonight-neon"
        CURSOR="Bibata-Modern-Ice"
        CURSOR_SIZE=24
        BTOP_THEME="tokyo-night"
        GTK_THEME="MacTahoe-Dark"
        ICON_THEME="WhiteSur-grey-dark"
        PAPIRUS_COLOR="cyan"
        DEFAULT_WALLPAPER="$HOME/.config/.wallpaper/wp16267603-retro-desktop-4k-wallpapers.webp"
        ;;
    "Auditory")
        THEME="auditory"
        CURSOR="Bibata-Modern-Classic"
        CURSOR_SIZE=24
        BTOP_THEME="dracula"
        GTK_THEME="Adwaita-dark"
        ICON_THEME="Dedicated-to-Hackerer"
        PAPIRUS_COLOR="red"
        DEFAULT_WALLPAPER="$HOME/.config/.wallpaper/add.png"
        ;;
    *)
        exit 1
        ;;
esac

apply_theme_symlinks "$THEME"

# Actualizar tema de eww y recargarlo
ln -sf "$HOME/.config/eww/themes/$THEME.scss" "$HOME/.config/eww/themes/active.scss"
eww reload 2>/dev/null || true

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

# Kitty — recargar config en todas las ventanas abiertas
pkill -SIGUSR1 kitty 2>/dev/null || true

# Tmux — recargar tema en sesiones abiertas
tmux source-file "$HOME/.config/tmux/theme.conf" 2>/dev/null || true

# Nvim — actualizar instancias abiertas en vivo
for sock in "$XDG_RUNTIME_DIR"/nvim.*.0; do
    [ -S "$sock" ] && nvim --server "$sock" \
        --remote-send ":colorscheme ${THEME}<CR>" 2>/dev/null &
done

THEME_WALLPAPER="$DEFAULT_WALLPAPER"

if [ -n "$THEME_WALLPAPER" ] && [ -f "$THEME_WALLPAPER" ]; then
    awww img "$THEME_WALLPAPER" \
        --transition-type fade \
        --transition-duration 1.5 \
        --transition-fps 60
    echo "$THEME_WALLPAPER" > "$HOME/.config/.current-wallpaper"
fi

hyprctl reload
systemctl --user restart waybar
pkill swaync && swaync &

notify-send "Tema activado" "$SELECTED" -i preferences-desktop-theme
