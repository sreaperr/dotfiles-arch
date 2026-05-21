#!/bin/bash
#==========================
# SYNC.SH — aplica cambios tras git pull
# Uso: git pull && ./sync.sh
#
# No reinstala todo — solo añade lo que falta
# en una instalación existente:
#   - Paquetes nuevos
#   - Symlinks nuevos
#   - Crontab de actualización automática
#   - Permisos de scripts
#   - Recarga el entorno si Hyprland está corriendo
#==========================

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME=$(cat "$HOME/.config/.current-theme" 2>/dev/null || echo "tokyonight")

ok()   { echo "  ✓ $*"; }
skip() { echo "  · $* (ya existe)"; }
info() { echo ""; echo "→ $*"; }

# ─── PAQUETES NUEVOS ──────────────────────────────────────────

info "Comprobando paquetes nuevos..."

pkg_check() {
    pacman -Qi "$1" &>/dev/null || sudo pacman -S --noconfirm "$1" && ok "instalado $1" || true
}

pkg_check eww
pkg_check kanshi

# ─── SYMLINKS NUEVOS ──────────────────────────────────────────

info "Comprobando symlinks..."

link() {
    local src="$1" dst="$2"
    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
        skip "$dst"
    else
        ln -sf "$src" "$dst" && ok "$dst"
    fi
}

mkdir -p "$HOME/.config"

link "$DOTFILES/.config/eww"     "$HOME/.config/eww"
link "$DOTFILES/.config/kanshi" "$HOME/.config/kanshi"
link "$DOTFILES/.config/hypr"  "$HOME/.config/hypr"
link "$DOTFILES/.config/waybar" "$HOME/.config/waybar"
link "$DOTFILES/.config/rofi"  "$HOME/.config/rofi"
link "$DOTFILES/.config/swaync" "$HOME/.config/swaync"
link "$DOTFILES/.config/kitty" "$HOME/.config/kitty"
link "$DOTFILES/.config/starship" "$HOME/.config/starship"
link "$DOTFILES/.config/fastfetch" "$HOME/.config/fastfetch"
link "$DOTFILES/.config/btop"  "$HOME/.config/btop"
link "$DOTFILES/.config/nvim"  "$HOME/.config/nvim"
link "$DOTFILES/.config/tmux"  "$HOME/.config/tmux"
link "$DOTFILES/.config/yazi"  "$HOME/.config/yazi"

# Tema activo de eww
link "$DOTFILES/.config/eww/themes/${THEME}.scss" \
     "$HOME/.config/eww/themes/active.scss"

# Starship: apuntar al toml correcto según tema actual
if [ "$THEME" = "auditory" ]; then
    link "$DOTFILES/.config/starship/themes/auditory.toml" \
         "$HOME/.config/starship/starship.toml"
else
    link "$DOTFILES/.config/starship/themes/tokyonight.toml" \
         "$HOME/.config/starship/starship.toml"
fi
rm -rf "$HOME/.cache/starship/" 2>/dev/null

# ─── PERMISOS DE SCRIPTS ──────────────────────────────────────

info "Actualizando permisos de scripts..."

chmod +x "$DOTFILES/update.sh"
chmod +x "$DOTFILES/sync.sh"
chmod +x "$DOTFILES/.config/eww/scripts/"*.sh
chmod +x "$DOTFILES/.config/hypr/scripts/"*.sh
chmod +x "$DOTFILES/.config/waybar/"*.sh
chmod +x "$DOTFILES/.config/swaync/"*.sh
ok "permisos de scripts actualizados"

# ─── CRONTAB ──────────────────────────────────────────────────

info "Configurando actualización automática (crontab @reboot)..."

CRON_CMD="@reboot sleep 60 && ${DOTFILES}/update.sh >> \$HOME/.local/share/update.log 2>&1"

if crontab -l 2>/dev/null | grep -q "update.sh"; then
    skip "crontab ya configurado"
else
    (crontab -l 2>/dev/null; echo "$CRON_CMD") | crontab -
    ok "crontab configurado"
fi

# ─── RECARGA DEL ENTORNO ──────────────────────────────────────

info "Recargando entorno..."

if hyprctl version &>/dev/null; then
    hyprctl reload && ok "Hyprland recargado"
    systemctl --user restart waybar 2>/dev/null && ok "Waybar reiniciado"
    eww reload 2>/dev/null && ok "eww recargado" || \
        (eww daemon 2>/dev/null && eww open control-center --toggle && eww open control-center --toggle && ok "eww iniciado")
else
    echo "  · Hyprland no está corriendo — los cambios se aplicarán en el próximo inicio de sesión"
fi

# ─── LISTO ────────────────────────────────────────────────────

echo ""
echo "Sincronización completada. Tema activo: $THEME"
