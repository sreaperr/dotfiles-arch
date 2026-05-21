#!/bin/zsh
#------INSTALADOR DE ARCH CON: HYPRLAND
#------HECHO POR: SREAPER
#---------
#VARIABLES
#---------
# Ruta dinámica: funciona independientemente de dónde esté clonado el repo
path_install="${0:A}"
DOTFILES_STATIC="$(dirname "$path_install")"
#-----------------------------------------
#PERMISOS DE INSTALL.SH
#-----------------------------------------
if [ ! -x "$path_install" ]; then
    echo "EL ARCHIVO NO ES EJECUTABLE. Ejecuta: chmod +x $path_install" && exit 1
fi
#-----------------------------------------
#VERIFICAR QUE NO ES ROOT (paru no funciona como root)
#-----------------------------------------
if [ "$EUID" -eq 0 ]; then
    echo "No ejecutar como root. Usa un usuario normal con sudo." && exit 1
fi
#-----------------------
#ACTUALIZAR SISTEMA
#-----------------------
echo "ACTUALIZANDO PAQUETES Y REPOSITORIOS..."
sudo pacman -Syu --noconfirm
#-----------------------
#BASE DEL SISTEMA
#-----------------------
echo "INSTALANDO BASE DEL SISTEMA..."
# zsh primero, necesario antes del chsh
sudo pacman -S --noconfirm zsh
# Herramientas de compilación, imprescindible para AUR y desarrollo
sudo pacman -S --noconfirm base-devel
# Control de versiones y descargas
sudo pacman -S --noconfirm git curl wget
# Compresión y archivos
sudo pacman -S --noconfirm unzip zip p7zip rsync
# SSH, manuales y carpetas estándar del usuario
sudo pacman -S --noconfirm openssh man-db man-pages xdg-user-dirs
#-------------------
#CAMBIAR SHELL A ZSH
#-------------------
chsh -s $(command -v zsh)
#-----------------------
#HERRAMIENTAS CLI
#-----------------------
echo "INSTALANDO HERRAMIENTAS CLI..."
# Prompt personalizable (se inicializa al final del .zshrc)
sudo pacman -S --noconfirm starship
# Alternativas modernas a comandos clásicos
# bat=cat | eza=ls | ripgrep=grep | fd=find | sd=sed | procs=ps
sudo pacman -S --noconfirm bat eza ripgrep fd sd procs
# Fuzzy finder, integra con historial de zsh, zoxide y yazi
sudo pacman -S --noconfirm fzf
# Monitores y visualizadores del sistema
# btop=monitor de recursos | duf=uso de discos | dust=tamaño de directorios | fastfetch=info del sistema
sudo pacman -S --noconfirm btop duf dust fastfetch
# Utilidades de productividad en terminal
# tldr=man pages con ejemplos | tmux=multiplexor de terminal | zoxide=cd inteligente
sudo pacman -S --noconfirm tldr tmux zoxide
# File manager en terminal
sudo pacman -S --noconfirm yazi
# Git mejorado: delta=diff visual | lazygit=TUI de git
sudo pacman -S --noconfirm git-delta lazygit
# Monitor de ancho de banda por proceso
sudo pacman -S --noconfirm bandwhich
# Procesador de JSON desde CLI
sudo pacman -S --noconfirm jq
# Lector de markdown en terminal con formato
sudo pacman -S --noconfirm glow
# Benchmarking de comandos CLI
sudo pacman -S --noconfirm hyperfine
# Panel de widgets lateral (control center: brillo, volumen, bluetooth, calendario)
sudo pacman -S --noconfirm eww
# Editores
sudo pacman -S --noconfirm neovim
# Contenedores y snapshots del sistema
sudo pacman -S --noconfirm docker timeshift
sudo systemctl enable docker
# Añadir usuario al grupo docker para usarlo sin sudo
sudo usermod -aG docker $USER
echo "NOTA: El grupo 'docker' requiere cerrar sesión completamente para tener efecto."
#-----------------------
#RED Y DIAGNÓSTICO
#-----------------------
echo "INSTALANDO HERRAMIENTAS DE RED..."
# Escáner de red y puertos
sudo pacman -S --noconfirm nmap
# Herramientas clásicas de red: ifconfig, netstat, etc.
sudo pacman -S --noconfirm net-tools
# Diagnóstico DNS (dig), trazado de rutas y test de velocidad en red local
sudo pacman -S --noconfirm bind-tools traceroute mtr iperf3
#-----------------------
#DISCO Y HARDWARE
#-----------------------
echo "INSTALANDO HERRAMIENTAS DE DISCO Y HARDWARE..."
# Salud de discos HDD/SSD (smartctl)
sudo pacman -S --noconfirm smartmontools
# Gestión y diagnóstico de SSDs NVMe
sudo pacman -S --noconfirm nvme-cli
# Listar ficheros abiertos por procesos
sudo pacman -S --noconfirm lsof
# Información de dispositivos USB y hardware PCI (GPU, tarjetas de red, etc.)
sudo pacman -S --noconfirm usbutils pciutils
# Leer y escribir discos con formato NTFS (Windows)
sudo pacman -S --noconfirm ntfs-3g
# Automontaje de USBs y discos externos sin root en Wayland
sudo pacman -S --noconfirm udisks2 udiskie
#-----------------------
#GESTIÓN DEL SISTEMA ARCH
#-----------------------
echo "INSTALANDO HERRAMIENTAS DE GESTIÓN DE ARCH..."
# Actualiza la lista de mirrors de pacman ordenados por velocidad
sudo pacman -S --noconfirm reflector
# paccache (limpia caché de paquetes), pacdiff y otras utilidades de pacman
sudo pacman -S --noconfirm pacman-contrib
# Grabación de pantalla en Wayland
sudo pacman -S --noconfirm wf-recorder
#-----------------------
#SEGURIDAD
#-----------------------
echo "INSTALANDO HERRAMIENTAS DE SEGURIDAD..."
# GPG: cifrado, firma de commits de git y verificación de paquetes
sudo pacman -S --noconfirm gnupg
# Cifrado moderno de ficheros, alternativa ligera a GPG
sudo pacman -S --noconfirm age
#-----------------------
#AUDIO (PIPEWIRE)
#-----------------------
echo "INSTALANDO PAQUETES DE AUDIO..."
# PipeWire: servidor de audio moderno, reemplaza PulseAudio y JACK
sudo pacman -S --noconfirm pipewire
# Compatibilidad con apps que usan ALSA, PulseAudio y JACK respectivamente
sudo pacman -S --noconfirm pipewire-alsa pipewire-pulse pipewire-jack
# Session manager de PipeWire, obligatorio para que funcione
sudo pacman -S --noconfirm wireplumber
# GUI de control de volumen y dispositivos de audio
sudo pacman -S --noconfirm pavucontrol
#-----------------------
#BLUETOOTH
#-----------------------
echo "INSTALANDO PAQUETES DE BLUETOOTH..."
# Stack de bluetooth y herramientas CLI (bluetoothctl)
sudo pacman -S --noconfirm bluez bluez-utils
# Applet GUI para gestionar dispositivos bluetooth fácilmente
sudo pacman -S --noconfirm blueman
sudo systemctl enable bluetooth
sudo systemctl start bluetooth
#-----------------------
#RED
#-----------------------
echo "INSTALANDO GESTIÓN DE RED..."
# Gestor de conexiones de red y su applet de systray
sudo pacman -S --noconfirm networkmanager network-manager-applet
sudo systemctl enable NetworkManager
#-----------------------
#TECLADO
#-----------------------
echo "INSTALANDO SOPORTE DE TECLADO..."
# Remapeo de teclas a nivel de kernel, necesario para teclados con distribución Mac
# Permite reasignar Cmd, Opt, Fn a equivalentes Linux (Super, Alt, etc.)
sudo pacman -S --noconfirm keyd
sudo systemctl enable keyd
#-----------------------
#NÚCLEO HYPRLAND
#-----------------------
echo "INSTALANDO NÚCLEO HYPRLAND..."
# Compositor Wayland y sus librerías del ecosistema Hypr
sudo pacman -S --noconfirm hyprland aquamarine hyprlang hyprcursor hyprutils hyprgraphics
# Daemon de inactividad (apagar pantalla, suspender tras X minutos)
sudo pacman -S --noconfirm hypridle
# Pantalla de bloqueo del ecosistema Hypr
sudo pacman -S --noconfirm hyprlock
# Portales XDG: necesarios para screenshare, selectores de ficheros y apps sandboxed
sudo pacman -S --noconfirm xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
# Agente de autenticación gráfica (ventanas de sudo en apps GUI)
sudo pacman -S --noconfirm polkit-gnome
# Soporte Wayland para apps Qt5 y Qt6
sudo pacman -S --noconfirm qt5-wayland qt6-wayland
#-----------------------
#PLUGINS DE HYPRLAND (hyprpm)
#-----------------------
echo "INSTALANDO PLUGINS DE HYPRLAND..."
# hyprpm descarga y compila cada plugin para la versión exacta de Hyprland instalada
# Así los .so nunca quedan desactualizados entre máquinas
hyprpm update
# Repo oficial del equipo de Hyprland — contiene hyprexpo y borders-plus-plus
hyprpm add https://github.com/hyprwm/hyprland-plugins
# Repo externo — contiene hyprfocus (efecto de enfoque al cambiar ventana)
hyprpm add https://github.com/VortexCoyote/hyprfocus
# Activar los tres plugins (hyprpm los cargará automáticamente al iniciar Hyprland)
hyprpm enable borders-plus-plus
hyprpm enable hyprexpo
hyprpm enable hyprfocus
#-----------------------
#ENTORNO VISUAL
#-----------------------
echo "INSTALANDO ENTORNO VISUAL..."
# Emulador de terminal con aceleración GPU
sudo pacman -S --noconfirm kitty
# Barra de estado configurable con JSON y CSS
sudo pacman -S --noconfirm waybar
# Gestor de notificaciones
sudo pacman -S --noconfirm swaync
# Fondo de pantalla con soporte de transiciones animadas
sudo pacman -S --noconfirm swww
# Capturas de pantalla: grim=captura | slurp=selección de región
sudo pacman -S --noconfirm grim slurp
# Portapapeles para Wayland y su historial
sudo pacman -S --noconfirm wl-clipboard cliphist
# Control de brillo y reproducción multimedia
sudo pacman -S --noconfirm brightnessctl playerctl
# Anotaciones sobre capturas de pantalla
sudo pacman -S --noconfirm swappy
# Filtro de luz azul nocturno
sudo pacman -S --noconfirm wlsunset
# Gestión de contraseñas en terminal
sudo pacman -S --noconfirm pass
# Chat
sudo pacman -S --noconfirm discord
#-----------------------
#MULTIMEDIA
#-----------------------
echo "INSTALANDO HERRAMIENTAS MULTIMEDIA..."
# Procesamiento de vídeo y audio, lo necesitan muchas apps internamente
sudo pacman -S --noconfirm ffmpeg
# Manipulación de imágenes desde CLI (redimensionar, convertir formatos, etc.)
sudo pacman -S --noconfirm imagemagick
# Reproductor multimedia minimalista y potente
sudo pacman -S --noconfirm mpv
# Visor de imágenes para Wayland (equivalente a feh en X11)
sudo pacman -S --noconfirm imv
# Visor de PDFs con navegación por teclado + plugin de renderizado
sudo pacman -S --noconfirm zathura zathura-pdf-mupdf
#-----------------------
#FUENTES
#-----------------------
echo "INSTALANDO FUENTES..."
# Hack Nerd Font (usada en kitty, waybar y starship)
sudo pacman -S --noconfirm ttf-hack-nerd
# JetBrains Mono con iconos Nerd Fonts
sudo pacman -S --noconfirm ttf-jetbrains-mono-nerd
# Iconos Font Awesome para waybar y otras apps
sudo pacman -S --noconfirm ttf-font-awesome
# Soporte completo de emojis en todo el sistema
sudo pacman -S --noconfirm noto-fonts-emoji
#-----------------------
#INSTALACIÓN DE PARU (AUR HELPER)
#-----------------------
echo "INSTALANDO PARU..."
PARU_BUILD=$(mktemp -d)
git clone https://aur.archlinux.org/paru.git "$PARU_BUILD"
(cd "$PARU_BUILD" && makepkg -si --noconfirm)
rm -rf "$PARU_BUILD"
#-----------------------
#PAQUETES AUR
#-----------------------
echo "INSTALANDO PAQUETES DE AUR..."
# Launcher de aplicaciones para Wayland (fork de rofi)
paru -S --noconfirm rofi-wayland rofi-calc
# Navegadores
paru -S --noconfirm brave-bin tor-browser
# Música
paru -S --noconfirm spotify
# Pack completo de Nerd Fonts
paru -S --noconfirm nerd-fonts
# Utilidad de capturas integrada con el ecosistema Hyprland
paru -S --noconfirm hyprshot
# Iconos para rofi y apps GTK
paru -S --noconfirm kora-icon-theme bibata-cursor-theme
# Temas GTK alineados con los temas del sistema
paru -S --noconfirm tokyonight-gtk-theme-git
#------------------------------
#SYMLINKS PARA CLONAR ARCHIVOS
#------------------------------
echo "CREANDO SYMLINKS..."
DOTFILES="$DOTFILES_STATIC"
# Crear ~/.config si no existe
mkdir -p ~/.config
# Archivos en $HOME
ln -sf "$DOTFILES/.zshrc" ~/.zshrc
ln -sf "$DOTFILES/.zprofile" ~/.zprofile
# Carpetas en ~/.config
ln -sf "$DOTFILES/.config/hypr" ~/.config/hypr
ln -sf "$DOTFILES/.config/kitty" ~/.config/kitty
ln -sf "$DOTFILES/.config/nvim" ~/.config/nvim
ln -sf "$DOTFILES/.config/waybar" ~/.config/waybar
ln -sf "$DOTFILES/.config/swaync" ~/.config/swaync
ln -sf "$DOTFILES/.config/rofi" ~/.config/rofi
ln -sf "$DOTFILES/.config/starship" ~/.config/starship
ln -sf "$DOTFILES/.config/tmux" ~/.config/tmux
ln -sf "$DOTFILES/.config/yazi" ~/.config/yazi
mkdir -p "$DOTFILES/.config/.wallpaper"
ln -sf "$DOTFILES/.config/.wallpaper" ~/.config/.wallpaper
ln -sf "$DOTFILES/.config/fastfetch" ~/.config/fastfetch
ln -sf "$DOTFILES/.config/eww" ~/.config/eww
# Tema activo de eww (mismo que el tema por defecto del sistema)
ln -sf "$DOTFILES/.config/eww/themes/tokyonight.scss" ~/.config/eww/themes/active.scss
ln -sf "$DOTFILES/.config/btop" ~/.config/btop
ln -sf "$DOTFILES/.config/mpv" ~/.config/mpv
ln -sf "$DOTFILES/.config/zathura" ~/.config/zathura
ln -sf "$DOTFILES/.config/gtk-3.0" ~/.config/gtk-3.0
ln -sf "$DOTFILES/.config/gtk-4.0" ~/.config/gtk-4.0
ln -sf "$DOTFILES/.config/user-dirs.dirs" ~/.config/user-dirs.dirs
ln -sf "$DOTFILES/.gitconfig" ~/.gitconfig
# SSH config
mkdir -p ~/.ssh && chmod 700 ~/.ssh
ln -sf "$DOTFILES/.ssh/config" ~/.ssh/config
chmod 600 ~/.ssh/config
# keyd va en /etc, requiere sudo
sudo mkdir -p /etc/keyd
sudo ln -sf "$DOTFILES/.config/keyd/default.conf" /etc/keyd/default.conf
# Aplicar configs de sistema
[ -f /etc/pacman.conf ] && sudo cp /etc/pacman.conf /etc/pacman.conf.bak
sudo cp "$DOTFILES/etc/pacman.conf" /etc/pacman.conf
sudo cp "$DOTFILES/etc/reflector.conf" /etc/xdg/reflector/reflector.conf
sudo mkdir -p /etc/modprobe.d
sudo cp "$DOTFILES/etc/modprobe.d/hid_apple.conf" /etc/modprobe.d/hid_apple.conf
sudo systemctl enable reflector.timer
# Permisos de ejecución a los scripts
chmod +x "$DOTFILES/.config/eww/scripts/cpu.sh"
chmod +x "$DOTFILES/.config/eww/scripts/toggle-noche.sh"
chmod +x "$DOTFILES/.config/hypr/scripts/theme-switch.sh"
chmod +x "$DOTFILES/.config/hypr/scripts/wallpaper.sh"
chmod +x "$DOTFILES/.config/hypr/scripts/powermenu.sh"
chmod +x "$DOTFILES/.config/hypr/scripts/recorder.sh"
# Aplicar tema por defecto (tokyonight)
ln -sf "$DOTFILES/.config/waybar/themes/tokyonight.css" ~/.config/waybar/theme.css
ln -sf "$DOTFILES/.config/kitty/themes/tokyonight.conf" ~/.config/kitty/theme.conf
ln -sf "$DOTFILES/.config/rofi/themes/tokyonight.rasi" ~/.config/rofi/theme.rasi
ln -sf "$DOTFILES/.config/swaync/themes/tokyonight.css" ~/.config/swaync/theme.css
ln -sf "$DOTFILES/.config/hypr/themes/tokyonight.conf" ~/.config/hypr/theme.conf
ln -sf "$DOTFILES/.config/hypr/themes/hyprlock-tokyonight.conf" ~/.config/hypr/hyprlock-theme.conf
echo "tokyonight" > ~/.config/.current-theme
echo "Bibata-Modern-Ice" > ~/.config/.current-cursor
# Crear carpetas en español
xdg-user-dirs-update
#-----------------------
#INSTALACIÓN DE TPM (TMUX PLUGIN MANAGER)
#-----------------------
echo "INSTALANDO TPM..."
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
#-----------------------
#INSTALACIÓN DE OH MY ZSH
#-----------------------
echo "INSTALANDO OH MY ZSH..."
# --unattended evita que el instalador lance zsh interactivo y rompa el script
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
# PLUGINS EXTERNOS DE OH-MY-ZSH
git clone https://github.com/zsh-users/zsh-autosuggestions \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-history-substring-search \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search

echo "INSTALACIÓN COMPLETADA. Reinicia sesión para aplicar todos los cambios."
