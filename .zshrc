#============================
#         == PATH ==
#============================
export PATH="$HOME/.local/share/pnpm/bin:$PATH"
export PATH="/usr/bin:$PATH"

#============================
#      == OH-MY-ZSH ==
#============================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
plugins=(
    git
    docker
    tmux
)
source $ZSH/oh-my-zsh.sh

# Plugins instalados como paquetes del sistema (pacman) — no en ~/.oh-my-zsh/plugins/
[[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
[[ -f /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh ]] && \
    source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh

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
[[ -f "$HOME/.config/zsh/aliases.zsh" ]] && source "$HOME/.config/zsh/aliases.zsh"

#============================
#      == FZF ==
#============================
[[ -f /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh
[[ -f /usr/share/fzf/completion.zsh   ]] && source /usr/share/fzf/completion.zsh

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
#  == ZSH HIGHLIGHT / SUGGEST ==
#============================
# Colores del syntax highlighting — por tema, gestionado por el theme switcher
typeset -A ZSH_HIGHLIGHT_STYLES
[[ -f "$HOME/.config/zsh/highlight.zsh" ]] && source "$HOME/.config/zsh/highlight.zsh"

# Autosuggestions: usa color8 (gris oscuro del tema) para no competir con el texto
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"

#============================
#     == INTEGRATIONS ==
#============================
[[ -f "$HOME/.config/omp/theme.json" ]] && eval "$(oh-my-posh init zsh --config ~/.config/omp/theme.json)"
eval "$(zoxide init zsh --cmd cd)"

