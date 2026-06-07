#============================
#      == ALIASES ==
#============================

# NAVEGACIÓN
alias ..="cd .."
alias ...="cd ../.."
alias ls="eza --icons"
alias list="eza --icons"
alias ll="eza -lah --icons"
alias lt="eza --tree --icons"
alias yy="yazi"
alias cp="cp -iv"
alias rm="rm -iv"
alias mkdir="mkdir -p"

# HERRAMIENTAS MODERNAS
alias cat="bat --paging=never"
alias grep="rg"
alias ps="procs"
alias du="dust"
alias df="duf"

# RED
alias ping="ping -c 5"
alias myip="curl -s ifconfig.me"
alias ports="ss -tulnp"

# GIT
alias g="git"
alias gs="git status"
alias gl="git log --oneline --graph"
alias ga="git add"
alias gc="git commit -m"
alias gp="git push"
alias gpl="git pull"
alias gd="git diff"
alias gco="git checkout"
alias gb="git branch"

# SISTEMA (Arch / paru)
alias pinstall="paru -S"
alias premove="paru -Rns"
alias psearch="paru -Ss"
alias pinfo="paru -Qi"
alias pupdate="paru -Syu"

# SISTEMA (Arch / pacman)
alias pminstall="sudo pacman -S"
alias pmremove="sudo pacman -Rns"
alias pmsearch="pacman -Ss"
alias pminfo="pacman -Qi"
alias pmupdate="sudo pacman -Syu"
alias pmorphans="pacman -Qtdq"
alias reload="source ~/.zshrc"
alias path='echo $PATH | tr ":" "\n"'
alias top="btop"

# NEOVIM
alias vim="nvim"
alias vi="nvim"
alias v="nvim"

# DOCKER
alias d="docker"
alias dc="docker compose"
alias dps="docker ps"
alias dimg="docker images"

# HACKING — DIRECTORIOS
alias hacking="cd $HOME/HACKING"
alias dockerhack="cd $HOME/HACKING/DockerLabs/"

# HACKING — RED
alias ifaces="ip -br a"
alias mymac="ip link show | grep ether"

# HACKING — NMAP
# Escaneo TCP (todos los puertos, SYN scan rápido)
alias nmap-tcp="sudo nmap -sS -p- --open -T4"
# Escaneo de hosts activos en red (sin puertos)
alias nmap-hosts="sudo nmap -sn"
# Detección de hosts Windows (SMB + OS fingerprint)
alias nmap-win="sudo nmap -p 135,139,445 --script smb-os-discovery,smb2-security-mode -O"
# Escaneo de puertos + versión de servicios
alias nmap-services="sudo nmap -sS -sV -p- --open -T4"
# Mapeo de red completo con salida a fichero
alias nmap-map="sudo nmap -sn -oN nmap-hosts.txt"
# Scripts por defecto + versiones
alias nmap-scripts="sudo nmap -sC -sV"
# Scripts de vulnerabilidades
alias nmap-vuln="sudo nmap --script vuln"

# HACKING — GOBUSTER
alias gob-dir="gobuster dir -w /usr/share/wordlists/dirb/common.txt -u"
alias gob-dir-big="gobuster dir -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -u"
alias gob-dns="gobuster dns -w /usr/share/wordlists/SecLists/Discovery/DNS/subdomains-top1million-5000.txt -d"
alias gob-vhost="gobuster vhost -w /usr/share/wordlists/SecLists/Discovery/DNS/subdomains-top1million-5000.txt -u"

# HACKING — FFUF
alias ffuf-dir="ffuf -w /usr/share/wordlists/dirb/common.txt -u"
alias ffuf-params="ffuf -w /usr/share/wordlists/SecLists/Discovery/Web-Content/burp-parameter-names.txt -u"
alias ffuf-vhost="ffuf -w /usr/share/wordlists/SecLists/Discovery/DNS/subdomains-top1million-5000.txt -H 'Host: FUZZ' -u"

# HACKING — ARJUN
alias arjun-get="arjun -m GET -u"
alias arjun-post="arjun -m POST -u"
alias arjun-json="arjun -m JSON -u"

# HACKING — HYDRA
alias hydra-ssh="hydra -l root -P /usr/share/wordlists/rockyou.txt ssh://"
alias hydra-ftp="hydra -l admin -P /usr/share/wordlists/rockyou.txt ftp://"
alias hydra-http="hydra -l admin -P /usr/share/wordlists/rockyou.txt http-post-form"

# HYPRLAND / ENTORNO
alias atajos="~/.config/hypr/scripts/show-atajos.sh | less -R"
alias keybinds="~/.config/hypr/scripts/show-atajos.sh | less -R"
alias info="fastfetch"

# LIMPIEZA DE PAQUETES HUÉRFANOS
cleanup() {
    local orphans
    orphans=$(pacman -Qtdq 2>/dev/null)
    [[ -n "$orphans" ]] && sudo pacman -Rns $orphans || echo "No hay paquetes huérfanos."
}
