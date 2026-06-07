#!/bin/bash
mouse_x=$(hyprctl cursorpos 2>/dev/null | awk -F',' '{print int($1)}')
[ -z "$mouse_x" ] && mouse_x=960
x_offset=$((mouse_x - 150))
[ $x_offset -lt 0 ] && x_offset=0

declare -a macs entries

while IFS= read -r line; do
    mac=$(awk '{print $2}' <<< "$line")
    name=$(awk '{$1=$2=""; print substr($0,3)}' <<< "$line")
    macs+=("$mac")
    bluetoothctl info "$mac" 2>/dev/null | grep -q "Connected: yes" \
        && entries+=("$name   ✓") || entries+=("$name")
done < <(bluetoothctl devices Paired 2>/dev/null)

[ ${#entries[@]} -eq 0 ] && { notify-send "Bluetooth" "No hay dispositivos emparejados"; exit 0; }

selected=$(printf '%s\n' "${entries[@]}" | \
    rofi -dmenu \
    -p "󰂯  Bluetooth" \
    -no-show-icons \
    -theme ~/.config/rofi/dropdown-right.rasi \
    -theme-str "window { x-offset: ${x_offset}px; y-offset: 0px; location: northwest; anchor: northwest; }")

[ -z "$selected" ] && exit 0
for i in "${!entries[@]}"; do [ "${entries[$i]}" = "$selected" ] && break; done
grep -q "✓" <<< "$selected" \
    && bluetoothctl disconnect "${macs[$i]}" \
    || bluetoothctl connect "${macs[$i]}"
