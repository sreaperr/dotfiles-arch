#!/bin/bash
mouse_x=$(hyprctl cursorpos 2>/dev/null | awk -F',' '{print int($1)}')
[ -z "$mouse_x" ] && mouse_x=960
x_offset=$((mouse_x - 150))
[ $x_offset -lt 0 ] && x_offset=0

declare -a names entries

while IFS=: read -r name type active; do
    [ "$type" != "802-11-wireless" ] && continue
    names+=("$name")
    [ "$active" = "yes" ] && entries+=("$name   ✓") || entries+=("$name")
done < <(nmcli -t -f NAME,TYPE,ACTIVE connection show 2>/dev/null)

[ ${#entries[@]} -eq 0 ] && { notify-send "Red" "No hay redes WiFi guardadas"; exit 0; }

selected=$(printf '%s\n' "${entries[@]}" | \
    rofi -dmenu \
    -p "󰖩  WiFi" \
    -no-show-icons \
    -theme ~/.config/rofi/dropdown-right.rasi \
    -theme-str "window { x-offset: ${x_offset}px; y-offset: 0px; location: northwest; anchor: northwest; }")

[ -z "$selected" ] && exit 0
for i in "${!entries[@]}"; do [ "${entries[$i]}" = "$selected" ] && break; done
nmcli connection up "${names[$i]}" 2>/dev/null || notify-send "Red" "No se pudo conectar a ${names[$i]}"
