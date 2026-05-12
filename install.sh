#!/bin/zsh
#------INSTALADOR DE ARCH CON: HYPRLAND
#------HECHO POR: SREAPER
#---------
#VARIABLES
#---------
path_install=~/dotfiles-arch/install.sh
#-----------------------------------------
#PERMISOS DE INSTALL.SH
#-----------------------------------------
if [ ! -x "$path_install" ]; then
    echo "EL ARCHIVO NO ES EJECUTABLE" && exit 1
fi
#-------------------
#CAMBIAR SHELL A ZSH
#-------------------
chsh -s $(command -v zsh)
#-----------------------
#ACTUALIZAR SISTEMA
#-----------------------
echo "ACTUALIZANDO PAQUETES Y REPOSITORIOS..."
pacman -Syu --noconfirm
#-----------------------
#BASE DEL SISTEMA
#-----------------------
echo "INSTALANDO BASE DEL SISTEMA..."
# Herramientas de compilación, imprescindible para AUR y desarrollo
pacman -S --noconfirm base-devel
# Control de versiones y descargas
pacman -S --noconfirm git curl wget
# Compresión y archivos
pacman -S --noconfirm unzip zip p7zip rsync
# SSH, manuales y carpetas estándar del usuario (Descargas, Documentos, etc.)
pacman -S --noconfirm openssh man-db man-pages xdg-user-dirs
#-----------------------
#HERRAMIENTAS CLI
#-----------------------
echo "INSTALANDO HERRAMIENTAS CLI..."
# Prompt personalizable (se inicializa al final del .zshrc)
pacman -S --noconfirm starship
# Alternativas modernas a comandos clásicos
# bat=cat | eza=ls | ripgrep=grep | fd=find | sd=sed | procs=ps
pacman -S --noconfirm bat eza ripgrep fd sd procs
# Fuzzy finder, integra con historial de zsh, zoxide y yazi
pacman -S --noconfirm fzf
# Monitores y visualizadores del sistema
# btop=monitor de recursos | duf=uso de discos | dust=tamaño de directorios | fastfetch=info del sistema
pacman -S --noconfirm btop duf dust fastfetch
# Utilidades de productividad en terminal
# tldr=man pages con ejemplos | tmux=multiplexor de terminal | zoxide=cd inteligente
pacman -S --noconfirm tldr tmux zoxide
# File manager en terminal
pacman -S --noconfirm yazi
# Git mejorado: delta=diff visual | lazygit=TUI de git
pacman -S --noconfirm git-delta lazygit
# Monitor de ancho de banda por proceso
pacman -S --noconfirm bandwhich
# Procesador de JSON desde CLI
pacman -S --noconfirm jq
# Lector de markdown en terminal con formato
pacman -S --noconfirm glow
# Benchmarking de comandos CLI
pacman -S --noconfirm hyperfine
# Editores
pacman -S --noconfirm neovim
# Contenedores y snapshots del sistema
pacman -S --noconfirm docker timeshift
systemctl enable docker
# Añadir usuario al grupo docker para usarlo sin sudo
usermod -aG docker $USER
#-----------------------
#RED Y DIAGNÓSTICO
#-----------------------
echo "INSTALANDO HERRAMIENTAS DE RED..."
# Escáner de red y puertos
pacman -S --noconfirm nmap
# Herramientas clásicas de red: ifconfig, netstat, etc.
pacman -S --noconfirm net-tools
# Diagnóstico DNS (dig), trazado de rutas y test de velocidad en red local
pacman -S --noconfirm bind-tools traceroute mtr iperf3
#-----------------------
#DISCO Y HARDWARE
#-----------------------
echo "INSTALANDO HERRAMIENTAS DE DISCO Y HARDWARE..."
# Salud de discos HDD/SSD (smartctl)
pacman -S --noconfirm smartmontools
# Gestión y diagnóstico de SSDs NVMe
pacman -S --noconfirm nvme-cli
# Listar ficheros abiertos por procesos
pacman -S --noconfirm lsof
# Información de dispositivos USB y hardware PCI (GPU, tarjetas de red, etc.)
pacman -S --noconfirm usbutils pciutils
# Leer y escribir discos con formato NTFS (Windows)
pacman -S --noconfirm ntfs-3g
# Automontaje de USBs y discos externos sin root en Wayland
pacman -S --noconfirm udisks2 udiskie
#-----------------------
#GESTIÓN DEL SISTEMA ARCH
#-----------------------
echo "INSTALANDO HERRAMIENTAS DE GESTIÓN DE ARCH..."
# Actualiza la lista de mirrors de pacman ordenados por velocidad
pacman -S --noconfirm reflector
# paccache (limpia caché de paquetes), pacdiff y otras utilidades de pacman
pacman -S --noconfirm pacman-contrib
# Grabación de pantalla en Wayland
pacman -S --noconfirm wf-recorder
#-----------------------
#SEGURIDAD
#-----------------------
echo "INSTALANDO HERRAMIENTAS DE SEGURIDAD..."
# GPG: cifrado, firma de commits de git y verificación de paquetes
pacman -S --noconfirm gnupg
# Cifrado moderno de ficheros, alternativa ligera a GPG
pacman -S --noconfirm age
#-----------------------
#AUDIO (PIPEWIRE)
#-----------------------
echo "INSTALANDO PAQUETES DE AUDIO..."
# PipeWire: servidor de audio moderno, reemplaza PulseAudio y JACK
pacman -S --noconfirm pipewire
# Compatibilidad con apps que usan ALSA, PulseAudio y JACK respectivamente
pacman -S --noconfirm pipewire-alsa pipewire-pulse pipewire-jack
# Session manager de PipeWire, obligatorio para que funcione
pacman -S --noconfirm wireplumber
# GUI de control de volumen y dispositivos de audio
pacman -S --noconfirm pavucontrol
#-----------------------
#BLUETOOTH
#-----------------------
echo "INSTALANDO PAQUETES DE BLUETOOTH..."
# Stack de bluetooth y herramientas CLI (bluetoothctl)
pacman -S --noconfirm bluez bluez-utils
# Applet GUI para gestionar dispositivos bluetooth fácilmente
pacman -S --noconfirm blueman
systemctl enable bluetooth
systemctl start bluetooth
#-----------------------
#RED
#-----------------------
echo "INSTALANDO GESTIÓN DE RED..."
# Gestor de conexiones de red y su applet de systray
pacman -S --noconfirm networkmanager network-manager-applet
systemctl enable NetworkManager
#-----------------------
#TECLADO
#-----------------------
echo "INSTALANDO SOPORTE DE TECLADO..."
# Remapeo de teclas a nivel de kernel, necesario para teclados con distribución Mac
# Permite reasignar Cmd, Opt, Fn a equivalentes Linux (Super, Alt, etc.)
pacman -S --noconfirm keyd
systemctl enable keyd
#-----------------------
#NÚCLEO HYPRLAND
#-----------------------
echo "INSTALANDO NÚCLEO HYPRLAND..."
# Compositor Wayland y sus librerías del ecosistema Hypr
pacman -S --noconfirm hyprland aquamarine hyprlang hyprcursor hyprutils hyprgraphics
# Daemon de inactividad (apagar pantalla, suspender tras X minutos)
pacman -S --noconfirm hypridle
# Pantalla de bloqueo del ecosistema Hypr
pacman -S --noconfirm hyprlock
# Portales XDG: necesarios para screenshare, selectores de ficheros y apps sandboxed
pacman -S --noconfirm xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
# Agente de autenticación gráfica (ventanas de sudo en apps GUI)
pacman -S --noconfirm polkit-gnome
# Soporte Wayland para apps Qt5 y Qt6
pacman -S --noconfirm qt5-wayland qt6-wayland
#-----------------------
#ENTORNO VISUAL
#-----------------------
echo "INSTALANDO ENTORNO VISUAL..."
# Emulador de terminal con aceleración GPU
pacman -S --noconfirm kitty
# Barra de estado configurable con JSON y CSS
pacman -S --noconfirm waybar
# Gestor de notificaciones
pacman -S --noconfirm swaync
# Fondo de pantalla con soporte de transiciones animadas
pacman -S --noconfirm swww
# Capturas de pantalla: grim=captura | slurp=selección de región
pacman -S --noconfirm grim slurp
# Portapapeles para Wayland y su historial 
pacman -S --noconfirm wl-clipboard cliphist
# Control de brillo de pantalla
pacman -S --noconfirm brightnessctl playerctl
# Anotaciones sobre capturas de pantalla
pacman -S --noconfirm swappy
# Filtro de luz azul nocturno
pacman -S --noconfirm wlsunset
# Gestión de contraseñas en terminal
pacman -S --noconfirm pass
# Chat
pacman -S --noconfirm discord
# Iconos para rofi y apps GTK
paru -S --noconfirm kora-icon-theme bibata-cursor-theme
# Temas GTK alineados con los temas del sistema
paru -S --noconfirm gruvbox-material-gtk-theme-git tokyonight-gtk-theme-git
#-----------------------
#MULTIMEDIA
#-----------------------
echo "INSTALANDO HERRAMIENTAS MULTIMEDIA..."
# Procesamiento de vídeo y audio, lo necesitan muchas apps internamente
pacman -S --noconfirm ffmpeg
# Manipulación de imágenes desde CLI (redimensionar, convertir formatos, etc.)
pacman -S --noconfirm imagemagick
# Reproductor multimedia minimalista y potente
pacman -S --noconfirm mpv
# Visor de imágenes para Wayland (equivalente a feh en X11)
pacman -S --noconfirm imv
# Visor de PDFs con navegación por teclado + plugin de renderizado
pacman -S --noconfirm zathura zathura-pdf-mupdf
#-----------------------
#FUENTES
#-----------------------
echo "INSTALANDO FUENTES..."
# JetBrains Mono con iconos Nerd Fonts (terminal y editor)
pacman -S --noconfirm ttf-jetbrains-mono-nerd 
# Iconos Font Awesome para waybar y otras apps
pacman -S --noconfirm ttf-font-awesome
# Soporte completo de emojis en todo el sistema
pacman -S --noconfirm noto-fonts-emoji
#-----------------------
#INSTALACIÓN DE PARU (AUR HELPER)
#-----------------------
echo "INSTALANDO PARU..."
git clone https://aur.archlinux.org/paru.git /tmp/paru
cd /tmp/paru && makepkg -si --noconfirm
cd -
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
#------------------------------
#SYMSLINKS PARA CLONAR ARCHIVOS
#-------------------------------
echo "CREANDO SYMLINKS..."
DOTFILES=$(dirname "$path_install")
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
ln -sf "$DOTFILES/.config/fastfetch" ~/.config/fastfetch
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

# Aplicar configs de sistema
sudo cp "$DOTFILES/etc/pacman.conf" /etc/pacman.conf
sudo cp "$DOTFILES/etc/reflector.conf" /etc/xdg/reflector/reflector.conf
sudo mkdir -p /etc/modprobe.d
sudo cp "$DOTFILES/etc/modprobe.d/hid_apple.conf" /etc/modprobe.d/hid_apple.conf
systemctl enable reflector.timer
# keyd va en /etc, requiere sudo
sudo mkdir -p /etc/keyd
sudo ln -sf "$DOTFILES/.config/keyd/default.conf" /etc/keyd/default.conf

# Permisos de ejecución a los scripts
chmod +x "$DOTFILES/.config/hypr/scripts/theme-switch.sh"
chmod +x "$DOTFILES/.config/hypr/scripts/wallpaper.sh"
chmod +x "$DOTFILES/.config/hypr/scripts/powermenu.sh"
chmod +x "$DOTFILES/.config/hypr/scripts/recorder.sh"

# Aplicar tema por defecto (gruvbox)
ln -sf "$DOTFILES/.config/waybar/themes/gruvbox.css" ~/.config/waybar/theme.css
ln -sf "$DOTFILES/.config/kitty/themes/gruvbox.conf" ~/.config/kitty/theme.conf
ln -sf "$DOTFILES/.config/rofi/themes/gruvbox.rasi" ~/.config/rofi/theme.rasi
ln -sf "$DOTFILES/.config/swaync/themes/gruvbox.css" ~/.config/swaync/theme.css
echo "gruvbox" > ~/.config/.current-theme
echo "Bibata-Modern-Amber" > ~/.config/.current-cursor

# Aplicar tema hyprland y hyprlock por defecto
ln -sf "$DOTFILES/.config/hypr/themes/gruvbox.conf" ~/.config/hypr/theme.conf
ln -sf "$DOTFILES/.config/hypr/themes/hyprlock-gruvbox.conf" ~/.config/hypr/hyprlock-theme.conf

# Crear carpetas en español
xdg-user-dirs-update

# Crear carpetas estándar del usuario (Descargas, Documentos, etc.)
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
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
# PLUGINS EXTERNOS DE OH-MY-ZSH
git clone https://github.com/zsh-users/zsh-autosuggestions \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-history-substring-search \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
  


