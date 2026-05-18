#!/bin/bash
#==========================
# SCRIPT DE MENÚ DE ENERGÍA
#==========================

OPCIONES="󰌾  Bloquear\n󰍃  Cerrar sesión\n󰜉  Reiniciar\n󰐥  Apagar"

SELECTED=$(echo -e "$OPCIONES" | rofi -dmenu \
    -p "  Sistema" \
    -theme ~/.config/rofi/theme.rasi \
    -theme-str 'window { location: center; anchor: center; width: 360px; }' \
    -i -no-custom \
    -lines 4)

[ -z "$SELECTED" ] && exit 0

case "$SELECTED" in
    *"Bloquear"*)
        hyprlock
        ;;
    *"Cerrar sesión"*)
        hyprctl dispatch exit
        ;;
    *"Reiniciar"*)
        CONFIRM=$(echo -e "Sí\nNo" | rofi -dmenu \
            -p "  ¿Reiniciar?" \
            -theme ~/.config/rofi/theme.rasi \
            -theme-str 'window { location: center; anchor: center; width: 220px; }' \
            -i -no-custom -lines 2)
        [ "$CONFIRM" = "Sí" ] && systemctl reboot
        ;;
    *"Apagar"*)
        CONFIRM=$(echo -e "Sí\nNo" | rofi -dmenu \
            -p "  ¿Apagar?" \
            -theme ~/.config/rofi/theme.rasi \
            -theme-str 'window { location: center; anchor: center; width: 220px; }' \
            -i -no-custom -lines 2)
        [ "$CONFIRM" = "Sí" ] && systemctl poweroff
        ;;
esac
