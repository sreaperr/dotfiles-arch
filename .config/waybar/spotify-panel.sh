#!/bin/bash
#
# spotify-panel.sh — Waybar Spotify Monitor
# Pasa el ratón por encima del módulo para ver título, artista y controles
#

# ── Colores Tokyo Night ───────────────────────────────────────────────
C_CYAN="#7dcfff"
C_GREEN="#9ece6a"
C_FG="#c0caf5"
C_DIM="#565f89"
C_PURPLE="#bb9af7"

SEP="<span color='${C_DIM}'>──────────────────────────────</span>"

# ── Detectar instancia de Spotify ────────────────────────────────────
player=$(playerctl -l 2>/dev/null | grep -i spotify | head -1)

if [ -z "$player" ]; then
    /usr/bin/jq -cn \
        --arg text "󰓇" \
        --arg tooltip "$(printf '%b' "<span color='${C_CYAN}'><b>󰓇  SPOTIFY</b></span>\n${SEP}\n<span color='${C_DIM}'>Sin instancia activa\nHaz clic para abrir</span>")" \
        --arg class "spotify-off" \
        '{text: $text, tooltip: $tooltip, class: $class}'
    exit 0
fi

# ── Metadata ──────────────────────────────────────────────────────────
status=$(playerctl -p "$player" status 2>/dev/null)
title=$(playerctl -p "$player" metadata title 2>/dev/null)
artist=$(playerctl -p "$player" metadata artist 2>/dev/null)
album=$(playerctl -p "$player" metadata album 2>/dev/null)
shuffle=$(playerctl -p "$player" shuffle 2>/dev/null)
loop=$(playerctl -p "$player" loop 2>/dev/null)
pos=$(playerctl -p "$player" position 2>/dev/null | cut -d. -f1)
duration=$(playerctl -p "$player" metadata mpris:length 2>/dev/null)

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

# ── Icono central de play/pausa ───────────────────────────────────────
if [ "$status" = "Playing" ]; then
    PLAY_ICON="<span color='${C_CYAN}'><b>⏸</b></span>"
else
    PLAY_ICON="<span color='${C_GREEN}'><b>▶</b></span>"
fi

# ── Progreso formateado ───────────────────────────────────────────────
fmt_time() {
    local secs=$1
    printf "%d:%02d" $(( secs / 60 )) $(( secs % 60 ))
}

PROGRESS_STR=""
if [ -n "$pos" ] && [ -n "$duration" ] && [ "$duration" -gt 0 ] 2>/dev/null; then
    dur_secs=$(( duration / 1000000 ))
    PROGRESS_STR="  <span color='${C_DIM}'>$(fmt_time "$pos") / $(fmt_time "$dur_secs")</span>"
fi

# ── Shuffle / Loop ────────────────────────────────────────────────────
[ "$shuffle" = "On" ] \
    && SHUFFLE_STR="<span color='${C_PURPLE}'>󰒝</span>" \
    || SHUFFLE_STR="<span color='${C_DIM}'>󰒞</span>"

case "$loop" in
    "Track")    LOOP_STR="<span color='${C_PURPLE}'>󰕠</span>" ;;
    "Playlist") LOOP_STR="<span color='${C_PURPLE}'>󰑖</span>" ;;
    *)          LOOP_STR="<span color='${C_DIM}'>󰑗</span>" ;;
esac

# ── Tooltip ───────────────────────────────────────────────────────────
TT=""
TT+="<span color='${C_CYAN}'><b>󰓇  SPOTIFY</b></span>\n"
TT+="${SEP}\n"

if [ -n "$title" ]; then
    TT+="<span color='${C_FG}'><b>${title}</b></span>\n"
    [ -n "$artist" ] && TT+="<span color='${C_CYAN}'>${artist}</span>\n"
    [ -n "$album"  ] && TT+="<span color='${C_DIM}'>󰀥  ${album}</span>\n"
    TT+="\n"
    TT+="${SEP}\n"
    TT+="\n"
    # ── Controles visuales ────────────────────────────────────────────
    TT+="<span color='${C_DIM}'>  ⏮  </span>    ${PLAY_ICON}    <span color='${C_DIM}'>  ⏭  </span>   ${SHUFFLE_STR}  ${LOOP_STR}\n"
    [ -n "$PROGRESS_STR" ] && TT+="\n${PROGRESS_STR}\n"
    TT+="\n"
    TT+="${SEP}\n"
    TT+="<span color='${C_DIM}'>Click: play/pausa  ·  Rueda ↑↓: pista ant/sig</span>\n"
    TT+="<span color='${C_DIM}'>Clic derecho: menú completo</span>\n"
else
    TT+="<span color='${C_DIM}'>Sin reproducción activa</span>\n"
    TT+="\n"
    TT+="<span color='${C_DIM}'>Haz clic para abrir el menú</span>\n"
fi

# ── Output JSON para Waybar ───────────────────────────────────────────
/usr/bin/jq -cn \
    --arg text    "$MOD_TEXT" \
    --arg tooltip "$(printf '%b' "$TT")" \
    --arg class   "$MOD_CLASS" \
    '{text: $text, tooltip: $tooltip, class: $class}'
