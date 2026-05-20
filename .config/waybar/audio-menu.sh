#!/bin/bash
mouse_x=$(hyprctl cursorpos 2>/dev/null | awk -F',' '{print int($1)}')
[ -z "$mouse_x" ] && mouse_x=960
x_offset=$((mouse_x - 150))
[ $x_offset -lt 0 ] && x_offset=0

declare -a sink_ids sink_descs entries
default=$(pactl get-default-sink 2>/dev/null)

current_name=""
while IFS= read -r line; do
    if [[ "$line" =~ "Name:" ]]; then
        current_name=$(awk '{print $2}' <<< "$line")
    elif [[ "$line" =~ "Description:" ]] && [ -n "$current_name" ]; then
        sink_ids+=("$current_name")
        sink_descs+=("$(sed 's/.*Description: //' <<< "$line")")
        current_name=""
    fi
done < <(pactl list sinks)

[ ${#sink_ids[@]} -eq 0 ] && { notify-send "Audio" "No se encontraron dispositivos"; exit 0; }

for i in "${!sink_ids[@]}"; do
    [ "${sink_ids[$i]}" = "$default" ] && entries+=("${sink_descs[$i]}   ✓") || entries+=("${sink_descs[$i]}")
done

selected=$(printf '%s\n' "${entries[@]}" | \
    rofi -dmenu \
    -p "󰕾  Audio" \
    -no-show-icons \
    -theme ~/.config/rofi/dropdown-right.rasi \
    -theme-str "window { x-offset: ${x_offset}px; y-offset: 0px; location: northwest; anchor: northwest; }")

[ -z "$selected" ] && exit 0
for i in "${!entries[@]}"; do [ "${entries[$i]}" = "$selected" ] && break; done
pactl set-default-sink "${sink_ids[$i]}"
pactl list sink-inputs short 2>/dev/null | awk '{print $1}' | xargs -I{} pactl move-sink-input {} "${sink_ids[$i]}"
