#!/bin/bash
#================================
# WALLPAPER PICKER — SUPER+T
#================================

WALLPAPER_DIR="$HOME/.config/.wallpaper"
ALIASES_FILE="$WALLPAPER_DIR/aliases.conf"
THEME=$(cat "$HOME/.config/.current-theme" 2>/dev/null || echo "desktop")

# Construir lista: si hay alias muestra el alias, si no el nombre de archivo
declare -A ALIAS_MAP
if [[ -f "$ALIASES_FILE" ]]; then
    while IFS='=' read -r file alias; do
        [[ -z "$file" || "$file" == \#* ]] && continue
        ALIAS_MAP["$alias"]="$file"
    done < "$ALIASES_FILE"
fi

# Archivos sin alias van con su nombre tal cual
for f in "$WALLPAPER_DIR"/*; do
    name=$(basename "$f")
    [[ "$name" == "aliases.conf" ]] && continue
    # Comprobar si ya tiene alias
    found=false
    for k in "${!ALIAS_MAP[@]}"; do
        [[ "${ALIAS_MAP[$k]}" == "$name" ]] && { found=true; break; }
    done
    [[ "$found" == false ]] && ALIAS_MAP["$name"]="$name"
done

SELECTED=$(printf '%s\n' "${!ALIAS_MAP[@]}" | sort | rofi -dmenu \
    -p "  Wallpaper" \
    -theme ~/.config/rofi/selector.rasi \
    -no-custom)

[ -z "$SELECTED" ] && exit 0

WP="$WALLPAPER_DIR/${ALIAS_MAP[$SELECTED]}"
[ -f "$WP" ] || exit 1

mapfile -t MONITORS < <(hyprctl monitors -j 2>/dev/null | \
    python3 -c "import sys,json; [print(m['name']) for m in json.load(sys.stdin)]" 2>/dev/null)

[[ ${#MONITORS[@]} -eq 0 ]] && MONITORS=("")

for _mon in "${MONITORS[@]}"; do
    if [[ -n "$_mon" ]]; then
        awww img "$WP" \
            --outputs "$_mon" \
            --transition-type fade \
            --transition-duration 1.5 \
            --transition-fps 60
        echo "$WP" > "$HOME/.config/.wallpaper-$THEME-$_mon"
    else
        awww img "$WP" \
            --transition-type fade \
            --transition-duration 1.5 \
            --transition-fps 60
    fi
done

echo "$WP" > "$HOME/.config/.current-wallpaper"
notify-send "Wallpaper" "$SELECTED" -i preferences-desktop-wallpaper
