#!/bin/sh
OPEN=$(eww -c ~/.config/eww active-windows 2>/dev/null | grep -cE 'launchermenu|music|fetch')
if [ "$OPEN" -gt 0 ]; then
    eww -c ~/.config/eww close launchermenu music fetch 2>/dev/null
else
    eww -c ~/.config/eww open launchermenu
    eww -c ~/.config/eww open music
    eww -c ~/.config/eww open fetch
fi
