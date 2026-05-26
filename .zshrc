#============================
#      == OH-MY-ZSH ==
#============================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-history-substring-search
    docker
    tmux
)
source $ZSH/oh-my-zsh.sh

#============================
#      == HISTORIAL ==
#============================
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY

#============================
#      == ALIASES ==
#============================

# DETECCIÓN DE DISTRO — usada en aliases y funciones distro-específicas
# $ID viene de /etc/os-release: "arch", "fedora", "ubuntu", "darwin", etc.
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    DOTFILES_DISTRO="$ID"
elif [[ "$(uname)" == "Darwin" ]]; then
    DOTFILES_DISTRO="darwin"
else
    DOTFILES_DISTRO="unknown"
fi

# NAVEGACIÓN
alias ..="cd .."
alias ...="cd ../.."
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

# SISTEMA — aliases dependientes de la distro
case "$DOTFILES_DISTRO" in
    arch)
        alias install="paru -S"
        alias remove="paru -Rns"
        alias search="paru -Ss"
        alias pkginfo="paru -Qi"
        alias update="~/dotfiles-arch/update.sh"
        ;;
    fedora)
        alias install="sudo dnf install -y"
        alias remove="sudo dnf remove -y"
        alias search="dnf search"
        alias pkginfo="dnf info"
        alias update="~/dotfiles-arch/update-fedora.sh"
        ;;
    debian)
        alias install="sudo apt install -y"
        alias remove="sudo apt remove -y"
        alias search="apt search"
        alias pkginfo="apt show"
        alias update="~/dotfiles-arch/update.sh"
        ;;
    darwin)
        alias install="brew install"
        alias remove="brew uninstall"
        alias search="brew search"
        alias pkginfo="brew info"
        alias update="brew update && brew upgrade"
        ;;
    *)
        alias update="echo 'Distro no reconocida: $DOTFILES_DISTRO'"
        ;;
esac
alias reload="source ~/.zshrc"
alias path="echo $PATH | tr ':' '\n'"
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

# HYPRLAND / ENTORNO
alias atajos="~/.config/hypr/scripts/show-atajos.sh | less -R"
alias keybinds="~/.config/hypr/scripts/show-atajos.sh | less -R"
alias info="fastfetch"

# Limpieza de paquetes huérfanos/no usados
cleanup() {
    case "$DOTFILES_DISTRO" in
        arch)
            local orphans
            orphans=$(pacman -Qtdq 2>/dev/null)
            [[ -n "$orphans" ]] && sudo pacman -Rns $orphans || echo "No hay paquetes huérfanos."
            ;;
        fedora)
            sudo dnf autoremove -y
            ;;
        debian)
            sudo apt autoremove -y && sudo apt autoclean
            ;;
        darwin)
            brew autoremove && brew cleanup
            ;;
        *)
            echo "cleanup: distro '$DOTFILES_DISTRO' no soportada"
            ;;
    esac
}

#============================
#      == FZF ==
#============================
# Las rutas de FZF varían según distro:
#   Arch:   /usr/share/fzf/key-bindings.zsh
#   Fedora: /usr/share/fzf/shell/key-bindings.zsh
for _fzf_kb in /usr/share/fzf/key-bindings.zsh \
               /usr/share/fzf/shell/key-bindings.zsh \
               /opt/homebrew/opt/fzf/shell/key-bindings.zsh; do
    [[ -f "$_fzf_kb" ]] && source "$_fzf_kb" && break
done
for _fzf_co in /usr/share/fzf/completion.zsh \
               /usr/share/fzf/shell/completion.zsh \
               /opt/homebrew/opt/fzf/shell/completion.zsh; do
    [[ -f "$_fzf_co" ]] && source "$_fzf_co" && break
done
unset _fzf_kb _fzf_co

# fd como backend: incluye hidden, excluye .git
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'

# Preview: bat para archivos, tree para directorios
export FZF_DEFAULT_OPTS="
  --height 40%
  --layout=reverse
  --border=rounded
  --preview-window=right:55%
  --preview '([[ -d {} ]] && eza --tree --icons --color=always {}) || bat --color=always --style=numbers {}'
  --bind 'ctrl-/:toggle-preview'
"
export FZF_CTRL_T_OPTS="$FZF_DEFAULT_OPTS"

#============================
#     == FASTFETCH ==
#============================
fastfetch() {
    if [[ "$*" == *"--config"* ]] || [[ "$*" == *" -c "* ]]; then
        command fastfetch "$@"
        return
    fi
    local theme=$(cat ~/.config/.current-theme 2>/dev/null || echo "tokyonight")
    local config="$HOME/.config/fastfetch/config-tokyonight.jsonc"
    [[ "$theme" == "auditory" ]] && config="$HOME/.config/fastfetch/config-auditory.jsonc"
    command fastfetch --config "$config" "$@"
}

#============================
#     == INTEGRATIONS ==
#============================
eval "$(zoxide init zsh)"
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
eval "$(starship init zsh)"
