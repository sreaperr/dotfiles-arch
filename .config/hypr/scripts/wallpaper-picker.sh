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

# ── Elegir monitor ───────────────────────────────────────────────────────────
mapfile -t MONITORS < <(hyprctl monitors -j 2>/dev/null | \
    python3 -c "import sys,json; [print(m['name']) for m in json.load(sys.stdin)]" 2>/dev/null)
[[ ${#MONITORS[@]} -eq 0 ]] && MONITORS=("")

MON_MENU="󰍹 Todos los monitores"
for _mon in "${MONITORS[@]}"; do
    [[ "$_mon" == "DP-1" ]]     && MON_MENU+="\n󰹑 DP-1  (Principal)"
    [[ "$_mon" == "HDMI-A-1" ]] && MON_MENU+="\n󰡁 HDMI-A-1  (Secundario)"
done

MON_SELECTED=$(printf "%b" "$MON_MENU" | rofi -dmenu \
    -p "  Monitor" \
    -theme ~/.config/rofi/wallpaper-selector.rasi \
    -theme-str 'window { width: 340px; } listview { columns: 1; lines: 3; spacing: 6px; padding: 10px; } element { orientation: horizontal; padding: 8px 12px; } element-icon { size: 0px; }' \
    -no-custom)

[ -z "$MON_SELECTED" ] && exit 0

# ── Resolver outputs ─────────────────────────────────────────────────────────
case "$MON_SELECTED" in
    *"DP-1"*)     TARGET_OUTPUTS="DP-1"     ;;
    *"HDMI-A-1"*) TARGET_OUTPUTS="HDMI-A-1" ;;
    *)             TARGET_OUTPUTS=""          ;;  # todos
esac

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

if [[ -n "$TARGET_OUTPUTS" ]]; then
    awww img "$WP" --outputs "$TARGET_OUTPUTS" \
        --transition-type fade --transition-duration 1.5 --transition-fps 60
else
    OUTPUTS=""
    for _mon in "${MONITORS[@]}"; do
        [[ -n "$_mon" && -f "$HOME/.config/.wallpaper-fixed-$_mon" ]] && continue
        [[ -n "$_mon" ]] && OUTPUTS="${OUTPUTS:+$OUTPUTS,}$_mon"
    done
    awww img "$WP" ${OUTPUTS:+--outputs "$OUTPUTS"} \
        --transition-type fade --transition-duration 1.5 --transition-fps 60
fi

# ── Persistencia ─────────────────────────────────────────────────────────────
if [[ -n "$TARGET_OUTPUTS" ]]; then
    echo "$WP" > "$HOME/.config/.wallpaper-$THEME-$TARGET_OUTPUTS"
else
    echo "$WP" > "$HOME/.config/.wallpaper-$THEME"
    echo "$WP" > "$HOME/.config/.current-wallpaper"
fi

MON_LABEL="${TARGET_OUTPUTS:-Todos}"
notify-send "Wallpaper" "$SELECTED  ›  $MON_LABEL" -i preferences-desktop-wallpaper
