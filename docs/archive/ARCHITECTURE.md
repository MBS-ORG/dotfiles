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

## Secrets & Credentials

This repo follows a **template-first, local-override** credential model:

| Credential | Where | Strategy |
|---|---|---|
| Git name/email | `packages/git/.gitconfig` | Template placeholder in staging (`mbs@localhost`); real values in machine branches or `.gitconfig.local` |
| GPG keys | Local machine only | Never tracked. Managed via `gpg --import` outside dotfiles |
| SSH keys | Local machine only | Never tracked. Generated per machine with `ssh-keygen` |
| GitHub tokens | Local machine only | Stored in `~/.config/gh/hosts.yml` or env vars, never in repo |
| API keys / tokens | Local machine only | Sourced via `local.zsh` (gitignored) or environment files |
| `local.zsh` | `packages/zsh/.config/zsh/local.zsh` | Gitignored machine override sourced by `.zshenv` at runtime |
| `.gitconfig.local` | `packages/git/.gitconfig.local` | Gitignored local override included via `includeIf` |

**CI/CD pipeline** does not use any credentials from the repo template — GitHub Actions
automatically sets its own git author information and uses `GITHUB_TOKEN` for authentication.
The CI workflow only validates syntax, runs shellcheck, and performs stow dry-runs.

**Enforcement**: The `.githooks/pre-commit` hook checks for patterns like `-----BEGIN.*KEY-----`
and blocks commits containing private keys. The `.gitignore` blocks `**/id_*`, `**/*.key`,
`**/*.pem`, `**/credentials`, `**/token*`, and `**/*secret*`.

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
