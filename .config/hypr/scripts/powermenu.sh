#!/bin/bash
#==========================
# MENÚ DE ENERGÍA
#==========================

OPCIONES="󰌾  Bloquear\n󰍃  Cerrar sesión\n󰜉  Reiniciar\n󰐥  Apagar"

SELECTED=$(echo -e "$OPCIONES" | rofi -dmenu \
    -p "  Sistema" \
    -theme ~/.config/rofi/powermenu.rasi \
    -i -no-custom \
    -lines 4)

[ -z "$SELECTED" ] && exit 0

# Diálogo de confirmación reutilizable
confirm() {
    echo -e "  Sí\n  No" | rofi -dmenu \
        -p "$1" \
        -theme ~/.config/rofi/powermenu.rasi \
        -theme-str 'window { width: 240px; } listview { lines: 2; }' \
        -i -no-custom -lines 2
}

case "$SELECTED" in
    *"Bloquear"*)
        hyprlock
        ;;
    *"Cerrar sesión"*)
        CONFIRM=$(confirm "  ¿Cerrar sesión?")
        [[ "$CONFIRM" == *"Sí"* ]] && hyprctl dispatch exit
        ;;
    *"Reiniciar"*)
        CONFIRM=$(confirm "󰜉  ¿Reiniciar?")
        [[ "$CONFIRM" == *"Sí"* ]] && systemctl reboot
        ;;
    *"Apagar"*)
        CONFIRM=$(confirm "󰐥  ¿Apagar?")
        [[ "$CONFIRM" == *"Sí"* ]] && systemctl poweroff
        ;;
esac
