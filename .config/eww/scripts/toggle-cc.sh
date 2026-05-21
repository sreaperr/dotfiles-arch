#!/bin/bash
# Toggle del control center — devuelve el foco al terminar
eww open control-center --toggle
sleep 0.05
hyprctl dispatch focuscurrentorlast 2>/dev/null || true
