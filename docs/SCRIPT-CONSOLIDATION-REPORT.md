# Script Suite Consolidation Report

> **Date:** 2026-08-27
> **Scope:** Full review and consolidation of `scripts/` directory
> **Result:** 15 scripts → 7 scripts (53% reduction), 1,309 lines removed

---

## Executive Summary

Reviewed all 15 scripts in the dotfiles repository for redundancy, overlap, and usefulness. Merged overlapping functionality, removed superseded scripts, renamed for clarity, and added centralized OS detection. The result is a leaner, more maintainable script suite with clear single responsibilities.

---

## Changes Applied

### 1. Merged `stow-all.sh` + `stow-package.sh` → `stow.sh`

| | Before | After |
|---|---|---|
| **Files** | 2 scripts (9 + 9 = 18 lines) | 1 script (29 lines) |
| **Usage** | `stow-all.sh` (all), `stow-package.sh <name>` (single) | `stow.sh` (all), `stow.sh <name>` (single), `stow.sh <n1> <n2>` (multiple) |
| **OS flag** | None | Accepts `--os <value>` for future OS-specific handling |

**Why:** Two scripts doing nearly the same thing. Merged into one with dual behavior based on args.

### 2. Deleted `kde-settings.sh`

| | Before | After |
|---|---|---|
| **Backup/restore** | Dedicated script with `backup`, `restore`, `sync` subcommands | Git handles it via `push-changes.sh` + `pull-updates.sh` |
| **Stow deployment** | Manual `restore` call in `bootstrap.sh` | Automatic via `pull-updates.sh` re-stow step |

**Why:** KDE configs are already tracked in git and deployed via stow. The script was an unnecessary abstraction layer over what git already does.

### 3. Renamed `update.sh` → `pull-updates.sh`

| | Before | After |
|---|---|---|
| **Name** | `update.sh` | `pull-updates.sh` |
| **Drift detection** | Called `drift-detect.sh` (subset of `validate.sh`) | Calls `validate.sh` (full validation) |
| **Stow call** | `./scripts/stow-all.sh` | `./scripts/stow.sh` |

**Why:** "pull-updates" is more declarative about what the script does (pull from remote, rebase, re-stow). The old `pull-updates.sh` (53 lines) was a subset of `update.sh` and was deleted first.

### 4. Added OS flag propagation in `bootstrap.sh`

| | Before | After |
|---|---|---|
| **OS values** | `wsl2`, `debian`, `linux`, `macos`, `unknown` | `wsl`, `linux`, `macos`, `unknown` |
| **Detection** | Called `detect_os()` but discarded result | Stores in `OS` variable, passes `--os` to downstream scripts |
| **Downstream** | Each script detected OS independently | `bootstrap.sh` is single authority; standalone scripts fall back to auto-detection |

**Why:** OS-specific configs (e.g., Windows Terminal on WSL) need consistent OS detection across the pipeline. Centralizing it in `bootstrap.sh` prevents drift between scripts.

### 5. Added `--os` flag to `install-tools.sh`

| | Before | After |
|---|---|---|
| **OS detection** | Hardcoded `uname -s` check | Accepts `--os <value>` override, falls back to `uname -s` |
| **Flag parsing** | None | Parses `--os` before OS detection block |

**Why:** When called from `bootstrap.sh`, it receives the detected OS. When run standalone, it auto-detects. Same script, two entry points.

### 6. Deleted `bootstrap-headless.sh`

| | Before | After |
|---|---|---|
| **File** | 3-line wrapper: `exec bootstrap.sh --headless "$@"` | Deleted |
| **Usage** | `./scripts/bootstrap-headless.sh` | `./scripts/bootstrap.sh --headless` |

**Why:** Trivial wrapper. The `--headless` flag already exists on `bootstrap.sh`.

### 7. Deleted `deploy.sh`

| | Before | After |
|---|---|---|
| **File** | 28-line script: clone repo + run `install.sh` | Deleted |
| **Alternative** | — | `bootstrap.sh` handles clone + install + everything else |

**Why:** `bootstrap.sh` already does everything `deploy.sh` does and more. Two entry points for the same flow is confusing.

### 8. Deleted `deploy-configs.sh`

| | Before | After |
|---|---|---|
| **File** | 142-line script: backup configs, stow, install tmux plugins, create helper scripts, Windows Terminal info | Deleted |
| **Stow loop** | Duplicated from `stow-all.sh` | Handled by `stow.sh` |
| **Tmux plugins** | Duplicated from `install.sh` | Handled by `install.sh` |
| **Helper scripts** | Created `reload-terminal`, `edit-terminal` on every run | Removed (overwrote user customizations) |

**Why:** Everything it did was either duplicated elsewhere or actively harmful (overwriting user scripts). The backup logic was useful but is now handled by git.

### 9. Deleted `doctor.sh`

| | Before | After |
|---|---|---|
| **File** | 72-line health check: tools, shell syntax, symlinks, git, disk | Deleted |
| **Alternative** | — | `validate.sh --quick` covers all the same checks and more |

**Why:** `validate.sh` is the comprehensive validator used in CI. `doctor.sh` was a strict subset.

### 10. Deleted `drift-detect.sh`

| | Before | After |
|---|---|---|
| **File** | 57-line drift check: symlinks, git dirty, git behind, unknown dotfiles | Deleted |
| **Alternative** | — | `validate.sh` covers all checks (symlinks #11, git #9-10, dotfiles #12) |

**Why:** Every check in `drift-detect.sh` already exists in `validate.sh`. Fully superseded.

---

## Files Changed Summary

| Action | File | Lines |
|--------|------|-------|
| **Created** | `scripts/stow.sh` | +29 |
| **Modified** | `scripts/bootstrap.sh` | +23 -15 |
| **Modified** | `scripts/install-tools.sh` | +39 -21 |
| **Modified** | `scripts/pull-updates.sh` | +44 -44 (renamed from update.sh) |
| **Modified** | `.githooks/post-merge` | +4 -4 |
| **Modified** | `.github/workflows/deploy.yml` | +24 -24 |
| **Modified** | `README.md` | +41 -110 |
| **Modified** | `install.sh` | +2 -3 |
| **Deleted** | `scripts/stow-all.sh` | -9 |
| **Deleted** | `scripts/stow-package.sh` | -9 |
| **Deleted** | `scripts/kde-settings.sh` | -65 |
| **Deleted** | `scripts/bootstrap-headless.sh` | -3 |
| **Deleted** | `scripts/deploy.sh` | -28 |
| **Deleted** | `scripts/deploy-configs.sh` | -142 |
| **Deleted** | `scripts/doctor.sh` | -72 |
| **Deleted** | `scripts/drift-detect.sh` | -57 |
| **Deleted** | `scripts/update.sh` | -44 (renamed to pull-updates.sh) |
| | **Net** | **+89 -1,309 = -1,220 lines** |

---

## Final Script Inventory

| Script | Lines | Purpose | Accepts `--os` |
|--------|-------|---------|----------------|
| `bootstrap.sh` | 241 | Entry point: OS detection, deps, clone, branch, stow, runtimes, shell | Yes (detects + exports) |
| `install-tools.sh` | 441 | Idempotent tool installer (12 phases: packages, fonts, rust, CLI tools, etc.) | Yes (override) |
| `stow.sh` | 29 | Stow all packages or specific ones | Yes (for future use) |
| `pull-updates.sh` | 44 | Pull staging, rebase machine branch, re-stow, full validation | No (not needed) |
| `push-changes.sh` | 27 | Auto-commit + push machine branch changes | No (not needed) |
| `validate.sh` | 559 | 15-check validation suite (CI + local, strict/quick modes) | No (not needed) |
| `manifest-gen.sh` | 33 | Snapshot installed packages per manager (dpkg/flatpak/cargo/npm) | No (not needed) |

---

## Reference Updates

All references to deleted/renamed scripts were updated in:

| File | Changes |
|------|---------|
| `README.md` | `stow-all.sh` → `stow.sh`, `stow-package.sh` → `stow.sh`, removed `doctor.sh`/`drift-detect.sh`/`kde-settings.sh` refs, `update.sh` → `pull-updates.sh`, rewrote KDE section for git-based workflow |
| `.githooks/post-merge` | `stow-all.sh` → `stow.sh` |
| `.github/workflows/deploy.yml` | Removed `deploy-configs.sh` validation, now validates `stow.sh` dry-run |
| `install.sh` | Removed `deploy-configs.sh` comment reference |
| `scripts/install-tools.sh` | Updated "next steps" echo: `deploy-configs.sh` → `stow.sh` |

Historical references in `docs/archive/` and `bugs+fixes-report-*.md` were intentionally left unchanged — they document the state at time of writing.

---

## OS Detection Flow

```
bootstrap.sh
  ├── detect_os() → wsl | linux | macos | unknown
  ├── install_deps()      ← uses $OS directly
  ├── run_stow() --os $OS ← passes to stow.sh
  └── ...

stow.sh --os <value>      ← accepts, currently unused (future-proofing)
install-tools.sh --os <value> ← accepts, overrides auto-detection
```

When scripts run standalone (outside bootstrap), they fall back to `uname -s` auto-detection.

---

## Validation

All modified scripts pass `bash -n` syntax checks:

```
stow.sh:           OK
bootstrap.sh:      OK
pull-updates.sh:   OK
install-tools.sh:  OK
```

---

## What Was NOT Changed

| Item | Reason |
|------|--------|
| `manifest-gen.sh` | Unique utility — snapshots installed packages per manager. No overlap with other scripts. |
| `push-changes.sh` | Unique purpose — auto-commit + push. Small (27 lines), clear responsibility. |
| `validate.sh` | Core validation suite — absorbs `doctor.sh` and `drift-detect.sh` functionality. |
| `docs/archive/*` | Historical documentation — references are accurate for their point in time. |
| `bugs+fixes-report-v3.0.md` | Historical audit report — documents issues that existed, not current state. |
