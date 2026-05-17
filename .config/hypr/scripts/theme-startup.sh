#!/bin/bash
#================================
# APLICAR TEMA GUARDADO AL ARRANCAR
#================================

DOTFILES=~/dotfiles-arch
WAYBAR_THEMES="$DOTFILES/.config/waybar/themes"
KITTY_THEMES="$DOTFILES/.config/kitty/themes"
ROFI_THEMES="$DOTFILES/.config/rofi/themes"
SWAYNC_THEMES="$DOTFILES/.config/swaync/themes"
HYPR_THEMES="$DOTFILES/.config/hypr/themes"
YAZI_THEMES="$DOTFILES/.config/yazi/themes"
STARSHIP_THEMES="$DOTFILES/.config/starship/themes"

THEME=$(cat "$HOME/.config/.current-theme" 2>/dev/null || echo "tokyonight")

case "$THEME" in
    "gruvbox")
        GTK_THEME="Gruvbox-Material-Dark"
        ICON_THEME="Papirus-Dark"
        CURSOR="Bibata-Modern-Amber"
        CURSOR_SIZE=24
        ;;
    "kali")
        GTK_THEME="Kali-Dark"
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

ln -sf "$WAYBAR_THEMES/$THEME.css"         "$HOME/.config/waybar/theme.css"
ln -sf "$YAZI_THEMES/$THEME.toml"          "$HOME/.config/yazi/theme.toml"
if [[ "$THEME" == "kali" ]]; then
    ln -sf "$STARSHIP_THEMES/kali.toml" "$HOME/.config/starship/starship.toml"
else
    ln -sf "$STARSHIP_THEMES/arch.toml" "$HOME/.config/starship/starship.toml"
fi
ln -sf "$KITTY_THEMES/$THEME.conf"         "$HOME/.config/kitty/theme.conf"
ln -sf "$ROFI_THEMES/$THEME.rasi"          "$HOME/.config/rofi/theme.rasi"
ln -sf "$SWAYNC_THEMES/$THEME.css"         "$HOME/.config/swaync/theme.css"
ln -sf "$HYPR_THEMES/$THEME.conf"          "$HOME/.config/hypr/theme.conf"
ln -sf "$HYPR_THEMES/hyprlock-$THEME.conf" "$HOME/.config/hypr/hyprlock-theme.conf"

gsettings set org.gnome.desktop.interface gtk-theme    "$GTK_THEME"
gsettings set org.gnome.desktop.interface icon-theme   "$ICON_THEME"
gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR"
gsettings set org.gnome.desktop.interface cursor-size  "$CURSOR_SIZE"

sed -i "s/^gtk-theme-name.*/gtk-theme-name        = $GTK_THEME/"      "$HOME/.config/gtk-3.0/settings.ini"
sed -i "s/^gtk-icon-theme-name.*/gtk-icon-theme-name   = $ICON_THEME/" "$HOME/.config/gtk-3.0/settings.ini"
sed -i "s/^gtk-cursor-theme-name.*/gtk-cursor-theme-name = $CURSOR/"   "$HOME/.config/gtk-3.0/settings.ini"
sed -i "s/^gtk-cursor-theme-size.*/gtk-cursor-theme-size = $CURSOR_SIZE/" "$HOME/.config/gtk-3.0/settings.ini"

sed -i "s/^gtk-theme-name.*/gtk-theme-name        = $GTK_THEME/"      "$HOME/.config/gtk-4.0/settings.ini"
sed -i "s/^gtk-icon-theme-name.*/gtk-icon-theme-name   = $ICON_THEME/" "$HOME/.config/gtk-4.0/settings.ini"
sed -i "s/^gtk-cursor-theme-name.*/gtk-cursor-theme-name = $CURSOR/"   "$HOME/.config/gtk-4.0/settings.ini"
sed -i "s/^gtk-cursor-theme-size.*/gtk-cursor-theme-size = $CURSOR_SIZE/" "$HOME/.config/gtk-4.0/settings.ini"
