#!/bin/bash
set -e
# == clear para mostrar mi logo en GRANDE ==
clear
cat <<'EOF'

  ███████╗██████╗ ███████╗ █████╗ ██████╗ ███████╗██████╗
  ██╔════╝██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔════╝██╔══██╗
  ███████╗██████╔╝█████╗  ███████║██████╔╝█████╗  ██████╔╝
  ╚════██║██╔══██╗██╔══╝  ██╔══██║██╔═══╝ ██╔══╝  ██╔══██╗
  ███████║██║  ██║███████╗██║  ██║██║     ███████╗██║  ██║
  ╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝     ╚══════╝╚═╝  ╚═╝

           Dotfiles · Arch Linux + Hyprland
           github.com/sreaperr/dotfiles-arch

EOF
# == Comprobaciones ==
[[ -f /etc/os-release ]] && source /etc/os-release
[[ "${ID:-}" == "arch" ]] || {
    echo "Solo Arch Linux."
    exit 1
}
[[ "$EUID" -ne 0 ]] || {
    echo "No ejecutar como root."
    exit 1
}
# == Variables ==
HOME_DIR="$HOME"
PATH_REPO="$HOME_DIR/dotfiles-arch"
# == Actualizar repos ==
echo "*** Actualizar REPOS ***" && sleep 3
sudo pacman -Syu --noconfirm
# == Instalar paru ==
echo "*** Instalando PARU ***" && sleep 2
# Rust necesario para compilar paru desde fuente
sudo pacman -S --needed --noconfirm git base-devel curl rust
if ! command -v paru &>/dev/null; then
    rm -rf "$HOME_DIR/paru-src"
    git clone https://aur.archlinux.org/paru.git "$HOME_DIR/paru-src" || {
        echo "Error: no se pudo clonar paru"
        exit 1
    }
    cd "$HOME_DIR/paru-src" || {
        echo "Error: directorio paru-src no encontrado"
        exit 1
    }
    makepkg -si --noconfirm && sleep 2
    cd "$HOME_DIR"
else
    echo "paru ya instalado, omitiendo."
fi
# == Paquetes pacman ==
# Dependencias de compilación (hyprpm, AUR builds)
sudo pacman -S --needed --noconfirm cmake cpio pkgconf gcc
# WM + compositor
sudo pacman -S --needed --noconfirm hyprland hypridle hyprlock xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
# Barra de estado
sudo pacman -S --needed --noconfirm waybar
# Audio
sudo pacman -S --needed --noconfirm pipewire pipewire-alsa pipewire-pulse wireplumber pavucontrol playerctl
# Red y Bluetooth
sudo pacman -S --needed --noconfirm networkmanager network-manager-applet bluez bluez-utils blueman
# Pantalla y captura
sudo pacman -S --needed --noconfirm wlsunset grim slurp wf-recorder flameshot
# Portapapeles
sudo pacman -S --needed --noconfirm wl-clipboard cliphist
# Sistema
sudo pacman -S --needed --noconfirm polkit-gnome kanshi udiskie libnotify nautilus xdg-user-dirs
# Terminal y utilidades CLI
sudo pacman -S --needed --noconfirm kitty tmux neovim yazi btop fastfetch calcurse bat jq ffmpeg lazygit eza fd fzf ripgrep brightnessctl pacman-contrib figlet glow git-delta
# Python
sudo pacman -S --needed --noconfirm python python-pip
# Fuentes e iconos
sudo pacman -S --needed --noconfirm papirus-icon-theme
# Navegadores
sudo pacman -S --needed --noconfirm firefox
# Shell
sudo pacman -S --needed --noconfirm zsh zoxide zsh-autosuggestions zsh-syntax-highlighting
# Notificaciones (en repos oficiales desde 2024)
sudo pacman -S --needed --noconfirm swaync
# == Paquetes AUR ==
# WM extras + launcher (pyprland separado para evitar prompt de proveedor)
paru -S --needed --noconfirm rofi-wayland uwsm swayosd
paru -S --needed --noconfirm pyprland
# Wallpaper daemon
paru -S --needed --noconfirm swww 2>/dev/null || paru -S --needed --noconfirm awww 2>/dev/null ||
    echo "Aviso: no se encontró swww ni awww en AUR — instala el daemon de wallpaper manualmente."
# Navegadores
paru -S --needed --noconfirm brave-bin google-chrome tor-browser
# Entretenimiento
paru -S --needed --noconfirm spotify
# Temas y apariencia
paru -S --needed --noconfirm bibata-cursor-theme kora-icon-theme tokyonight-gtk-theme-git
# Nerd Fonts (todas)
paru -S --needed --noconfirm nerd-fonts
# Terminal extras
paru -S --needed --noconfirm tty-clock oh-my-posh-bin zsh-history-substring-search procs dust duf
# GTK settings (Wayland)
paru -S --needed --noconfirm nwg-look
# == TPM - Gestor de plugins de tmux ==
git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"

# == Servicios ==
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now bluetooth
# == Carpetas de usuario en español ==
# Requiere que es_ES.UTF-8 esté generado (locale-gen) — lo verificamos antes
if locale -a 2>/dev/null | grep -qi "es_ES.utf8\|es_ES.UTF-8"; then
    LC_ALL=es_ES.UTF-8 xdg-user-dirs-update --force
else
    echo "Aviso: locale es_ES.UTF-8 no generado, omitiendo xdg-user-dirs."
fi
# == Shell por defecto ==
chsh -s "$(which zsh)"
# == Instalar oh-my-zsh ==
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# == Clonando .config del repo a local ==
cp -r "$PATH_REPO/.config/." "$HOME/.config/"

# Crear archivo vacío de keybinds locales si no existe (gitignored, cada máquina lo gestiona)
touch "$HOME/.config/hypr/keybinds-local.conf"

# == Copiar configs del sistema ==
sudo mkdir -p /etc/xdg/reflector
sudo cp "$PATH_REPO/etc/pacman.conf" /etc/pacman.conf
sudo cp "$PATH_REPO/etc/reflector.conf" /etc/xdg/reflector/reflector.conf
cp "$PATH_REPO/.zprofile" "$HOME/.zprofile"
cp "$PATH_REPO/.zshrc" "$HOME/.zshrc"

# == Tema por defecto (desktop) ==
# Solo copia los archivos de color — no se recarga nada porque Hyprland aún no está corriendo.
# Al primer arranque, apply-theme.sh se ejecuta desde theme-startup.sh dentro de la sesión.
THEME_SRC="$HOME/.config/themes/desktop"
cp -f "$THEME_SRC/waybar.css" "$HOME/.config/waybar/theme.css"
cp -f "$THEME_SRC/rofi.rasi" "$HOME/.config/rofi/theme.rasi"
cp -f "$THEME_SRC/rofi.rasi" "$HOME/.config/rofi/colors/current.rasi"
cp -f "$THEME_SRC/swaync.css" "$HOME/.config/swaync/theme.css"
cp -f "$THEME_SRC/hypr.conf" "$HOME/.config/hypr/theme.conf"
cp -f "$THEME_SRC/hyprlock.conf" "$HOME/.config/hypr/hyprlock-theme.conf"
cp -f "$THEME_SRC/kitty.conf" "$HOME/.config/kitty/theme.conf"
cp -f "$THEME_SRC/tmux.conf" "$HOME/.config/tmux/theme.conf"
cp -f "$THEME_SRC/yazi.toml" "$HOME/.config/yazi/theme.toml"
cp -f "$THEME_SRC/omp.json" "$HOME/.config/omp/theme.json"
[[ -f "$THEME_SRC/highlight.zsh" ]] && cp -f "$THEME_SRC/highlight.zsh" "$HOME/.config/zsh/highlight.zsh"
echo "desktop" >"$HOME/.config/.current-theme"
clear
echo ""
echo "Instalación completada. Reinicia el sistema."
echo "Una vez dentro de Hyprland ejecuta 'nwg-look' para aplicar tema GTK, cursor e iconos."
cat <<'EOF'

  ███████╗██████╗ ███████╗ █████╗ ██████╗ ███████╗██████╗
  ██╔════╝██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔════╝██╔══██╗
  ███████╗██████╔╝█████╗  ███████║██████╔╝█████╗  ██████╔╝
  ╚════██║██╔══██╗██╔══╝  ██╔══██║██╔═══╝ ██╔══╝  ██╔══██╗
  ███████║██║  ██║███████╗██║  ██║██║     ███████╗██║  ██║
  ╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝     ╚══════╝╚═╝  ╚═╝

           Dotfiles · Arch Linux + Hyprland
           github.com/sreaperr/dotfiles-arch

EOF
echo ""
echo ""
echo "*** THANK YOU FOR YOUR SUPPORT ENJOY THE SYSTEM ***"
