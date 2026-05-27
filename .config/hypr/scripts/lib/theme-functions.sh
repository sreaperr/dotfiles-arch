#!/bin/bash

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"

# ── Carpeta centralizada de temas ────────────────────────────────────────────
THEMES_DIR="$DOTFILES/.config/themes"

apply_theme_symlinks() {
    local THEME=$1
    local T="$THEMES_DIR/$THEME"

    # Comprobar que el tema existe
    if [[ ! -d "$T" ]]; then
        echo "ERROR: tema '$THEME' no encontrado en $THEMES_DIR" >&2
        return 1
    fi

    # ── Symlinks directos ──────────────────────────────────────────────────
    ln -sf "$T/waybar.css"      "$HOME/.config/waybar/theme.css"
    ln -sf "$T/kitty.conf"      "$HOME/.config/kitty/theme.conf"
    ln -sf "$T/rofi.rasi"       "$HOME/.config/rofi/theme.rasi"
    ln -sf "$T/swaync.css"      "$HOME/.config/swaync/theme.css"
    ln -sf "$T/hypr.conf"       "$HOME/.config/hypr/theme.conf"
    ln -sf "$T/hyprlock.conf"   "$HOME/.config/hypr/hyprlock-theme.conf"
    ln -sf "$T/yazi.toml"       "$HOME/.config/yazi/theme.toml"
    ln -sf "$T/starship.toml"   "$HOME/.config/starship/starship.toml"
    ln -sf "$T/tmux.conf"       "$HOME/.config/tmux/theme.conf"
    ln -sf "$T/fastfetch.jsonc" "$HOME/.config/fastfetch/config.jsonc"
    rm -rf "$HOME/.cache/starship/" 2>/dev/null

    # ── Nvim: solo si el tema tiene colorscheme propio (.lua) ─────────────
    if [[ -f "$T/nvim.lua" ]]; then
        ln -sf "$T/nvim.lua" "$HOME/.config/nvim/colors/${THEME}.lua"
    fi

    # ── Calcurse: actualizar solo la línea de color ────────────────────────
    if [[ -f "$T/calcurse.conf" ]]; then
        local calcurse_color
        calcurse_color=$(tr -d '\n' < "$T/calcurse.conf")
        sed -i "s|^appearance\.theme=.*|appearance.theme=$calcurse_color|" \
            "$HOME/.config/calcurse/conf"
    fi

    # ── SwayOSD: copiar CSS y reiniciar servidor ───────────────────────────
    if [[ -f "$T/swayosd.css" ]]; then
        cp "$T/swayosd.css" "$HOME/.config/swayosd/style.css"
        pkill -x swayosd-server 2>/dev/null || true
        nohup swayosd-server --style "$HOME/.config/swayosd/style.css" \
            >/dev/null 2>&1 &
    fi
}

apply_gtk_cursor() {
    local GTK_THEME=$1 ICON_THEME=$2 CURSOR=$3 CURSOR_SIZE=$4
    local content
    content="[Settings]
gtk-theme-name        = $GTK_THEME
gtk-icon-theme-name   = $ICON_THEME
gtk-cursor-theme-name = $CURSOR
gtk-cursor-theme-size = $CURSOR_SIZE
gtk-font-name         = Hack Nerd Font 11
gtk-application-prefer-dark-theme = 1"
    for ini in "$HOME/.config/gtk-3.0/settings.ini" \
               "$HOME/.config/gtk-4.0/settings.ini"; do
        printf '%s\n' "$content" > "$ini"
    done
}
