#!/bin/bash
#
# spotify-panel.sh — Waybar Spotify Monitor
# Muestra la canción en reproducción (sin tooltip ni menú)
#

# ── Detectar instancia de Spotify ────────────────────────────────────
player=$(playerctl -l 2>/dev/null | grep -i spotify | head -1)

if [ -z "$player" ]; then
    /usr/bin/jq -cn \
        --arg text "󰓇" \
        --arg class "spotify-off" \
        '{text: $text, class: $class}'
    exit 0
fi

# ── Metadata ──────────────────────────────────────────────────────────
status=$(playerctl -p "$player" status 2>/dev/null)
title=$(playerctl -p "$player" metadata title 2>/dev/null)

# ── Texto del módulo (icono + título corto) ───────────────────────────
if [ "$status" = "Playing" ] && [ -n "$title" ]; then
    short=$(echo "$title" | cut -c1-22)
    [ "${#title}" -gt 22 ] && short="${short}…"
    MOD_TEXT="󰓇  ${short}"
    MOD_CLASS="spotify-playing"
else
    MOD_TEXT="󰓇"
    [ "$status" = "Paused" ] && MOD_CLASS="spotify-paused" || MOD_CLASS="spotify-off"
fi

# ── Output JSON para Waybar ───────────────────────────────────────────
/usr/bin/jq -cn \
    --arg text  "$MOD_TEXT" \
    --arg class "$MOD_CLASS" \
    '{text: $text, class: $class}'
