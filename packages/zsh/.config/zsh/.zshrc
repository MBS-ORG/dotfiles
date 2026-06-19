# History
HISTSIZE=50000; SAVEHIST=50000
HISTFILE="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/history"
mkdir -p "$(dirname "$HISTFILE")"
setopt INC_APPEND_HISTORY SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE

# Completion
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Starship
command -v starship &>/dev/null && eval "$(starship init zsh)"

# Aliases
command -v eza &>/dev/null && alias ls='eza --icons' ll='eza -la --icons' lt='eza -T --icons'
alias grep='rg' 2>/dev/null
alias gs='git status' ga='git add' gc='git commit' gp='git push' gl='git log --oneline --graph'
alias gd='git diff' gco='git checkout' gcb='git checkout -b'

# Tool init
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"
command -v direnv &>/dev/null && eval "$(direnv hook zsh)"

# Overrides
[[ -f "$ZDOTDIR/local.zsh" ]] && source "$ZDOTDIR/local.zsh"
