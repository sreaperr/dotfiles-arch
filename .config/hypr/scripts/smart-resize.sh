#!/usr/bin/env bash
# Redimensiona la ventana activa (layout master).
#
# Bug de Hyprland: resizeactive solo puede "crecer" robando espacio a la
# SIGUIENTE ventana del stack; la última ventana no tiene siguiente. Por eso,
# para esa última ventana, ↓ (que nativamente intenta crecer) no hace nada,
# y ↑ (que nativamente encoge) sí funciona.
#
# Mapeo invertido para ese caso límite (↓ = achicar, ↑ = agrandar):
#   - ↓ en la última ventana → resize nativo -30 (encoger, ya funciona solo)
#   - ↑ en la última ventana → redirigido: encoge la ventana de arriba
#     (focus up / resize -30 / focus down), lo que agranda la de abajo sin
#     que se note el cambio de foco.
# El resto de casos (ventanas que sí tienen siguiente, y left/right) usan el
# dispatcher nativo sin tocar.

set -euo pipefail

step=30
dir="${1:?uso: smart-resize.sh <up|down|left|right>}"

resize() { hyprctl dispatch "hl.dsp.window.resize({ x = $1, y = $2, relative = true })" >/dev/null; }

if [ "$dir" = "up" ] || [ "$dir" = "down" ]; then
  read -r addr ax ay aw ws < <(hyprctl activewindow -j | jq -r '[.address, .at[0], .at[1], .size[0], .workspace.id] | @tsv')

  has_next=$(hyprctl clients -j | jq --arg addr "$addr" --argjson ax "$ax" --argjson ay "$ay" --argjson aw "$aw" --argjson ws "$ws" '
    any(.[]; .workspace.id == $ws
      and .address != $addr
      and (.floating // false) == false
      and (.at[0] > ($ax - $aw/2)) and (.at[0] < ($ax + $aw/2))
      and (.at[1] > $ay))
  ')

  if [ "$has_next" = "false" ]; then
    if [ "$dir" = "up" ]; then
      hyprctl dispatch 'hl.dsp.focus({ direction = "up" })' >/dev/null
      resize 0 -"$step"
      hyprctl dispatch 'hl.dsp.focus({ direction = "down" })' >/dev/null
      exit 0
    else
      resize 0 -"$step"
      exit 0
    fi
  fi
fi

case "$dir" in
  up)    resize 0 -"$step" ;;
  down)  resize 0 "$step" ;;
  left)  resize -"$step" 0 ;;
  right) resize "$step" 0 ;;
  *) echo "direccion invalida: $dir" >&2; exit 1 ;;
esac
