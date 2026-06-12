# dotfiles

> Unified dotfiles environment — GNU Stow, Catppuccin Mocha, 15 packages.
> Consolidates 3 legacy repos into one, managed with idempotent install scripts.

---

## Quick Deploy

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Sabir-test/dotfiles/MAIN/scripts/deploy.sh)
```

Or locally:

```bash
git clone https://github.com/Sabir-test/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./install.sh
```

---

## What's Included

### 15 Stow Packages

| Package | Target | What It Configures |
|---------|--------|--------------------|
| `agent` | `~/.agent/AGENT_VM.md` | VM agent specification |
| `bash` | `~/.bashrc`, `~/.profile` | Bash environment, aliases |
| `bin` | `~/bin/` | Custom scripts directory |
| `cursor` | `~/.config/Cursor/User/settings.json` | Cursor editor settings |
| `fish` | `~/.config/fish/config.fish` | Fish shell config |
| `gh` | `~/.config/gh/config.yml` | GitHub CLI config |
| `git` | `~/.gitconfig` | Git config (delta, aliases, credentials) |
| `pam` | `~/.pam_environment` | PAM environment variables |
| `ripgrep` | `~/.ripgreprc` | ripgrep config |
| `starship` | `~/.config/starship.toml` | Starship prompt (Catppuccin Mocha) |
| `tmux` | `~/.tmux.conf` | Tmux config (prefix: Ctrl+a, TPM) |
| `vscode` | `~/.config/Code/User/settings.json` | VS Code settings |
| `windows-terminal` | `windows-terminal-settings.json` | Windows Terminal settings (Gruvbox) |
| `yazi` | `~/.config/yazi/yazi.toml` | Yazi file manager config |
| `zsh` | `~/.zshrc` | Zsh config |

### Tools Installed

The `install-tools.sh` script installs the following (idempotent, Linux + macOS):

| Phase | Tools |
|-------|-------|
| 1 — System | build-essential, curl, wget, git, tmux, zsh, fish, stow, ripgrep, fd, bat, jq, fzf, btop, direnv, make |
| 2 — Fonts | JetBrainsMono Nerd Font, Hack Nerd Font |
| 3 — Rust | Rust toolchain (rustup + cargo) |
| 4 — CLI | eza, zoxide, git-delta, du-dust, procs, tealdeer |
| 5 — Prompt | Starship |
| 6 — FZF | fzf (git install with key bindings) |
| 7 — Lazygit | Lazygit (latest GitHub release) |
| 8 — GitHub CLI | gh (apt repo) |
| 9 — Docker | Docker engine + docker group |
| 10 — Version mgmt | mise (universal version manager) |
| 11 — Node.js | NVM + Node.js 24 LTS |
| 12 — Tmux | Tmux Plugin Manager (TPM) |

---

## Installation Methods

### 1. One-Command Deploy (recommended for new machines)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Sabir-test/dotfiles/MAIN/scripts/deploy.sh)
```

This clones the repo and runs `install.sh`. Requires `git`, `curl`, and `sudo` access.

### 2. Full Bootstrap

```bash
git clone https://github.com/Sabir-test/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` runs:
1. `scripts/install-tools.sh` — installs all CLI tools, fonts, and dependencies
2. Stow deploy — symlinks all 15 packages to `$HOME`
3. Tmux plugin install
4. Docker `dev-network` creation

### 3. Config Only (stow, no tools)

If tools are already installed, deploy just the config files:

```bash
cd ~/dotfiles
./scripts/deploy-configs.sh
```

### 4. Tool Installation Only

```bash
cd ~/dotfiles
./scripts/install-tools.sh
```

This is idempotent — safe to re-run.

---

## Post-Install

1. **Reload shell**: `exec $SHELL`
2. **Set Git identity**: `git config --global user.name "Your Name"` / `git config --global user.email "you@example.com"`
3. **Tmux plugins**: `prefix + I` (Ctrl+a then Shift+i) inside tmux
4. **Docker group**: Log out and back in for docker group membership
5. **Set terminal font**: JetBrainsMono Nerd Font Mono (or Hack Nerd Font Mono)

---

## Quick Reference

### Aliases

| Alias | Command | Source |
|-------|---------|--------|
| `ls` | `eza -la --icons --git` | bash/zsh |
| `ll` | `eza -l --icons --git` | bash/zsh |
| `la` | `eza -la --icons` | bash/zsh |
| `y` / `yy` | `yazi` / `yazi .` | bash/zsh |
| `g` | `lazygit` | bash/zsh |
| `gs` / `ga` / `gc` / `gp` / `gl` / `gd` | git status/add/commit/push/pull/diff | bash/zsh |
| `..` / `...` | `cd ..` / `cd ../..` | bash/zsh |
| `b` | `btop` | bash/zsh |
| `ff` | `fastfetch` | bash/zsh |

### Tmux Cheatsheet

| Binding | Action |
|---------|--------|
| `Ctrl+a` | Prefix |
| `Prefix + c` | New window |
| `Prefix + \|` | Split horizontal |
| `Prefix + -` | Split vertical |
| `Prefix + h/j/k/l` | Navigate panes |
| `Prefix + H/J/K/L` | Resize panes |
| `Prefix + d` | Detach |
| `Prefix + I` | Install TPM plugins |
| `Prefix + R` | Reload config |
| `Prefix + s` | Choose session |
| `Prefix + w` | Choose window |

### Git Aliases

| Alias | Command |
|-------|---------|
| `co` | checkout |
| `br` | branch |
| `ci` | commit |
| `st` | status |
| `unstage` | `reset HEAD --` |
| `last` | `log -1 HEAD` (pretty) |
| `visual` | `log --graph --oneline --all` |
| `undo` | `reset --soft HEAD~1` |
| `amend` | `commit --amend --no-edit` |

---

## Project Structure

```
dotfiles/
├── install.sh                  # Full bootstrap (tools → stow → tmux → docker)
├── scripts/
│   ├── deploy.sh              # One-command deploy script (curl-to-bash)
│   ├── install-tools.sh       # 12-phase idempotent tool installer
│   └── deploy-configs.sh      # Stow-only config deployment
├── packages/
│   ├── bash/    .bashrc, .profile
│   ├── git/     .gitconfig
│   ├── zsh/     .zshrc
│   ├── fish/    .config/fish/config.fish
│   ├── tmux/    .tmux.conf
│   ├── starship/ .config/starship.toml
│   ├── yazi/    .config/yazi/yazi.toml
│   ├── gh/      .config/gh/config.yml
│   ├── vscode/  .config/Code/User/settings.json
│   ├── cursor/  .config/Cursor/User/settings.json
│   ├── ripgrep/ .ripgreprc
│   ├── pam/     .pam_environment
│   ├── agent/   .agent/AGENT_VM.md
│   ├── bin/     (custom scripts directory)
│   └── windows-terminal/  windows-terminal-settings.json
├── .githooks/
│   └── pre-commit           # Syntax + structure validation
├── .github/workflows/
│   ├── validate.yml         # CI: bash -n + stow validation
│   └── deploy.yml           # Manual deploy trigger
├── SCOPE.md                 # Project scope definition
└── MIGRATION-PLAN.md        # Historical migration record
```

---

## Configuration Highlights

- **Theme**: Catppuccin Mocha (Starship, tmux)
- **Git diff**: delta with Dracula theme
- **Editor**: nvim (default), VS Code / Cursor settings included
- **Docker**: `dev-network` created on bootstrap
- **GitHub auth**: gh credential helper configured
- **Locale**: PAM environment variables in `pam` package

---

## References

| Tool | URL |
|------|-----|
| GNU Stow | https://www.gnu.org/software/stow/ |
| Starship | https://starship.rs |
| Tmux | https://github.com/tmux/tmux |
| TPM | https://github.com/tmux-plugins/tpm |
| Lazygit | https://github.com/jesseduffield/lazygit |
| Eza | https://github.com/eza-community/eza |
| Bat | https://github.com/sharkdp/bat |
| Fzf | https://github.com/junegunn/fzf |
| Zoxide | https://github.com/ajeetdsouza/zoxide |
| Yazi | https://yazi-rs.github.io |
| Ripgrep | https://github.com/BurntSushi/ripgrep |
| Git-delta | https://github.com/dandavison/delta |
| Mise | https://mise.jdx.dev |
| Btop | https://github.com/aristocratos/btop |
| Catppuccin | https://catppuccin.com |
