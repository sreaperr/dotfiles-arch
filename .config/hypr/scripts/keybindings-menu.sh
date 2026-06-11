#!/bin/bash
# Muestra los keybinds activos de Hyprland en un menu rofi (al estilo omarchy)
# y ejecuta la accion seleccionada.

modmask_to_text() {
  case "$1" in
    0)  printf '' ;;
    1)  printf 'SHIFT' ;;
    4)  printf 'CTRL' ;;
    5)  printf 'SHIFT CTRL' ;;
    8)  printf 'ALT' ;;
    9)  printf 'SHIFT ALT' ;;
    12) printf 'CTRL ALT' ;;
    13) printf 'SHIFT CTRL ALT' ;;
    64) printf 'SUPER' ;;
    65) printf 'SUPER SHIFT' ;;
    68) printf 'SUPER CTRL' ;;
    69) printf 'SUPER SHIFT CTRL' ;;
    72) printf 'SUPER ALT' ;;
    73) printf 'SUPER SHIFT ALT' ;;
    76) printf 'SUPER CTRL ALT' ;;
    77) printf 'SUPER SHIFT CTRL ALT' ;;
    *)  printf '%s' "$1" ;;
  esac
}

records=$(
  hyprctl -j binds |
    jq -r '.[] | [.modmask, (.key // ""), (.description // ""), (.dispatcher // ""), (.arg // "")] | join("")' |
    while IFS=$'\x1f' read -r modmask key description dispatcher arg; do
      [[ -z $key ]] && continue

      modifiers=$(modmask_to_text "$modmask")
      combo="${modifiers:+$modifiers + }$key"

      if [[ -n $description ]]; then
        action="$description"
      elif [[ -n $arg ]]; then
        action="$dispatcher $arg"
      else
        action="$dispatcher"
      fi

      printf '%s\t%s\t%s\t%s\n' "$combo" "$action" "$dispatcher" "$arg"
    done |
    sort -u -t$'\t' -k1,1
)

selection=$(cut -f1 <<<"$records" | rofi -dmenu -p "Atajos" -theme ~/.config/rofi/runner.rasi -theme-str 'window {width: 280px;}')

[[ -z $selection ]] && exit 0

record=$(awk -F '\t' -v sel="$selection" '$1 == sel { print; exit }' <<<"$records")
dispatcher=$(cut -f2 <<<"$record")
arg=$(cut -f3- <<<"$record")

case "$dispatcher" in
  exec) [[ -n $arg ]] && hyprctl dispatch exec "$arg" ;;
  "")   ;;
  *)    if [[ -n $arg ]]; then hyprctl dispatch "$dispatcher" "$arg"; else hyprctl dispatch "$dispatcher"; fi ;;
esac
