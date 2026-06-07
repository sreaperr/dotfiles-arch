#!/bin/bash
# theme-toggle — alterna Desktop ↔ Auditory
# Solo cambia kitty, prompt (omp), fastfetch y wallpaper. Sin waybar ni rofi.

source "$(dirname "${BASH_SOURCE[0]}")/lib/theme-functions.sh"

CURRENT=$(cat "$HOME/.config/.current-theme" 2>/dev/null || echo "desktop")

if [[ "$CURRENT" == "desktop" ]]; then
    THEME="auditory"
else
    THEME="desktop"
fi

source "$THEMES_DIR/$THEME/meta.sh"

apply_partial_theme_symlinks "$THEME"
pkill -SIGUSR1 kitty 2>/dev/null || true
rm -f "$HOME/.cache/oh-my-posh/"*.omp.cache 2>/dev/null || true

mapfile -t MONITORS < <(hyprctl monitors -j 2>/dev/null | \
    python3 -c "import sys,json; [print(m['name']) for m in json.load(sys.stdin)]" 2>/dev/null)

if [[ -n "${DEFAULT_WALLPAPER:-}" && -f "$DEFAULT_WALLPAPER" && ${#MONITORS[@]} -gt 0 ]]; then
    for _mon in "${MONITORS[@]}"; do
        awww img "$DEFAULT_WALLPAPER" \
            --outputs "$_mon" \
            --transition-type fade \
            --transition-duration 1.5 \
            --transition-fps 60
    done
    echo "$DEFAULT_WALLPAPER" > "$HOME/.config/.current-wallpaper"
fi

echo "$THEME" > "$HOME/.config/.current-theme"
notify-send "Tema" "$DISPLAY_NAME" -i preferences-desktop-theme
