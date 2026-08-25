# Scope: dotfiles — Shell & CLI Tool Configuration

**All shell environment configs, managed with GNU Stow.**
Consolidates 3 legacy repos into a single Stow-managed codebase.

## What belongs here

- Shell configs: `.zshrc`, `config.fish`, `.bashrc`, `.profile`
- Terminal multiplexer: `.tmux.conf`
- Prompt: `starship.toml` (Catppuccin Mocha)
- Git: `.gitconfig` (delta, aliases, gh credential helper)
- CLI tools: yazi, ripgrep, lazygit, fzf, zoxide, eza, bat, btop
- Editor configs: VS Code, Cursor
- GitHub CLI: `gh/config.yml`
- PAM environment variables
- `install.sh` bootstrap script + `scripts/` tool installer

## Package layout

Each subdirectory under `packages/` mirrors its `$HOME` path for Stow.
Example: `packages/git/.gitconfig` → `~/.gitconfig`

```
packages/
├── agent/       →  ~/.agent/AGENT_VM.md
├── bash/        →  ~/.bashrc, ~/.profile
├── bin/         →  ~/bin/ (custom scripts)
├── cursor/      →  ~/.config/Cursor/User/settings.json
├── fish/        →  ~/.config/fish/config.fish
├── gh/          →  ~/.config/gh/config.yml
├── git/         →  ~/.gitconfig
├── pam/         →  ~/.pam_environment
├── ripgrep/     →  ~/.ripgreprc
├── starship/    →  ~/.config/starship.toml
├── tmux/        →  ~/.tmux.conf
├── vscode/      →  ~/.config/Code/User/settings.json
├── windows-terminal/  →  Windows Terminal settings (manual import)
├── yazi/        →  ~/.config/yazi/yazi.toml
└── zsh/         →  ~/.zshrc
```

## Installation

```bash
# One-command deploy (new machine):
bash <(curl -fsSL https://raw.githubusercontent.com/Sabir-test/dotfiles/MAIN/scripts/deploy.sh)

# Full bootstrap:
git clone https://github.com/Sabir-test/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./install.sh
```

## What does NOT belong here

- Project-specific editor configs → stay in project `.vscode/` or `.editorconfig`
- Homelab/infrastructure configs → `home-template`
- VM-specific app installs → `sandboxed-devspace`
- Secrets, tokens, SSH keys, `.pem` files
- Old source repos (deleted after migration)

## Used by

- `sandboxed-devspace` references this repo for VM bootstrap
- Fresh Ubuntu/macOS machines via one-command deploy
