#!/bin/bash
kitty --app-id yazi-term -e yazi &
until hyprctl clients | grep -q "class: yazi-term"; do sleep 0.05; done
hyprctl dispatch setfloating 'class:^(yazi-term)$'
hyprctl dispatch resizewindowpixel 'exact 1000 560,class:^(yazi-term)$'
hyprctl dispatch centerwindow
