#!/bin/bash
#============================================================
#  INSTALADOR — HYPRLAND  (Arch / Fedora / Debian)
#============================================================

# ── Ruta real del repo ────────────────────────────────────
DOTFILES="$(cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")" && pwd)"

# ── Detección de distro ────────────────────────────────────
[[ -f /etc/os-release ]] || { echo "ERROR: /etc/os-release no encontrado."; exit 1; }
# shellcheck source=/dev/null
. /etc/os-release
DISTRO="$ID"   # "arch" | "fedora" | "debian"

echo "===================================================="
echo "  Distribución: $DISTRO  (${PRETTY_NAME:-})"
echo "===================================================="

# ── Comprobaciones previas ────────────────────────────────
[[ "$EUID" -eq 0 ]]                        && { echo "No ejecutar como root."; exit 1; }
[[ ! -x "$(realpath "${BASH_SOURCE[0]}")" ]] && { echo "Haz ejecutable: chmod +x install.sh"; exit 1; }
[[ "$DISTRO" =~ ^(arch|fedora|debian)$ ]]  || { echo "Distro '$DISTRO' no soportada (arch|fedora|debian)."; exit 1; }

if [[ "$DISTRO" == "debian" ]]; then
    echo "AVISO: Debian 13 Trixie (Testing) o Sid requerido para Hyprland."
    echo "Ctrl+C para cancelar o Enter para continuar..."; read -r
fi

#============================================================
#  FUNCIONES
#============================================================

PKG() {
    case "$DISTRO" in
        arch)   sudo pacman -S --noconfirm "$@" ;;
        fedora) sudo dnf install -y "$@" ;;
        debian) sudo apt install -y "$@" ;;
    esac
}

# Mapa de nombres de paquetes por distro
pkgname() {
    case "$DISTRO:$1" in
        # Herramientas de compilación
        arch:build-tools)    echo "base-devel" ;;
        fedora:build-tools)  echo "" ;;          # usa groupinstall abajo
        debian:build-tools)  echo "build-essential" ;;
        # Compresión
        arch:p7zip|fedora:p7zip) echo "p7zip" ;;
        debian:p7zip)            echo "p7zip-full" ;;
        # SSH y manuales
        arch:openssh|fedora:openssh) echo "openssh" ;;
        debian:openssh)              echo "openssh-client openssh-server" ;;
        arch:man-pages)   echo "man-db man-pages" ;;
        fedora:man-pages) echo "man-db" ;;
        debian:man-pages) echo "man-db manpages" ;;
        # Red
        arch:bind-utils)   echo "bind-tools" ;;
        fedora:bind-utils) echo "bind-utils" ;;
        debian:bind-utils) echo "dnsutils" ;;
        # Seguridad
        arch:gnupg) echo "gnupg" ;;
        *:gnupg)    echo "gnupg2" ;;
        # Cron
        arch:cronie|fedora:cronie) echo "cronie" ;;
        debian:cronie)             echo "cron" ;;
        # Audio
        arch:pipewire-pulse|debian:pipewire-pulse) echo "pipewire-pulse" ;;
        fedora:pipewire-pulse) echo "pipewire-pulseaudio" ;;
        arch:pipewire-jack|debian:pipewire-jack)   echo "pipewire-jack" ;;
        fedora:pipewire-jack) echo "pipewire-jack-audio-connection-kit" ;;
        # Bluetooth
        arch:bluez-utils)   echo "bluez-utils" ;;
        fedora:bluez-utils) echo "bluez-tools" ;;
        debian:bluez-utils) echo "" ;;           # incluido en bluez
        # Network applet
        arch:nm-applet|fedora:nm-applet) echo "network-manager-applet" ;;
        debian:nm-applet)                echo "network-manager-gnome" ;;
        # Qt Wayland
        arch:qt5-wayland)   echo "qt5-wayland" ;;
        fedora:qt5-wayland) echo "qt5-qtwayland" ;;
        debian:qt5-wayland) echo "qtwayland5" ;;
        arch:qt6-wayland)   echo "qt6-wayland" ;;
        fedora:qt6-wayland) echo "qt6-qtwayland" ;;
        debian:qt6-wayland) echo "qt6-wayland" ;;
        # Polkit
        arch:polkit-gnome|fedora:polkit-gnome) echo "polkit-gnome" ;;
        debian:polkit-gnome) echo "policykit-1-gnome" ;;
        # Notificaciones
        arch:swaync|debian:swaync) echo "swaync" ;;
        fedora:swaync) echo "SwayNotificationCenter" ;;
        # Multimedia
        fedora:imagemagick) echo "ImageMagick" ;;
        *:imagemagick)      echo "imagemagick" ;;
        fedora:ffmpeg)      echo "ffmpeg ffmpeg-libs" ;;
        *:ffmpeg)           echo "ffmpeg" ;;
        # fd-find
        arch:fd)             echo "fd" ;;
        fedora:fd|debian:fd) echo "fd-find" ;;
        # tldr/tealdeer
        arch:tldr)   echo "tldr" ;;
        fedora:tldr) echo "tealdeer" ;;
        debian:tldr) echo "tealdeer" ;;
        # Default: mismo nombre
        *) echo "$1" ;;
    esac
}

# Instala con nombre mapeado; omite si la cadena es vacía
P() { local p; p="$(pkgname "$1")"; [[ -n "$p" ]] && PKG $p; }

# Descarga binario desde la última GitHub Release
gh_install() {
    local repo="$1" pattern="$2" binary="$3"
    local tmpdir; tmpdir=$(mktemp -d)
    echo "  → Descargando $binary desde github.com/$repo..."
    local url
    url=$(curl -s "https://api.github.com/repos/${repo}/releases/latest" \
          | grep "browser_download_url" | grep -E "$pattern" | head -1 | cut -d '"' -f 4)
    if [[ -z "$url" ]]; then
        echo "  ✗ No se pudo obtener URL para $binary — omitiendo."
        rm -rf "$tmpdir"; return 1
    fi
    curl -sL "$url" -o "$tmpdir/asset"
    case "$url" in
        *.tar.gz|*.tgz) tar -xzf "$tmpdir/asset" -C "$tmpdir" ;;
        *.tar.xz)        tar -xJf "$tmpdir/asset" -C "$tmpdir" ;;
        *.zip)           unzip -q  "$tmpdir/asset" -d "$tmpdir" ;;
        *)               cp "$tmpdir/asset" "$tmpdir/$binary" ;;
    esac
    local bin_path; bin_path=$(find "$tmpdir" -type f -name "$binary" | head -1)
    [[ -z "$bin_path" ]] && bin_path="$tmpdir/asset"
    sudo install -m 755 "$bin_path" "/usr/local/bin/$binary"
    rm -rf "$tmpdir"
    echo "  ✓ $binary → /usr/local/bin/$binary"
}

install_nerd_font() {
    local font_name="$1" fonts_dir="$HOME/.local/share/fonts"
    mkdir -p "$fonts_dir"
    echo "  → Descargando ${font_name} Nerd Font..."
    local url
    url=$(curl -s "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest" \
          | grep "browser_download_url" | grep "${font_name}\.tar\.xz" | cut -d '"' -f 4)
    if [[ -n "$url" ]]; then
        curl -sL "$url" | tar -xJ -C "$fonts_dir"
        echo "  ✓ ${font_name} Nerd Font → $fonts_dir"
    else
        echo "  WARN: No se pudo descargar ${font_name} Nerd Font"
    fi
}

#============================================================
#  REPOSITORIOS EXTRA
#============================================================
echo "▶ Configurando repositorios..."

case "$DISTRO" in
    arch)
        echo "  · Arch: sin repositorios adicionales."
        ;;
    fedora)
        sudo dnf install -y \
            "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
            "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
        sudo dnf groupupdate -y core
        sudo dnf install -y flatpak
        flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
        sudo dnf copr enable -y solopasha/hyprland
        sudo dnf copr enable -y erikreider/SwayNotificationCenter
        sudo dnf config-manager addrepo \
            --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo
        ;;
    debian)
        sudo apt install -y ca-certificates gnupg curl apt-transport-https
        sudo apt install -y flatpak
        flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
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

#============================================================
#  ACTUALIZAR SISTEMA
#============================================================
echo "▶ Actualizando sistema..."
case "$DISTRO" in
    arch)   sudo pacman -Syu --noconfirm ;;
    fedora) sudo dnf update -y ;;
    debian) sudo apt update && sudo apt full-upgrade -y ;;
esac

#============================================================
#  LIMPIAR OTROS WM/DE
#============================================================
echo "▶ Eliminando otros WM/DE..."
OTHER_WM=(gnome-shell gnome-session gnome-control-center mutter gdm
          plasma-desktop plasma-workspace kwin sddm
          xfce4-session xfwm4 lxqt-session lxde-common
          i3 i3-gaps sway openbox bspwm awesome qtile
          mate-session-manager cinnamon lightdm ly greetd lxdm)
for pkg in "${OTHER_WM[@]}"; do
    case "$DISTRO" in
        arch)   pacman -Qi "$pkg" &>/dev/null && sudo pacman -Rns --noconfirm "$pkg" 2>/dev/null || true ;;
        fedora) rpm -q "$pkg" &>/dev/null && sudo dnf remove -y "$pkg" 2>/dev/null || true ;;
        debian) dpkg -l "$pkg" 2>/dev/null | grep -q "^ii" && sudo apt remove -y --purge "$pkg" 2>/dev/null || true ;;
    esac
done

#============================================================
#  BASE DEL SISTEMA
#============================================================
echo "▶ Base del sistema..."

PKG zsh git curl wget unzip zip rsync
P p7zip
P openssh
P man-pages
PKG xdg-user-dirs

# Herramientas de compilación (Fedora necesita groupinstall)
if [[ "$DISTRO" == "fedora" ]]; then
    sudo dnf groupinstall -y "Development Tools"
else
    P build-tools
fi

# usermod evita el prompt de contraseña que bloquearía chsh en Debian/Fedora
sudo usermod -s "$(command -v zsh)" "$USER"

#============================================================
#  HERRAMIENTAS CLI
#============================================================
echo "▶ Herramientas CLI..."

PKG bat ripgrep fzf btop jq tmux neovim kanshi
P fd

# starship (Debian no tiene paquete oficial)
case "$DISTRO" in
    arch|fedora) PKG starship ;;
    debian) gh_install 'starship/starship' 'starship-x86_64-unknown-linux-gnu\.tar\.gz' 'starship' ;;
esac

# eza
case "$DISTRO" in
    arch|fedora) PKG eza ;;
    debian) PKG eza 2>/dev/null \
                || gh_install 'eza-community/eza' 'eza_x86_64-unknown-linux-gnu\.tar\.gz' 'eza' ;;
esac

# sd, procs — mismas en arch/fedora; Debian puede no tenerlas
case "$DISTRO" in
    arch|fedora) PKG sd procs ;;
    debian)
        PKG sd    2>/dev/null || gh_install 'chmln/sd'      'sd-v.*-x86_64-unknown-linux-gnu\.tar\.gz' 'sd'
        PKG procs 2>/dev/null || gh_install 'dalance/procs' 'procs-v.*-x86_64-linux\.zip'              'procs'
        ;;
esac

# duf, dust, fastfetch
case "$DISTRO" in
    arch|fedora) PKG duf dust fastfetch ;;
    debian)
        PKG duf       2>/dev/null || gh_install 'muesli/duf'              'duf_.*_linux_amd64\.tar\.gz'                  'duf'
        PKG dust      2>/dev/null || gh_install 'bootandy/dust'           'dust-v.*-x86_64-unknown-linux-gnu\.tar\.gz'   'dust'
        PKG fastfetch 2>/dev/null || gh_install 'fastfetch-cli/fastfetch' 'fastfetch-linux-amd64\.tar\.gz'               'fastfetch'
        ;;
esac

# zoxide
case "$DISTRO" in
    arch|fedora) PKG zoxide ;;
    debian) PKG zoxide 2>/dev/null \
                || curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh ;;
esac

# tldr / tealdeer
case "$DISTRO" in
    arch)   PKG tldr ;;
    fedora) PKG tealdeer ;;
    debian) PKG tealdeer 2>/dev/null \
                || gh_install 'dbrgn/tealdeer' 'tealdeer-linux-x86_64-musl' 'tldr' ;;
esac

# yazi (Arch tiene paquete; resto desde GitHub)
case "$DISTRO" in
    arch) PKG yazi ;;
    *)    gh_install 'sxyazi/yazi' 'yazi-x86_64-unknown-linux-gnu\.tar\.gz' 'yazi' ;;
esac

# git-delta
case "$DISTRO" in
    arch|fedora) PKG git-delta ;;
    debian) PKG git-delta 2>/dev/null \
                || gh_install 'dandavison/delta' 'delta-.*-x86_64-unknown-linux-gnu\.tar\.gz' 'delta' ;;
esac

# lazygit (solo Arch tiene paquete)
case "$DISTRO" in
    arch) PKG lazygit ;;
    *)    gh_install 'jesseduffield/lazygit' 'lazygit_.*_Linux_x86_64\.tar\.gz' 'lazygit' ;;
esac

# bandwhich
case "$DISTRO" in
    arch|fedora) PKG bandwhich ;;
    debian) PKG bandwhich 2>/dev/null \
                || gh_install 'imsnif/bandwhich' 'bandwhich-v.*-x86_64-unknown-linux-musl\.tar\.gz' 'bandwhich' ;;
esac

# glow (solo Arch tiene paquete)
case "$DISTRO" in
    arch) PKG glow ;;
    *)    gh_install 'charmbracelet/glow' 'glow_Linux_x86_64\.tar\.gz' 'glow' ;;
esac

# hyperfine
case "$DISTRO" in
    arch|fedora) PKG hyperfine ;;
    debian) PKG hyperfine 2>/dev/null \
                || gh_install 'sharkdp/hyperfine' 'hyperfine-v.*-x86_64-unknown-linux-gnu\.tar\.gz' 'hyperfine' ;;
esac

#============================================================
#  RED Y DISCO
#============================================================
echo "▶ Red y hardware..."

PKG nmap net-tools traceroute mtr iperf3
P bind-utils

PKG smartmontools nvme-cli lsof usbutils pciutils ntfs-3g udisks2 udiskie wf-recorder

case "$DISTRO" in
    arch)   PKG reflector pacman-contrib ;;
    fedora) PKG dnf-plugins-core ;;
    debian) PKG apt-utils ;;
esac

#============================================================
#  SEGURIDAD Y CRON
#============================================================
echo "▶ Seguridad y cron..."

P gnupg

case "$DISTRO" in
    arch|fedora) PKG age ;;
    debian) PKG age 2>/dev/null \
                || gh_install 'FiloSottile/age' 'age-v.*-linux-amd64\.tar\.gz' 'age' ;;
esac

P cronie
sudo systemctl enable cron 2>/dev/null || sudo systemctl enable cronie 2>/dev/null || true

#============================================================
#  AUDIO (PIPEWIRE)
#============================================================
echo "▶ Audio..."

PKG pipewire wireplumber pavucontrol pipewire-alsa
P pipewire-pulse
P pipewire-jack

#============================================================
#  BLUETOOTH
#============================================================
echo "▶ Bluetooth..."

PKG bluez blueman
P bluez-utils

sudo systemctl enable bluetooth
sudo systemctl start bluetooth 2>/dev/null || true

#============================================================
#  RED
#============================================================
echo "▶ Red..."

PKG networkmanager
sudo systemctl enable NetworkManager
[[ "$DISTRO" == "fedora" ]] && PKG nm-connection-editor
P nm-applet

#============================================================
#  DOCKER
#============================================================
echo "▶ Docker..."

case "$DISTRO" in
    arch)
        PKG docker docker-compose
        ;;
    fedora)
        PKG docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        ;;
    debian)
        # Intentar Docker CE oficial; si el repo no tiene trixie, usar docker.io de Debian
        PKG docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 2>/dev/null \
            || PKG docker.io docker-compose
        ;;
esac
sudo systemctl enable docker
sudo usermod -aG docker "$USER"
echo "NOTA: El grupo 'docker' requiere cerrar sesión para tener efecto."

# Timeshift
case "$DISTRO" in
    arch) PKG timeshift ;;
    fedora)
        PKG timeshift 2>/dev/null \
            || echo "  WARN: timeshift no disponible — habilita: sudo dnf copr enable paolosr/timeshift"
        ;;
    debian)
        TS_TMP=$(mktemp -d)
        TS_URL=$(curl -s "https://api.github.com/repos/teejee2008/timeshift/releases/latest" \
            | grep "browser_download_url" | grep "\.deb" | head -1 | cut -d '"' -f 4)
        if [[ -n "$TS_URL" ]]; then
            curl -sL "$TS_URL" -o "$TS_TMP/timeshift.deb"
            sudo apt install -y "$TS_TMP/timeshift.deb" 2>/dev/null || echo "  WARN: timeshift .deb no instalado"
        fi
        rm -rf "$TS_TMP"
        ;;
esac

#============================================================
#  HYPRLAND
#============================================================
echo "▶ Hyprland..."

case "$DISTRO" in
    arch|fedora) PKG hyprland aquamarine hyprlang hyprcursor hyprutils hyprgraphics ;;
    debian)      PKG hyprland ;;
esac

PKG hypridle hyprlock
PKG xdg-desktop-portal-hyprland xdg-desktop-portal-gtk

# Polkit
case "$DISTRO" in
    arch|fedora) PKG polkit-gnome ;;
    debian)      PKG policykit-1-gnome 2>/dev/null || PKG polkit-gnome 2>/dev/null || true ;;
esac

P qt5-wayland
P qt6-wayland

#============================================================
#  PLUGINS DE HYPRLAND (hyprpm)
#============================================================
echo "▶ Plugins de Hyprland..."

[[ "$DISTRO" == "fedora" ]] && PKG hyprland-devel 2>/dev/null || true
[[ "$DISTRO" == "debian" ]] && PKG libhyprland-dev 2>/dev/null || true

hyprpm update
hyprpm add https://github.com/hyprwm/hyprland-plugins   # hyprexpo + borders-plus-plus
hyprpm add https://github.com/VortexCoyote/hyprfocus     # efecto de enfoque
hyprpm enable borders-plus-plus
hyprpm enable hyprexpo
hyprpm enable hyprfocus

#============================================================
#  ENTORNO VISUAL
#============================================================
echo "▶ Entorno visual..."

PKG kitty waybar

# swaync
case "$DISTRO" in
    arch)   PKG swaync ;;
    fedora) PKG SwayNotificationCenter ;;
    debian)
        if ! PKG swaync 2>/dev/null; then
            # gh_install no sirve para .deb → descargar e instalar con dpkg
            _SNC_TMP=$(mktemp -d)
            _SNC_URL=$(curl -s "https://api.github.com/repos/ErikReider/SwayNotificationCenter/releases/latest" \
                | grep "browser_download_url" | grep 'amd64\.deb' | head -1 | cut -d '"' -f 4)
            if [[ -n "$_SNC_URL" ]]; then
                curl -sL "$_SNC_URL" -o "$_SNC_TMP/swaync.deb"
                sudo apt install -y "$_SNC_TMP/swaync.deb" 2>/dev/null \
                    || echo "  WARN: swaync .deb no instalado — instalar desde github.com/ErikReider/SwayNotificationCenter"
            else
                echo "  WARN: swaync no disponible — instalar desde github.com/ErikReider/SwayNotificationCenter"
            fi
            rm -rf "$_SNC_TMP"
        fi
        ;;
esac

# swww
case "$DISTRO" in
    arch|fedora) PKG swww ;;
    debian) PKG swww 2>/dev/null \
                || gh_install 'LGFae/swww' 'swww-.*-x86_64-unknown-linux-musl\.tar\.gz' 'swww' ;;
esac

PKG grim slurp

# swappy
case "$DISTRO" in
    arch|fedora) PKG swappy ;;
    debian)      PKG swappy 2>/dev/null || echo "  WARN: swappy no disponible en apt" ;;
esac

PKG wl-clipboard

# cliphist
case "$DISTRO" in
    arch|fedora) PKG cliphist ;;
    debian) PKG cliphist 2>/dev/null \
                || gh_install 'sentriz/cliphist' 'linux_amd64$' 'cliphist' ;;
esac

PKG brightnessctl playerctl

# swayosd
case "$DISTRO" in
    arch|fedora) PKG swayosd ;;
    debian)
        PKG swayosd 2>/dev/null \
            || echo "  WARN: swayosd no disponible — instalar desde github.com/ErikReider/SwayOSD"
        ;;
esac

# wlsunset
case "$DISTRO" in
    arch|fedora) PKG wlsunset ;;
    debian)      PKG wlsunset 2>/dev/null || PKG gammastep 2>/dev/null || true ;;
esac

PKG pass

# Discord
case "$DISTRO" in
    arch) PKG discord ;;
    *)    flatpak install -y flathub com.discordapp.Discord ;;
esac

#============================================================
#  MULTIMEDIA
#============================================================
echo "▶ Multimedia..."

P ffmpeg
P imagemagick
PKG mpv imv

# zathura + plugin mupdf
case "$DISTRO" in
    arch|fedora) PKG zathura zathura-pdf-mupdf ;;
    debian)      PKG zathura zathura-plugin-mupdf 2>/dev/null || PKG zathura ;;
esac

#============================================================
#  FUENTES
#============================================================
echo "▶ Fuentes..."

case "$DISTRO" in
    arch)
        PKG ttf-hack-nerd ttf-jetbrains-mono-nerd ttf-font-awesome noto-fonts-emoji
        ;;
    fedora)
        PKG fontawesome-fonts fontawesome6-fonts google-noto-emoji-fonts
        install_nerd_font "Hack"
        install_nerd_font "JetBrainsMono"
        fc-cache -fv "$HOME/.local/share/fonts" 2>/dev/null
        ;;
    debian)
        PKG fonts-font-awesome fonts-noto-color-emoji
        install_nerd_font "Hack"
        install_nerd_font "JetBrainsMono"
        fc-cache -fv "$HOME/.local/share/fonts" 2>/dev/null
        ;;
esac

#============================================================
#  EXTRAS — APPS, CURSORES, TEMAS GTK
#============================================================
echo "▶ Apps extra..."

case "$DISTRO" in
    arch)
        # AUR helper
        echo "  → Instalando paru..."
        PARU_TMP=$(mktemp -d)
        git clone https://aur.archlinux.org/paru.git "$PARU_TMP"
        (cd "$PARU_TMP" && makepkg -si --noconfirm)
        rm -rf "$PARU_TMP"

        paru -S --noconfirm rofi-wayland rofi-calc
        paru -S --noconfirm pypr
        PKG calcurse flameshot
        PKG firefox
        paru -S --noconfirm brave-bin google-chrome tor-browser spotify
        paru -S --noconfirm nerd-fonts
        paru -S --noconfirm uwsm
        paru -S --noconfirm kora-icon-theme bibata-cursor-theme
        paru -S --noconfirm tokyonight-gtk-theme-git
        ;;

    fedora)
        PKG calcurse flameshot uwsm rofi-wayland
        PKG python3-pip && pip3 install --user --break-system-packages pyprland
        echo "  NOTA: pypr instalado en ~/.local/bin — asegúrate de que está en \$PATH"

        PKG firefox
        flatpak install -y flathub com.brave.Browser
        flatpak install -y flathub com.google.Chrome
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
        PKG uwsm 2>/dev/null \
            || gh_install 'Vladimir-csp/uwsm' 'uwsm-.*-x86_64.*\.tar\.gz' 'uwsm' 2>/dev/null \
            || echo "  WARN: uwsm no disponible — arranca Hyprland directamente desde TTY"
        PKG python3-pip && pip3 install --user --break-system-packages pyprland
        echo "  NOTA: pypr instalado en ~/.local/bin — asegúrate de que está en \$PATH"

        PKG firefox 2>/dev/null || PKG firefox-esr 2>/dev/null || true
        flatpak install -y flathub com.brave.Browser
        flatpak install -y flathub com.google.Chrome
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
echo "▶ Creando symlinks..."
mkdir -p ~/.config

# Archivos en $HOME
ln -sf "$DOTFILES/.zshrc"    ~/.zshrc
ln -sf "$DOTFILES/.zprofile" ~/.zprofile
ln -sf "$DOTFILES/.gitconfig" ~/.gitconfig

# Carpetas en ~/.config
for cfg in hypr kitty nvim waybar swaync rofi starship tmux yazi fastfetch \
           kanshi btop mpv zathura gtk-3.0 gtk-4.0 \
           themes calcurse swayosd pypr hyprexpose; do
    ln -sf "$DOTFILES/.config/$cfg" ~/.config/$cfg
done

# Wallpapers
mkdir -p "$DOTFILES/.config/.wallpaper"
ln -sf "$DOTFILES/.config/.wallpaper" ~/.config/.wallpaper
ln -sf "$DOTFILES/.config/user-dirs.dirs" ~/.config/user-dirs.dirs

# Configs de sistema específicas de Arch
if [[ "$DISTRO" == "arch" ]]; then
    [[ -f /etc/pacman.conf ]] && sudo cp /etc/pacman.conf /etc/pacman.conf.bak
    sudo cp "$DOTFILES/etc/pacman.conf" /etc/pacman.conf
    sudo mkdir -p /etc/xdg/reflector
    sudo cp "$DOTFILES/etc/reflector.conf" /etc/xdg/reflector/reflector.conf
    sudo systemctl enable reflector.timer
fi

# Permisos de scripts
chmod +x "$DOTFILES/update.sh" "$DOTFILES/sync.sh"
chmod +x "$DOTFILES/.config/hypr/scripts/"*.sh
chmod +x "$DOTFILES/.config/waybar/"*.sh
chmod +x "$DOTFILES/.config/swaync/"*.sh

# Aplicar tema inicial (tokyonight) usando theme-functions
# shellcheck source=.config/hypr/scripts/lib/theme-functions.sh
source "$DOTFILES/.config/hypr/scripts/lib/theme-functions.sh"
apply_theme_symlinks "tokyonight"

echo "tokyonight"        > ~/.config/.current-theme
echo "Bibata-Modern-Ice" > ~/.config/.current-cursor

xdg-user-dirs-update

#============================================================
#  TPM — TMUX PLUGIN MANAGER
#============================================================
echo "▶ Instalando TPM..."
[[ -d ~/.tmux/plugins/tpm ]] \
    || git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

#============================================================
#  OH MY ZSH
#============================================================
echo "▶ Instalando Oh My Zsh..."
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
[[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]] \
    || git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
[[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]] \
    || git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
[[ -d "$ZSH_CUSTOM/plugins/zsh-history-substring-search" ]] \
    || git clone https://github.com/zsh-users/zsh-history-substring-search "$ZSH_CUSTOM/plugins/zsh-history-substring-search"

#============================================================
#  CRONTAB — ACTUALIZACIÓN AUTOMÁTICA AL ARRANCAR
#============================================================
echo "▶ Configurando actualización automática..."
(crontab -l 2>/dev/null | grep -v 'update.sh'; \
 echo "@reboot sleep 60 && ${DOTFILES}/update.sh >> \$HOME/.local/share/update.log 2>&1") | crontab -

#============================================================
#  AUTOLOGIN TTY1 → ZSH → HYPRLAND (via uwsm)
#============================================================
echo "▶ Configurando autologin en TTY1..."

for dm in gdm sddm lightdm ly greetd lxdm; do
    systemctl is-enabled "$dm" &>/dev/null && sudo systemctl disable "$dm"
done

sudo systemctl enable getty@tty1
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
sudo tee /etc/systemd/system/getty@tty1.service.d/autologin.conf > /dev/null <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $USER --noclear %I \$TERM
EOF
echo "  ✓ Autologin configurado para '$USER' en TTY1."

#============================================================
#  RESUMEN FINAL
#============================================================
echo ""
echo "======================================================"
echo "  INSTALACIÓN COMPLETADA — $DISTRO + Hyprland"
echo "======================================================"
echo ""
echo "  → Reinicia para aplicar todos los cambios."
echo ""
echo "  Configura git antes de usar:"
echo "    git config --global user.name  'Tu Nombre'"
echo "    git config --global user.email 'tu@email.com'"
echo ""

if [[ "$DISTRO" =~ ^(fedora|debian)$ ]]; then
    echo "  APPS INSTALADAS COMO FLATPAK:"
    echo "    brave      → flatpak run com.brave.Browser"
    echo "    chrome     → flatpak run com.google.Chrome"
    echo "    spotify    → flatpak run com.spotify.Client"
    echo "    discord    → flatpak run com.discordapp.Discord"
    echo "    torbrowser → flatpak run com.github.micahflee.torbrowser-launcher"
    echo ""
    echo "  pypr instalado en ~/.local/bin (ya en \$PATH via .zprofile)"
    echo ""
fi
