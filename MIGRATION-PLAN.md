# Dotfiles Consolidation — Migration Plan

## Goal

Merge features from 3 separate dotfiles projects into a single, unified dotfiles repository managed by GNU Stow.

---

## Source Codebases

| # | Project | Remote | Manager | Shells | Theme | Status |
|---|---------|--------|---------|--------|-------|--------|
| 1 | `dotfile.d/` | `Sabir-test/dotfiles` | GNU Stow | Bash | None | Clean, 1 commit |
| 2 | `dotfiles/` | `Sabir-test/dotfiles` | `ln -sf` + Stow (staging) | Zsh+Fish+Bash | Catppuccin Mocha | 9 commits, extra branches |
| 3 | `windows-wsl-terminal-customization/` | `Sabir-test/windows-wsl-terminal-customization` | `ln -sf` | Bash (Oh-My-Bash) | Gruvbox Dark | Clean, 2 commits |

---

## Key Decisions (Defaults)

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Dotfiles manager | GNU Stow | Cleaner than manual symlinks; already proven in `dotfile.d/` |
| Theme | Catppuccin Mocha | Richer shell + TUI integration; already in `dotfiles/` |
| Package layout | Flat at root (`bash/`, `tmux/`, `zsh/`, etc.) | Matches existing `dotfile.d/` convention |
| Remote | `github.com/Sabir-test/dotfiles` | Already shared by `dotfile.d/` + `dotfiles/` |
| Old repos | Kept in-place for reference; not archived | Preserves history without blocking migration |

---

## Phase 1 — Feature Inventory & Mapping

### From `dotfile.d/` (Stow-based, already clean)

| Feature | Path | Target Stow Package |
|---------|------|---------------------|
| Bash shell config | `bash/.bashrc`, `bash/.profile` | `bash/` — merge |
| Git config | `git/.gitconfig` | `git/` — adopt |
| GitHub CLI config | `gh/.config/gh/config.yml` | `gh/` — adopt |
| VS Code settings | `vscode/.config/Code/User/settings.json` | `vscode/` — adopt |
| Cursor settings | `cursor/.config/Cursor/User/settings.json` | `cursor/` — adopt |
| PAM locale (Qatar) | `pam/.pam_environment` | `pam/` — adopt |
| AI agent governance | `agent/.agent/AGENT_VM.md` | `agent/` — adopt |
| Bootstrap script | `install.sh` | `install.sh` — merge |
| `.gitignore` patterns | `.gitignore` | `.gitignore` — merge |

### From `dotfiles/` (zip-based, needs extraction)

| Feature | Source Archive | Target Stow Package |
|---------|---------------|---------------------|
| Zsh + Powerlevel10k | `Dotfiles_Tools/zsh/.zshrc` | `zsh/` |
| Fish shell config | `Dotfiles_Tools/fish/config.fish` | `fish/` |
| Bash enhancements | `Dotfiles_Tools/bash/.bashrc` | `bash/` — merge |
| Starship (Catppuccin) | `Dotfiles_Tools/starship/starship.toml` | `starship/` |
| Tmux + Catppuccin | `Dotfiles_Tools/tmux/.tmux.conf` | `tmux/` |
| Yazi file manager | `Dotfiles_Tools/yazi/yazi.toml` | `yazi/` |
| Git config (delta, aliases) | `Dotfiles_Tools/git/.gitconfig` | `git/` — merge |
| Custom bin scripts | `Dotfiles_Tools/bin/` | `bin/` |
| Install script | `Dotfiles_Tools/install.sh` | `install.sh` — merge |
| README | `Dotfiles_Tools/README.md` | `docs/` |

### From `windows-wsl-terminal-customization/` (Windows + WSL2 focus)

| Feature | Source File | Target Stow Package |
|---------|-------------|---------------------|
| Windows Terminal settings | `windows-terminal-settings.json` | `windows-terminal/` |
| Enhanced bashrc (50+ aliases, fzf, zoxide) | `ultimate-bashrc` | `bash/` — merge |
| Starship (Gruvbox) | `starship.toml` | `starship/` — merge with Catppuccin |
| Tmux (Gruvbox, TPM) | `tmux.conf` | `tmux/` — merge with Catppuccin |
| Ripgrep config | `ripgreprc` | `ripgrep/` |
| Install script | `ultimate-terminal-setup.sh` | `install.sh` — merge |
| Deploy script | `deploy-configs.sh` | `scripts/deploy-configs.sh` |
| Documentation (3 tiers) | `README.md`, `INSTALLATION.md`, `QUICKSTART.md`, `CHEATSHEET.md`, `PROJECT_SUMMARY.md` | `docs/` |

---

## Phase 2 — Migration Steps (Sequential)

### Step 1: Initialize root git repo (this file)

```bash
cd /home/mbs/DevHome/Workspaces/dotfiles-projects/
git init
git add MIGRATION-PLAN.md
git commit -m "init: migration plan for dotfiles consolidation"
```

### Step 2: Create target directory structure

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
├── starship/     — starship.toml (Catppuccin + Gruvbox merge)
├── tmux/         — .tmux.conf (merged)
├── vscode/       — VS Code settings
├── windows-terminal/ — Windows Terminal settings
├── yazi/         — yazi config
└── zsh/          — .zshrc
```

### Step 3: Extract files from zip archives

```bash
unzip -o dotfiles/Dotfiles.zip -d /tmp/dotfiles-extract/
unzip -o dotfiles/Staging/dotfile.d-main.zip -d /tmp/dotfiles-staging-extract/
```

### Step 4: Copy files into target packages

Pull from `dotfile.d/`, extracted zips, and `windows-wsl/` into the new `packages/` structure.

### Step 5: Merge duplicate configs

| File | Sources | Merge Strategy |
|------|---------|----------------|
| `bash/.bashrc` | dotfile.d + Dotfiles.zip + windows-wsl | Keep dotfile.d as base; add aliases, functions, starship init, zoxide from others |
| `git/.gitconfig` | dotfile.d + Dotfiles.zip | Keep dotfile.d identity; add delta, aliases, undo/amend from Dotfiles.zip |
| `starship/starship.toml` | Dotfiles.zip (Catppuccin) + windows-wsl (Gruvbox) | Adopt Catppuccin as base; port useful modules from Gruvbox version |
| `tmux/.tmux.conf` | Dotfiles.zip (Catppuccin) + windows-wsl (Gruvbox, TPM) | Adopt Catppuccin as base; add TPM plugins from windows-wsl |
| `install.sh` | dotfile.d + Dotfiles.zip + windows-wsl | Phase 1: system pkgs + Rust tools + Docker + NVM + DevPod + Stow deploy |
| `.gitignore` | dotfile.d + generalize | Keep secrets exclusion; generalize for combined project |

### Step 6: Create unified bootstrap

A single `install.sh` that:
1. Installs system packages (from dotfile.d + windows-wsl)
2. Installs Rust toolchain + modern CLI tools (ripgrep, fd, bat, eza, zoxide, delta, dust, procs, tealdeer)
3. Installs Docker CE + Docker Compose
4. Installs NVM + Node.js 24
5. Installs DevPod
6. Installs tmux TPM plugins
7. Deploys all Stow packages: `stow --restow --target="$HOME" packages/*`
8. Optionally configures Windows Terminal

### Step 7: Verification

- Run `stow --restow --target="$HOME" packages/*` — verify symlinks
- Source each shell config — verify no errors
- Run the install script on a clean environment — verify idempotent

---

## Phase 3 — Old Repo Handling

| Repo | Action |
|------|--------|
| `dotfile.d/` | Keep as-is. The new unified repo supersedes it. |
| `dotfiles/` | Keep as-is for zip extraction reference; eventually deprecate. |
| `windows-wsl-terminal-customization/` | Keep as-is; Windows-specific features now live in `windows-terminal/` + merged configs. |

No old repos will be deleted. The new unified repo at the workspace root becomes the source of truth.

---

## Phase 4 — Future Enhancements (Post-Migration)

- [ ] Add CI to validate Stow packages on push
- [ ] Add support for macOS (Homebrew paths, `.zprofile`)
- [ ] Document per-machine overrides (env-specific `.gitconfig`, `.pam_environment`)
- [ ] Add bootstrap for Windows Terminal via PowerShell script
- [ ] Publish as a template for others
