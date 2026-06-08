# GitOps Workflow — Dotfiles Migration

## Repository Structure

```
dotfiles-projects/             ← single source of truth
├── MIGRATION-PLAN.md
├── GITOPS-WORKFLOW.md
├── .gitignore
├── install.sh
├── packages/
│   ├── bash/
│   ├── zsh/
│   ├── fish/
│   ├── tmux/
│   ├── starship/
│   ├── git/
│   ├── gh/
│   ├── vscode/
│   ├── cursor/
│   ├── yazi/
│   ├── ripgrep/
│   ├── pam/
│   ├── agent/
│   ├── windows-terminal/
│   ├── bin/
│   └── scripts/
└── docs/
    └── ...
```

---

## Branching Strategy

```
MAIN  ────●──────────●──────────●────────  (stable, deployable)
           \        / \        /
MIGRATION  ─●──●──●──●────●──●──●──●──    (migration work)
              \        /
FEATURE/      ●──●───●                       (per-package feature branches)
<package>
```

### Branches

| Branch | Purpose | Who Pushes |
|--------|---------|------------|
| `MAIN` | Stable, tested, deployable state. Every commit here is a milestone. | Merge only |
| `MIGRATION` | Active migration work — adding packages, merging configs, building install.sh | You (daily work) |
| `FEATURE/<package>` | Per-package feature branches: `FEATURE/zsh`, `FEATURE/tmux`, etc. | You (optional, for focused work) |

### Flow

1. Work on `MIGRATION` branch for all migration tasks
2. For complex packages, create `FEATURE/<package>` from `MIGRATION`, merge back when done
3. When a milestone is complete (e.g., "all shell configs merged"), merge `MIGRATION` → `MAIN` via `--no-ff`
4. `MAIN` always represents a coherent state — the `install.sh` works, Stow packages are valid

---

## Commit Convention

Each commit message documents **what** moved and **why**.

```
<type>: <short description>

[optional body — details on conflicts resolved, decisions made]
```

### Types

| Type | When to use |
|------|-------------|
| `migrate` | Copying a feature from a source repo into the unified structure |
| `merge` | Merging two config files (e.g., bashrc from source A + source B) |
| `feat` | Adding new functionality not present in any source |
| `fix` | Fixing a bug discovered during migration |
| `docs` | Changes to MIGRATION-PLAN.md, GITOPS-WORKFLOW.md, README |
| `refactor` | Restructuring packages, renaming, reorganizing |
| `chore` | .gitignore, git config, tooling |

### Examples

```
migrate: copy zsh/.zshrc from Dotfiles.zip

migrate: copy tmux/.tmux.conf from windows-wsl repo

merge: combine bashrc from dotfile.d + Dotfiles.zip + windows-wsl

feat: add unified install.sh with system pkgs + rust + docker + stow

docs: add GITOPS-WORKFLOW.md

chore: add .gitignore to exclude old source repos
```

### Commit Granularity

One commit per logical move. This makes it easy to:
- Revert a single migration if needed
- Track exactly what came from where
- Review progress at a glance

**Good:** `migrate: copy starship/starship.toml from Dotfiles.zip`

**Too broad:** `migrate: copy all remaining packages`

---

## File Provenance Convention

Every migrated file that required manual merging or decisions gets a provenance header comment:

```bash
# === Migrated from: dotfiles/Dotfiles.zip (Dotfiles_Tools/zsh/.zshrc) ===
# === Merged with:   windows-wsl-terminal-customization/ultimate-bashrc (aliases section) ===
# === Date:          2026-06-09 ===
```

This documents the origin for future reference. Once the migration is fully stable, these headers can be cleaned up.

---

## State Tracking During Migration

### Migration Status per Package

Track progress in commit messages and optionally in MIGRATION-PLAN.md:

```markdown
| Package | Status | Source | Notes |
|---------|--------|--------|-------|
| bash/   | ✅ DONE | Merged from all 3 | Aliases unified |
| zsh/    | ✅ DONE | dotfiles/Dotfiles.zip | Direct copy |
| tmux/   | 🔄 WIP  | dotfiles + windows-wsl | Need to resolve Catppuccin vs Gruvbox |
| yazi/   | ⏳ TODO | dotfiles/Dotfiles.zip | |
```

### Tags for Milestones

```
v0.1 — shell configs migrated
v0.2 — editor configs migrated
v0.3 — install.sh unified
v1.0 — full migration complete, old repos deprecated
```

---

## Handling the 3 Old Source Repos

### In `.gitignore`

```
# Old source repos — kept for reference, not tracked
/dotfile.d/
/dotfiles/
/windows-wsl-terminal-customization/
```

### During Migration

| Action | Git command |
|--------|-------------|
| Reset accidental submodule staging | `git rm --cached dotfile.d dotfiles windows-wsl-terminal-customization` |
| Add .gitignore | `echo -e '/dotfile.d/\n/dotfiles/\n/windows-wsl-terminal-customization/' >> .gitignore` |
| Verify clean status | `git status` — should show only MIGRATION-PLAN.md, GITOPS-WORKFLOW.md, .gitignore, packages/ |

---

## Verification Before Each Commit

Before committing to `MIGRATION`:

1. **Git status is clean** — no accidental submodule pointers or dirty child repos
2. **Stow packages are valid** — directory structure mirrors `$HOME` path
3. **Configs syntax-check** — `bash -n`, `zsh -n`, `tmux -c "list-keys"`, etc.
4. **`.gitignore` covers old repos** — confirm they show as `!!` ignored in `git status`

---

## Summary: One Migration, One Repo

```
3 old repos (untracked, reference only)
        │
        │  copy + merge
        ▼
1 unified repo (tracked, source of truth)
        │
        │  git push
        ▼
github.com/Sabir-test/dotfiles
```
