#!/bin/bash
#================================
# WALLPAPER PICKER — SUPER+T
#================================

WALLPAPER_DIR="$HOME/.config/.wallpaper"
ALIASES_FILE="$WALLPAPER_DIR/aliases.conf"
WE_DIR="$HOME/.local/share/Steam/steamapps/workshop/content/431960"
THEME=$(cat "$HOME/.config/.current-theme" 2>/dev/null || echo "desktop")

# ── Construir lista estática ─────────────────────────────────────────────────
declare -A ALIAS_MAP   # alias → filename (estáticos)
declare -A WE_MAP      # título → id (WE)

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

# ── Construir lista WE (desde whitelist we-wallpapers.conf) ─────────────────
WE_CONF="$WALLPAPER_DIR/we-wallpapers.conf"
if [[ -f "$WE_CONF" && -d "$WE_DIR" ]]; then
    while IFS='=' read -r id alias; do
        [[ -z "$id" || "$id" == \#* ]] && continue
        id="${id// /}"
        [[ -d "$WE_DIR/$id" ]] && WE_MAP["[WE] $alias"]="$id"
    done < "$WE_CONF"
fi

# ── Mostrar rofi combinado ───────────────────────────────────────────────────
SELECTED=$(
    {
        for alias in "${!ALIAS_MAP[@]}"; do
            printf "%s\000icon\037%s/%s\n" "$alias" "$WALLPAPER_DIR" "${ALIAS_MAP[$alias]}"
        done
        for title in "${!WE_MAP[@]}"; do
            id="${WE_MAP[$title]}"
            preview="$WE_DIR/$id/preview.jpg"
            if [[ -f "$preview" ]]; then
                printf "%s\000icon\037%s\n" "$title" "$preview"
            else
                printf "%s\n" "$title"
            fi
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

if [[ -v "WE_MAP[$SELECTED]" ]]; then
    # ── Wallpaper Engine ─────────────────────────────────────────────────────
    WE_ID="${WE_MAP[$SELECTED]}"
    pkill awww-daemon 2>/dev/null
    pkill -f linux-wallpaperengine 2>/dev/null
    sleep 0.3

    for _mon in "${MONITORS[@]}"; do
        [[ -n "$_mon" && -f "$HOME/.config/.wallpaper-fixed-$_mon" ]] && continue
        if [[ -n "$_mon" ]]; then
            linux-wallpaperengine --layer background --screen-root "$_mon" --bg "$WE_ID" --silent &
        else
            linux-wallpaperengine --layer background --bg "$WE_ID" --silent &
        fi
        echo "we:$WE_ID" > "$HOME/.config/.wallpaper-$THEME${_mon:+-$_mon}"
    done
    echo "we:$WE_ID" > "$HOME/.config/.current-wallpaper"
    notify-send "Wallpaper" "$SELECTED" -i preferences-desktop-wallpaper

else
    # ── Wallpaper estático ───────────────────────────────────────────────────
    WP="$WALLPAPER_DIR/${ALIAS_MAP[$SELECTED]}"
    [ -f "$WP" ] || exit 1

    pkill -f linux-wallpaperengine 2>/dev/null

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
fi
