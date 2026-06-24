# Dotfiles Consolidation — Migration Plan ✅ COMPLETED

> **Status: ✅ ALL FEATURES MIGRATED**
> All 3 source repos have been fully merged into `packages/`. The old repos have been deleted.
> This file is kept as historical reference. For current workflow, see `GITOPS-WORKFLOW.md`.

---

## Goal

Merge features from 3 separate dotfiles projects into a single, unified dotfiles repository managed by GNU Stow.

---

## Source Codebases (Historical)

| # | Project | Remote | Manager | Shells | Theme | Status |
|---|---------|--------|---------|--------|-------|--------|
| 1 | `dotfile.d/` | `Sabir-test/dotfiles` | GNU Stow | Bash | None | ✅ Merged, source deleted |
| 2 | `dotfiles/` | `Sabir-test/dotfiles` | `ln -sf` + Stow (staging) | Zsh+Fish+Bash | Catppuccin Mocha | ✅ Merged, source deleted |
| 3 | `windows-wsl-terminal-customization/` | `Sabir-test/windows-wsl-terminal-customization` | `ln -sf` | Bash (Oh-My-Bash) | Gruvbox Dark | ✅ Merged, source deleted |

---

## Key Decisions (Defaults)

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Dotfiles manager | GNU Stow | Cleaner than manual symlinks; already proven in `dotfile.d/` |
| Theme | Catppuccin Mocha | Richer shell + TUI integration; already in `dotfiles/` |
| Package layout | Flat at root (`bash/`, `tmux/`, `zsh/`, etc.) | Matches existing `dotfile.d/` convention |
| Remote | `github.com/Sabir-test/dotfiles` | Already shared by `dotfile.d/` + `dotfiles/` |
| Old repos | Deleted after full migration | Clean workspace, no stale references |

---

## Final Package Layout

```
packages/
├── agent/        — AI agent governance rules
├── bash/         — .bashrc, .profile (merged from all 3 sources)
├── bin/          — custom scripts
├── cursor/       — Cursor editor settings
├── fish/         — config.fish
├── gh/           — GitHub CLI config
├── git/          — .gitconfig (merged from all sources)
├── pam/          — .pam_environment locale
├── ripgrep/      — ripgreprc
├── scripts/      — deploy, helper scripts
├── starship/     — starship.toml (Catppuccin base)
├── tmux/         — .tmux.conf (merged)
├── vscode/       — VS Code settings
├── windows-terminal/ — Windows Terminal settings
├── yazi/         — yazi config
└── zsh/          — .zshrc
```

Additional files at repo root:

- `install.sh` — orchestrator: tools → Stow deploy → tmux plugins → Docker network
- `scripts/install-tools.sh` — idempotent 12-phase tool installer (Linux/macOS)
- `scripts/deploy-configs.sh` — Stow wrapper for config deployment

---

## Steps Completed (Historical Record)

### Step 1-4: Initialize repo, create packages, extract files ✅

### Step 5: Merge duplicate configs ✅

### Step 6: Create unified bootstrap ✅

### Step 7: Verification ✅

### Old repo deletion ✅
