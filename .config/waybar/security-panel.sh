#!/bin/bash
#
# security-panel.sh — Waybar Security Monitor
# Pasa el ratón por encima del módulo para ver el panel
#
exec 2>/dev/null  # suprime todo stderr para no contaminar el JSON

# ── Colores Tokyo Night ───────────────────────────────────────────────
C_CYAN="#7dcfff"
C_GREEN="#9ece6a"
C_RED="#f7768e"
C_ORANGE="#ff9e64"
C_YELLOW="#e0af68"
C_PURPLE="#bb9af7"
C_FG="#c0caf5"
C_DIM="#565f89"

# ── Cache IP pública (5 min para no saturar la API) ──────────────────
CACHE_FILE="/tmp/.waybar-pubip-cache"
CACHE_TTL=300

get_public_ip() {
    if [[ -f "$CACHE_FILE" ]]; then
        AGE=$(( $(date +%s) - $(stat -c %Y "$CACHE_FILE") ))
        [[ $AGE -lt $CACHE_TTL ]] && { cat "$CACHE_FILE"; return; }
    fi
    DATA=$(curl -sf --max-time 4 https://ipinfo.io/json 2>/dev/null)
    [[ -n "$DATA" ]] && echo "$DATA" > "$CACHE_FILE"
    [[ -f "$CACHE_FILE" ]] && cat "$CACHE_FILE"
}

# ── IP Pública + geolocalización ─────────────────────────────────────
PUB_DATA=$(get_public_ip)
PUB_IP=$(echo "$PUB_DATA"     | jq -r '.ip      // "N/A"' 2>/dev/null || echo "N/A")
PUB_COUNTRY=$(echo "$PUB_DATA" | jq -r '.country // "??"'  2>/dev/null || echo "??")
PUB_CITY=$(echo "$PUB_DATA"   | jq -r '.city    // ""'    2>/dev/null || echo "")
PUB_ORG=$(echo "$PUB_DATA"    | jq -r '.org     // ""'    2>/dev/null | cut -c1-40)

# ── IPs locales ───────────────────────────────────────────────────────
LOCAL_IPS=$(ip -4 addr show \
    | grep -oP '(?<=inet\s)\d+(\.\d+){3}' \
    | grep -v '^127\.' \
    | paste -sd'   ')
[[ -z "$LOCAL_IPS" ]] && LOCAL_IPS="N/A"

# ── VPN (WireGuard / OpenVPN) ─────────────────────────────────────────
VPN_STATUS="DESCONECTADA"
VPN_IFACE=""
VPN_COLOR="$C_RED"
VPN_ICON="󰖂"

for iface in wg0 wg1 wg2 tun0 tun1 vpn0; do
    if ip link show "$iface" 2>/dev/null | grep -qE "state UP|,UP,"; then
        VPN_STATUS="ACTIVA"
        VPN_IFACE="  ($iface)"
        VPN_COLOR="$C_GREEN"
        VPN_ICON="󰌾"
        break
    fi
done

# ── Conexiones ────────────────────────────────────────────────────────
ESTABLISHED=$(ss -tn state established 2>/dev/null | tail -n +2 | wc -l)
TIMEWAIT=$(ss -tn state time-wait  2>/dev/null | tail -n +2 | wc -l)
LISTEN_COUNT=$(ss -tlnp 2>/dev/null | tail -n +2 | wc -l)
LISTEN_PORTS=$(ss -tlnp 2>/dev/null | tail -n +2 \
    | awk '{print $4}' | rev | cut -d: -f1 | rev \
    | sort -n | uniq | paste -sd', ')

# Top 3 IPs remotas con más conexiones (excluye loopback e internas)
TOP_IPS=$(ss -tn state established 2>/dev/null | tail -n +2 \
    | awk '{print $5}' | sed 's/\[//g; s/\]//g' \
    | rev | cut -d: -f2- | rev \
    | grep -vE '^(127\.|::1|$|192\.168\.|10\.|172\.(1[6-9]|2[0-9]|3[01])\.)' \
    | sort | uniq -c | sort -rn | head -3 \
    | awk '{printf "   %s  (%s conex)\n", $2, $1}' \
    | paste -sd'\n')

# ── DNS ───────────────────────────────────────────────────────────────
DNS=$(resolvectl status 2>/dev/null | grep -m1 "DNS Servers" | awk '{print $3}')
[[ -z "$DNS" ]] && DNS=$(grep -m1 "^nameserver" /etc/resolv.conf 2>/dev/null | awk '{print $2}')
[[ -z "$DNS" ]] && DNS="N/A"

case "$DNS" in
    1.1.1.1|1.0.0.1)   DNS_NAME="Cloudflare" ;;
    8.8.8.8|8.8.4.4)   DNS_NAME="Google"     ;;
    9.9.9.9)            DNS_NAME="Quad9"      ;;
    192.168.*|10.*)     DNS_NAME="LAN"        ;;
    *)                  DNS_NAME="Custom"     ;;
esac

# ── SSH sesiones remotas (sólo con IP remota, no consolas locales) ────
SSH_SESSIONS=$(who 2>/dev/null \
    | grep -E '\([0-9]{1,3}\.[0-9]{1,3}|[0-9a-f:]{3,}\)' \
    | wc -l)
SSH_COLOR="$C_GREEN"
SSH_ICON=""
[[ "$SSH_SESSIONS" -gt 0 ]] && { SSH_COLOR="$C_RED"; SSH_ICON="  "; }
SSH_DETAIL=""
[[ "$SSH_SESSIONS" -gt 0 ]] && \
    SSH_DETAIL=$(who 2>/dev/null \
        | grep -E '\([0-9]{1,3}\.[0-9]{1,3}|[0-9a-f:]{3,}\)' \
        | awk '{print "   " $1 "  desde  " $5}' | paste -sd'\n')

# ── Firewall ──────────────────────────────────────────────────────────
FW_INFO="no detectado"
FW_COLOR="$C_DIM"
if command -v nft &>/dev/null; then
    FW_RULES=$(sudo -n nft list ruleset 2>/dev/null \
        | grep -cE "^\s*(accept|drop|reject)" || true)
    if [[ -n "$FW_RULES" && "$FW_RULES" -gt 0 ]]; then
        FW_INFO="nftables  ($FW_RULES reglas activas)"
        FW_COLOR="$C_GREEN"
    else
        FW_INFO="nftables  (sin reglas detectadas)"
        FW_COLOR="$C_YELLOW"
    fi
elif command -v iptables &>/dev/null; then
    FW_INFO="iptables"
    FW_COLOR="$C_YELLOW"
fi

# ── Estado del módulo ─────────────────────────────────────────────────
ALERT=0
[[ "$VPN_STATUS" == "DESCONECTADA" ]] && ALERT=1
[[ "$SSH_SESSIONS" -gt 0 ]]          && ALERT=1

if [[ $ALERT -eq 1 ]]; then
    MOD_ICON="󰒙 "
    MOD_CLASS="sec-warn"
else
    MOD_ICON="󰒙"
    MOD_CLASS="sec-ok"
fi

# ── Tooltip ───────────────────────────────────────────────────────────
SEP="<span color='${C_DIM}'>──────────────────────────────</span>"

TT=""
TT+="<span color='${C_CYAN}'><b>󰒙  SECURITY MONITOR</b></span>\n"
TT+="${SEP}\n"

# Bloque IP
TT+="<span color='${C_DIM}'>  IP PÚBLICA</span>\n"
TT+="  <span color='${C_FG}'><b>${PUB_IP}</b></span>   <span color='${C_DIM}'>${PUB_COUNTRY} ${PUB_CITY}</span>\n"
[[ -n "$PUB_ORG" ]] && \
TT+="  <span color='${C_DIM}'>${PUB_ORG}</span>\n"
TT+="\n"
TT+="<span color='${C_DIM}'>  IP LOCAL</span>\n"
TT+="  <span color='${C_FG}'>${LOCAL_IPS}</span>\n"

TT+="${SEP}\n"

# VPN
TT+="<span color='${C_DIM}'>  VPN</span>\n"
TT+="  <span color='${VPN_COLOR}'><b>${VPN_ICON}  ${VPN_STATUS}${VPN_IFACE}</b></span>\n"
TT+="\n"

# Firewall
TT+="<span color='${C_DIM}'>  FIREWALL</span>\n"
TT+="  <span color='${FW_COLOR}'>󰒒  ${FW_INFO}</span>\n"

TT+="${SEP}\n"

# Conexiones
TT+="<span color='${C_DIM}'>  CONEXIONES</span>\n"
TT+="  <span color='${C_FG}'>󰌘  Established: <b>${ESTABLISHED}</b>    Time-wait: <b>${TIMEWAIT}</b></span>\n"
TT+="  <span color='${C_FG}'>󰁦  Puertos escuchando: <b>${LISTEN_COUNT}</b></span>\n"
[[ -n "$LISTEN_PORTS" ]] && \
TT+="  <span color='${C_DIM}'>${LISTEN_PORTS}</span>\n"
if [[ -n "$TOP_IPS" ]]; then
    TT+="  <span color='${C_DIM}'>Top IPs remotas:</span>\n"
    TT+="<span color='${C_DIM}'>${TOP_IPS}</span>\n"
fi

TT+="${SEP}\n"

# DNS
TT+="<span color='${C_DIM}'>  DNS</span>\n"
TT+="  <span color='${C_PURPLE}'>󰛡  ${DNS}   <span color='${C_DIM}'>(${DNS_NAME})</span></span>\n"
TT+="\n"

# SSH
TT+="<span color='${C_DIM}'>  SSH REMOTO</span>\n"
TT+="  <span color='${SSH_COLOR}'><b>${SSH_ICON}${SSH_SESSIONS} sesiones activas</b></span>\n"
[[ -n "$SSH_DETAIL" ]] && \
TT+="<span color='${C_DIM}'>${SSH_DETAIL}</span>\n"

# ── Output JSON para Waybar ───────────────────────────────────────────
/usr/bin/jq -cn \
    --arg text    "$MOD_ICON" \
    --arg tooltip "$(printf '%b' "$TT")" \
    --arg class   "$MOD_CLASS" \
    '{text: $text, tooltip: $tooltip, class: $class}'
