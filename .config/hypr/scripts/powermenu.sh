#!/bin/bash
#==========================
# SCRIPT DE MENÚ DE ENERGÍA
#==========================

OPCIONES="󰌾  Bloquear\n󰍃  Cerrar sesión\n󰜉  Reiniciar\n󰐥  Apagar"

SELECTED=$(echo -e "$OPCIONES" | rofi -dmenu \
    -p "  Sistema" \
    -theme ~/.config/rofi/theme.rasi \
    -theme-str 'window { location: north-east; anchor: north-east; x-offset: 0px; y-offset: 36px; width: 220px; border-radius: 0px 0px 10px 10px; }' \
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
