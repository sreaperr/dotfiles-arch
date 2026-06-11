#!/bin/bash
# update-local.sh — sincroniza los configs del repo a ~/.config/
# Los archivos de ~/.config/ son copias independientes del repo.
# Ejecutar después de cada git pull para aplicar cambios.
# Solo copia archivos, no instala paquetes ni toca servicios.

PATH_REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Sincronizando configs desde $PATH_REPO..."
echo ""

# Mostrar qué se va a sobreescribir
echo "Se copiarán los siguientes directorios a ~/.config/:"
for d in "$PATH_REPO/.config/"/*/; do
    echo "  → $(basename "$d")"
done
echo "  → user-dirs.dirs"
echo "  → .wallpaper/ (fondos)"
echo "  → .zshrc / .zprofile"
echo ""
read -rp "¿Continuar? (s/N): " CONFIRM
[[ "${CONFIRM,,}" != "s" ]] && echo "Cancelado." && exit 0

# Eliminar symlinks de runtime antes de copiar para que cp no los siga
# (rofi-theme-cycle.sh los convierte en symlinks a rutas absolutas de la máquina)
for f in \
    "$HOME/.config/waybar/theme.css" \
    "$HOME/.config/swaync/theme.css" \
    "$HOME/.config/rofi/theme.rasi" \
    "$HOME/.config/rofi/colors/current.rasi"
do
    [[ -L "$f" ]] && rm -f "$f"
done

# Copiar .config/
cp -r "$PATH_REPO/.config/." "$HOME/.config/"

# Copiar .zshrc y .zprofile
cp "$PATH_REPO/.zshrc"   "$HOME/.zshrc"
cp "$PATH_REPO/.zprofile" "$HOME/.zprofile"

# Re-aplicar el tema activo para regenerar los archivos de runtime
CURRENT_THEME=$(cat "$HOME/.config/.current-theme" 2>/dev/null || echo "desktop")
THEME_FUNCS="$HOME/.config/hypr/scripts/lib/theme-functions.sh"
THEME_META="$HOME/.config/themes/$CURRENT_THEME/meta.sh"

if [[ -f "$THEME_FUNCS" && -f "$THEME_META" ]]; then
    echo "Re-aplicando tema '$CURRENT_THEME'..."
    source "$THEME_FUNCS"
    source "$THEME_META"

    if [[ "${PARTIAL_THEME:-false}" == "true" ]]; then
        apply_partial_theme_symlinks "$CURRENT_THEME"
    else
        apply_theme_symlinks "$CURRENT_THEME"
    fi

    gsettings set org.gnome.desktop.interface gtk-theme    "$GTK_THEME"
    gsettings set org.gnome.desktop.interface icon-theme   "$ICON_THEME"
    gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR"
    gsettings set org.gnome.desktop.interface cursor-size  "$CURSOR_SIZE"
    gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
    apply_gtk_cursor "$GTK_THEME" "$ICON_THEME" "$CURSOR" "$CURSOR_SIZE"

    hyprctl reload &>/dev/null || true
fi

echo ""
echo "Hecho."
echo "  → Recarga shell:    source ~/.zshrc"
echo "  → Recarga Hyprland: hyprctl reload"
