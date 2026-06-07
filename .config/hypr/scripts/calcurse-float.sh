#!/bin/bash
kitty --app-id calcurse-term -e calcurse &
until hyprctl clients | grep -q "class: calcurse-term"; do sleep 0.05; done
hyprctl dispatch setfloating 'class:^(calcurse-term)$'
hyprctl dispatch resizewindowpixel 'exact 900 580,class:^(calcurse-term)$'
hyprctl dispatch centerwindow
