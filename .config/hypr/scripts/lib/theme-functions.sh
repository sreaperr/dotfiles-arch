#!/bin/bash

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"

# ── Carpeta centralizada de temas ────────────────────────────────────────────
THEMES_DIR="$DOTFILES/.config/themes"

safe_cp() { [[ -L "$2" ]] && rm -f "$2"; cp -f "$1" "$2"; }

# ── Colores compartidos de rofi/waybar/swaync (SUPER+R) ──────────────────────
apply_color_scheme() {
    local SCHEME=$1
    local COLORS_DIR="$HOME/.config/rofi/colors"

    [[ -f "$COLORS_DIR/$SCHEME.rasi" ]] && ln -sf "$COLORS_DIR/$SCHEME.rasi" "$COLORS_DIR/current.rasi"
    ln -sf "$HOME/.config/rofi/colors-bridge.rasi" "$HOME/.config/rofi/theme.rasi"

    local WAYBAR_CSS="$HOME/.config/waybar/themes/$SCHEME.css"
    if [[ -f "$WAYBAR_CSS" ]]; then
        ln -sf "$WAYBAR_CSS" "$HOME/.config/waybar/theme.css"
        pkill -x waybar 2>/dev/null
        sleep 0.3
        (systemctl --user start waybar 2>/dev/null || waybar &) >/dev/null 2>&1
        (sleep 0.5 && awww restore) >/dev/null 2>&1 &
    fi

    local SWAYNC_CSS="$HOME/.config/swaync/colors/$SCHEME.css"
    if [[ -f "$SWAYNC_CSS" ]]; then
        ln -sf "$SWAYNC_CSS" "$HOME/.config/swaync/theme.css"
        swaync-client --reload-css >/dev/null 2>&1 || true
    fi
}

# ── Colorscheme de Neovim ─────────────────────────────────────────────────────
apply_nvim_colorscheme() {
    local SCHEME=$1 T=$2

    [[ -z "$SCHEME" ]] && return 0

    local THEMES_LUA="$HOME/.config/nvim/lua/plugins/themes.lua"
    [[ -f "$THEMES_LUA" ]] && sed -i "s|colorscheme = \".*\"|colorscheme = \"$SCHEME\"|" "$THEMES_LUA"

    if [[ -f "$T/nvim.lua" ]]; then
        mkdir -p "$HOME/.config/nvim/colors"
        cp -f "$T/nvim.lua" "$HOME/.config/nvim/colors/$SCHEME.lua"
    fi
}

apply_partial_theme_symlinks() {
    local THEME=$1
    local T="$THEMES_DIR/$THEME"

    if [[ ! -d "$T" ]]; then
        echo "ERROR: tema '$THEME' no encontrado en $THEMES_DIR" >&2
        return 1
    fi

    safe_cp "$T/kitty.conf"      "$HOME/.config/kitty/theme.conf"
    safe_cp "$T/fastfetch.jsonc" "$HOME/.config/fastfetch/config.jsonc"
    rm -f "$HOME/.config/omp/theme.json" && cp "$T/omp.json" "$HOME/.config/omp/theme.json"
    [[ -f "$T/highlight.zsh" ]] && safe_cp "$T/highlight.zsh" "$HOME/.config/zsh/highlight.zsh"

    # ── Colores de rofi/waybar/swaync a juego con el tema ──────────────────
    apply_color_scheme "$ROFI_COLORS"

    # ── Colorscheme de nvim ─────────────────────────────────────────────────
    apply_nvim_colorscheme "$NVIM_SCHEME" "$T"

    # ── Calcurse: actualizar solo la línea de color ────────────────────────
    if [[ -f "$T/calcurse.conf" ]]; then
        local calcurse_color
        calcurse_color=$(tr -d '\n' < "$T/calcurse.conf")
        sed -i "s|^appearance\.theme=.*|appearance.theme=$calcurse_color|" \
            "$HOME/.config/calcurse/conf"
    fi

    # ── Bordes de ventana ────────────────────────────────────────────────────
    if [[ -f "$T/hypr.conf" ]]; then
        safe_cp "$T/hypr.conf" "$HOME/.config/hypr/theme.conf"
        hyprctl reload &>/dev/null || true
    fi
}

apply_theme_symlinks() {
    local THEME=$1
    local T="$THEMES_DIR/$THEME"

    # Comprobar que el tema existe
    if [[ ! -d "$T" ]]; then
        echo "ERROR: tema '$THEME' no encontrado en $THEMES_DIR" >&2
        return 1
    fi

    apply_partial_theme_symlinks "$THEME"

    # ── Copiar archivos de tema ────────────────────────────────────────────
    safe_cp "$T/hyprlock.conf"   "$HOME/.config/hypr/hyprlock-theme.conf"
    safe_cp "$T/yazi.toml"       "$HOME/.config/yazi/theme.toml"
    safe_cp "$T/tmux.conf"       "$HOME/.config/tmux/theme.conf"

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

    _gtk_set_key() {
        local file="$1" key="$2" val="$3"
        if grep -q "^${key}" "$file" 2>/dev/null; then
            sed -i "s|^${key}.*|${key} = ${val}|" "$file"
        else
            printf '%s = %s\n' "$key" "$val" >> "$file"
        fi
    }

    for ini in "$HOME/.config/gtk-3.0/settings.ini" \
               "$HOME/.config/gtk-4.0/settings.ini"; do
        # Crear fichero con cabecera si no existe
        [[ -f "$ini" ]] || printf '[Settings]\n' > "$ini"
        _gtk_set_key "$ini" "gtk-theme-name"                    "$GTK_THEME"
        _gtk_set_key "$ini" "gtk-icon-theme-name"               "$ICON_THEME"
        _gtk_set_key "$ini" "gtk-cursor-theme-name"             "$CURSOR"
        _gtk_set_key "$ini" "gtk-cursor-theme-size"             "$CURSOR_SIZE"
        _gtk_set_key "$ini" "gtk-font-name"                     "Hack Nerd Font 11"
        _gtk_set_key "$ini" "gtk-application-prefer-dark-theme" "1"
    done
}
