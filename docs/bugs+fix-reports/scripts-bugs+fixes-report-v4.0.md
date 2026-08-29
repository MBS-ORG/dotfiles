# Bugs + Fixes Report — Dotfiles Scripts (Consolidated Suite)

**Generated:** 2026-08-27
**Validated:** 2026-08-27
**Repository:** `/home/mbs/dev/dotfiles`
**Scope:** The 7 scripts in `scripts/` post-consolidation, plus `install.sh`, `.githooks/post-merge`, and `.github/workflows/deploy.yml`
**Validation:** All issues confirmed against current source. Fixes shown were syntax/behavior spot-checked where noted.

---

## Summary

| Severity | Count | Fixed | Skipped | Failed | Description |
|----------|-------|-------|---------|--------|-------------|
| **CRITICAL** | 0 | 0 | 0 | 0 | System-breaking / security / data-loss |
| **HIGH** | 3 | 3 | 0 | 0 | Broken functionality (`set -e` aborts, download URL fragility) |
| **MEDIUM** | 4 | 4 | 0 | 0 | Reliability, dead code, inconsistency |
| **LOW** | 2 | 2 | 0 | 0 | Redundant logic, minor robustness |
| **SECURITY** | 2 | 1 | 1 | 0 | Documented supply-chain patterns (flag-only) |
| **Total** | 11 | 10 | 1 | 0 | |

---

## High Issues

### 1. `verify()` aborts on first missing tool due to bare `((errors++))` under `set -e`

**File:** `scripts/bootstrap.sh:188-198`

```bash
  if command -v zsh &>/dev/null; then info "  zsh:     OK"; else warn "  zsh:     MISSING"; ((errors++)); fi
```

**Description:** The script sets `set -euo pipefail` (`bootstrap.sh:2`). Inside `verify()`, each tool check uses a bare `((errors++))`. The post-increment expression evaluates to the *old* counter value (0 on the first missing tool), which is a falsy arithmetic result → exit status 1 → `set -e` terminates the script immediately. This stops verification after reporting only the FIRST missing tool instead of all of them, and reports the run as failed even though prior install steps succeeded.

**Impact:** With a single missing tool, `verify()` aborts mid-run; the "Symlinks" check (`bootstrap.sh:200-208`) and the final pass/fail summary are never reached. The user gets an incomplete diagnostic — the opposite of what a verification step should provide.

**Fix:**
- `scripts/bootstrap.sh:188-198` — append `|| true` to every counter increment (or use `$((errors+=1))`):
  ```bash
  if command -v zsh &>/dev/null; then info "  zsh:     OK"; else warn "  zsh:     MISSING"; ((errors++)) || true; fi
  ```

**Status:** ✅ Applied

---

### 2. `((broken_symlinks++))` aborts on first broken symlink due to `set -e`

**File:** `scripts/bootstrap.sh:205`

```bash
      warn "  Broken symlink: $link"
      ((broken_symlinks++))
```

**Description:** Same class of bug as issue 1. The broken-symlink scan (`bootstrap.sh:202-207`) is wrapped in a `while IFS= read` loop whose body runs `((broken_symlinks++))`. When the counter is 0 and the first broken symlink is found, the post-increment returns non-zero and `set -e` aborts the loop (and the script). Verified: feeding a nonexistent path into this loop with `set -euo pipefail` exits with `rc=1`.

**Impact:** The symlink integrity report is truncated at the first broken link; subsequent symlinks and the final summary never print.

**Fix:**
- `scripts/bootstrap.sh:205` — guard the increment:
  ```bash
  ((broken_symlinks++)) || true
  ```

**Status:** ✅ Applied

---

### 3. Lazygit version extraction can produce a malformed URL; hardcoded `x86_64` ignores `$ARCH`

**File:** `scripts/install-tools.sh:314-316`

```bash
    lg_ver="$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest \
      | grep '"tag_name":' | sed 's/.*"v\([^"]*\)".*/\1/')"
    lg_url="https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${lg_ver}_Linux_x86_64.tar.gz"
```

**Description:** Two weaknesses:
1. `lg_ver` is parsed from the GitHub API JSON with `grep/sed`. If the request fails, is rate-limited, or the regex doesn't match, `lg_ver` becomes empty and `lg_url` is built as `.../lazygit__Linux_x86_64.tar.gz` — a broken URL. The subsequent `curl -fsSL "$lg_url"` fails, and because it runs under `set -e` (no `|| true`), the whole script aborts at the lazygit phase.
2. The arch is hardcoded `Linux_x86_64` even though `$ARCH="$(uname -m)"` is already captured at `install-tools.sh:40`. On an ARM host, this downloads a wrong or nonexistent binary.

**Impact:** Lazygit installation fails (and aborts the entire script) on any API hiccup or on non-x86_64 architectures.

**Fix:**
- `scripts/install-tools.sh:314-331` — use `jq` (already installed in Phase 1) and the detected arch, guard empty version / unsupported arch / download failure (no `continue` — not in a loop scope):
  ```bash
    lg_ver="$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest \
      | jq -r '.tag_name' 2>/dev/null | sed 's/^v//')"
    if [[ -z "$lg_ver" ]]; then
      print_warn "Could not determine lazygit version — skipping"
    else
      case "$ARCH" in
        x86_64|amd64)   lg_arch="x86_64" ;;
        aarch64|arm64)  lg_arch="arm64" ;;
        *) print_warn "Unsupported arch for lazygit: $ARCH — skipping"; lg_arch="" ;;
      esac
      if [[ -n "$lg_arch" ]]; then
        lg_url="https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${lg_ver}_Linux_${lg_arch}.tar.gz"
        if curl -fsSL "$lg_url" -o /tmp/lazygit.tar.gz; then
          CLEANUP_FILES+=("/tmp/lazygit.tar.gz")
          tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
          sudo install /tmp/lazygit /usr/local/bin/
          rm -f /tmp/lazygit /tmp/lazygit.tar.gz
          print_ok "lazygit ${lg_ver} installed"
        else
          print_warn "lazygit download failed — skipping"
        fi
      fi
    fi
  ```

**Status:** ✅ Applied

---

## Medium Issues

### 4. `install_deps()` re-detects OS instead of using the centralized `$OS`

**File:** `scripts/bootstrap.sh:71-72`

```bash
install_deps() {
  local os
  os="$(detect_os)"
```

**Description:** `main()` computes `OS="$(detect_os)"` at `bootstrap.sh:224` and declares bootstrap as the "single authority" for OS detection (per the consolidation report), but `install_deps()` independently re-runs `detect_os()` into a local. The two calls could diverge or the centralized value could be refined and not propagate.

**Impact:** Duplicated detection logic; inconsistent with the stated architecture where `bootstrap.sh` is the single OS authority. Low functional risk today but a maintenance/consistency concern and drift risk.

**Fix:**
- `scripts/bootstrap.sh:71-72` — reuse the module-level `$OS` when set (falls back to auto-detection for standalone runs):
  ```bash
  install_deps() {
    local os="${OS:-$(detect_os)}"
    info "Detected OS: ${os}"
  ```
  and remove the separate `local os` / `os="$(detect_os)"` lines.

**Status:** ✅ Applied

---

### 5. `stow.sh --os` is parsed but never used (dead parameter)

**File:** `scripts/stow.sh:5-11`

```bash
OS=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --os) OS="$2"; shift 2 ;;
    *)    break ;;
  esac
done
```

**Description:** `bootstrap.sh` explicitly passes `--os "$OS"` to `stow.sh` (`bootstrap.sh:231`, via `run_stow`), but `stow.sh` stores the value in `$OS` and never reads it anywhere in the stow logic. The parameter has zero effect on behavior.

**Impact:** Misleading interface — a caller passing `--os` expects OS-specific behavior that does not exist. Silent no-op invites future bugs (a future edit might assume `$OS` already drives behavior).

**Fix (decision required):** Either remove the parameter entirely, or make it consume a value before generic parsing so positional package args still work:
- `scripts/stow.sh:5-11` — to remove:
  ```bash
  # (delete the OS parsing block entirely)
  ```
- Or, if it must exist, add a guard/warning so it isn't silently ignored:
  ```bash
    --os) OS="$2"; shift 2 ;;
  ```
  plus after parsing: `[[ -z "$OS" ]] || echo "  info: --os '$OS' accepted (OS-specific stow not yet implemented)" >&2`

**Status:** ✅ Applied (option 2 — keep parameter with informational warning; bootstrap passes `--os "$OS"` so removing it would break delegation)

---

### 6. Background sudo keep-alive loop is never cleanly terminated

**File:** `scripts/install-tools.sh:93`

```bash
  while true; do sudo -n true 2>/dev/null; sleep 60; kill -0 "$$" 2>/dev/null || exit; done &
```

**Description:** `request_sudo()` launches a background loop to refresh the sudo timestamp every 60s. The loop's exit condition is `kill -0 "$$"` — but in the background subshell, `$$` still refers to the *parent* shell PID (bash does not re-assign `$$` in subshells). The loop only exits once the parent shell dies *and* the PID is released/reused; there is no explicit kill of the background job when the script finishes normally.

**Impact:** On a normal script completion, a detached background job may linger for up to PID-reuse time, periodically spawning `sudo -n true` — an orphaned process / resource leak window.

**Fix:**
- `scripts/install-tools.sh:27`/`93` — capture the job and kill it in `cleanup`:
  ```bash
  # at top:  SUDO_KEEPER_PID=""
  # after starting:
  while true; do sudo -n true 2>/dev/null; sleep 60; kill -0 "$$" 2>/dev/null || break; done &
  SUDO_KEEPER_PID=$!
  # in cleanup():
  [[ -n "${SUDO_KEEPER_PID:-}" ]] && kill "$SUDO_KEEPER_PID" 2>/dev/null || true
  ```

**Status:** ✅ Applied (also changed loop exit `|| exit` → `|| break` to avoid exiting the subshell)

---

### 7. `verify()` expects eza/starship only under `--desktop`, but `install-tools.sh` installs them unconditionally

**File:** `scripts/bootstrap.sh:195-198` vs `scripts/install-tools.sh:137`

```bash
  if $DESKTOP; then
    if command -v starship &>/dev/null; then info "  starship: OK"; else warn "  starship: MISSING"; ((errors++)); fi
    if command -v eza &>/dev/null; then info "  eza:      OK"; else warn "  eza:      MISSING"; ((errors++)); fi
  fi
```

**Description:** `bootstrap.sh`'s `verify()` only considers `starship`/`eza` required when `--desktop` is set, but `install-tools.sh` installs both (and zoxide, delta, lazygit, etc.) on every Linux/macOS run regardless of desktop mode. The two scripts disagree about what "expected" tooling is.

**Impact:** A headless user can run the full install (which installs starship/eza) yet `verify()` won't validate them; conversely the expectation model is inconsistent and undocumented.

**Fix:**
- `scripts/bootstrap.sh:195-198` — either always validate the core GUI-agnostic tools, or document that desktop-only validation is intentional:
  ```bash
  # If starship/eza are now installed by default, validate them always:
  if command -v starship &>/dev/null; then info "  starship: OK"; else warn "  starship: MISSING"; ((errors++)) || true; fi
  if command -v eza &>/dev/null; then info "  eza:      OK"; else warn "  eza:      MISSING"; ((errors++)) || true; fi
  ```
  (adjust to `if $DESKTOP` only if the intent is truly desktop-only).

**Status:** ✅ Applied (chose "always validate" — removed the `if $DESKTOP` wrapper since install-tools.sh installs starship/eza unconditionally)

---

## Low Issues

### 8. `CLEANUP_FILES` entry points at an already-deleted temp file

**File:** `scripts/install-tools.sh:165-167` (inside `install_nerd_font`)

```bash
    CLEANUP_FILES+=("$zip_path")
    unzip -q -o "$zip_path" -d "$FONT_DIR" 2>/dev/null
    rm -f "$zip_path"
```

**Description:** The downloaded zip is added to the cleanup list, then immediately removed with `rm -f`. On script exit, `cleanup()` will attempt `rm -f` again on a path that no longer exists — harmless (guarded by `2>/dev/null || true`) but redundant dead bookkeeping.

**Impact:** Purely cosmetic; no functional bug. Cleaning up the leftover entry removes a stale reference.

**Fix:**
- `scripts/install-tools.sh:165` — drop the `CLEANUP_FILES+=` line since the file is removed inline:
  ```bash
    unzip -q -o "$zip_path" -d "$FONT_DIR" 2>/dev/null
    rm -f "$zip_path"
  ```

**Status:** ✅ Applied

---

### 9. `manifest-gen.sh` cargo line filter is fragile

**File:** `scripts/manifest-gen.sh:23`

```bash
  cargo install --list 2>/dev/null | grep '^[a-zA-Z]' | awk '{print $1}' | sort > manifests/cargo.txt
```

**Description:** Filtering on `^[a-zA-Z]` assumes every crate name starts with a letter. Crate names beginning with digits or `_` would be silently dropped from the manifest.

**Impact:** Incomplete cargo manifest snapshot for edge-case crate names.

**Fix:**
- `scripts/manifest-gen.sh:23` — filter out header lines more precisely:
  ```bash
  cargo install --list 2>/dev/null | grep -v '^path:' | grep -v '^[[:space:]]*$' | awk '{print $1}' | sort -u > manifests/cargo.txt
  ```

**Status:** ✅ Applied

---

## Security (flag-only, documented patterns)

### 10. rustup piped from network (`curl | sh`)

**Files:** `scripts/bootstrap.sh:149`, `scripts/install-tools.sh:192`

```bash
  run curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
```

**Description:** Executes a remote script directly into the shell. Both call sites already annotate this as an accepted supply-chain risk. TLS is HTTPS, which mitigates the obvious MITM, but the script content is not reviewed/pinned by hash.

**Impact:** Supply-chain risk if the upstream installer is ever compromised. Documented as intentional; retained in the report for visibility.

**Fix (applied hardening):** download to a temp file, then execute:
- `scripts/install-tools.sh:194-203`:
  ```bash
  tmpfile=$(mktemp)
  CLEANUP_FILES+=("$tmpfile")
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o "$tmpfile"
  sh "$tmpfile" -y
  rm -f "$tmpfile"
  ```
- `scripts/bootstrap.sh:146-151` (uses the `run` wrapper):
  ```bash
  run bash -c 'tmpfile=$(mktemp) && curl --proto '\''=https'\'' --tlsv1.2 -sSf https://sh.rustup.rs -o "$tmpfile" && sh "$tmpfile" -y && rm -f "$tmpfile"'
  ```

**Status:** ✅ Applied (both call sites)

---

### 11. GitHub CLI keyring piped via `sudo dd`

**File:** `scripts/install-tools.sh:340-344`

```bash
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg 2>/dev/null
```

**Description:** Standard Debian third-party-repo pattern (installs an APT signing key from the upstream). HTTPS, pinned vendor URL. No explicit signature verification beyond transport TLS.

**Impact:** Standard, widely-used approach; low additional risk. Noted for completeness.

**Status:** ⏭️ Skipped — standard vendor pattern, no additional risk warranting a change

---

## Recommendations

### Short-Term Fixes (High — fix before relying on `verify()` or lazygit install)
- [ ] Fix issue 1 (`scripts/bootstrap.sh:188-198` — `((errors++)) || true`)
- [ ] Fix issue 2 (`scripts/bootstrap.sh:205` — `((broken_symlinks++)) || true`)
- [ ] Fix issue 3 (`scripts/install-tools.sh:314-321` — jq + `$ARCH` + empty-version guard)

### Medium-Term Improvements (Medium)
- [ ] Reuse central `$OS` in `install_deps()` (issue 4)
- [ ] Decide fate of `stow.sh --os` — remove or gate (issue 5)
- [ ] Kill the sudo keep-alive background job in `cleanup()` (issue 6)
- [ ] Reconcile `verify()` tool expectations with `install-tools.sh` (issue 7)

### Documentation Cleanup / Minor (Low)
- [ ] Remove redundant `CLEANUP_FILES` entry in `install_nerd_font` (issue 8)
- [ ] Make cargo manifest filter robust (issue 9)

### Security Notes
- [ ] Consider pinning/verifying the rustup installer script hash (issue 10)
- [ ] No action required for the gh keyring pattern (issue 11)

---

## Testing Checklist

- [ ] Run `bash -n` on all scripts in `scripts/`
- [ ] Simulate a missing tool and confirm `verify()` now reports all missing tools instead of aborting (issue 1)
- [ ] Create a broken symlink and confirm the scan completes without aborting (issue 2)
- [ ] Unit-test lazygit URL construction with a forced empty `lg_ver` and with `aarch64` arch (issue 3)
- [ ] Confirm `install_deps()` behaves with pre-set `OS` (issue 4)
- [ ] Run `./scripts/stow.sh --os linux <pkg>` and confirm no hidden OS behavior / no regression (issue 5)
- [ ] Run `install-tools.sh` to completion and confirm no orphaned background sudo loop remains (issue 6)
- [ ] Confirm `verify()` and installed-tool expectations match after any change (issue 7)
- [ ] Confirm font install works and no stale `rm` cleanup warnings appear (issue 8)
- [ ] Compare `manifests/cargo.txt` against `cargo install --list` for edge-case crates (issue 9)

---

## Bug-Fix Execution Log

**Date:** 2026-08-27
**Report:** `docs/scripts-bugs+fixes-report.md`
**Files modified:** 4

### Applied Fixes

| # | Issue | Files Modified |
|---|-------|----------------|
| 1 | `verify()` `((errors++))` abort | `scripts/bootstrap.sh` |
| 2 | `((broken_symlinks++))` abort | `scripts/bootstrap.sh` |
| 3 | Lazygit URL/arch fragility | `scripts/install-tools.sh` |
| 4 | `install_deps()` re-detects OS | `scripts/bootstrap.sh` |
| 5 | `stow.sh --os` dead parameter (kept w/ warning) | `scripts/stow.sh` |
| 6 | sudo keep-alive leak | `scripts/install-tools.sh` |
| 7 | `verify()` eza/starship expectation mismatch | `scripts/bootstrap.sh` |
| 8 | Redundant `CLEANUP_FILES` entry | `scripts/install-tools.sh` |
| 9 | Cargo manifest filter fragility | `scripts/manifest-gen.sh` |
| 10 | rustup `curl | sh` hardening | `scripts/bootstrap.sh`, `scripts/install-tools.sh` |

### Skipped

| # | Issue | Reason |
|---|-------|--------|
| 11 | GitHub CLI keyring pattern | Standard vendor pattern, no additional risk |

### Failed

| # | Issue | Error |
|---|-------|-------|
| — | None | |

### Verification

- `bash -n` passes on all modified scripts: `bootstrap.sh`, `install-tools.sh`, `stow.sh`, `manifest-gen.sh`
- `verify()` fix empirically validated: with a missing tool, `((errors++)) || true` yields `rc=0` and reports all missing tools
- `stow.sh --os linux` prints the informational warning and proceeds correctly
- `$OS` is set in `main()` (bootstrap.sh:221) before `install_deps()` (line 225) — confirmed order for issue 4

---

## Verification Results

**Date:** 2026-08-28
**Commits:** `2c0aa49` (consolidation refactor), `49f1068` (bug fixes)
**Validator:** `validate.sh --verbose` + manual per-issue spot-checks + PII scan

### Automated Validation

| Check | Result |
|-------|--------|
| Shell syntax (bash — all scripts, hooks, configs, install.sh) | ✅ All pass |
| Shell syntax (zsh — .zshrc/.zshenv) | ✅ All pass |
| JSON validation | ✅ 5/5 files parse |
| TOML validation | ✅ 2/2 files parse |
| JSONC validation | ✅ 1/1 files parse |
| Package integrity | ✅ All 17 packages contain files |
| Stow dry-run | ✅ All 17 packages stowable |
| Required tools | ✅ All present |
| Git hooks syntax | ✅ All valid |
| Config file formats | ✅ All parse correctly |
| **validate.sh result** | **⚠️ 1 FAIL — Dockerfile build (environmental)** |

The single `validate.sh` failure is `Dockerfile: build failed` — caused by a network/registry error (HTTP 403 pulling `ubuntu:24.04` from Docker Hub), unrelated to any fix. No dotfiles / Dockerfile / config content was modified by this audit.

### Manual Spot-Checks

| Issue | What Was Checked | Result |
|-------|-----------------|--------|
| #1 verify() abort | 8× `((errors++)) || true` present; 0 bare `((errors++))); fi` remain | ✅ |
| #2 broken-symlink abort | `((broken_symlinks++)) || true` present | ✅ |
| #3 lazygit URL/arch | `jq -r '.tag_name'` + `$ARCH`-based `lg_arch`; no `grep '"tag_name":'` remains | ✅ |
| #4 install_deps re-detect | `local os="${OS:-$(detect_os)}"` present | ✅ |
| #5 stow.sh --os dead param | informational warning line present; `--os linux` run emits warning + stows | ✅ |
| #6 sudo keep-alive leak | `SUDO_KEEPER_PID` set at `$!` and killed in `cleanup()`; loop uses `break` | ✅ |
| #7 verify eza/starship | always-validate (no `if $DESKTOP` wrapper) | ✅ |
| #8 redundant CLEANUP | inline `unzip`/`rm` without `CLEANUP_FILES+=` | ✅ |
| #9 cargo filter | `grep -v '^path:'` robust filter present | ✅ |
| #10 rustup hardening | both call sites download-to-tmpfile-then-execute | ✅ |

### Doctor Check

⏭️ `doctor.sh` does not exist — removed as part of the script consolidation (superseded by `validate.sh`).

### PII/Secrets Scan

```
git diff --cached | grep -inE 'password|secret|api.?key|token|credential|PRIVATE|gmail|hotmail|@.*\.(com|org|net)'
```
Result: **CLEAN** — matches only the repo's own clone URL (`git@github.com:Sabir-test/dotfiles.git` in README/install.sh) and a doc note about intentionally gitignoring secrets. No credentials, tokens, keys, or emails leaked.


