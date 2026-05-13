#!/bin/bash
PREV_FILE="/tmp/waybar_sysinfo_prev"
CURR=$(awk '/^cpu / {print $2+$3+$4, $2+$3+$4+$5+$6+$7+$8; exit}' /proc/stat)
ACTIVE=${CURR% *}
TOTAL=${CURR#* }

if [ -f "$PREV_FILE" ]; then
    read -r PREV_ACTIVE PREV_TOTAL < "$PREV_FILE"
    DELTA_ACTIVE=$((ACTIVE - PREV_ACTIVE))
    DELTA_TOTAL=$((TOTAL - PREV_TOTAL))
    [ "$DELTA_TOTAL" -gt 0 ] && CPU=$((DELTA_ACTIVE * 100 / DELTA_TOTAL)) || CPU=0
else
    CPU=0
fi

echo "$ACTIVE $TOTAL" > "$PREV_FILE"
RAM=$(free | awk '/Mem:/ {printf "%.0f", $3/$2*100}')
echo "󰍛 ${CPU}%  󰻠 ${RAM}%"
