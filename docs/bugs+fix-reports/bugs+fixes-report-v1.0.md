# Bug Report - Dotfiles Repository

**Generated:** 2026-08-24
**Repository:** /home/mbs/dev/dotfiles/

---

## Summary

| Severity | Count | Description |
|----------|-------|-------------|
| **CRITICAL** | 4 | System-breaking issues requiring immediate attention |
| **HIGH** | 8 | Significant functionality problems |
| **MEDIUM** | 11 | Code quality, security, and reliability concerns |
| **LOW** | 14 | Documentation and minor issues |
| **Total** | **37** | |

---

## Critical Issues

### 1. Two Competing Zsh Configurations

**File:** `packages/zsh/.zshrc` (292 lines) vs `packages/zsh/.config/zsh/.zshrc` (26 lines)

Two completely different `.zshrc` files exist that could both be sourced:

- `packages/zsh/.zshrc` — Massive 292-line config using Oh My Zsh, Powerlevel10k, atuin, dozens of aliases
- `packages/zsh/.config/zsh/.zshrc` — Clean 26-line config using Starship, minimal aliases

The `ZDOTDIR` redirect in `packages/zsh/.zshenv` means `.config/zsh/.zshrc` is loaded. The root-level `.zshrc` is dead code that sits in `$HOME` confusingly.

**Impact:** Incomplete migration, confusion about which config is active.

**Suggested Fix:** Delete `packages/zsh/.zshrc` (the 292-line Oh My Zsh file). It is dead code — the `ZDOTDIR` redirect in `.zshenv` means only `packages/zsh/.config/zsh/.zshrc` is sourced. Remove the file entirely.

---

### 2. ZSH_THEME References Powerlevel10k but Starship is Installed

**File:** `packages/zsh/.zshrc:9,32,221`

```bash
ZSH_THEME="powerlevel10k/powerlevel10k"  # Line 9
eval "$(starship init zsh)"              # Line 221
```

Oh My Zsh theme is set to Powerlevel10k, but Starship prompt is also initialized. These are competing prompt systems that will conflict if both are sourced.

**Impact:** Undefined prompt behavior, visual glitches.

**Suggested Fix:** Resolved by Bug #1 fix. The deleted file contained `ZSH_THEME="powerlevel10k/powerlevel10k"`. The active `.config/zsh/.zshrc` already uses Starship correctly. No additional change needed.

---

### 3. Missing `packages/scripts/` Referenced in Documentation

**Files:**
- `AGENTS.md:69`
- `MIGRATION-PLAN.md:50`
- `GITOPS-WORKFLOW.md:16`

Documentation lists `packages/scripts/` as a target package, but this directory does not exist under `packages/`. Scripts live at repo root `scripts/` directory.

**Impact:** Broken documentation references, confusion during setup.

**Suggested Fix:** Update documentation to remove `packages/scripts/` references:
- `AGENTS.md:69` — remove from target package layout
- `MIGRATION-PLAN.md:50` — update package listing
- `GITOPS-WORKFLOW.md:16` — remove reference
Scripts live at repo root `scripts/`, not as a stow package.

---

### 4. Latent Infinite Recursion Risk in `.zshenv`

**File:** `packages/zsh/.zshenv:1-2`

```bash
export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
[[ -f "$ZDOTDIR/.zshenv" ]] && . "$ZDOTDIR/.zshenv"
```

The redirector file sets `ZDOTDIR` and sources `$ZDOTDIR/.zshenv`. If the inner file ever sources `~/.zshenv` for any reason, it creates an infinite loop.

**Impact:** Potential stack overflow on shell startup.

**Suggested Fix:** Rewrite `packages/zsh/.zshenv` to prevent re-sourcing with a guard variable:
```zsh
export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
if [[ -z "$_ZSHENV_SOURCED" ]]; then
  export _ZSHENV_SOURCED=1
  [[ -f "$ZDOTDIR/.zshenv" ]] && . "$ZDOTDIR/.zshenv"
fi
```

---

## High Issues

### 5. Inconsistent GitHub Repository URLs

Multiple files reference different GitHub organizations:

| File | Line | URL |
|------|------|-----|
| `README.md` | 8 | `mbs-org/dotfiles` |
| `scripts/bootstrap.sh` | 12 | `mbs-org/dotfiles.git` |
| `scripts/deploy.sh` | 3, 13 | `Sabir-test/dotfiles` |
| `SCOPE.md` | 46, 49 | `Sabir-test/dotfiles` |
| `docs/BOOTSTRAP.md` | 12, 18 | `mbs-org/dotfiles` |
| `GITOPS-WORKFLOW.md` | 80 | `Sabir-test/dotfiles` |

**Impact:** One-line install commands will fail if only one org has the repo.

**Suggested Fix:** Standardize all URLs to `Sabir-test/dotfiles` (the canonical remote per AGENTS.md). Files to change:
- `README.md:8` — `mbs-org/dotfiles` → `Sabir-test/dotfiles`
- `scripts/bootstrap.sh:12` — `mbs-org/dotfiles.git` → `Sabir-test/dotfiles.git`
- `docs/BOOTSTRAP.md:12,18` — `mbs-org/dotfiles` → `Sabir-test/dotfiles`

---

### 6. `validate.yml` Workflow Branch Case Mismatch

**File:** `.github/workflows/validate.yml:5-7`

```yaml
on:
  push:
    branches: [MAIN]
  pull_request:
    branches: [MAIN]
```

Workflow triggers on `MAIN` (uppercase), but `ci.yml` triggers on `main` (lowercase). Git branches are case-sensitive on Linux. If actual branch is `main`, workflow will never trigger.

**Impact:** CI validation never runs on pushes/PRs.

**Suggested Fix:** In `.github/workflows/validate.yml:6,8`, change `MAIN` to `main` (lowercase):
```yaml
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
```

---

### 7. `deploy.yml` References Non-Existent Path

**File:** `.github/workflows/deploy.yml:19`

```yaml
bash -n packages/scripts/deploy-configs.sh
```

Path `packages/scripts/deploy-configs.sh` does not exist. Script is at `scripts/deploy-configs.sh`.

**Impact:** Workflow step always fails.

**Suggested Fix:** In `.github/workflows/deploy.yml:19`, change `packages/scripts/deploy-configs.sh` to `scripts/deploy-configs.sh`.

---

### 8. `bash/.bashrc` Execs to Zsh Unconditionally

**File:** `packages/bash/.bashrc:2`

```bash
[ - /usr/bin/zsh ] && exec zsh
```

Runs before `export EDITOR=cursor` on line 1. Every Bash invocation (including non-interactive scripts) will be hijacked into Zsh, breaking build systems, CI scripts, and Makefiles that expect Bash.

**Impact:** POSIX compliance violation, broken build systems.

**Suggested Fix:** Guard the exec behind an interactive shell check so non-interactive invocations (scripts, CI, Makefiles) are not hijacked:
```bash
export EDITOR=cursor
[[ $- == *i* ]] && [ -f /usr/bin/zsh ] && exec zsh
```

---

### 9. `deploy-configs.sh` Uses `wslpath` Unconditionally

**File:** `scripts/deploy-configs.sh:60`

```bash
echo -e "${BLUE}cp $(wslpath -w "$SCRIPT_DIR/../packages/windows-terminal/windows-terminal-settings.json") ..."
```

`wslpath` is only available in WSL2. On native Linux or macOS, this will error with "command not found".

**Impact:** Script fails on non-WSL systems.

**Suggested Fix:** Wrap the WSL-specific echo block in `scripts/deploy-configs.sh:60` with a WSL detection guard:
```bash
if grep -qi microsoft /proc/version 2>/dev/null; then
  echo -e "${BLUE}cp $(wslpath -w ...)${NC}"
fi
```

---

### 10. Duplicate Backup Timestamp Directories

**File:** `scripts/deploy-configs.sh:33-34`

```bash
mkdir -p "$HOME/config-backups/$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR=~/config-backups/$(date +%Y%m%d_%H%M%S)
```

Two separate `date` calls produce different timestamps if minute changes between calls. `mkdir` creates one directory, but `BACKUP_DIR` might reference a different directory.

**Impact:** Backup directory mismatch, potential data loss.

**Suggested Fix:** In `scripts/deploy-configs.sh:33-34`, capture the timestamp once and reuse it:
```bash
TS="$(date +%Y%m%d_%H%M%S)"
mkdir -p "$HOME/config-backups/$TS"
BACKUP_DIR="$HOME/config-backups/$TS"
```

---

### 11. `deploy-configs.sh` Only Stows Subset of Packages

**File:** `scripts/deploy-configs.sh:45-46`

```bash
stow --restow --dir="$SCRIPT_DIR/../packages" --target="$HOME" \
  agent bash bin cursor fish gh git pam ripgrep starship tmux vscode yazi zsh
```

Missing `kde` and `opencode` packages that exist in `packages/`. The canonical `stow-all.sh` iterates all packages.

**Impact:** Some packages silently skipped during deployment.

**Suggested Fix:** In `scripts/deploy-configs.sh:45-46`, replace the hardcoded package list with a dynamic loop (matching `stow-all.sh`):
```bash
for pkg in packages/*/; do
  name=$(basename "$pkg")
  stow --restow --dir="$SCRIPT_DIR/../packages" --target="$HOME" "$name"
done
```

---

### 12. `install.sh` Package List Does Not Match Actual Packages

**File:** `install.sh:20`

```bash
for pkg in agent bash bin cursor fish gh git pam ripgrep starship tmux vscode yazi zsh; do
```

Missing `kde` and `opencode`. The `packages/` directory has 17 packages; `install.sh` only lists 15.

**Impact:** Incomplete installation on fresh systems.

**Suggested Fix:** Same fix as Bug #11. In `install.sh:20`, replace the hardcoded list with:
```bash
for pkg in packages/*/; do
  pkg=$(basename "$pkg")
```

---

## Medium Issues

### 13. Code Injection Vulnerability in `validate.sh`

**File:** `scripts/validate.sh:291,308,339`

```bash
if python3 -c "import json; json.load(open('$f'))" 2>/dev/null; then
```

File path `$f` is interpolated directly into Python string. Filenames with single quotes can break the code. Malicious filenames could execute arbitrary code.

**Impact:** Security vulnerability, script failure on special filenames.

**Suggested Fix:** In `scripts/validate.sh:291,308,339`, pass the file path as a CLI argument instead of interpolating it into a Python string:
```bash
# Before (vulnerable):
python3 -c "import json; json.load(open('$f'))"
# After (safe):
python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$f"
```

---

### 14. Hardcoded Home Path in `fish_variables`

**File:** `packages/fish/.config/fish/fish_variables:3`

```
SETUVAR fish_user_paths:/home/mbs/.cargo/bin.../home/mbs/.local/bin.../home/mbs/.fzf/bin
```

Hardcodes `/home/mbs` in universal variables. Will be incorrect for any other user.

**Impact:** Broken PATH for other users.

**Suggested Fix:** Remove `packages/fish/.config/fish/fish_variables` from the stow package (add to `.stow-local-ignore` or `.gitignore`). Fish universal variables are machine-specific and should not be shared. Alternatively, rewrite the entries to use `$HOME` but fish_variables format doesn't support variable expansion.

---

### 15. Duplicate `settings.json` in VS Code Package

**Files:**
- `packages/vscode/settings.json` (17 lines, minimal)
- `packages/vscode/.config/Code/User/settings.json` (113 lines, full config)

Root-level `settings.json` will be stowed to `~/settings.json` (wrong location). Should only exist in `.config/`.

**Impact:** Incorrect symlink at `~/settings.json`, duplicate config.

**Suggested Fix:** Delete `packages/vscode/settings.json` (the 17-line root-level file). It stows to `~/settings.json` which is the wrong location. The correct file is `packages/vscode/.config/Code/User/settings.json`.

---

### 16. `packages/pam/` README Stows to Wrong Location

**File:** `packages/pam/README.md`

When stowed, `README.md` symlinks to `~/README.md`, polluting home directory. Should be in `.stow-local-ignore`.

**Impact:** Unwanted file in home directory.

**Suggested Fix:** Delete `packages/pam/README.md` (1-line placeholder). Or add `README\.md` to `packages/pam/.stow-local-ignore` to prevent it from being stowed to `~/README.md`.

---

### 17. `git/.gitconfig` Path Mismatch

**File:** `packages/git/.gitconfig:32`

```ini
[includeIf "gitdir:~/.config/dotfiles/"]
    path = .gitconfig.local
```

References `~/.config/dotfiles/`, but `deploy.sh` clones to `~/dotfiles`. Include will never trigger.

**Impact:** Local git config never loaded for some setups.

**Suggested Fix:** In `packages/git/.gitconfig:32`, change the `includeIf` path to match the actual clone location:
```ini
[includeIf "gitdir:~/dotfiles/"]
    path = .gitconfig.local
```

---

### 18. KDE Restore Has No Confirmation Prompt

**File:** `scripts/kde-settings.sh:28-33`

```bash
for f in "${KDE_DST}"/*; do
    local name
    name="$(basename "$f")"
    cp "$f" "${KDE_SRC}/${name}"
```

Copies files into `~/.config/` without confirmation or backup. Stale configs can silently overwrite user settings.

**Impact:** Potential data loss on KDE settings.

**Suggested Fix:** In `scripts/kde-settings.sh:28-33`, add an interactive confirmation before overwriting:
```bash
read -p "Overwrite ${KDE_SRC}/${name}? [y/N] " confirm
[[ "$confirm" =~ ^[Yy]$ ]] || continue
cp "$f" "${KDE_SRC}/${name}"
```
Add a `--force` flag to skip prompts for non-interactive use.

---

### 19. `bootstrap.sh` Downloads Scripts Without Verification

**File:** `scripts/bootstrap.sh:144,151`

```bash
run curl -fsSL https://fnm.vercel.app/install | bash
run curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
```

Piping curl output to shell without GPG signature verification. If servers are compromised, arbitrary code runs as user.

**Impact:** Security risk, supply chain attack vector.

**Suggested Fix:** This is a known trade-off for bootstrap scripts (fnm and rustup official install methods). Add a comment documenting the trust assumption. For higher security, download first, verify checksum/signature, then execute — but this adds complexity to the bootstrap flow.

---

### 20. `push-changes.sh` Uses `git add -A` Without Filtering

**File:** `scripts/push-changes.sh:24`

```bash
git add -A
```

Stages everything, including potentially sensitive files like `local.zsh`, `.env`, or `fish_variables`. Machine-specific overrides could slip through.

**Impact:** Accidental commit of secrets or machine-specific configs.

**Suggested Fix:** In `scripts/push-changes.sh:24`, change `git add -A` to `git add -u` to only stage changes to already-tracked files. This prevents accidentally committing untracked machine-specific files.

---

### 21. `pull-updates.sh` Checkout May Fail Due to Untracked Files

**File:** `scripts/pull-updates.sh:16-22`

Script stashes changes but uses `git diff --quiet` which doesn't catch untracked files. Checkout could fail or carry unwanted files.

**Impact:** Failed updates, untracked files contaminating branch.

**Suggested Fix:** In `scripts/pull-updates.sh:16-22`, use `git stash push --include-untracked` instead of plain `git stash push`, and check for untracked files in the dirty detection:
```bash
if ! git diff --quiet || ! git diff --cached --quiet || [ -n "$(git ls-files --others --exclude-standard)" ]; then
```

---

### 22. `doctor.sh` Hardcoded Dotfile List May Miss Packages

**File:** `scripts/doctor.sh:34-38`

Only checks for `.bashrc` and `.profile` by name. Misses `.bash_logout`. Find command uses `-o` without parentheses grouping.

**Impact:** Incomplete validation, missed syntax errors.

**Suggested Fix:** In `scripts/doctor.sh:34-38`, add `.bash_logout` to the checked files and fix the `-o` grouping with proper parentheses:
```bash
find "$HOME" -maxdepth 1 \( -name ".bashrc" -o -name ".profile" -o -name ".bash_logout" \) ...
```

---

### 23. Unquoted Variables in Shell Scripts

**File:** `scripts/doctor.sh:30`

```bash
rel="${f#"$(pwd)"/}"
```

Uses `$(pwd)` inside parameter expansion which could break if path contains special characters.

**Impact:** Script failure on paths with spaces or special chars.

**Suggested Fix:** In `scripts/doctor.sh:30`, the parameter expansion `${f#"$(pwd)"/}` is actually safe because `$(pwd)` inside `${...#...}` is evaluated as a pattern, but quoting can be improved for clarity. The real fix is ensuring the overall script handles paths with spaces by quoting all variable references.

---

## Low Issues

### 24. README Repository Structure Name Is Wrong

**File:** `README.md:28`

```
dotfiles-projects/
```

Root directory is named `dotfiles/`, not `dotfiles-projects/`. Stale reference.

**Suggested Fix:** In `README.md:28`, change `dotfiles-projects/` to `dotfiles/`.

---

### 25. README Lists Packages That Don't Exist; Omits Packages That Do

**File:** `README.md:29-50`

Missing `pam` from package list. README structure diagram is incomplete.

**Suggested Fix:** In `README.md:29-50`, add `pam/`, `kde/`, and `opencode/` to the package tree listing.

---

### 26. AGENTS.md Package Layout Lists Non-Existent Directory

**File:** `AGENTS.md:65-69`

Lists `scripts/` as a package directory, but `packages/scripts/` does not exist.

**Suggested Fix:** In `AGENTS.md:69`, remove `scripts/` from the target package layout. Scripts are at repo root `scripts/`, not under `packages/`. Same fix in `MIGRATION-PLAN.md:50` and `GITOPS-WORKFLOW.md:16`.

---

### 27. README Branch Strategy Has Grammar Issues

**File:** `README.md:55-84`

- "When The installer Scripts Got executed..."
- "The Local/main should opens A PR"
- "So Basicly The <orign/main>..."

**Suggested Fix:** In `README.md:55-84`, fix grammar:
- "When The installer Scripts Got executed..." → "When the installer scripts run..."
- "The Local/main should opens A PR" → "The local machine opens a PR"
- "So Basicly The <orign/main>..." → "Basically, `<origin/main>`..."

---

### 28. NVM Version Pin Is Outdated

**File:** `scripts/install-tools.sh:371`

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
```

Pinned to NVM v0.39.7. Newer versions available with security fixes.

**Suggested Fix:** In `scripts/install-tools.sh:371`, update NVM from `v0.39.7` to `v0.40.7`:
```
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.7/install.sh | bash
```

---

### 29. `fish/config.fish` Calls `fzf_key_bindings` Without Guard

**File:** `packages/fish/.config/fish/config.fish:148`

```fish
fzf_key_bindings
```

Calls function without checking if fzf is installed. Errors on every shell startup if missing.

**Suggested Fix:** In `packages/fish/.config/fish/config.fish:148`, wrap in a command existence check:
```fish
type -q fzf_key_bindings && fzf_key_bindings
```

---

### 30. `deploy-configs.sh` Creates Scripts That Override Stow-Managed Files

**File:** `scripts/deploy-configs.sh:78-109`

Creates `~/.local/bin/reload-terminal` and `edit-terminal` with `cat >`. These are not managed by Stow and persist across re-stows.

**Suggested Fix:** Move `reload-terminal` and `edit-terminal` scripts into `packages/bin/` so they are managed by Stow and persist across re-stows. Remove the `cat >` creation blocks from `scripts/deploy-configs.sh:78-109`.

---

### 31. `starship.toml` Uses Potentially Deprecated Option

**File:** `packages/starship/.config/starship.toml:7`

```toml
show_milliseconds = true
```

Minor forward-compatibility concern with newer Starship versions.

**Suggested Fix:** In `packages/starship/.config/starship.toml:7`, `show_milliseconds = true` still works but the modern equivalent is `command_execution_time` with custom format. Since `min_time = 2000` already means millisecond precision is visible, this can be left as-is or updated to:
```toml
[command_execution_time]
min_time = 2_000
format = "took [$duration]($style) "
```

---

### 32. `.stow-local-ignore` Ignores Non-Existent Directories

**File:** `.stow-local-ignore:7,12`

```
themes/
var/
```

These directories don't exist in the repo. Stale entries.

**Suggested Fix:** In `.stow-local-ignore`, remove the stale entries `themes/` and `var/` (lines 7, 12).

---

### 33. `kde-settings.sh` Backup Path Inconsistency

**File:** `scripts/kde-settings.sh:13`

References `.gtkrc-2.0` and `gtkrc` without consistent path prefix matching actual package contents.

**Suggested Fix:** In `scripts/kde-settings.sh:13`, verify that `.gtkrc-2.0` and `gtkrc` exist in the KDE config directory before attempting backup/restore. The script already has `if [[ -f "${KDE_SRC}/${f}" ]]` guards in backup, but restore doesn't have them. Add the same guard to the restore loop.

---

### 34. `vscode/settings.json` at Package Root Creates Wrong Symlink

**File:** `packages/vscode/settings.json`

When stowed, creates symlink at `~/settings.json` instead of proper XDG location.

**Suggested Fix:** Resolved by Bug #15 fix (delete root-level file).

---

### 35. `validate.yml` Zsh Syntax Check Silently Swallows Errors

**File:** `.github/workflows/validate.yml:42-44`

```yaml
find packages/zsh -name '*.zsh' -exec zsh -n {} \; 2>&1 || true
echo "zsh syntax check complete (warnings may be informational)"
```

`|| true` means syntax errors are never caught. Step always passes.

**Suggested Fix:** In `.github/workflows/validate.yml:42-44`, remove `|| true` and instead capture output, then only fail on actual syntax errors (not informational warnings):
```yaml
- name: Check zsh syntax
  run: |
    find packages/zsh -name '*.zsh' -exec zsh -n {} \; 2>&1
    echo "zsh syntax check complete"
```

---

### 36. `.opencode/` vs `packages/opencode/` Naming Confusion

**File:** `.gitignore:27,36`

`.gitignore` excludes `.opencode/` (repo config), but `packages/opencode/` (stow package) is different. Both share name "opencode."

**Suggested Fix:** No code change needed. Add a clarifying comment in `.gitignore`:
```
# .opencode/ = repo-level agent config (NOT the stow package)
# packages/opencode/ = stow package for user opencode config
.opencode/
```

---

### 37. README Branch Strategy References Wrong Branch Name Format

**File:** `README.md:61`

Describes old gitops workflow with feature branches. `GITOPS-WORKFLOW.md` now says there's only one branch (`MAIN`). README is stale.

**Suggested Fix:** In `README.md:61`, update the branch strategy description to match `GITOPS-WORKFLOW.md` — single `MAIN` branch, no feature branches, push directly and fix regressions in next commit.

---

## Recommendations

### Immediate Actions (Critical)
1. Remove `packages/zsh/.zshrc` (dead code) or consolidate configs
2. Fix `packages/scripts/` references in documentation
3. Choose either Powerlevel10k or Starship, not both

### Short-Term Fixes (High)
1. Standardize GitHub URLs to single organization
2. Fix branch case in `validate.yml` (`MAIN` → `main`)
3. Fix path in `deploy.yml` (`packages/scripts/` → `scripts/`)
4. Remove or gate `exec zsh` in `.bashrc`
5. Gate WSL-specific code behind WSL2 detection
6. Update package lists in `install.sh` and `deploy-configs.sh`

### Medium-Term Improvements (Medium)
1. Sanitize filenames in `validate.sh` Python calls
2. Remove hardcoded paths from `fish_variables`
3. Clean up duplicate `settings.json` in VS Code package
4. Add confirmation prompts to destructive operations
5. Use `git stash --include-untracked` in pull script

### Documentation Cleanup (Low)
1. Fix grammar in README branch strategy
2. Update package lists in README
3. Remove stale directory references
4. Update NVM version pin

---

## Testing Checklist

- [ ] Verify zsh startup with ZDOTDIR redirect
- [ ] Test install.sh on fresh system
- [ ] Test deploy-configs.sh on non-WSL system
- [ ] Validate all CI workflows trigger correctly
- [ ] Check stow symlinks for all packages
- [ ] Test KDE settings backup/restore
- [ ] Verify fish startup without fzf
- [ ] Test bootstrap.sh on clean machine
