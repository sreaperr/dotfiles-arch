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

           Pentesting Tools · Arch Linux
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
command -v paru &>/dev/null || {
    echo "paru no está instalado. Ejecuta install.sh primero."
    exit 1
}
# == Actualizar repos ==
echo "*** Actualizar REPOS ***" && sleep 2
sudo pacman -Syu --noconfirm
# == Herramientas de pentesting (repos oficiales) ==
# Reconocimiento / escaneo
sudo pacman -S --needed --noconfirm nmap gobuster nikto
# Explotación web
sudo pacman -S --needed --noconfirm sqlmap wpscan
# Explotación / post-explotación
sudo pacman -S --needed --noconfirm metasploit openbsd-netcat socat
# Cracking / fuerza bruta
sudo pacman -S --needed --noconfirm hydra john hashcat
# Análisis de red
sudo pacman -S --needed --noconfirm wireshark-qt wireshark-cli tcpdump
# Enumeración SMB
sudo pacman -S --needed --noconfirm smbclient
# == Herramientas de pentesting (AUR) ==
# Se instalan una a una: un solo paquete AUR roto no debe abortar el resto.
AUR_TOOLS="ffuf whatweb enum4linux smbmap nuclei-bin burpsuite"
TOOLS_LOG="$HOME/tools-install-failed.log"
: >"$TOOLS_LOG"
for pkg in $AUR_TOOLS; do
    paru -S --needed --noconfirm "$pkg" || echo "$pkg" >>"$TOOLS_LOG"
done
if [ -s "$TOOLS_LOG" ]; then
    echo "Aviso: $(wc -l <"$TOOLS_LOG") paquetes fallaron. Lista en $TOOLS_LOG"
fi

clear
echo ""
echo "Herramientas de pentesting instaladas."
cat <<'EOF'

  ███████╗██████╗ ███████╗ █████╗ ██████╗ ███████╗██████╗
  ██╔════╝██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔════╝██╔══██╗
  ███████╗██████╔╝█████╗  ███████║██████╔╝█████╗  ██████╔╝
  ╚════██║██╔══██╗██╔══╝  ██╔══██║██╔═══╝ ██╔══╝  ██╔══██╗
  ███████║██║  ██║███████╗██║  ██║██║     ███████╗██║  ██║
  ╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝     ╚══════╝╚═╝  ╚═╝

           Pentesting Tools · Arch Linux
           github.com/sreaperr/dotfiles-arch

EOF
echo ""
echo "*** GRACIAS POR EL APOYO DISFRUTA DE LAS HERRAMIENTAS ***"
