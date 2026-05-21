#!/bin/bash
# Abre fastfetch con el config del tema activo al iniciar sesión
THEME=$(cat "$HOME/.config/.current-theme" 2>/dev/null || echo "tokyonight")
case "$THEME" in
    "tokyonight-storm") CONFIG="config-tokyonight-storm" ;;
    "tokyonight-neon")  CONFIG="config-tokyonight-neon"  ;;
    "auditory")         CONFIG="config-auditory"         ;;
    *)                  CONFIG="config-tokyonight"       ;;
esac

kitty --class startup-fastfetch \
  --override initial_window_width=47c \
  --override initial_window_height=43c \
  --hold -e fastfetch --config "$HOME/.config/fastfetch/${CONFIG}.jsonc"
