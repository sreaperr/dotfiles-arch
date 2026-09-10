#!/usr/bin/env bash
# Asigna los workspaces 1-10 a los monitores conectados en este momento:
#   - 1 monitor conectado -> workspaces 1-10 todos ahí.
#   - 2+ monitores        -> el de mayor resolución (ancho*alto) se lleva 1-8,
#                            el segundo más grande se lleva 9-10.
#                            Empate de resolución -> desempate alfabético por nombre de salida.
#
# Se invoca desde cada perfil de ~/.config/kanshi/config (directiva "exec"), así se
# reevalúa solo en cada hotplug — kanshi ya arranca junto con Hyprland (hyprland.lua).
#
# NOTA: desde la migración a hyprland.lua (parser no-legacy) "hyprctl keyword" y
# "hyprctl dispatch <args...>" ya no funcionan (ver `hyprctl --help`: "Use eval").
# El equivalente correcto es pasar Lua a `hyprctl eval`:
#   - hl.workspace_rule({workspace="N", monitor="NAME"})            -> fija la regla
#   - hl.dispatch(hl.dsp.workspace.move({workspace=N, monitor="NAME"})) -> mueve un
#     workspace ya existente/visible (hl.dsp.workspace.move({...}) por sí solo NO
#     hace nada; hay que envolverlo en hl.dispatch(...) para que se ejecute).

set -euo pipefail

mapfile -t names < <(hyprctl monitors -j | jq -r '
    sort_by(-(.width * .height), .name) | .[].name
')

[ "${#names[@]}" -eq 0 ] && exit 0

primary="${names[0]}"
secondary="${names[1]:-$primary}"

target_for() {
    local ws=$1
    if [ "$secondary" = "$primary" ] || [ "$ws" -le 8 ]; then
        echo "$primary"
    else
        echo "$secondary"
    fi
}

for ws in {1..10}; do
    target=$(target_for "$ws")
    extra=""
    { [ "$ws" -eq 1 ] || [ "$ws" -eq 9 ]; } && extra=', default=true'
    hyprctl eval "hl.workspace_rule({workspace=\"$ws\", monitor=\"$target\"$extra})" >/dev/null
done

# Si el cambio de monitores ocurre en caliente y ya hay workspaces con ventanas
# en el monitor "equivocado" según la nueva asignación, los movemos también.
while read -r ws current_mon; do
    target=$(target_for "$ws")
    if [ "$current_mon" != "$target" ]; then
        hyprctl eval "hl.dispatch(hl.dsp.workspace.move({workspace=$ws, monitor=\"$target\"}))" >/dev/null
    fi
done < <(hyprctl workspaces -j | jq -r '.[] | select(.id >= 1 and .id <= 10) | "\(.id) \(.monitor)"')
