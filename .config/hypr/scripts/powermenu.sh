#!/bin/bash
#==========================
# SCRIPT DE MENÚ DE ENERGÍA
#==========================

OPCIONES="󰌾  Bloquear\n󰍃  Cerrar sesión\n󰜉  Reiniciar\n󰐥  Apagar"

SELECTED=$(echo -e "$OPCIONES" | rofi -dmenu \
    -p "  Sistema" \
    -theme ~/.config/rofi/theme.rasi \
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
        systemctl reboot
        ;;
    *"Apagar"*)
        systemctl poweroff
        ;;
esac
