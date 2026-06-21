# ============================================================================
# Zsh Configuration - Oh My Zsh
# ============================================================================

# Path to Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-autocomplete
    fzf
    docker
    kubectl
    docker-compose
    pip
    python
    node
    npm
    yarn
    rust
    golang
    tmux
)

# Enable Powerlevel10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ============================================================================
# ENVIRONMENT VARIABLES
# ============================================================================

# Set default editor
export EDITOR="nvim"
export VISUAL="$EDITOR"

# XDG Base Directory
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# Development paths
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/dotfiles/bin:$PATH"

# History settings
export HISTSIZE=10000
export SAVEHIST=10000
export HISTFILE="$HOME/.zsh_history"
export HISTDUP=empty

# ============================================================================
# ALIASES - File Management
# ============================================================================

alias ls='eza -la --icons --git'
alias ll='eza -l --icons --git'
alias la='eza -la --icons'
alias lt='eza -lTg'
alias tree='eza --tree'
alias tr='eza --tree'

# ============================================================================
# ALIASES - File Viewing
# ============================================================================

alias cat='bat'
alias catn='bat --number'
alias less='bat'

# ============================================================================
# ALIASES - Git
# ============================================================================

alias g='lazygit'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias gf='git fetch'
alias gm='git merge'
alias gr='git rebase'
alias gst='git stash'
alias gsp='git stash pop'
alias glog='git log --oneline --graph --decorate'

# ============================================================================
# ALIASES - Docker
# ============================================================================

alias d='docker'
alias dc='docker-compose'
alias dcu='docker-compose up -d'
alias dcd='docker-compose down'
alias di='docker images'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias dex='docker exec -it'
alias dlog='docker logs -f'

# ============================================================================
# ALIASES - System
# ============================================================================

alias h='htop'
alias b='btop'
alias ff='fastfetch'
alias ports='netstat -tulanp'
alias memi='free -m -l'
alias cpui='lscpu'
alias myip='curl http://ipecho.net/plain; echo'

# ============================================================================
# ALIASES - Navigation
# ============================================================================

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~~='cd ~'
alias down='cd ~/Downloads'
alias repos='cd ~/Repositories'
alias desk='cd ~/Desktop'
alias docx='cd ~/Documents'
alias Dev='cd ~/DevHome'
alias Pform='cd ~/DevHome/Platforms/'
alias works='cd ~/DevHome/Workspaces/'
alias hlab='cd ~/DevHome/Workspaces/Homelab-Workspace'
alias SS='cd ~/DevHome/Staging-Space/'

# ============================================================================
# ALIASES - Utilities
# ============================================================================

alias v='nvim'
alias n='nvim'
alias vim='nvim'
alias code='code .'
alias cls='clear'
alias which='which -a'

# ============================================================================
# ALIASES - Shortcuts
# ============================================================================

alias lg='lazygit'
alias ld='lazydocker'
alias y='yazi'
alias yy='yazi .'
alias f='fzf --preview="bat --color=always {}"'

# ============================================================================
# CUSTOM FUNCTIONS
# ============================================================================

# Create directory and cd into it
function mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Yazi with directory change
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXX.cwd")"
    pwd > "$tmp"
    command yazi "$@" --cwd-file="$tmp"
    local ret=$?
    if [ $ret -eq 0 ]; then
        cd "$(cat "$tmp")"
    fi
    rm -f "$tmp"
    return $ret
}

# Find file
function ff() {
    find . -type f -name "*$1*"
}

# Kill port
function kp() {
    lsof -ti:$1 | xargs kill -9
}

# Extract archives
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2) tar xjf "$1" ;;
            *.tar.gz) tar xzf "$1" ;;
            *.bz2) bunzip2 "$1" ;;
            *.rar) unrar x "$1" ;;
            *.gz) gunzip "$1" ;;
            *.tar) tar xf "$1" ;;
            *.tbz2) tar xjf "$1" ;;
            *.tgz) tar xzf "$1" ;;
            *.zip) unzip "$1" ;;
            *.Z) uncompress "$1" ;;
            *.7z) 7z x "$1" ;;
            *) echo "Don't know how to extract '$1'..." ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# ============================================================================
# TOOL INITIALIZATIONS
# ============================================================================

# Starship prompt
eval "$(starship init zsh)"

# Atuin history
eval "$(atuin init zsh)"

# zoxide
eval "$(zoxide init zsh)"

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# direnv
if command -v direnv &>/dev/null; then
    eval "$(direnv hook zsh)"
fi

# mise
if command -v mise &>/dev/null; then
    eval "$(mise hook zsh)"
fi

# ============================================================================
# COMPLETION SETTINGS
# ============================================================================

# Enable autocompletion
autoload -Uz compinit
compinit

# Case-insensitive completion
zstyle ':completion:*' matcher 'r:|=*' 'l:|=*'

# Colored completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Group by type
zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*' groups ''

# ============================================================================
# KEY BINDINGS
# ============================================================================

# Use emacs key bindings
bindkey -e

# Ctrl+Left/Right for word jumping
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# Home/End keys
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line

# Delete key
bindkey "^[[3~" delete-char

# ============================================================================
# TMUX AUTO-START
# ============================================================================

# if command -v tmux &>/dev/null && [ -z "$TMUX" ]; then
#     if ! tmux has-session 2>/dev/null; then
#         tmux new-session -d -s main
#     fi
#     tmux attach-session -d -t main
# fi

# ============================================================================
# END OF ZSH CONFIG
# ============================================================================
