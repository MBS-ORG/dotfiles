# AGENTS.md

## What this repo is

A **migration workspace** that consolidates 3 separate dotfiles repositories into a single unified dotfiles repo managed by GNU Stow. This is NOT a working dotfiles deployment — it is the factory floor.

## Source repositories (gitignored, keep them that way)

| Repo | Manager | Theme | Shells | Key features |
|------|---------|-------|--------|-------------|
| `dotfile.d/` | GNU Stow (7 packages) | None | Bash | VM infra, editor configs, PAM locale, agent governance |
| `dotfiles/` | `ln -sf` (+ Stow staging zip) | Catppuccin Mocha | Zsh+Fish+Bash | Rich TUI tools (lazygit, yazi, btop, tmux), modern CLIs, Starship |
| `windows-wsl-terminal-customization/` | `ln -sf` | Gruvbox Dark | Bash (Oh-My-Bash) | Windows Terminal, 50+ aliases, TPM, ripgreprc, 2-script bootstrap |

All three are *references*. Never `git add`, submodule, or delete them.

## Migration state (current)

- Root repo: 5 commits (init plan → workflow doc → fix submodule pointers → gitignore → initial migration)
- `packages/` directory has 16 packages created from initial migration
- The old repos sit untracked per `.gitignore` (which excludes them as `/path/`)

## Canonical docs

Read these first before any migration work:

1. **`MIGRATION-PLAN.md`** — what to merge, in what order, merge strategies per file
2. **`GITOPS-WORKFLOW.md`** — branch strategy, commit convention, pre-commit verification

## Key decisions (from MIGRATION-PLAN.md)

- **Dotfiles manager**: GNU Stow (not `ln -sf`)
- **Theme**: Catppuccin Mocha (port useful modules from Gruvbox)
- **Package layout**: Flat at root (`bash/`, `tmux/`, `zsh/`, etc.)
- **Remote**: `github.com/Sabir-test/dotfiles` (already shared by 2 of 3 repos)

## Branch workflow

| Branch | Purpose |
|--------|---------|
| `MAIN` | Stable, deployable milestones. Merge only via `--no-ff`. |
| `MIGRATION` | Active daily work. Default branch for agent. |
| `FEATURE/<package>` | For complex per-package work, branch from `MIGRATION`. |

## Commit convention

```
<type>: <short description>

[body — conflicts resolved, decisions made]
```

Types: `migrate`, `merge`, `feat`, `fix`, `docs`, `refactor`, `chore`. One commit per logical move. See GITOPS-WORKFLOW.md for examples.

## Pre-commit verification (from GITOPS-WORKFLOW.md)

1. Git status clean — no accidental submodule pointers or dirty child repos
2. Stow packages are valid — directory structure mirrors `$HOME` path
3. Configs pass syntax check: `bash -n`, `zsh -n`, `tmux -c "list-keys"`, etc.
4. `.gitignore` covers old repos — confirm they show as `!!` ignored

## Target package layout (from MIGRATION-PLAN.md)

```
packages/
├── agent/        bash/         bin/           cursor/
├── fish/         gh/           git/           pam/
├── ripgrep/      scripts/      starship/      tmux/
├── vscode/       windows-terminal/  yazi/     zsh/
```

Each mirrors the `$HOME` path so Stow creates correct symlinks (e.g. `git/.gitconfig` → `~/.gitconfig`).

## Verification commands

```bash
# Syntax checks
bash -n packages/bash/.bashrc
zsh -n packages/zsh/.zshrc
tmux -c "list-keys"  # loads .tmux.conf implicitly

# Stow dry-run (from repo root)
stow --simulate --target="$HOME" packages/*

# Full deploy
stow --restow --target="$HOME" packages/*
```

## Things to never do

- Commit SSH keys, GitHub tokens, `hosts.yml`, or `*.pem`
- Commit `node_modules`, `*.log`, `.DS_Store`
- Add old repos as submodules or track them directly
- Force-push to `MAIN`
