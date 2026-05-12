#----------------------------
#FICHERO .ZSHRC PARA TERMINAL
#-----------------------------
#============================
#      == OH-MY-ZSH ==
#============================
# === VARIABLE ===
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="" #DESACTIVADO PARA QUE LO USE PROMPT
# === PLUGINS ===
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
#      == ALIASES ==
#============================
# NAVEGACIÓN Y ARCHIVOS
alias ..="cd .."
alias ...="cd ../.."
alias ls="eza --icons"
alias ll="eza -lah --icons"
alias lt="eza --tree --icons"
alias yy="yazi"
alias cp="cp -iv"
alias rm="rm -iv"
alias mkdir="mkdir -p"
# HERRAMIENTAS MODERNAS
alias cat="bat"
alias grep="rg"
alias find="fd"
alias ps="procs"
alias du="dust"
alias df="duf"
# RED
alias ip="ip -color"
alias ping="ping -c 5"
alias myip="curl ifconfig.me"
alias ports="ss -tulnp"
# GIT
alias g="git"
alias gs="git status"
alias gl="git log --oneline --graph"
# SISTEMA
alias update="sudo pacman -Syu"
alias cleanup="sudo pacman -Rns $(pacman -Qtdq)"
alias reload="source ~/.zshrc"
alias path="echo $PATH | tr ':' '\n'"
alias keybinds="cat ~/.config/hypr/keybinds.conf"
alias top="btop"
alias info="fastfetch"
# NEOVIM
alias vim="nvim"
alias vi="nvim"
alias v="nvim"
# DOCKER
alias d="docker"
alias dc="docker compose"
alias dps="docker ps"
alias dimg="docker images"
# PACMAN/PARU
alias install="paru -S"
alias remove="paru -Rns"
alias search="paru -Ss"
alias pkginfo="paru -Qi"
# GIT EXTENDED
alias ga="git add"
alias gc="git commit -m"
alias gp="git push"
alias gpl="git pull"
alias gd="git diff"
alias gco="git checkout"
alias gb="git branch"
#============================
#     == INTEGRATIONS ==
#============================
# ZOXIDE(CD INTELIGENTE)
eval "$(zoxide init zsh)"
# FZF
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh

#============================
#     == STARSHIP ==
#============================
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
eval "$(starship init zsh)"