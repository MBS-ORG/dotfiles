# Workflow

## Branch Strategy

```
main              # Stable, release-ready
├── staging       # Active development
├── machine/<hn>  # Machine-specific overrides
└── feature/*     # Feature branches
```

- `main` is protected — only PR merges from `staging` or hotfix branches.
- `staging` is the default branch for all PRs.
- `machine/<hostname>` branches hold per-machine local overrides.

## Change Flow

```bash
git checkout staging
# Make changes to packages/<name>/
./scripts/stow-package.sh <name>   # Apply locally
git add -A
git commit -m "feat: add <description>"
git push
```

## Sync (on another machine)

```bash
./scripts/update.sh
# Pulls latest, re-stows all packages, runs drift-detect
```

## Rollback

```bash
git checkout <previous-commit>
./scripts/stow-all.sh
```

## Machine Overrides

Create machine-specific files (they are gitignored):

- `packages/zsh/.config/zsh/local.zsh`
- `packages/git/.gitconfig.local`
- `packages/starship/.config/starship.local.toml`

These are automatically sourced by the main config files.
