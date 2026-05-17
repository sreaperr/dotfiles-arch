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
YAZI_THEMES="$DOTFILES/.config/yazi/themes"

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
    *)
        exit 1
        ;;
esac

# Aplicar tema en waybar
ln -sf "$WAYBAR_THEMES/$THEME.css" "$HOME/.config/waybar/theme.css"

# Aplicar tema en yazi
ln -sf "$YAZI_THEMES/$THEME.toml" "$HOME/.config/yazi/theme.toml"

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
gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME"
sed -i "s/^gtk-theme-name.*/gtk-theme-name        = $GTK_THEME/" "$HOME/.config/gtk-3.0/settings.ini"
sed -i "s/^gtk-icon-theme-name.*/gtk-icon-theme-name   = $ICON_THEME/" "$HOME/.config/gtk-3.0/settings.ini"
sed -i "s/^gtk-theme-name.*/gtk-theme-name        = $GTK_THEME/" "$HOME/.config/gtk-4.0/settings.ini"
sed -i "s/^gtk-icon-theme-name.*/gtk-icon-theme-name   = $ICON_THEME/" "$HOME/.config/gtk-4.0/settings.ini"

# Cambiar color de carpetas Papirus
papirus-folders -C "$PAPIRUS_COLOR" --theme Papirus-Dark

# Aplicar cursor
hyprctl setcursor "$CURSOR" $CURSOR_SIZE
gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR"
gsettings set org.gnome.desktop.interface cursor-size $CURSOR_SIZE
sed -i "s/^gtk-cursor-theme-name.*/gtk-cursor-theme-name = $CURSOR/" "$HOME/.config/gtk-3.0/settings.ini"
sed -i "s/^gtk-cursor-theme-size.*/gtk-cursor-theme-size = $CURSOR_SIZE/" "$HOME/.config/gtk-3.0/settings.ini"
sed -i "s/^gtk-cursor-theme-name.*/gtk-cursor-theme-name = $CURSOR/" "$HOME/.config/gtk-4.0/settings.ini"
sed -i "s/^gtk-cursor-theme-size.*/gtk-cursor-theme-size = $CURSOR_SIZE/" "$HOME/.config/gtk-4.0/settings.ini"
mkdir -p "$HOME/.icons/default"
printf '[Icon Theme]\nName=Default\nComment=Default Cursor Theme\nInherits=%s\n' "$CURSOR" > "$HOME/.icons/default/index.theme"
sed -i "s/^env = XCURSOR_THEME,.*/env = XCURSOR_THEME,$CURSOR/" "$HOME/.config/hypr/hyprland.conf"
echo "$CURSOR" > "$HOME/.config/.current-cursor"

# Guardar tema activo
echo "$THEME" > "$HOME/.config/.current-theme"

# Recargar waybar
systemctl --user restart waybar

# Recargar swaync
pkill swaync && swaync &

# Notificación
notify-send "Tema activado" "$SELECTED" -i preferences-desktop-theme
