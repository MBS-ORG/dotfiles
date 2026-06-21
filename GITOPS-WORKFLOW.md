# GitOps Workflow — Dotfiles Repo

## Repository Structure

```
dotfiles-projects/             ← single source of truth
├── GITOPS-WORKFLOW.md
├── .gitignore
├── install.sh
├── .githooks/                  ← pre-commit hooks
├── .github/workflows/          ← CI pipeline
├── packages/
│   ├── agent/          bash/           bin/           cursor/
│   ├── fish/           gh/             git/           pam/
│   ├── ripgrep/        scripts/        starship/      tmux/
│   ├── vscode/         windows-terminal/  yazi/       zsh/
└── .omo/
    ├── drafts/          ← WIP documents
    ├── plans/           ← execution plans
    ├── sessions/        ← session exports
    └── skills/          ← opencode skill definitions
```

---

## Branching Strategy

```
MAIN  ●──────●──────●──────●────  (stable, deployable)
```

Only one branch. All work happens on `MAIN`. No feature branches, no migration branches — the migration is complete, and this repo is now in maintenance/iteration mode.

If you need to experiment with a risky change, commit on `MAIN` but do not push until stable, or use a local branch that you squash-merge back.

---

## Commit Convention

```
<type>: <short description>

[optional body — details on conflicts resolved, decisions made]
```

### Types

| Type | When to use |
|------|-------------|
| `feat` | Adding a new config, package, or feature |
| `fix` | Fixing a broken config, path, or syntax |
| `docs` | Changes to docs, README, workflow |
| `refactor` | Restructuring packages, renaming, reorganizing |
| `chore` | .gitignore, git config, tooling, CI, hooks |

### Examples

```
feat: add macOS Homebrew paths to bash/.bashrc
fix: correct neovim binary name in bash aliases
docs: update AGENTS.md with current package count
refactor: rename packages/scripts to packages/bin
chore: add pre-commit hooks for Stow validation
```

---

## Verification Before Each Commit

1. **Git status is clean** — no untracked secrets, no dirty submodules
2. **Stow packages are valid** — `stow --simulate --target="$HOME" packages/*` succeeds
3. **Configs syntax-check** — `bash -n`, `zsh -n`, `tmux -c "list-keys"`, etc. on changed files
4. **CI passes** — GitHub Actions validates on push

---

## Remote

```
origin  github.com/Sabir-test/dotfiles
```

Push to `MAIN` directly. If the push introduces a regression, fix it in the next commit — no revert-and-branch ceremony needed for a personal dotfiles repo.
