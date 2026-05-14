#!/bin/bash
kitty --class startup-keybinds \
  --override initial_window_width=68c \
  --override initial_window_height=52c \
  -e bash -c "~/.config/hypr/scripts/show-atajos.sh | less -R --no-init --quit-if-one-screen"
