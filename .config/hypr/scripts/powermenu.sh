#!/bin/bash
#==========================
# MENÚ DE ENERGÍA — panel lateral derecho
#==========================

OPCIONES="󰌾\n󰍃\n󰜉\n󰐥"

SELECTED=$(printf '%b' "$OPCIONES" | rofi -dmenu \
    -theme ~/.config/rofi/powermenu.rasi \
    -no-custom \
    -urgent "3")

[ -z "$SELECTED" ] && exit 0

confirm() {
    printf '  Sí\n  No' | rofi -dmenu \
        -p "$1" \
        -theme ~/.config/rofi/selector.rasi \
        -no-custom
}

case "$SELECTED" in
    "󰌾")
        hyprlock
        ;;
    "󰍃")
        CONFIRM=$(confirm "  ¿Cerrar sesión?")
        [[ "$CONFIRM" == *"Sí"* ]] && hyprctl dispatch exit
        ;;
    "󰜉")
        CONFIRM=$(confirm "󰜉  ¿Reiniciar?")
        [[ "$CONFIRM" == *"Sí"* ]] && systemctl reboot
        ;;
    "󰐥")
        CONFIRM=$(confirm "󰐥  ¿Apagar?")
        [[ "$CONFIRM" == *"Sí"* ]] && systemctl poweroff
        ;;
esac
