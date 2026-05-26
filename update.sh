#!/bin/bash
#============================================================
#  SCRIPT DE ACTUALIZACIÓN MULTI-DISTRO
#  Se ejecuta automáticamente al encender el PC (crontab @reboot)
#  También puede ejecutarse manualmente: ./update.sh
#  DISTROS SOPORTADAS: Arch Linux | Fedora | Debian Sid/Testing
#============================================================

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

# Detectar distribución
if [[ -f /etc/os-release ]]; then
    # shellcheck source=/dev/null
    . /etc/os-release
    DISTRO="$ID"
else
    DISTRO="unknown"
fi

ERRORES=0
log() { echo "[$(date '+%H:%M')] $*"; }

log "Iniciando actualización del sistema ($DISTRO)..."

#------------------------------------------------------------
#  SISTEMA + PAQUETES (distro-específico)
#------------------------------------------------------------
case "$DISTRO" in
    arch)
        # Actualizar mirrors ordenados por velocidad antes de descargar paquetes
        log "Actualizando mirrors (reflector)..."
        sudo reflector --save /etc/pacman.d/mirrorlist \
            --sort rate --latest 10 --protocol https --country Spain,France,Germany \
            2>/dev/null || log "WARN: reflector falló, continuando..."

        log "Actualizando paquetes del sistema (pacman)..."
        sudo pacman -Syu --noconfirm 2>&1 | tail -5 || ERRORES=$((ERRORES+1))

        log "Actualizando paquetes AUR (paru)..."
        paru -Sua --noconfirm 2>&1 | tail -5 || ERRORES=$((ERRORES+1))
        ;;

    fedora)
        log "Actualizando paquetes del sistema (dnf)..."
        sudo dnf update -y 2>&1 | tail -5 || ERRORES=$((ERRORES+1))

        log "Actualizando apps Flatpak..."
        flatpak update -y 2>&1 | tail -5 || ERRORES=$((ERRORES+1))
        ;;

    debian)
        log "Actualizando paquetes del sistema (apt)..."
        sudo apt update && sudo apt full-upgrade -y 2>&1 | tail -5 || ERRORES=$((ERRORES+1))
        sudo apt autoremove -y 2>/dev/null || true

        log "Actualizando apps Flatpak..."
        flatpak update -y 2>&1 | tail -5 || ERRORES=$((ERRORES+1))
        ;;

    *)
        log "WARN: Distro '$DISTRO' no reconocida — omitiendo actualización del sistema."
        ;;
esac

#------------------------------------------------------------
#  PLUGINS HYPRLAND (común a todas las distros)
#------------------------------------------------------------
log "Actualizando plugins de Hyprland (hyprpm)..."
hyprpm update 2>&1 | tail -3 || log "WARN: hyprpm no disponible"

#------------------------------------------------------------
#  NEOVIM (común)
#------------------------------------------------------------
log "Actualizando plugins de Neovim (lazy.nvim)..."
nvim --headless "+Lazy! sync" +qa 2>/dev/null || log "WARN: nvim no disponible"

#------------------------------------------------------------
#  TMUX (común)
#------------------------------------------------------------
log "Actualizando plugins de Tmux (tpm)..."
"$HOME/.tmux/plugins/tpm/bin/update_plugins" all 2>/dev/null \
    || log "WARN: tpm no disponible"

#------------------------------------------------------------
#  TIMESTAMP Y NOTIFICACIÓN
#------------------------------------------------------------
date +%s > "$STAMP"

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
