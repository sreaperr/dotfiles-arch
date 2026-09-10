#!/bin/bash
#================================
# ARRANQUE RÁPIDO DE WALLPAPER
# Arranca awww-daemon y pinta cada monitor con su fondo
# correcto de inmediato, para evitar tanto la pantalla gris
# como el flash del fondo equivocado antes de theme-startup.sh
#================================
if ! command -v awww &>/dev/null; then
    notify-send "Wallpaper" "awww no instalado. Instala con: paru -S awww" 2>/dev/null
    exit 1
fi

awww-daemon &

# Esperar a que el daemon esté listo (máx 5 segundos)
TRIES=0
until awww query &>/dev/null; do
    sleep 0.2
    TRIES=$((TRIES + 1))
    [ $TRIES -ge 25 ] && exit 1
done

DEFAULT_WALLPAPER="$HOME/.config/.wallpaper/the-ghost-coders-rj-3440x1440.jpg"
THEME=$(cat "$HOME/.config/.current-theme" 2>/dev/null || echo "desktop")

mapfile -t MONITORS < <(hyprctl monitors -j 2>/dev/null | \
    python3 -c "import sys,json; [print(m['name']) for m in json.load(sys.stdin)]" 2>/dev/null)
[[ ${#MONITORS[@]} -eq 0 ]] && MONITORS=("")

for _mon in "${MONITORS[@]}"; do
    WP=""

    # Fondo fijo por monitor (ignora el tema)
    fixed_file="$HOME/.config/.wallpaper-fixed${_mon:+-$_mon}"
    if [[ -n "$_mon" && -f "$fixed_file" ]]; then
        WP=$(cat "$fixed_file")
        [[ -f "$WP" ]] || WP=""
    fi

    # Fondo guardado para el tema/monitor actual
    if [[ -z "$WP" ]]; then
        saved="$HOME/.config/.wallpaper-$THEME${_mon:+-$_mon}"
        [[ -f "$saved" ]] && WP=$(cat "$saved")
        [[ -n "$WP" && -f "$WP" ]] || WP=""
    fi

    # Último fondo aplicado (global), si no hay nada por monitor
    [[ -z "$WP" ]] && WP=$(cat "$HOME/.config/.current-wallpaper" 2>/dev/null)
    [[ -f "$WP" ]] || WP="$DEFAULT_WALLPAPER"

    if [[ -n "$_mon" ]]; then
        awww img "$WP" --outputs "$_mon" --transition-type none
    else
        awww img "$WP" --transition-type none
    fi
done
