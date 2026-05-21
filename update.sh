#!/bin/bash
#==========================
# SCRIPT DE ACTUALIZACIÓN
# Se ejecuta automáticamente al encender el PC (crontab @reboot)
# También puede ejecutarse manualmente: ./update.sh
#==========================

# Evitar actualizaciones si se ejecutó hace menos de 24 horas
STAMP="$HOME/.local/share/.last-update"
if [ -f "$STAMP" ]; then
    LAST=$(cat "$STAMP")
    NOW=$(date +%s)
    DIFF=$(( NOW - LAST ))
    if [ "$DIFF" -lt 86400 ]; then
        echo "[$(date '+%H:%M')] Actualización reciente (hace $(( DIFF/3600 ))h), omitiendo."
        exit 0
    fi
fi

ERRORES=0
log() { echo "[$(date '+%H:%M')] $*"; }

log "Iniciando actualización del sistema..."

# --- MIRRORS ---
log "Actualizando mirrors de pacman..."
sudo reflector --save /etc/pacman.d/mirrorlist \
    --sort rate --latest 10 --protocol https --country Spain,France,Germany \
    2>/dev/null || { log "WARN: reflector falló, continuando..."; }

# --- SISTEMA ---
log "Actualizando paquetes del sistema (pacman)..."
sudo pacman -Syu --noconfirm 2>&1 | tail -5 || ERRORES=$((ERRORES+1))

# --- AUR ---
log "Actualizando paquetes AUR (paru)..."
paru -Sua --noconfirm 2>&1 | tail -5 || ERRORES=$((ERRORES+1))

# --- PLUGINS HYPRLAND ---
log "Actualizando plugins de Hyprland (hyprpm)..."
hyprpm update 2>&1 | tail -3 || log "WARN: hyprpm no disponible"

# --- NEOVIM ---
log "Actualizando plugins de Neovim (lazy.nvim)..."
nvim --headless "+Lazy! sync" +qa 2>/dev/null || log "WARN: nvim no disponible"

# --- TMUX ---
log "Actualizando plugins de Tmux (tpm)..."
"$HOME/.tmux/plugins/tpm/bin/update_plugins" all 2>/dev/null \
    || log "WARN: tpm no disponible"

# --- TIMESTAMP ---
date +%s > "$STAMP"

# --- NOTIFICACIÓN ---
if [ "$ERRORES" -eq 0 ]; then
    log "Actualización completada sin errores."
    notify-send "Sistema actualizado" \
        "Paquetes, Hyprland, Neovim y Tmux al día." \
        -i system-software-update 2>/dev/null || true
else
    log "Actualización completada con $ERRORES error(es). Revisa el log."
    notify-send "Actualización con errores" \
        "$ERRORES componente(s) fallaron. Revisa ~/.local/share/update.log" \
        -i dialog-warning 2>/dev/null || true
fi
