# === Migrated from: dotfile.d/bash/.bashrc (base) ===
# === Merged with:   Dotfiles.zip/bash/.bashrc (aliases, tools) ===
# === Merged with:   windows-wsl/ultimate-bashrc (functions, fzf, welcome) ===
# === Date:          2026-06-09 ===

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# ===== ENVIRONMENT =====

export EDITOR="nvim"
export VISUAL="$EDITOR"

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

export HISTCONTROL=ignoreboth:erasedups
export HISTSIZE=10000
export HISTFILESIZE=20000
shopt -s histappend
shopt -s checkwinsize

export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
esac

# ===== RIPGREP =====
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"

# ===== TOOL INITIALIZATIONS =====

if command -v starship &> /dev/null; then
    eval "$(starship init bash)"
fi

if command -v zoxide &> /dev/null; then
    eval "$(zoxide init bash)"
fi

if command -v mise &> /dev/null; then
    eval "$(mise activate bash)"
fi

# fzf
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

if command -v fd &> /dev/null; then
    export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"
fi

export FZF_DEFAULT_OPTS="
    --height 40% --layout=reverse --border --margin=1 --padding=1
    --color=fg:#cdd6f4,bg:#1e1e2e,hl:#f9e2af
    --color=fg+:#cdd6f4,bg+:#313244,hl+:#f9e2af
    --color=info:#89b4fa,prompt:#f5c2e7,pointer:#fab387
    --color=marker:#fab387,spinner:#f9e2af,header:#6c7086
"

if command -v bat &> /dev/null && command -v eza &> /dev/null; then
    export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :500 {}'"
    export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always --icons {} | head -200'"
fi

# ===== COLOR SUPPORT =====

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# ===== MODERN ALIASES =====

if command -v eza &> /dev/null; then
    alias ls="eza --icons --group-directories-first"
    alias ll="eza -l --icons --group-directories-first --git"
    alias la="eza -la --icons --group-directories-first --git"
    alias lt="eza --tree --level=2 --icons"
    alias tree="eza --tree"
else
    alias ls='ls --color=auto'
    alias ll='ls -alF'
    alias la='ls -A'
fi

if command -v bat &> /dev/null; then
    alias cat="bat --style=auto"
    alias less="bat"
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

if command -v fd &> /dev/null; then
    alias find="fd"
fi

if command -v rg &> /dev/null; then
    alias grep="rg"
fi

if command -v procs &> /dev/null; then
    alias ps="procs"
fi

if command -v dust &> /dev/null; then
    alias du="dust"
fi

if command -v btop &> /dev/null; then
    alias top="btop"
    alias htop="btop"
fi

if command -v lazygit &> /dev/null; then
    alias lg="lazygit"
fi

if command -v nvim &> /dev/null; then
    alias v="nvim"
    alias n="nvim"
fi

alias y="yazi"
alias yy="yazi ."

# ===== NAVIGATION =====

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ~="cd ~"
alias -- -="cd -"

# ===== FILE OPERATIONS =====

alias cp="cp -iv"
alias mv="mv -iv"
alias rm="rm -I"
alias mkdir="mkdir -pv"

# ===== GIT =====

alias g="git"
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gpl="git pull"
alias gd="git diff"
alias gco="git checkout"
alias gb="git branch"
alias glog="git log --oneline --graph --decorate --all"

# ===== DOCKER =====

alias d="docker"
alias dc="docker-compose"
alias dcu="docker-compose up -d"
alias dcd="docker-compose down"
alias dps="docker ps"
alias dpa="docker ps -a"
alias di="docker images"
alias dlog="docker logs -f"
alias dex="docker exec -it"

# ===== SYSTEM =====

alias reload="source ~/.bashrc"
alias update="sudo apt update && sudo apt upgrade -y"
alias cleanup="sudo apt autoremove -y && sudo apt autoclean"
alias serve="python3 -m http.server"
alias myip="curl ifconfig.me"
alias ff="fastfetch"

# ===== CUSTOM FUNCTIONS =====

mkcd() {
    mkdir -p "$1" && cd "$1"
}

extract() {
    if [ -f $1 ]; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

fopen() {
    local file
    file=$(fzf --preview 'bat --color=always --line-range :500 {}')
    [ -n "$file" ] && ${EDITOR:-nvim} "$file"
}

fcd() {
    local dir
    dir=$(fd --type d | fzf --preview 'eza --tree --color=always --icons {} | head -200')
    [ -n "$dir" ] && cd "$dir"
}

qcommit() {
    git add -A && git commit -m "$1" && git push
}

search() {
    rg -p "$1" | less -R
}

fkill() {
    local pid
    pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
    [ -n "$pid" ] && echo $pid | xargs kill -${1:-9}
}

# ===== NVM =====

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
. "$HOME/.cargo/env"
