#!/bin/bash
BOLD='\033[1m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
RESET='\033[0m'

format_mod() {
    local mod="$1"
    [[ -z "$mod" ]] && echo "(ninguno)" && return
    mod="${mod//SUPER/󰖳 Super}"
    mod="${mod//SHIFT/ + Shift}"
    mod="${mod//CTRL/ + Ctrl}"
    echo "$mod"
}

print_section() {
    echo ""
    printf "${BLUE}${BOLD}  %s${RESET}\n" "$1"
    printf "  \033[2m%s\033[0m\n" "$(printf '─%.0s' {1..50})"
}

in_block=0

while IFS= read -r line; do
    # Ignorar separadores decorativos
    [[ "$line" =~ ^#[=\-]+$ ]] && continue
    [[ "$line" =~ ^#[[:space:]]*$ ]] && continue

    # Líneas de comentario → sección o descripción
    if [[ "$line" =~ ^#[[:space:]]*(.*) ]]; then
        text="${BASH_REMATCH[1]}"
        [[ -z "$text" ]] && continue
        # Si el texto está todo en mayúsculas o es una sección clara, mostrarlo como cabecera
        if [[ "$text" =~ ^[A-ZÁÉÍÓÚÑ[:space:]()]+$ ]] || \
           [[ "$text" =~ ^[A-Z]+.*: ]] || \
           [[ ${#text} -lt 50 && ! "$text" =~ →  ]]; then
            print_section "$text"
        fi
        continue
    fi

    # Líneas bind/bindel/bindl/binde/bindm
    if [[ "$line" =~ ^bind[elm]*[[:space:]]*=[[:space:]]*(.*) ]]; then
        rest="${BASH_REMATCH[1]}"
        IFS=',' read -ra parts <<< "$rest"

        mod="${parts[0]}"
        mod="${mod// /}"
        key="$(echo "${parts[1]}" | xargs)"
        action="${parts[2]:-}"
        action="${action#"${action%%[! ]*}"}"
        arg="${parts[3]:-}"
        arg="${arg#"${arg%%[! ]*}"}"

        [[ -z "$key" ]] && continue

        # Construir descripción legible
        full_action="${action}"
        [[ -n "$arg" ]] && full_action="${action} ${arg}"

        if [[ -n "$mod" ]]; then
            combo="$(format_mod "$mod") + ${key}"
        else
            combo="${key}"
        fi
        printf "  ${YELLOW}%-36s${RESET} %s\n" "$combo" "$full_action"
    fi
done < ~/.config/hypr/keybinds.conf

echo ""
