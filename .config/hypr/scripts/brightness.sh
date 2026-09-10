#!/bin/bash
# brightness.sh — control de brillo vía DDC/CI (ddcutil) con feedback visual
# En un PC de sobremesa no hay backlight en /sys/class/backlight (eso es
# solo para paneles internos de portátil); el brillo del monitor externo
# se ajusta enviando comandos DDC/CI por el propio cable HDMI/DP.
# Uso: brightness.sh up | down

ACTION="${1:-up}"
STEP=10

case "$ACTION" in
    up)   SIGN="+" ;;
    down) SIGN="-" ;;
    *) echo "uso: brightness.sh up|down" >&2; exit 1 ;;
esac

mapfile -t DISPLAYS < <(ddcutil detect --brief 2>/dev/null | awk '/^Display [0-9]+/{print $2}')

if [ "${#DISPLAYS[@]}" -eq 0 ]; then
    notify-send "󰃞 Brillo" "No se detectó ningún monitor con soporte DDC/CI" -t 2000
    exit 1
fi

for d in "${DISPLAYS[@]}"; do
    ddcutil setvcp 10 "$SIGN" "$STEP" --display "$d" >/dev/null 2>&1
done

# Feedback con el brillo resultante del primer monitor
BRILLO=$(ddcutil getvcp 10 --display "${DISPLAYS[0]}" 2>/dev/null | grep -oP 'current value = *\K[0-9]+')
[ -z "$BRILLO" ] && exit 0

LLENOS=$(( BRILLO / 10 ))
BARRA=""
for i in $(seq 1 10); do
    if [ "$i" -le "$LLENOS" ]; then BARRA="${BARRA}█"
    else                            BARRA="${BARRA}░"
    fi
done

notify-send \
    -h string:x-canonical-private-synchronous:brightness \
    -t 1500 \
    "󰃞 Brillo  ${BRILLO}%" \
    "$BARRA"
