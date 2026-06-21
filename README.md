# Dotfiles — Configuration as Code

> Declarative, stow-managed dotfiles with multi-machine support.

## Quick Start

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/mbs-org/dotfiles/main/scripts/bootstrap.sh)
```

## Tech Stack

| Layer | Tool | Purpose |
|-------|------|---------|
| Shell | Zsh + Starship | Interactive shell + prompt |
| Shell | Bash | POSIX fallback |
| Terminal | tmux | Terminal multiplexer |
| Editor | Cursor / VS Code | Primary editor |
| Search | ripgrep | File search |
| File mgr | yazi | Terminal file browser |
| Font | Nerd Font | Icon glyphs |
| Dotfile mgr | GNU Stow | Symlink management |
| Config lang | TOML / INI / YAML | Tool configs |

## Repository Structure

```
dotfiles-projects/
├── packages/           # Stow packages — each mirrors $HOME
│   ├── bash/           # .bashrc, .profile, .bash_logout
│   ├── zsh/            # .zshenv → .config/zsh/.zshenv, .zshrc
│   ├── git/            # .gitconfig
│   ├── tmux/           # .tmux.conf
│   ├── ripgrep/        # .ripgreprc
│   ├── starship/       # .config/starship.toml
│   ├── kde/            # .config/{kdeglobals,kwinrc,…}
│   ├── cursor/         # .config/cursor/
│   ├── vscode/         # .config/Code/User/
│   ├── yazi/           # .config/yazi/
│   ├── fish/           # .config/fish/
│   ├── gh/             # .config/gh/
│   ├── opencode/       # .config/opencode/
│   ├── bin/            # .local/bin/
│   ├── agent/          # .config/agent/
│   └── windows-terminal/ # Windows Terminal config
├── scripts/            # Automation scripts
├── docs/               # Documentation
├── manifests/          # Installed-package manifests
├── .github/workflows/  # CI/CD pipelines
└── .githooks/          # Git hooks
```

## Branch Strategy

| Branch | Purpose |
|--------|---------|
| `staging` | Active development, PRs target this |
| `main` | Stable, release-ready |
| `machine/<hostname>` | Machine-specific overrides |

## Machine Overrides

Create `local.zsh`, `local.gitconfig`, or `local.toml` in the respective package — these are gitignored and sourced automatically.

## Prerequisites

- GNU Stow (package: `stow`)
- Zsh 5.8+
- Git 2.30+
- curl

## License

MIT — see [LICENSE](LICENSE).
