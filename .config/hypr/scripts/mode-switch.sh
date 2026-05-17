#!/bin/bash
#==========================
# SCRIPT DE CAMBIO DE MODO
# Arch (escritorio) / Kali (pentesting)
#==========================

DOTFILES_ARCH=~/dotfiles-arch
DOTFILES_KALI=~/dotfiles-kali
WAYBAR_THEMES="$DOTFILES_ARCH/.config/waybar/themes"
KITTY_THEMES="$DOTFILES_ARCH/.config/kitty/themes"
ROFI_THEMES="$DOTFILES_ARCH/.config/rofi/themes"
SWAYNC_THEMES="$DOTFILES_ARCH/.config/swaync/themes"
HYPR_THEMES="$DOTFILES_ARCH/.config/hypr/themes"
STARSHIP_THEMES="$DOTFILES_ARCH/.config/starship/themes"

CURRENT_MODE=$(cat ~/.config/.current-mode 2>/dev/null || echo "arch")

MODES=" Arch Mode\n Kali Mode"

SELECTED=$(echo -e "$MODES" | rofi -dmenu \
    -p "  Modo" \
    -theme ~/.config/rofi/theme.rasi \
    -theme-str 'window { location: center; anchor: center; width: 240px; }' \
    -i -no-custom)

[ -z "$SELECTED" ] && exit 0

case "$SELECTED" in
    *"Arch Mode"*) MODE="arch" ;;
    *"Kali Mode"*) MODE="kali" ;;
    *) exit 1 ;;
esac

[ "$MODE" = "$CURRENT_MODE" ] && exit 0

apply_kali() {
    # Guardar tema arch activo para restaurarlo después
    cp ~/.config/.current-theme ~/.config/.arch-theme-backup 2>/dev/null
    cp ~/.config/.current-wallpaper ~/.config/.arch-wallpaper-backup 2>/dev/null

    # Wallpaper
    WALLPAPER="$DOTFILES_KALI/.config/wallpapers/kali.jpg"
    awww img "$WALLPAPER" --transition-type fade --transition-duration 1
    echo "$WALLPAPER" > ~/.config/.current-wallpaper

    # Hyprland
    ln -sf "$HYPR_THEMES/kali.conf" ~/.config/hypr/theme.conf
    ln -sf "$HYPR_THEMES/hyprlock-kali.conf" ~/.config/hypr/hyprlock-theme.conf
    hyprctl reload

    # Kitty
    ln -sf "$KITTY_THEMES/kali.conf" ~/.config/kitty/theme.conf

    # Waybar
    ln -sf "$WAYBAR_THEMES/kali.css" ~/.config/waybar/theme.css

    # Rofi
    ln -sf "$ROFI_THEMES/kali.rasi" ~/.config/rofi/theme.rasi

    # SwayNC
    ln -sf "$SWAYNC_THEMES/kali.css" ~/.config/swaync/theme.css

    # Starship
    ln -sf "$STARSHIP_THEMES/kali.toml" ~/.config/starship/starship.toml

    # Nvim
    echo "kali" > ~/.config/.current-theme

    echo "kali" > ~/.config/.current-mode
    pkill waybar; waybar &
    pkill swaync; swaync &
    notify-send " Kali Mode" "Modo pentesting activado" -t 3000
}

apply_arch() {
    ARCH_THEME=$(cat ~/.config/.arch-theme-backup 2>/dev/null || echo "tokyonight")
    ARCH_WALLPAPER=$(cat ~/.config/.arch-wallpaper-backup 2>/dev/null)

    # Wallpaper
    if [ -z "$ARCH_WALLPAPER" ] || [ ! -f "$ARCH_WALLPAPER" ]; then
        ARCH_WALLPAPER="$DOTFILES_ARCH/.config/.wallpaper/wallpaper_pc.png"
    fi
    awww img "$ARCH_WALLPAPER" --transition-type fade --transition-duration 1
    echo "$ARCH_WALLPAPER" > ~/.config/.current-wallpaper

    # Hyprland
    ln -sf "$HYPR_THEMES/$ARCH_THEME.conf" ~/.config/hypr/theme.conf
    ln -sf "$HYPR_THEMES/hyprlock-$ARCH_THEME.conf" ~/.config/hypr/hyprlock-theme.conf
    hyprctl reload

    # Kitty
    ln -sf "$KITTY_THEMES/$ARCH_THEME.conf" ~/.config/kitty/theme.conf

    # Waybar
    ln -sf "$WAYBAR_THEMES/$ARCH_THEME.css" ~/.config/waybar/theme.css

    # Rofi
    ln -sf "$ROFI_THEMES/$ARCH_THEME.rasi" ~/.config/rofi/theme.rasi

    # SwayNC
    ln -sf "$SWAYNC_THEMES/$ARCH_THEME.css" ~/.config/swaync/theme.css

    # Starship
    ln -sf "$STARSHIP_THEMES/arch.toml" ~/.config/starship/starship.toml

    # Nvim
    echo "$ARCH_THEME" > ~/.config/.current-theme

    echo "arch" > ~/.config/.current-mode
    pkill waybar; waybar &
    pkill swaync; swaync &
    notify-send " Arch Mode" "Modo escritorio activado" -t 3000
}

if [ "$MODE" = "kali" ]; then
    apply_kali
else
    apply_arch
fi
