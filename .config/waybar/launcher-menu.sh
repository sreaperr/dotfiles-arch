#!/bin/bash
mouse_x=$(hyprctl cursorpos 2>/dev/null | awk -F',' '{print int($1)}')
[ -z "$mouse_x" ] && mouse_x=110
x_offset=$((mouse_x - 110))
[ $x_offset -lt 0 ] && x_offset=0

rofi -show drun \
    -theme ~/.config/rofi/dropdown.rasi \
    -theme-str "window { x-offset: ${x_offset}px; y-offset: 0px; location: northwest; anchor: northwest; }"
