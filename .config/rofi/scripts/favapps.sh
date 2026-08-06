#!/usr/bin/env bash
# Rofi script mode — Aplicaciones favoritas
# Formato: nombre\0icon\x1ficono_tema

declare -A APPS=(
    ["Terminal"]="kitty"
    ["Archivos"]="thunar"
    ["Editor"]="kitty -e nvim"
    ["Navegador"]="brave"
    ["Música"]="spotify"
    ["Settings"]="nwg-look"
)

declare -A ICONS=(
    ["Terminal"]="utilities-terminal"
    ["Archivos"]="system-file-manager"
    ["Editor"]="text-editor"
    ["Navegador"]="brave"
    ["Música"]="spotify"
    ["Settings"]="preferences-system"
)

if [[ -z "$1" ]]; then
    for name in Terminal Archivos Editor Navegador Música Settings; do
        printf "%s\0icon\x1f%s\n" "$name" "${ICONS[$name]}"
    done
else
    cmd="${APPS[$1]}"
    [[ -n "$cmd" ]] && eval "$cmd" &
fi
