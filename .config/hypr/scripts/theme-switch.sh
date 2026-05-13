#!/bin/bash
#==========================
# SCRIPT DE CAMBIO DE TEMA
#==========================

DOTFILES=~/dotfiles-arch
WAYBAR_THEMES="$DOTFILES/.config/waybar/themes"
KITTY_THEMES="$DOTFILES/.config/kitty/themes"
ROFI_THEMES="$DOTFILES/.config/rofi/themes"
SWAYNC_THEMES="$DOTFILES/.config/swaync/themes"
HYPR_THEMES="$DOTFILES/.config/hypr/themes"

# Opciones del menú de rofi
THEMES="Gruvbox\nTokyo Night"

# Mostrar menú con rofi
SELECTED=$(echo -e "$THEMES" | rofi -dmenu \
    -p "  Tema" \
    -theme ~/.config/rofi/theme.rasi \
    -theme-str 'window { location: center; anchor: center; width: 220px; }' \
    -i -no-custom)

# Salir si no se seleccionó nada
[ -z "$SELECTED" ] && exit 0

case "$SELECTED" in
    "Gruvbox")
        THEME="gruvbox"
        CURSOR="Bibata-Modern-Amber"
        CURSOR_SIZE=24
        BTOP_THEME="gruvbox_dark_v2"
        GTK_THEME="Gruvbox-Material-Dark"
        ;;
    "Tokyo Night")
        THEME="tokyonight"
        CURSOR="Bibata-Modern-Ice"
        CURSOR_SIZE=24
        BTOP_THEME="tokyo-night"
        GTK_THEME="Tokyonight-Dark"
        ;;
    *)
        exit 1
        ;;
esac

# Aplicar tema en waybar
ln -sf "$WAYBAR_THEMES/$THEME.css" "$HOME/.config/waybar/theme.css"

# Aplicar tema en kitty
ln -sf "$KITTY_THEMES/$THEME.conf" "$HOME/.config/kitty/theme.conf"

# Aplicar tema en rofi
ln -sf "$ROFI_THEMES/$THEME.rasi" "$HOME/.config/rofi/theme.rasi"

# Aplicar tema en swaync
ln -sf "$SWAYNC_THEMES/$THEME.css" "$HOME/.config/swaync/theme.css"

# Aplicar colores en Hyprland (bordes)
ln -sf "$HYPR_THEMES/$THEME.conf" "$HOME/.config/hypr/theme.conf"
hyprctl reload

# Aplicar colores en hyprlock
ln -sf "$HYPR_THEMES/hyprlock-$THEME.conf" "$HOME/.config/hypr/hyprlock-theme.conf"

# Aplicar tema en btop
sed -i "s/^color_theme = .*/color_theme = \"$BTOP_THEME\"/" "$HOME/.config/btop/btop.conf"

# Aplicar tema GTK
gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME"
sed -i "s/^gtk-theme-name.*/gtk-theme-name        = $GTK_THEME/" "$HOME/.config/gtk-3.0/settings.ini"
sed -i "s/^gtk-theme-name.*/gtk-theme-name        = $GTK_THEME/" "$HOME/.config/gtk-4.0/settings.ini"

# Aplicar cursor
hyprctl setcursor "$CURSOR" $CURSOR_SIZE
gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR"
gsettings set org.gnome.desktop.interface cursor-size $CURSOR_SIZE
echo "$CURSOR" > "$HOME/.config/.current-cursor"

# Guardar tema activo
echo "$THEME" > "$HOME/.config/.current-theme"

# Recargar waybar
pkill waybar && waybar &

# Recargar swaync
pkill swaync && swaync &

# Notificación
notify-send "Tema activado" "$SELECTED" -i preferences-desktop-theme
