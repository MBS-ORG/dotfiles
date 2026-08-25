# Bootstrap Analysis Report

**Date:** 2026-07-08
**Tested on:** minilap (WSL2, Debian-based)
**Branch:** main (v2026.07.08-15.34.36)

## Summary

Bootstrap completed dependency installation, repo clone, and branch switching but **failed at the stow step** with:

```
stow: ERROR: Slashes are not permitted in package names
```

This is a systemic issue affecting 5 source files with the same root cause. The failure is silent because `set -e` aborts the script before any error message is printed.

## Issues Found

### C1 — Stow slash bug (CRITICAL)

`scripts/stow-all.sh` iterates over `packages/*/` but passes the full glob-expanded path (e.g. `packages/agent/`) as the package name. Stow rejects paths containing slashes.

**Root cause:** The glob `packages/*/` in `stow-all.sh:4` expands to paths with a trailing slash. The same pattern is replicated in:

| File | Line | Pattern |
|------|------|---------|
| `scripts/stow-all.sh` | 6 | `stow -R --target="$HOME" "$pkg"` |
| `scripts/bootstrap.sh` | 134 | `run stow -R --target="${HOME}" "$pkg"` (fallback) |
| `Dockerfile` | 12 | `stow --no --target=/tmp/th "$pkg"` |
| `.github/workflows/deploy.yml` | 28 | `stow --simulate --target="/tmp/stow-target" packages/*` |
| `.github/workflows/validate.yml` | 52 | `stow --simulate --target="/tmp/stow-target" packages/*` |

**Correct pattern** (already used in `scripts/validate.sh:189-190` and `install.sh:22`):

```bash
name=$(basename "$pkg")
stow -R --target="$HOME" --dir=packages "$name"
```

### C2 — Silent failure on stow error (CRITICAL)

`set -euo pipefail` at the top of `bootstrap.sh` causes immediate abort when stow fails. No error message, no diagnostic, no continuation. The `run()` function (line 62-69) has no error handling beyond `set -e`.

**Impact:** Bootstrap halts mid-install, leaving the system in an inconsistent state with no indication of what went wrong.

**Fix:** Add `|| warn "..."` guard after stow invocation, or wrap in an explicit check.

### C3 — Pull targets `main` instead of `staging` (HIGH)

`clone_or_pull_repo()` (line 96-103) calls `git clone` without specifying a branch, so it pulls the default (main). This transiently clones 14 stale/regressive files from main before `switch_to_machine_branch()` switches to `staging` or `machine/<hostname>`.

**Impact:** Brief dirty working tree during bootstrap; `validate.sh --strict` would fail if run immediately after clone.

**Fix:** `git clone --branch staging <url> <dir>`

### C4 — No post-bootstrap validation (MEDIUM)

After stowing packages, the bootstrap runs `install_runtimes`, `desktop_setup`, `change_shell`, and `verify`, but never runs `validate.sh` to confirm all configs are properly deployed.

**Fix:** Call `./scripts/validate.sh` at the end of `main()`.

### C5 — `packages/pam/` is a placeholder (LOW)

`packages/pam/` contains only a `README.md` — no `.pam_environment` or actual PAM config. This passes CI (package integrity checks count `README.md`) but provides no functional value.

**Options:** Either add `.pam_environment` or remove the empty package.

### H1 — `packages/opencode/` not in README diagram (LOW)

The `packages/opencode/` directory exists on disk with opencode agent/skill configurations but is not listed in the README structure diagram.

## Files fixed in this commit

1. `scripts/stow-all.sh` — `--dir=packages` + `basename`
2. `scripts/bootstrap.sh` — fallback loop fix + `|| warn` guard
3. `Dockerfile` — `--dir=packages` + `basename`
4. `.github/workflows/deploy.yml` — iterate with basename + `--dir`
5. `.github/workflows/validate.yml` — iterate with basename + `--dir`

## Remaining work

- #9: doctor.sh `set -e` rewrite
- #10: bootstrap initial pull branch target
- #11: README diagram missing packages
- #13: comprehensive stow slash fix (tracking issue)
- Add post-bootstrap `validate.sh` run
- `packages/pam/` content decision
- `clone_or_pull_repo` `--branch staging` flag
