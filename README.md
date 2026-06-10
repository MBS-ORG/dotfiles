The Bellow Readme, Belongs To The Compressed Folder named dotfiles.zip, and it has been Renamed Form Dotfiles_Tools to -> dotfiles  

# dotfiles

> A comprehensive dotfiles collection for Linux/macOS development environment with modern CLI tools, TUI applications, and shell configurations.

---

## 📋 INDEX

1. [What's Included](#whats-included)
2. [Directory Structure](#directory-structure)
3. [Installation](#installation)
4. [Tool Dependencies](#tool-dependencies)
5. [Quick Start](#quick-start)
6. [Aliases Reference](#aliases-reference)
7. [Configuration](#configuration)

---

## 📦 What's Included

| Category | Tools |
|----------|-------|
| **Shells** | Zsh + Oh My Zsh, Fish Shell, Bash |
| **History** | Atuin (sync & search) |
| **File Management** | eza, yazi |
| **File Viewing** | bat, fzf |
| **System Monitoring** | btop, fastfetch |
| **Git Tools** | lazygit, delta |
| **Docker Tools** | lazydocker |
| **Directory Jumping** | zoxide |
| **Prompts** | Powerlevel10k, Starship |
| **Terminal Multiplexer** | tmux |

---

## 📁 Directory Structure

```
dotfiles/
├── install.sh           # Installation script
├── README.md           # This file
├── zsh/
│   └── .zshrc         # Zsh configuration
├── fish/
│   └── config.fish    # Fish shell configuration
├── bash/
│   └── .bashrc       # Bash configuration
├── git/
│   └── .gitconfig    # Git configuration
├── tmux/
│   └── .tmux.conf    # Tmux configuration
├── starship/
│   └── starship.toml  # Starship prompt configuration
├── yazi/
│   └── yazi.toml     # Yazi file manager config
└── bin/
                      # Custom scripts (if any)
```

---

## 🔧 Installation

### Automated

```bash
# Clone this repository
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles

# Run installation script
cd ~/dotfiles
./install.sh
```

### Manual

```bash
# Clone this repository
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles

# Link configuration files
ln -sf ~/dotfiles/zsh/.zshrc ~/.zshrc
ln -sf ~/dotfiles/bash/.bashrc ~/.bashrc
ln -sf ~/dotfiles/git/.gitconfig ~/.gitconfig
ln -sf ~/dotfiles/fish/config.fish ~/.config/fish/config.fish
ln -sf ~/dotfiles/tmux/.tmux.conf ~/.tmux.conf
ln -sf ~/dotfiles/starship/starship.toml ~/.config/starship.toml
ln -sf ~/dotfiles/yazi/yazi.toml ~/.config/yazi/yazi.toml

# Restart terminal
exec $SHELL
```

---

## 🛠 Tool Dependencies

### Required Tools

```bash
# Install via package manager (Ubuntu/Debian)
sudo apt install zsh git curl wget

# Install via package manager (macOS)
brew install zsh git curl wget
```

### CLI Tools

```bash
# Install eza (modern ls)
wget https://github.com/eza-community/eza/releases/download/v0.20.0/eza_v0.20.0_x86_64-unknown-linux-gnu.tar.gz
tar xzf eza_v0.20.0_x86_64-unknown-linux-gnu.tar.gz
sudo mv eza /usr/local/bin/

# Install bat (modern cat)
wget https://github.com/sharkdp/bat/releases/download/v0.24.0/bat-v0.24.0-x86_64-unknown-linux-gnu.tar.gz
tar xzf bat-v0.24.0-x86_64-unknown-linux-gnu.tar.gz
sudo mv bat /usr/local/bin/

# Install fzf (fuzzy finder)
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# Install zoxide (smart cd)
curl -sSf https://get.zooxide.st | sh

# Install starship (prompt)
curl -sS https://starship.rs/install.sh | sh

# Install yazi (file manager)
cargo install yazi --locked

# Install btop (system monitor)
sudo apt install btop

# Install lazygit (git TUI)
wget https://github.com/jesseduffield/lazygit/releases/download/v0.45.0/lazygit_v0.45.0_linux_amd64.tar.gz
tar xzf lazygit_v0.45.0_linux_amd64.tar.gz
sudo mv lazygit /usr/local/bin/

# Install fastfetch (system info)
wget https://github.com/LinusHenze/fastfetch/releases/download/v2.50.0/fastfetch-linux-amd64.tar.gz
tar xzf fastfetch-linux-amd64.tar.gz
sudo mv fastfetch /usr/local/bin/
```

---

## ⚡ Quick Start

### Switch Shell

```bash
zsh    # Zsh
fish   # Fish
bash   # Bash
```

### Quick Aliases

```bash
ls/ll/la    # eza aliases
cat         # bat
yy          # yazi in current directory
lg          # lazygit
ld          # lazydocker
b           # btop
ff          # fastfetch
```

### Tmux

```bash
tmux                # Start tmux
prefix + c           # New window
prefix + |           # Split horizontally
prefix + -           # Split vertically
prefix + h/j/k/l    # Navigate panes
prefix + d           # Detach
```

---

## 🔑 Aliases Reference

### File Management

| Alias | Command |
|-------|---------|
| `ls` | `eza -la --icons --git` |
| `ll` | `eza -l --icons --git` |
| `la` | `eza -la --icons` |
| `lt` | `eza -lTg` |
| `y` | `yazi` |
| `yy` | `yazi .` |

### Git

| Alias | Command |
|-------|---------|
| `g` | `lazygit` |
| `gs` | `git status` |
| `ga` | `git add` |
| `gc` | `git commit` |
| `gp` | `git push` |
| `gl` | `git pull` |
| `gd` | `git diff` |
| `gco` | `git checkout` |
| `gb` | `git branch` |
| `gf` | `git fetch` |
| `gm` | `git merge` |
| `gr` | `git rebase` |

### Docker

| Alias | Command |
|-------|---------|
| `d` | `docker` |
| `dc` | `docker-compose` |
| `dcu` | `docker-compose up -d` |
| `dcd` | `docker-compose down` |
| `dps` | `docker ps` |
| `di` | `docker images` |
| `dex` | `docker exec -it` |

### Navigation

| Alias | Command |
|-------|---------|
| `..` | `cd ..` |
| `...` | `cd ../..` |
| `~~` | `cd ~` |

### System

| Alias | Command |
|-------|---------|
| `b` | `btop` |
| `h` | `htop` |
| `ff` | `fastfetch` |

---

## ⚙️ Configuration

### Oh My Zsh

- Edit `~/.zshrc` to modify plugins
- Run `p10k configure` to configure Powerlevel10k

### Starship

- Edit `~/.config/starship.toml` to customize prompt
- Theme: Catppuccin Mocha

### Tmux

- Prefix: `Ctrl+a`
- Run `tmux` to start
- Configuration is in `.tmux.conf`

### Git

- Edit `~/.gitconfig` to set your name and email

---

## 📚 References

| Tool | URL |
|------|-----|
| Oh My Zsh | https://github.com/ohmyzsh/ohmyzsh |
| Powerlevel10k | https://github.com/romkatv/powerlevel10k |
| Starship | https://starship.rs |
| Yazi | https://yazi-rs.github.io |
| Lazygit | https://github.com/jesseduffield/lazygit |
| Eza | https://github.com/eza-community/eza |
| Bat | https://github.com/sharkdp/bat |
| Fzf | https://github.com/junegunn/fzf |
| Zoxide | https://github.com/ajeetdsouza/zoxide |

---

## 📝 License

MIT License - Feel free to use and customize!

---

**Last Updated:** April 2026
**Version:** 2.0
