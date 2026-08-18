#!/bin/bash
#================================
# WALLPAPER PICKER — SUPER+T
#================================

WALLPAPER_DIR="$HOME/.config/.wallpaper"
ALIASES_FILE="$WALLPAPER_DIR/aliases.conf"
THEME=$(cat "$HOME/.config/.current-theme" 2>/dev/null || echo "desktop")

# ── Construir lista estática ─────────────────────────────────────────────────
declare -A ALIAS_MAP   # alias → filename

if [[ -f "$ALIASES_FILE" ]]; then
    while IFS='=' read -r file alias; do
        [[ -z "$file" || "$file" == \#* ]] && continue
        ALIAS_MAP["$alias"]="$file"
    done < "$ALIASES_FILE"
fi

for f in "$WALLPAPER_DIR"/*; do
    name=$(basename "$f")
    [[ "$name" == "aliases.conf" || "$name" == "we-wallpapers.conf" ]] && continue
    found=false
    for k in "${!ALIAS_MAP[@]}"; do
        [[ "${ALIAS_MAP[$k]}" == "$name" ]] && { found=true; break; }
    done
    [[ "$found" == false ]] && ALIAS_MAP["$name"]="$name"
done

# ── Mostrar rofi ─────────────────────────────────────────────────────────────
SELECTED=$(
    {
        for alias in "${!ALIAS_MAP[@]}"; do
            printf "%s\000icon\037%s/%s\n" "$alias" "$WALLPAPER_DIR" "${ALIAS_MAP[$alias]}"
        done
    } | sort | rofi -dmenu \
        -p "  Wallpaper" \
        -theme ~/.config/rofi/wallpaper-selector.rasi \
        -icon-size 300 \
        -no-custom
)

[ -z "$SELECTED" ] && exit 0

# ── Aplicar wallpaper ────────────────────────────────────────────────────────
mapfile -t MONITORS < <(hyprctl monitors -j 2>/dev/null | \
    python3 -c "import sys,json; [print(m['name']) for m in json.load(sys.stdin)]" 2>/dev/null)
[[ ${#MONITORS[@]} -eq 0 ]] && MONITORS=("")

# ── Wallpaper estático ───────────────────────────────────────────────────────
WP="$WALLPAPER_DIR/${ALIAS_MAP[$SELECTED]}"
[ -f "$WP" ] || exit 1

if ! awww query &>/dev/null; then
        awww-daemon &
        TRIES=0
        until awww query &>/dev/null; do
            sleep 0.2; TRIES=$((TRIES+1))
            [[ $TRIES -ge 25 ]] && break
        done
    fi

    for _mon in "${MONITORS[@]}"; do
        [[ -n "$_mon" && -f "$HOME/.config/.wallpaper-fixed-$_mon" ]] && continue
        if [[ -n "$_mon" ]]; then
            awww img "$WP" --outputs "$_mon" \
                --transition-type fade --transition-duration 1.5 --transition-fps 60
            echo "$WP" > "$HOME/.config/.wallpaper-$THEME-$_mon"
        else
            awww img "$WP" \
                --transition-type fade --transition-duration 1.5 --transition-fps 60
        fi
    done
echo "$WP" > "$HOME/.config/.current-wallpaper"
notify-send "Wallpaper" "$SELECTED" -i preferences-desktop-wallpaper
