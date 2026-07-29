export PATH="/usr/bin:$PATH"
export PATH="$HOME/.npm-global/bin:$PATH"
#============================
#         == PATH ==
#============================
export PATH="$HOME/.local/share/pnpm/bin:$PATH"

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
  --highlight-line
  --info=inline-right
  --ansi
  --color=bg+:#283457
  --color=bg:#16161e
  --color=border:#27a1b9
  --color=fg:#c0caf5
  --color=gutter:#16161e
  --color=header:#ff9e64
  --color=hl+:#2ac3de
  --color=hl:#2ac3de
  --color=info:#545c7e
  --color=marker:#ff007c
  --color=pointer:#ff007c
  --color=prompt:#2ac3de
  --color=query:#c0caf5:regular
  --color=scrollbar:#27a1b9
  --color=separator:#ff9e64
  --color=spinner:#ff007c
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
eval "$(oh-my-posh init zsh --config /usr/share/oh-my-posh/themes/tokyonight_storm.omp.json)"
eval "$(zoxide init zsh --cmd cd)"

# OpenClaw Completion
[ -f "/home/sreaper/.openclaw/completions/openclaw.zsh" ] && source "/home/sreaper/.openclaw/completions/openclaw.zsh"

. "$HOME/.local/share/../bin/env"
