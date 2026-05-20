#!/bin/bash
# Salta al workspace de la ventana que envió la notificación clickeada.
# swaync llama este script con run-on:action y expone $SWAYNC_DESKTOP_ENTRY.

ENTRY="${SWAYNC_DESKTOP_ENTRY,,}"
[[ -z "$ENTRY" ]] && exit 0

CLIENT=$(hyprctl clients -j | jq -r --arg e "$ENTRY" '
    [.[] | select(
        (.class        | ascii_downcase | contains($e)) or
        (.initialClass | ascii_downcase | contains($e)) or
        ($e | contains(.class | ascii_downcase))
    )] | first
')

WS=$(printf '%s' "$CLIENT"   | jq -r '.workspace.id')
ADDR=$(printf '%s' "$CLIENT" | jq -r '.address')

[[ -z "$WS" || "$WS" == "null" || "$WS" == "-1" ]] && exit 0

hyprctl dispatch workspace "$WS"
[[ -n "$ADDR" && "$ADDR" != "null" ]] && hyprctl dispatch focuswindow "address:$ADDR"
