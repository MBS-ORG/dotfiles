# Workflow

## Branch Strategy

```
main                    # Stable, release-ready (protected)
└── staging             # Integration branch — all PRs merge here first
    ├── feature/*        # Feature branches (branch from staging, PR → staging)
    └── machine/*        # Per-machine config branches (long-lived)
```

### Branch Lifecycle

| Branch | Purpose | Protected | Deletes |
|--------|---------|-----------|---------|
| `main` | Release-ready, tagged | Yes | Never |
| `staging` | Active development integration | No | Never |
| `feature/<name>` | New packages, scripts, docs | No | After merge |
| `fix/<name>` | Bug fixes | No | After merge |
| `machine/<hostname>` | Per-machine overrides (kwinrc, gitconfig, local.zsh) | No | Never |

## Change Flow (Standard)

```bash
# 1. Branch from staging
git checkout staging && git pull
git checkout -b feature/add-fzf-package

# 2. Make changes
mkdir -p packages/fzf/.config/fzf/
cp ~/.config/fzf/key-bindings.zsh packages/fzf/.config/fzf/
# Add README, test with stow
./scripts/stow-package.sh fzf

# 3. Commit
git add packages/fzf/
git commit -m "feat(fzf): add fzf package with key bindings"

# 4. PR → staging
git push -u origin $(git branch --show-current)
# Create PR via GitHub CLI or web
```

## Machine-Specific Configs

Machine-specific branches hold per-hostname overrides that cannot be shared:

```bash
# Create a machine branch from staging
git checkout staging && git pull
git checkout -b machine/thinkpad-t14s

# Override machine-specific KDE configs
cp ~/.config/kwinrc packages/kde/.config/kwinrc      # UUIDs differ per machine
cp ~/.config/plasmarc packages/kde/.config/plasmarc    # Activity IDs differ
cp ~/.config/kdeglobals packages/kde/.config/kdeglobals

# Override git config (name, email)
# Edit packages/git/.gitconfig — user.name and user.email
# (OR use .gitconfig.local on the actual machine — it's gitignored)

# Commit machine overrides
git add packages/kde/.config/kwinrc packages/git/.gitconfig
git commit -m "machine(thinkpad-t14s): add KDE and git overrides"
git push -u origin machine/thinkpad-t14s

# Create PR from machine/thinkpad-t14s → staging
# Reviewer inspects: no secrets? no hardcoded paths? UUIDs only in KDE files?
```

### What Belongs in Machine Branches vs Local Override Files

| File | Strategy | Why |
|------|----------|-----|
| `packages/kde/.config/kwinrc` | Machine branch override | Desktop UUIDs, tiling layout IDs differ per machine |
| `packages/kde/.config/plasmarc` | Machine branch override | Activity UUIDs differ per machine |
| `packages/kde/.config/kdeglobals` | Machine branch override | May have machine-specific settings |
| `packages/git/.gitconfig` | Machine branch (user section) or `.gitconfig.local` | Name/email per machine |
| `packages/zsh/.config/zsh/local.zsh` | `.gitignore`d local file | Machine-specific env vars, PATH, secrets |
| `packages/starship/.config/starship.local.toml` | `.gitignore`d local file | Machine-specific prompt config |

**Rule of thumb**: If a file has machine-specific *structure* (like kwinrc UUIDs that get regenerated entirely), track it in a machine branch. If it has machine-specific *values you append* (like local.zsh sourcing secrets), use the gitignored local override pattern.

## Syncing KDE Configs Across Machines

### Step 1: Backup from source machine

```bash
# On the machine with desired config
./scripts/kde-settings.sh backup
# This copies ~/.config/<file> → packages/kde/.config/<file>
# and prints a diff summary
```

### Step 2: Commit to feature branch

```bash
git checkout -b feature/update-kde-configs
./scripts/kde-settings.sh backup   # copies from ~/.config
git add packages/kde/
git commit -m "feat(kde): sync kwinrc, kdeglobals, plasmakeyboardrc"
git push -u origin feature/update-kde-configs
# PR → staging
```

### Step 3: Deploy to target machine

```bash
# On target machine (after merge to staging)
git checkout staging && git pull
./scripts/stow-package.sh kde

# WARNING: stow will symlink. The target machine's kwinrc will be
# overwritten with symlinks. If kwinrc UUIDs don't match, KDE may
# reset desktop layouts. After stowing, run:
#   1. Re-login to KDE or `plasma-apply-desktoptheme`
#   2. Verify tiling layouts work correctly
#   3. If layouts reset, copy back the auto-generated kwinrc from ~/.config/
```

### Machine Branch Strategy for KDE

For machines that share most settings but have different hardware (different display, GPU, monitors):

1. Keep the *settings* (padding, animations, tiling preferences) in `staging`/`main`
2. Keep the *UUIDs* (desktop IDs, activity IDs, tiling instance IDs) in `machine/<hostname>`
3. When upgrading KDE configs from staging, merge `staging` into `machine/<hostname>` and resolve UUID conflicts (accept machine branch version for UUID lines, staging for everything else)

```bash
# Merge staging into machine branch (keeps machine UUIDs)
git checkout machine/thinkpad-t14s
git merge staging --no-edit
# If conflicts in kwinrc: keep machine branch UUIDs (they're the correct ones)
# Resolve manually or with: git checkout --ours packages/kde/.config/kwinrc
```

## CI/CD Pipeline

### Pull Request Checks (all PRs)

See `.github/workflows/ci.yml` — runs on every PR to `staging` and `main`:

- **Shellcheck**: validates all `.sh` scripts
- **Stow dry-run**: verifies all packages can be stowed without conflicts
- **Docker build**: validates the development container
- **Manifest freshness**: checks that `manifests/dpkg.txt` is up-to-date

### Comprehensive Checks (scheduled + manual)

See `.github/workflows/comprehensive.yml`:

- Multi-OS shell syntax validation (Ubuntu, macOS, Arch Linux)
- Full Docker-based bootstrap dry-run
- Drift detection simulation

### Release Workflow (staging → main)

See `.github/workflows/release.yml`:

1. Triggered by manual dispatch
2. Runs all CI checks
3. Merges `staging` → `main`
4. Creates a CalVer tag: `vYYYY.MM.DD-HH.MM.SS`

### CI on Machine Branches

Machine branches (`machine/*`) get a lighter CI run:
- Shellcheck only
- No Docker build (avoid wasting resources on machine-specific branches)
- No manifest freshness check (machine configs don't update manifests)

Configured via branch filter in `ci.yml`:

```yaml
on:
  pull_request:
    branches:
      - staging
      - main
      - 'machine/**'
```

## PR Review Checklist

When reviewing a PR to `staging`:

- [ ] No secrets, API keys, tokens, or passwords in tracked files
- [ ] No absolute paths referencing specific user home directories
- [ ] No machine hostnames in shared configs (use machine branch for those)
- [ ] UUIDs only in KDE config files (and only in machine branches or feature branches targeting machine branches)
- [ ] `.gitconfig` user section uses real name if in a machine branch; placeholder in staging/main
- [ ] Shell scripts pass `shellcheck` without warnings
- [ ] README updated if adding a new package
- [ ] Manifest updated if adding new system packages (dpkg.txt)
- [ ] New stow packages follow the standard structure:
  ```
  packages/<name>/
  ├── .config/<app>/    # Config files (optional)
  ├── README.md         # Purpose, dependencies, tips
  └── ...               # Any other files to stow
  ```

## Rollback

```bash
# Quick rollback to previous commit
git checkout staging
git checkout <previous-commit> -- packages/kde/
./scripts/stow-all.sh

# Full rollback
git checkout <previous-commit>
./scripts/stow-all.sh
```

## Sync (on target machine)

```bash
./scripts/update.sh
# Pulls latest, re-stows all packages, runs drift-detect
```
