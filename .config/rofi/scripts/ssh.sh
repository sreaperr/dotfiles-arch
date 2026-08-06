#!/usr/bin/env bash
# Rofi script mode — SSH hosts

HOSTS=$(cat ~/.ssh/config 2>/dev/null | grep "^Host " | awk '{print $2}' | grep -v '\*')

if [[ -z "$1" ]]; then
    if [[ -n "$HOSTS" ]]; then
        while IFS= read -r host; do
            printf "%s\0icon\x1futilities-terminal\n" "$host"
        done <<< "$HOSTS"
    else
        printf "No hay hosts configurados\0icon\x1fdialog-information\n"
    fi
else
    [[ "$1" == "No hay hosts"* ]] && exit 0
    kitty -- ssh "$1" &
fi
