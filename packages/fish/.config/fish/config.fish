# ============================================================================
# Fish Shell Configuration
# ============================================================================

# ===== ENVIRONMENT =====

# Set default editor
set -gx EDITOR nvim
set -gx VISUAL nvim

# XDG Base Directory
set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx XDG_DATA_HOME "$HOME/.local/share"
set -gx XDG_CACHE_HOME "$HOME/.cache"

# Development paths
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.cargo/bin

# History settings
set -gx fish_max_history_size 10000

# ===== TOOL INITIALIZATIONS =====

# Starship prompt
starship init fish | source

# Atuin history
atuin init fish | source

# zoxide
zoxide init fish | source

# direnv
if type -q direnv
    direnv hook fish | source
end

# mise
if type -q mise
    mise hook fish | source
end

# ===== ALIASES - File Management =====

alias ls 'eza -la --icons --git'
alias ll 'eza -l --icons --git'
alias la 'eza -la --icons'
alias lt 'eza -lTg'
alias tree 'eza --tree'

# ===== ALIASES - File Viewing =====

alias cat 'bat'
alias catn 'bat --number'
alias less 'bat'

# ===== ALIASES - Git =====

alias g 'lazygit'
alias gs 'git status'
alias ga 'git add'
alias gc 'git commit'
alias gp 'git push'
alias gl 'git pull'
alias gd 'git diff'
alias gco 'git checkout'
alias gb 'git branch'
alias gf 'git fetch'
alias gm 'git merge'
alias gr 'git rebase'
alias gst 'git stash'
alias gsp 'git stash pop'
alias glog 'git log --oneline --graph --decorate'

# ===== ALIASES - Docker =====

alias d 'docker'
alias dc 'docker-compose'
alias dcu 'docker-compose up -d'
alias dcd 'docker-compose down'
alias di 'docker images'
alias dps 'docker ps'
alias dpsa 'docker ps -a'
alias dex 'docker exec -it'
alias dlog 'docker logs -f'

# ===== ALIASES - System =====

alias h 'htop'
alias b 'btop'
alias ff 'fastfetch'
alias ports 'netstat -tulanp'
alias myip 'curl http://ipecho.net/plain; echo'

# ===== ALIASES - Navigation =====

alias .. 'cd ..'
alias ... 'cd ../..'
alias .... 'cd ../../..'
alias ~~ 'cd ~'
alias down 'cd ~/Downloads'
alias repos 'cd ~/Repositories'
alias desk 'cd ~/Desktop'

# ===== ALIASES - Utilities =====

alias v 'nvim'
alias n 'nvim'
alias vim 'nvim'
alias code 'code .'
alias cls 'clear'

# ===== ALIASES - Shortcuts =====

alias lg 'lazygit'
alias ld 'lazydocker'
alias y 'yazi'
alias yy 'yazi .'
alias f 'fzf --preview="bat --color=always {}"'

# ===== FISHER PLUGINS =====

# fisher add PatrickF1/fzf.fish
# fisher add Edu4rdSHL/based.fish

# ===== CUSTOM FUNCTIONS =====

# Create directory and cd into it
function mkcd --description 'Create directory and cd into it'
    mkdir -p $argv[1]; and cd $argv[1]
end

# Yazi with directory change
function y --description 'Yazi file manager with directory change'
    set -l tmp (mktemp -t "yazi-cwd.XXX.cwd")
    pwd > $tmp
    command yazi $argv --cwd-file $tmp
    if test $status -eq 0
        cd (cat $tmp)
    end
    rm -f $tmp
end

# ===== KEY BINDINGS =====

# fzf key bindings
fzf_key_bindings

# ============================================================================
# END OF FISH CONFIG
# ============================================================================