# Architecture

## Core Principles

1. **GNU Stow** — Each package mirrors the HOME directory tree exactly. `stow -t $HOME packages/<name>` creates a symlink farm.
2. **XDG Compliance** — All configs use `$XDG_CONFIG_HOME` (default `~/.config/`).
3. **Idempotency** — Every script and bootstrap step can be re-run safely.
4. **Machine Overrides** — Gitignored `local.*` files are sourced at runtime, never committed.
5. **Portability** — Linux-first, with cross-platform support for macOS and WSL2.

## Shell Architecture

```
.zshenv (home)          # Sets ZDOTDIR → ~/.config/zsh/
  └── .config/zsh/.zshenv   # XDG vars, PATH, EDITOR
       └── .config/zsh/.zshrc   # History, completions, aliases, tools
            └── .config/zsh/local.zsh  # Machine overrides (gitignored)
```

- Login shells source `.zshenv` → redirects `ZDOTDIR` → sources config-level `.zshenv` → invokes `.zshrc`.
- Non-login interactive shells source `.zshrc` directly (via `ZDOTDIR`).
- Bash is a fallback: `.bashrc` execs into Zsh if available.

## Repository Tree

```
dotfiles-projects/
├── packages/           # Stow packages (symlink targets)
├── scripts/            # Bootstrap, stow, drift-detect, doctor, update
├── docs/               # Architecture, workflow, bootstrap guides
├── manifests/          # dpkg/flatpak/cargo/npm listings
├── .github/workflows/  # CI: shellcheck, syntax, stow dry-run, Docker
├── .githooks/          # pre-commit (shellcheck), post-merge (stow)
├── Dockerfile          # CI validation image
└── .stow-local-ignore  # Files stow should skip
```

## Bootstrap Pipeline

1. `bootstrap.sh` detects OS and desktop environment
2. Installs system deps (stow, zsh, git, curl)
3. Clones or pulls the dotfiles repo
4. Runs `stow-all.sh` to symlink every package
5. Installs runtime managers (fnm, rustup)
6. Installs shell tools (starship, zoxide, eza, ripgrep, delta, tmux)
7. Changes default shell to zsh
8. Verifies all symlinks and tool availability

## Tech Stack

| Layer | Tool |
|-------|------|
| Package manager | GNU Stow |
| Shell | Zsh + starship |
| Fallback shell | Bash |
| Multiplexer | tmux |
| Editor | Cursor / VS Code |
| File search | ripgrep |
| File browser | yazi |
| Prompt | starship |
| CD | zoxide |
| Env vars | direnv |
| Diff | git-delta |
