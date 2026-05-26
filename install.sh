#!/bin/bash
#============================================================
#  INSTALADOR MULTI-DISTRO — HYPRLAND
#  HECHO POR: SREAPER
#  DISTROS SOPORTADAS: Arch Linux | Fedora | Debian Sid/Testing
#============================================================

#---------
#VARIABLES
#---------
# BASH_SOURCE[0]: ruta real del script (compatible bash/zsh)
path_install="$(realpath "${BASH_SOURCE[0]}")"
DOTFILES_STATIC="$(dirname "$path_install")"

#-----------------------------------------
#DETECCIÓN DE DISTRO
#-----------------------------------------
if [[ -f /etc/os-release ]]; then
    # shellcheck source=/dev/null
    . /etc/os-release
    DISTRO="$ID"   # "arch" | "fedora" | "debian"
else
    echo "ERROR: No se puede detectar la distribución (/etc/os-release no existe)." && exit 1
fi

echo "============================================================"
echo "  Distribución detectada: $DISTRO  (${PRETTY_NAME:-})"
echo "============================================================"
echo ""

#-----------------------------------------
#COMPROBACIONES PREVIAS
#-----------------------------------------
if [ ! -x "$path_install" ]; then
    echo "EL ARCHIVO NO ES EJECUTABLE. Ejecuta: chmod +x $path_install" && exit 1
fi

if [ "$EUID" -eq 0 ]; then
    echo "No ejecutar como root. Usa un usuario normal con sudo." && exit 1
fi

if [[ "$DISTRO" != "arch" && "$DISTRO" != "fedora" && "$DISTRO" != "debian" ]]; then
    echo "Distribución '$DISTRO' no soportada."
    echo "Soportadas: arch | fedora | debian"
    exit 1
fi

# Debian requiere Sid o Testing para tener Hyprland empaquetado
if [[ "$DISTRO" == "debian" ]]; then
    echo "  AVISO: Debian requiere Sid (unstable) o Testing para Hyprland."
    echo "         En Debian Stable muchos paquetes no están disponibles."
    echo "         Presiona Ctrl+C para cancelar o Enter para continuar..."
    read -r
fi

#-----------------------------------------
#FUNCIÓN: INSTALAR BINARIO DESDE GITHUB RELEASES
# Uso: gh_install <repo> <patrón_asset> <nombre_binario>
#-----------------------------------------
gh_install() {
    local repo="$1" pattern="$2" binary="$3"
    local tmpdir; tmpdir=$(mktemp -d)

    echo "  → Descargando $binary desde github.com/$repo..."
    local url
    url=$(curl -s "https://api.github.com/repos/${repo}/releases/latest" \
          | grep "browser_download_url" \
          | grep -E "$pattern" \
          | head -1 \
          | cut -d '"' -f 4)

    if [[ -z "$url" ]]; then
        echo "  ✗ No se pudo obtener URL para $binary — omitiendo."
        rm -rf "$tmpdir"; return 1
    fi

    curl -sL "$url" -o "$tmpdir/asset"
    case "$url" in
        *.tar.gz|*.tgz) tar -xzf "$tmpdir/asset" -C "$tmpdir" ;;
        *.tar.xz)        tar -xJf "$tmpdir/asset" -C "$tmpdir" ;;
        *.zip)           unzip -q  "$tmpdir/asset" -d "$tmpdir" ;;
        *)               cp "$tmpdir/asset" "$tmpdir/$binary"   ;;
    esac

    local bin_path
    bin_path=$(find "$tmpdir" -type f -name "$binary" | head -1)
    [[ -z "$bin_path" ]] && bin_path="$tmpdir/asset"

    sudo install -m 755 "$bin_path" "/usr/local/bin/$binary"
    rm -rf "$tmpdir"
    echo "  ✓ $binary → /usr/local/bin/$binary"
}

#-----------------------------------------
#FUNCIÓN: INSTALAR NERD FONT DESDE GITHUB
# Arch las tiene en repos/AUR; Fedora y Debian usan esta función.
#-----------------------------------------
install_nerd_font() {
    local font_name="$1"   # Ej: "Hack", "JetBrainsMono"
    local fonts_dir="$HOME/.local/share/fonts"
    mkdir -p "$fonts_dir"
    echo "  → Descargando ${font_name} Nerd Font..."
    local url
    url=$(curl -s "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest" \
          | grep "browser_download_url" \
          | grep "${font_name}\.tar\.xz" \
          | cut -d '"' -f 4)
    if [[ -n "$url" ]]; then
        curl -sL "$url" | tar -xJ -C "$fonts_dir"
        echo "  ✓ ${font_name} Nerd Font instalada en $fonts_dir"
    else
        echo "  WARN: No se pudo descargar ${font_name} Nerd Font"
    fi
}

#-----------------------------------------
#FUNCIÓN: WRAPPER DEL GESTOR DE PAQUETES
#-----------------------------------------
PKG() {
    case "$DISTRO" in
        arch)   sudo pacman -S --noconfirm "$@" ;;
        fedora) sudo dnf install -y "$@" ;;
        debian) sudo apt install -y "$@" ;;
    esac
}

#============================================================
#  PRE-SETUP — Repositorios y canales extra
#============================================================
echo "CONFIGURANDO REPOSITORIOS..."

case "$DISTRO" in
    arch)
        # Arch no necesita repos extra; pacman ya tiene todo.
        # El AUR helper (paru) se instala más adelante.
        echo "  · Arch: sin repositorios adicionales."
        ;;

    fedora)
        # RPM Fusion: repositorio de terceros principal en Fedora.
        # 'free'    → software libre no incluido por Fedora (ffmpeg completo, etc.)
        # 'nonfree' → software privativo (códecs, drivers Nvidia, etc.)
        sudo dnf install -y \
            "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
            "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
        sudo dnf groupupdate -y core

        # Flatpak + Flathub: necesario para Brave, Spotify, Discord, etc.
        sudo dnf install -y flatpak
        flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

        # COPR solopasha/hyprland: ecosistema Hyprland completo para Fedora.
        # Incluye: hyprland, hyprlock, hypridle, aquamarine, swww, waybar,
        #          kanshi, rofi-wayland, cliphist, swayosd, uwsm y más.
        sudo dnf copr enable -y solopasha/hyprland

        # COPR para SwayNotificationCenter (swaync)
        sudo dnf copr enable -y erikreider/SwayNotificationCenter

        # Repositorio oficial de Docker CE
        sudo dnf config-manager addrepo \
            --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo
        ;;

    debian)
        # Asegurar herramientas base para añadir repos
        sudo apt install -y ca-certificates gnupg curl apt-transport-https

        # Flatpak + Flathub: para Brave, Spotify, Discord
        sudo apt install -y flatpak
        flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

        # Docker CE: repositorio oficial
        sudo install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/debian/gpg \
            | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        sudo chmod a+r /etc/apt/keyrings/docker.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/debian \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
            | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

        sudo apt update
        ;;
esac

#-----------------------
#ACTUALIZAR SISTEMA
#-----------------------
echo "ACTUALIZANDO PAQUETES Y REPOSITORIOS..."
case "$DISTRO" in
    arch)   sudo pacman -Syu --noconfirm ;;
    fedora) sudo dnf update -y ;;
    debian) sudo apt update && sudo apt full-upgrade -y ;;
esac

#-----------------------
#LIMPIAR OTROS WM/DE
#-----------------------
echo "ELIMINANDO OTROS ENTORNOS DE ESCRITORIO Y GESTORES DE VENTANAS..."
OTHER_WM=(
    gnome-shell gnome-session gnome-control-center mutter gdm
    plasma-desktop plasma-workspace kwin sddm
    xfce4-session xfwm4
    lxqt-session lxde-common
    i3 i3-gaps sway
    openbox bspwm awesome qtile
    mate-session-manager cinnamon
    lightdm ly greetd lxdm
)
for pkg in "${OTHER_WM[@]}"; do
    case "$DISTRO" in
        arch)
            if pacman -Qi "$pkg" &>/dev/null; then
                echo "  → Eliminando $pkg..."
                sudo pacman -Rns --noconfirm "$pkg" 2>/dev/null || true
            fi
            ;;
        fedora)
            if rpm -q "$pkg" &>/dev/null; then
                echo "  → Eliminando $pkg..."
                sudo dnf remove -y "$pkg" 2>/dev/null || true
            fi
            ;;
        debian)
            if dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"; then
                echo "  → Eliminando $pkg..."
                sudo apt remove -y --purge "$pkg" 2>/dev/null || true
            fi
            ;;
    esac
done
echo "Limpieza de WM/DE completada."

#============================================================
#  BASE DEL SISTEMA
#============================================================
echo "INSTALANDO BASE DEL SISTEMA..."

# zsh — necesario antes del chsh
PKG zsh

# Herramientas de compilación
case "$DISTRO" in
    arch)   PKG base-devel ;;
    fedora) sudo dnf groupinstall -y "Development Tools" ;;
    debian) PKG build-essential ;;
esac

# Control de versiones y descargas
PKG git curl wget

# Compresión y archivos
PKG unzip zip rsync
case "$DISTRO" in
    arch)   PKG p7zip ;;
    fedora) PKG p7zip ;;
    debian) PKG p7zip-full ;;
esac

# SSH, manuales y carpetas estándar del usuario
PKG xdg-user-dirs
case "$DISTRO" in
    arch)   PKG openssh man-db man-pages ;;
    fedora) PKG openssh man-db ;;
    debian) PKG openssh-client openssh-server man-db manpages ;;
esac

#-------------------
#CAMBIAR SHELL A ZSH
#-------------------
chsh -s "$(command -v zsh)"

#============================================================
#  HERRAMIENTAS CLI
#============================================================
echo "INSTALANDO HERRAMIENTAS CLI..."

# Prompt personalizable — en Arch y Fedora está en repos; en Debian via GitHub
case "$DISTRO" in
    arch|fedora) PKG starship ;;
    debian)      gh_install 'starship/starship' 'starship-x86_64-unknown-linux-gnu\.tar\.gz' 'starship' ;;
esac

# bat=cat mejorado | eza=ls moderno | ripgrep=grep rápido
PKG bat ripgrep
case "$DISTRO" in
    arch|fedora) PKG eza ;;
    # En Debian Sid eza está en repos; si falla, gh_install
    debian)
        PKG eza 2>/dev/null \
            || gh_install 'eza-community/eza' 'eza_x86_64-unknown-linux-gnu\.tar\.gz' 'eza'
        ;;
esac

# fd=find | sd=sed | procs=ps
case "$DISTRO" in
    arch)          PKG fd sd procs ;;
    # Fedora: fd se llama fd-find (el binario sigue siendo 'fd')
    fedora)        PKG fd-find sd procs ;;
    # Debian: fd-find igual que Fedora; sd y procs via GitHub si no están en repos
    debian)
        PKG fd-find
        PKG sd    2>/dev/null || gh_install 'chmln/sd'    'sd-v.*-x86_64-unknown-linux-gnu\.tar\.gz' 'sd'
        PKG procs 2>/dev/null || gh_install 'dalance/procs' 'procs-v.*-x86_64-linux\.zip' 'procs'
        ;;
esac

# Fuzzy finder
PKG fzf

# btop=monitor | duf=df moderno | dust=du moderno | fastfetch=info del sistema
PKG btop
case "$DISTRO" in
    arch|fedora) PKG duf dust fastfetch ;;
    debian)
        PKG duf 2>/dev/null || gh_install 'muesli/duf' 'duf_.*_linux_amd64\.tar\.gz' 'duf'
        PKG dust 2>/dev/null || gh_install 'bootandy/dust' 'dust-v.*-x86_64-unknown-linux-gnu\.tar\.gz' 'dust'
        PKG fastfetch 2>/dev/null || gh_install 'fastfetch-cli/fastfetch' 'fastfetch-linux-amd64\.tar\.gz' 'fastfetch'
        ;;
esac

# tmux=multiplexor | zoxide=cd inteligente
PKG tmux
case "$DISTRO" in
    arch|fedora) PKG zoxide ;;
    debian)
        PKG zoxide 2>/dev/null \
            || curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
        ;;
esac

# tldr: man pages con ejemplos
case "$DISTRO" in
    arch)   PKG tldr ;;
    fedora) PKG tealdeer ;;
    # tealdeer en Debian via GitHub si no está en repos
    debian)
        PKG tealdeer 2>/dev/null \
            || gh_install 'dbrgn/tealdeer' 'tealdeer-linux-x86_64-musl' 'tldr'
        ;;
esac

# File manager en terminal
case "$DISTRO" in
    arch)          PKG yazi ;;
    fedora|debian) gh_install 'sxyazi/yazi' 'yazi-x86_64-unknown-linux-gnu\.tar\.gz' 'yazi' ;;
esac

# git-delta: diff visual mejorado
case "$DISTRO" in
    arch|fedora) PKG git-delta ;;
    debian)
        PKG git-delta 2>/dev/null \
            || gh_install 'dandavison/delta' 'delta-.*-x86_64-unknown-linux-gnu\.tar\.gz' 'delta'
        ;;
esac

# lazygit: TUI de git
case "$DISTRO" in
    arch)          PKG lazygit ;;
    fedora|debian) gh_install 'jesseduffield/lazygit' 'lazygit_.*_Linux_x86_64\.tar\.gz' 'lazygit' ;;
esac

# bandwhich: monitor de ancho de banda por proceso
case "$DISTRO" in
    arch|fedora) PKG bandwhich ;;
    debian)
        PKG bandwhich 2>/dev/null \
            || gh_install 'imsnif/bandwhich' 'bandwhich-v.*-x86_64-unknown-linux-musl\.tar\.gz' 'bandwhich'
        ;;
esac

# jq: procesador de JSON
PKG jq

# glow: lector de markdown en terminal
case "$DISTRO" in
    arch)          PKG glow ;;
    fedora|debian) gh_install 'charmbracelet/glow' 'glow_Linux_x86_64\.tar\.gz' 'glow' ;;
esac

# hyperfine: benchmarking de comandos
case "$DISTRO" in
    arch|fedora) PKG hyperfine ;;
    debian)
        PKG hyperfine 2>/dev/null \
            || gh_install 'sharkdp/hyperfine' 'hyperfine-v.*-x86_64-unknown-linux-gnu\.tar\.gz' 'hyperfine'
        ;;
esac

# Daemon cron — necesario para el crontab de actualización automática
case "$DISTRO" in
    arch|fedora) PKG cronie ;;
    debian)      PKG cron ;;
esac
sudo systemctl enable cron 2>/dev/null || sudo systemctl enable cronie 2>/dev/null || true

# Gestor de perfiles de monitor (detecta pantallas y aplica config)
PKG kanshi

# Editor
PKG neovim

# Contenedores y snapshots del sistema
case "$DISTRO" in
    arch)
        PKG docker timeshift
        ;;
    fedora)
        # Docker CE desde el repo oficial (añadido en pre-setup)
        sudo dnf install -y docker-ce docker-ce-cli containerd.io \
            docker-buildx-plugin docker-compose-plugin
        sudo dnf install -y timeshift 2>/dev/null \
            || echo "  WARN: timeshift no encontrado. Habilita: sudo dnf copr enable paolosr/timeshift"
        ;;
    debian)
        # Docker CE desde el repo oficial (añadido en pre-setup)
        sudo apt install -y docker-ce docker-ce-cli containerd.io \
            docker-buildx-plugin docker-compose-plugin
        # timeshift en Debian via GitHub (paquete .deb oficial)
        TMP_DEB=$(mktemp -d)
        TS_URL=$(curl -s "https://api.github.com/repos/teejee2008/timeshift/releases/latest" \
            | grep "browser_download_url" | grep "\.deb" | head -1 | cut -d '"' -f 4)
        if [[ -n "$TS_URL" ]]; then
            curl -sL "$TS_URL" -o "$TMP_DEB/timeshift.deb"
            sudo apt install -y "$TMP_DEB/timeshift.deb" 2>/dev/null \
                || echo "  WARN: timeshift .deb no instalado"
        fi
        rm -rf "$TMP_DEB"
        ;;
esac
sudo systemctl enable docker
sudo usermod -aG docker "$USER"
echo "NOTA: El grupo 'docker' requiere cerrar sesión completamente para tener efecto."

#============================================================
#  RED Y DIAGNÓSTICO
#============================================================
echo "INSTALANDO HERRAMIENTAS DE RED..."

PKG nmap net-tools traceroute mtr iperf3

# Herramientas DNS: distinto nombre según distro
case "$DISTRO" in
    arch)          PKG bind-tools ;;
    fedora)        PKG bind-utils ;;
    debian)        PKG dnsutils ;;
esac

#============================================================
#  DISCO Y HARDWARE
#============================================================
echo "INSTALANDO HERRAMIENTAS DE DISCO Y HARDWARE..."

PKG smartmontools nvme-cli lsof usbutils pciutils ntfs-3g udisks2 udiskie

#============================================================
#  GESTIÓN DEL SISTEMA
#============================================================
echo "INSTALANDO HERRAMIENTAS DE GESTIÓN DEL SISTEMA..."

# Grabación de pantalla en Wayland
PKG wf-recorder

case "$DISTRO" in
    arch)
        # Actualiza la lista de mirrors de pacman ordenados por velocidad
        PKG reflector
        # paccache, pacdiff y otras utilidades de pacman
        PKG pacman-contrib
        ;;
    fedora)
        # Fedora gestiona mirrors automáticamente (fastestmirror en dnf)
        PKG dnf-plugins-core
        ;;
    debian)
        # Debian gestiona mirrors automáticamente
        # apt-utils incluye herramientas de gestión útiles
        PKG apt-utils
        ;;
esac

#============================================================
#  SEGURIDAD
#============================================================
echo "INSTALANDO HERRAMIENTAS DE SEGURIDAD..."

# GPG: nombre del paquete según distro
case "$DISTRO" in
    arch)          PKG gnupg ;;
    fedora|debian) PKG gnupg2 ;;
esac

# age: cifrado moderno de ficheros
case "$DISTRO" in
    arch|fedora) PKG age ;;
    debian)
        PKG age 2>/dev/null \
            || gh_install 'FiloSottile/age' 'age-v.*-linux-amd64\.tar\.gz' 'age'
        ;;
esac

#============================================================
#  AUDIO (PIPEWIRE)
#============================================================
echo "INSTALANDO PAQUETES DE AUDIO..."
# Fedora 34+ y Debian 12+ instalan PipeWire por defecto.

PKG pipewire wireplumber pavucontrol pipewire-alsa

# PulseAudio compat: nombre distinto en Fedora
case "$DISTRO" in
    arch|debian) PKG pipewire-pulse pipewire-jack ;;
    fedora)      PKG pipewire-pulseaudio pipewire-jack-audio-connection-kit ;;
esac

#============================================================
#  BLUETOOTH
#============================================================
echo "INSTALANDO PAQUETES DE BLUETOOTH..."

PKG bluez blueman

# Herramientas CLI: nombre distinto según distro
case "$DISTRO" in
    arch)   PKG bluez-utils ;;
    fedora) PKG bluez-tools ;;
    debian) ;; # bluetoothctl ya viene incluido en el paquete bluez de Debian
esac

sudo systemctl enable bluetooth
sudo systemctl start bluetooth 2>/dev/null || true  # puede fallar en VM sin hardware BT

#============================================================
#  RED
#============================================================
echo "INSTALANDO GESTIÓN DE RED..."

PKG networkmanager
sudo systemctl enable NetworkManager

case "$DISTRO" in
    arch)   PKG network-manager-applet ;;
    fedora) PKG NetworkManager nm-connection-editor network-manager-applet ;;
    # En Debian, nm-applet viene en el paquete network-manager-gnome
    debian) PKG network-manager-gnome ;;
esac

#============================================================
#  NÚCLEO HYPRLAND
#============================================================
echo "INSTALANDO NÚCLEO HYPRLAND..."
# En Fedora los paquetes vienen del COPR solopasha/hyprland.
# En Debian los paquetes están en Sid/Testing.
# En Arch están en los repositorios oficiales.

# Compositor y librerías Hypr — en Debian solo se instala hyprland
# (aquamarine, hyprlang, etc. son dependencias automáticas via apt)
case "$DISTRO" in
    arch|fedora) PKG hyprland aquamarine hyprlang hyprcursor hyprutils hyprgraphics ;;
    debian)      PKG hyprland ;;
esac

# Daemon de inactividad
PKG hypridle

# Pantalla de bloqueo
PKG hyprlock

# Portales XDG: screenshare, selectores de ficheros, apps sandboxed
PKG xdg-desktop-portal-hyprland xdg-desktop-portal-gtk

# Agente de autenticación gráfica
case "$DISTRO" in
    arch|fedora) PKG polkit-gnome ;;
    # En Debian el paquete se llama distinto según versión
    debian)      PKG policykit-1-gnome 2>/dev/null || PKG polkit-gnome 2>/dev/null || true ;;
esac

# Soporte Wayland para apps Qt5 y Qt6
case "$DISTRO" in
    arch)   PKG qt5-wayland qt6-wayland ;;
    fedora) PKG qt5-qtwayland qt6-qtwayland ;;
    debian) PKG qtwayland5 qt6-wayland 2>/dev/null || PKG qtwayland5 ;;
esac

#============================================================
#  PLUGINS DE HYPRLAND (hyprpm)
#============================================================
echo "INSTALANDO PLUGINS DE HYPRLAND..."
# hyprpm compila los plugins para la versión exacta instalada.

case "$DISTRO" in
    fedora) PKG hyprland-devel 2>/dev/null || true ;;
    debian) PKG libhyprland-dev 2>/dev/null || true ;;
esac

hyprpm update
hyprpm add https://github.com/hyprwm/hyprland-plugins   # hyprexpo + borders-plus-plus
hyprpm add https://github.com/VortexCoyote/hyprfocus     # efecto de enfoque al cambiar ventana
hyprpm enable borders-plus-plus
hyprpm enable hyprexpo
hyprpm enable hyprfocus

#============================================================
#  ENTORNO VISUAL
#============================================================
echo "INSTALANDO ENTORNO VISUAL..."

# Emulador de terminal con aceleración GPU
PKG kitty

# Barra de estado
PKG waybar

# Gestor de notificaciones
case "$DISTRO" in
    arch)   PKG swaync ;;
    fedora) PKG SwayNotificationCenter ;;
    # En Debian swaync no está en repos → instalar binario desde GitHub
    debian)
        PKG swaync 2>/dev/null \
            || gh_install 'ErikReider/SwayNotificationCenter' \
               'sway-notification-center_.*_amd64\.deb' 'swaync' 2>/dev/null \
            || echo "  WARN: swaync no instalado — instalar manualmente desde github.com/ErikReider/SwayNotificationCenter"
        ;;
esac

# Fondo de pantalla con transiciones animadas
case "$DISTRO" in
    arch|fedora) PKG swww ;;
    # swww en Debian via GitHub binary
    debian)
        PKG swww 2>/dev/null \
            || gh_install 'LGFae/swww' 'swww-.*-x86_64-unknown-linux-musl\.tar\.gz' 'swww'
        ;;
esac

# Capturas de pantalla
PKG grim slurp
case "$DISTRO" in
    arch|fedora) PKG swappy ;;
    debian)      PKG swappy 2>/dev/null || echo "  WARN: swappy no disponible en apt" ;;
esac

# Portapapeles Wayland y su historial
PKG wl-clipboard
case "$DISTRO" in
    arch|fedora) PKG cliphist ;;
    debian)
        PKG cliphist 2>/dev/null \
            || gh_install 'sentriz/cliphist' 'linux_amd64$' 'cliphist'
        ;;
esac

# Control de brillo y multimedia
PKG brightnessctl playerctl

# OSD de volumen/brillo en pantalla
case "$DISTRO" in
    arch|fedora) PKG swayosd ;;
    debian)
        PKG swayosd 2>/dev/null \
            || echo "  WARN: swayosd no disponible en apt — instalar desde github.com/ErikReider/SwayOSD"
        ;;
esac

# Filtro de luz azul nocturno
case "$DISTRO" in
    arch|fedora) PKG wlsunset ;;
    debian)      PKG wlsunset 2>/dev/null || PKG gammastep 2>/dev/null || true ;;
esac

# Gestor de contraseñas
PKG pass

# Chat (Discord)
case "$DISTRO" in
    arch)          PKG discord ;;
    fedora|debian) flatpak install -y flathub com.discordapp.Discord ;;
esac

#============================================================
#  MULTIMEDIA
#============================================================
echo "INSTALANDO HERRAMIENTAS MULTIMEDIA..."

# ffmpeg
case "$DISTRO" in
    arch)   PKG ffmpeg ;;
    fedora) PKG ffmpeg ffmpeg-libs ;;
    debian) PKG ffmpeg ;;
esac

# ImageMagick: capitalización distinta en Fedora
case "$DISTRO" in
    arch|debian) PKG imagemagick ;;
    fedora)      PKG ImageMagick ;;
esac

PKG mpv imv

# Visor de PDFs + plugin mupdf
case "$DISTRO" in
    arch|fedora) PKG zathura zathura-pdf-mupdf ;;
    # En Debian el plugin mupdf se llama zathura-plugin-mupdf
    debian)      PKG zathura zathura-plugin-mupdf 2>/dev/null || PKG zathura ;;
esac

#============================================================
#  FUENTES
#============================================================
echo "INSTALANDO FUENTES..."

case "$DISTRO" in
    arch)
        # Nerd Fonts disponibles directamente en repos de Arch
        PKG ttf-hack-nerd ttf-jetbrains-mono-nerd ttf-font-awesome noto-fonts-emoji
        ;;
    fedora)
        PKG fontawesome-fonts fontawesome6-fonts google-noto-emoji-fonts
        install_nerd_font "Hack"
        install_nerd_font "JetBrainsMono"
        fc-cache -fv "$HOME/.local/share/fonts" 2>/dev/null
        ;;
    debian)
        # fonts-font-awesome | fonts-noto-color-emoji están en repos
        PKG fonts-font-awesome fonts-noto-color-emoji
        install_nerd_font "Hack"
        install_nerd_font "JetBrainsMono"
        fc-cache -fv "$HOME/.local/share/fonts" 2>/dev/null
        ;;
esac

#============================================================
#  PAQUETES EXTRA
#============================================================
echo "INSTALANDO PAQUETES EXTRA..."

case "$DISTRO" in
    arch)
        #--- PARU (AUR HELPER) ---
        echo "  → Instalando paru (AUR helper)..."
        PARU_BUILD=$(mktemp -d)
        git clone https://aur.archlinux.org/paru.git "$PARU_BUILD"
        (cd "$PARU_BUILD" && makepkg -si --noconfirm)
        rm -rf "$PARU_BUILD"

        # Launcher de aplicaciones Wayland
        paru -S --noconfirm rofi-wayland rofi-calc
        # Terminal dropdown/scratchpad para Hyprland
        paru -S --noconfirm pypr
        # Calendario en terminal
        PKG calcurse
        # Navegadores
        paru -S --noconfirm brave-bin tor-browser
        # Música
        paru -S --noconfirm spotify
        # Nerd Fonts (pack completo)
        paru -S --noconfirm nerd-fonts
        # Gestor de sesiones Wayland
        paru -S --noconfirm uwsm
        # Capturas con GUI
        PKG flameshot
        # Iconos y cursores
        paru -S --noconfirm kora-icon-theme bibata-cursor-theme
        # Tema GTK TokyoNight
        paru -S --noconfirm tokyonight-gtk-theme-git
        ;;

    fedora)
        PKG calcurse flameshot
        # uwsm (del COPR solopasha/hyprland)
        PKG uwsm
        # rofi-wayland (del COPR)
        PKG rofi-wayland
        # pyprland vía pip
        PKG python3-pip
        pip3 install --user pyprland
        echo "  NOTA: pypr instalado en ~/.local/bin"

        flatpak install -y flathub com.brave.Browser
        flatpak install -y flathub com.github.micahflee.torbrowser-launcher
        flatpak install -y flathub com.spotify.Client

        # Cursor Bibata-Modern-Ice
        BIBATA_URL=$(curl -s "https://api.github.com/repos/ful1e5/Bibata_Cursor/releases/latest" \
            | grep "browser_download_url" | grep "Bibata-Modern-Ice\.tar\.xz" | cut -d '"' -f 4)
        if [[ -n "$BIBATA_URL" ]]; then
            mkdir -p "$HOME/.local/share/icons"
            curl -sL "$BIBATA_URL" | tar -xJ -C "$HOME/.local/share/icons"
            echo "  ✓ Cursor Bibata-Modern-Ice → ~/.local/share/icons"
        fi

        # Tema GTK TokyoNight
        TN_URL=$(curl -s "https://api.github.com/repos/Fausto-Korpsvart/Tokyonight-GTK-Theme/releases/latest" \
            | grep "browser_download_url" | grep "Tokyonight-Dark.*\.tar\.gz" | head -1 | cut -d '"' -f 4)
        if [[ -n "$TN_URL" ]]; then
            mkdir -p "$HOME/.local/share/themes"
            curl -sL "$TN_URL" | tar -xz -C "$HOME/.local/share/themes"
            echo "  ✓ Tema TokyoNight → ~/.local/share/themes"
        fi
        ;;

    debian)
        PKG calcurse flameshot rofi

        # uwsm (gestor de sesiones Wayland) — intentar apt; si falla, GitHub
        PKG uwsm 2>/dev/null \
            || gh_install 'Vladimir-csp/uwsm' 'uwsm-.*-x86_64.*\.tar\.gz' 'uwsm' 2>/dev/null \
            || echo "  WARN: uwsm no disponible — arranca Hyprland directamente desde TTY"

        # pyprland vía pip
        PKG python3-pip
        pip3 install --user pyprland
        echo "  NOTA: pypr instalado en ~/.local/bin"

        flatpak install -y flathub com.brave.Browser
        flatpak install -y flathub com.github.micahflee.torbrowser-launcher
        flatpak install -y flathub com.spotify.Client

        # Cursor Bibata-Modern-Ice
        BIBATA_URL=$(curl -s "https://api.github.com/repos/ful1e5/Bibata_Cursor/releases/latest" \
            | grep "browser_download_url" | grep "Bibata-Modern-Ice\.tar\.xz" | cut -d '"' -f 4)
        if [[ -n "$BIBATA_URL" ]]; then
            mkdir -p "$HOME/.local/share/icons"
            curl -sL "$BIBATA_URL" | tar -xJ -C "$HOME/.local/share/icons"
            echo "  ✓ Cursor Bibata-Modern-Ice → ~/.local/share/icons"
        fi

        # Tema GTK TokyoNight
        TN_URL=$(curl -s "https://api.github.com/repos/Fausto-Korpsvart/Tokyonight-GTK-Theme/releases/latest" \
            | grep "browser_download_url" | grep "Tokyonight-Dark.*\.tar\.gz" | head -1 | cut -d '"' -f 4)
        if [[ -n "$TN_URL" ]]; then
            mkdir -p "$HOME/.local/share/themes"
            curl -sL "$TN_URL" | tar -xz -C "$HOME/.local/share/themes"
            echo "  ✓ Tema TokyoNight → ~/.local/share/themes"
        fi
        ;;
esac

#============================================================
#  SYMLINKS
#============================================================
echo "CREANDO SYMLINKS..."
DOTFILES="$DOTFILES_STATIC"
mkdir -p ~/.config

# Archivos en $HOME
ln -sf "$DOTFILES/.zshrc"    ~/.zshrc
ln -sf "$DOTFILES/.zprofile" ~/.zprofile

# Carpetas en ~/.config
for cfg in hypr kitty nvim waybar swaync rofi starship tmux yazi fastfetch \
           kanshi btop mpv zathura gtk-3.0 gtk-4.0; do
    ln -sf "$DOTFILES/.config/$cfg" ~/.config/$cfg
done

mkdir -p "$DOTFILES/.config/.wallpaper"
ln -sf "$DOTFILES/.config/.wallpaper"    ~/.config/.wallpaper
ln -sf "$DOTFILES/.config/user-dirs.dirs" ~/.config/user-dirs.dirs
ln -sf "$DOTFILES/.gitconfig"             ~/.gitconfig

# Configs de sistema específicas de Arch
case "$DISTRO" in
    arch)
        [[ -f /etc/pacman.conf ]] && sudo cp /etc/pacman.conf /etc/pacman.conf.bak
        sudo cp "$DOTFILES/etc/pacman.conf" /etc/pacman.conf
        sudo mkdir -p /etc/xdg/reflector
        sudo cp "$DOTFILES/etc/reflector.conf" /etc/xdg/reflector/reflector.conf
        sudo systemctl enable reflector.timer
        ;;
    # Fedora y Debian gestionan sus repos automáticamente
esac

chmod +x "$DOTFILES/update.sh"
chmod +x "$DOTFILES/sync.sh"
chmod +x "$DOTFILES/.config/hypr/scripts/"*.sh
chmod +x "$DOTFILES/.config/waybar/"*.sh
chmod +x "$DOTFILES/.config/swaync/"*.sh

# Tema por defecto (tokyonight)
ln -sf "$DOTFILES/.config/waybar/themes/tokyonight.css"           ~/.config/waybar/theme.css
ln -sf "$DOTFILES/.config/kitty/themes/tokyonight.conf"           ~/.config/kitty/theme.conf
ln -sf "$DOTFILES/.config/rofi/themes/tokyonight.rasi"            ~/.config/rofi/theme.rasi
ln -sf "$DOTFILES/.config/swaync/themes/tokyonight.css"           ~/.config/swaync/theme.css
ln -sf "$DOTFILES/.config/hypr/themes/tokyonight.conf"            ~/.config/hypr/theme.conf
ln -sf "$DOTFILES/.config/hypr/themes/hyprlock-tokyonight.conf"   ~/.config/hypr/hyprlock-theme.conf
ln -sf "$DOTFILES/.config/tmux/themes/tokyonight.conf"            ~/.config/tmux/theme.conf
ln -sf "$DOTFILES/.config/starship/themes/tokyonight.toml"        ~/.config/starship/starship.toml

echo "tokyonight"        > ~/.config/.current-theme
echo "Bibata-Modern-Ice" > ~/.config/.current-cursor

xdg-user-dirs-update

#============================================================
#  TPM — TMUX PLUGIN MANAGER
#============================================================
echo "INSTALANDO TPM..."
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

#============================================================
#  OH MY ZSH
#============================================================
echo "INSTALANDO OH MY ZSH..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

git clone https://github.com/zsh-users/zsh-autosuggestions \
    "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
git clone https://github.com/zsh-users/zsh-syntax-highlighting \
    "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
git clone https://github.com/zsh-users/zsh-history-substring-search \
    "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search"

#============================================================
#  CRONTAB — ACTUALIZACIÓN AUTOMÁTICA AL ARRANCAR
#============================================================
echo "CONFIGURANDO ACTUALIZACIÓN AUTOMÁTICA..."
(crontab -l 2>/dev/null | grep -v 'update.sh'; \
 echo "@reboot sleep 60 && ${DOTFILES_STATIC}/update.sh >> \$HOME/.local/share/update.log 2>&1") | crontab -

#============================================================
#  INICIO DE SESIÓN EN TERMINAL (autologin TTY1 → zsh → Hyprland)
#============================================================
echo "CONFIGURANDO INICIO DE SESIÓN EN TERMINAL..."

for dm in gdm sddm lightdm ly greetd lxdm; do
    if systemctl is-enabled "$dm" &>/dev/null; then
        echo "  → Deshabilitando $dm..."
        sudo systemctl disable "$dm"
    fi
done

sudo systemctl enable getty@tty1
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
sudo tee /etc/systemd/system/getty@tty1.service.d/autologin.conf > /dev/null <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $USER --noclear %I \$TERM
EOF

echo "  Autologin configurado para '$USER' en TTY1."

#============================================================
#  RESUMEN FINAL
#============================================================
echo ""
echo "======================================================"
echo " INSTALACIÓN COMPLETADA — $DISTRO + HYPRLAND"
echo "======================================================"
echo ""
echo "  → Reinicia el sistema para aplicar todos los cambios."
echo ""
echo "  PENDIENTE (configura antes de usar git):"
echo "    git config --global user.name  'Tu Nombre'"
echo "    git config --global user.email 'tu@email.com'"
echo ""

case "$DISTRO" in
    fedora|debian)
        echo "  APPS INSTALADAS COMO FLATPAK:"
        echo "    brave      → flatpak run com.brave.Browser"
        echo "    spotify    → flatpak run com.spotify.Client"
        echo "    discord    → flatpak run com.discordapp.Discord"
        echo "    torbrowser → flatpak run com.github.micahflee.torbrowser-launcher"
        echo ""
        echo "  pypr instalado en ~/.local/bin (ya en \$PATH via .zprofile)"
        echo ""
        ;;
esac
