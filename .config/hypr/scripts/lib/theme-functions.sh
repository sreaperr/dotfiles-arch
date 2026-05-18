#!/bin/bash

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"

WAYBAR_THEMES="$DOTFILES/.config/waybar/themes"
KITTY_THEMES="$DOTFILES/.config/kitty/themes"
ROFI_THEMES="$DOTFILES/.config/rofi/themes"
SWAYNC_THEMES="$DOTFILES/.config/swaync/themes"
HYPR_THEMES="$DOTFILES/.config/hypr/themes"
YAZI_THEMES="$DOTFILES/.config/yazi/themes"
STARSHIP_THEMES="$DOTFILES/.config/starship/themes"

apply_theme_symlinks() {
    local THEME=$1
    ln -sf "$WAYBAR_THEMES/$THEME.css"         "$HOME/.config/waybar/theme.css"
    ln -sf "$YAZI_THEMES/$THEME.toml"          "$HOME/.config/yazi/theme.toml"
    if [[ "$THEME" == "kali" ]]; then
        ln -sf "$STARSHIP_THEMES/kali.toml" "$HOME/.config/starship/starship.toml"
    else
        ln -sf "$STARSHIP_THEMES/arch.toml" "$HOME/.config/starship/starship.toml"
    fi
    rm -rf "$HOME/.cache/starship/" 2>/dev/null
    ln -sf "$KITTY_THEMES/$THEME.conf"         "$HOME/.config/kitty/theme.conf"
    ln -sf "$ROFI_THEMES/$THEME.rasi"          "$HOME/.config/rofi/theme.rasi"
    ln -sf "$SWAYNC_THEMES/$THEME.css"         "$HOME/.config/swaync/theme.css"
    ln -sf "$HYPR_THEMES/$THEME.conf"          "$HOME/.config/hypr/theme.conf"
    ln -sf "$HYPR_THEMES/hyprlock-$THEME.conf" "$HOME/.config/hypr/hyprlock-theme.conf"
}

apply_gtk_cursor() {
    local GTK_THEME=$1 ICON_THEME=$2 CURSOR=$3 CURSOR_SIZE=$4
    for ini in "$HOME/.config/gtk-3.0/settings.ini" "$HOME/.config/gtk-4.0/settings.ini"; do
        sed -i "s/^gtk-theme-name.*/gtk-theme-name        = $GTK_THEME/"         "$ini"
        sed -i "s/^gtk-icon-theme-name.*/gtk-icon-theme-name   = $ICON_THEME/"   "$ini"
        sed -i "s/^gtk-cursor-theme-name.*/gtk-cursor-theme-name = $CURSOR/"     "$ini"
        sed -i "s/^gtk-cursor-theme-size.*/gtk-cursor-theme-size = $CURSOR_SIZE/" "$ini"
    done
}
