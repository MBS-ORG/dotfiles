#!/usr/bin/env bash
# validate.sh — cross-branch repository health check
# Validates shell syntax, package integrity, stowability, config formats, and drift.
set -euo pipefail

# ── Config ──────────────────────────────────────────────────────────────
VERBOSE=false
STRICT=false
QUICK=false
CI_MODE=false
ERRORS=0
WARNINGS=0
SKIPPED=0

# Auto-detect CI
[[ -n "${CI:-}" ]] && CI_MODE=true

# ── Logging ─────────────────────────────────────────────────────────────
if $CI_MODE; then
  PASS()  { echo "  [PASS] $*"; }
  FAIL()  { echo "  [FAIL] $*"; ((ERRORS++)) || true; }
  WARN()  { echo "  [WARN] $*"; ((WARNINGS++)) || true; }
  SKIP()  { echo "  [SKIP] $*"; ((SKIPPED++)) || true; }
  INFO()  { echo "  [INFO] $*"; }
  HEADER(){ echo; echo "── $* ──"; }
  GRP_START() { echo "::group::Dotfiles Validation — ${1:-}"; }
  GRP_END()   { echo "::endgroup::"; }
else
  PASS()  { echo "  [PASS] $*"; }
  FAIL()  { echo "  [FAIL] $*"; ((ERRORS++)) || true; }
  WARN()  { echo "  [WARN] $*"; ((WARNINGS++)) || true; }
  SKIP()  { echo "  [SKIP] $*"; ((SKIPPED++)) || true; }
  INFO()  { echo "  [INFO] $*"; }
  HEADER(){ echo; echo "── $* ──"; }
  GRP_START() { :; }
  GRP_END()   { :; }
fi

# ── Help ────────────────────────────────────────────────────────────────
usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Validate all dotfiles across shell syntax, package integrity, stowability,
tool availability, symlinks, and git health.  Intended to be run from any
branch — the same checks used in CI.

Options:
  --help       Show this help
  --verbose    Show all output including passed checks
  --strict     Treat warnings as failures
  --quick      Skip slow checks (shellcheck, docker, config parse)
  --ci         CI mode (auto-detected via \$CI).  Installs missing system
               packages (shellcheck) and skips machine-local checks
               (symlinks, managed dotfiles, desktop tools).
EOF
  exit 0
}

# ── Args ────────────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --help)    usage ;;
    --verbose) VERBOSE=true ;;
    --strict)  STRICT=true ;;
    --quick)   QUICK=true ;;
    --ci)      CI_MODE=true ;;
    *)         echo "Unknown option: $1"; usage ;;
  esac
  shift
done

# ── Helpers ─────────────────────────────────────────────────────────────
cd "$(dirname "$0")/.."
REPO_ROOT="$(pwd)"

ci_install() {
  $CI_MODE || return 0
  local pkg=$1
  if ! command -v "$pkg" &>/dev/null; then
    if command -v apt-get &>/dev/null; then
      INFO "CI: installing $pkg..."
      sudo apt-get install -y --no-install-recommends "$pkg" &>/dev/null || WARN "Could not install $pkg (continuing)"
    elif command -v brew &>/dev/null; then
      INFO "CI: installing $pkg..."
      brew install "$pkg" &>/dev/null || WARN "Could not install $pkg (continuing)"
    fi
  fi
}

# ── CI bootstrap ────────────────────────────────────────────────────────
if $CI_MODE; then
  ci_install shellcheck
  echo "══ CI mode: machine-local checks (symlinks, managed dotfiles) will be skipped ══"
fi

GRP_START "$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo '(detached)')"
echo "═══════════════════════════════════════════════════════════════"
echo "  Dotfiles Validation — $(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo '(detached)')"
echo "═══════════════════════════════════════════════════════════════"

# ═══════════════════════════════════════════════════════════════════════
# 1. Shell Syntax
# ═══════════════════════════════════════════════════════════════════════
HEADER "1. Shell Syntax"

if command -v zsh &>/dev/null; then
  syntax_errors=0
  while IFS= read -r f; do
    rel="${f#"$REPO_ROOT"/}"
    if zsh -n "$f" 2>/dev/null; then
      $VERBOSE && PASS "zsh: $rel"
    else
      FAIL "zsh syntax error: $rel"
      ((syntax_errors++)) || true
    fi
  done < <(find packages/zsh -name '*.zsh' -o -name '.zshrc' -o -name '.zshenv' 2>/dev/null)
  [[ $syntax_errors -eq 0 ]] && PASS "zsh syntax: all files valid"
else
  SKIP "zsh not installed"
fi

if command -v bash &>/dev/null; then
  syntax_errors=0
  while IFS= read -r f; do
    rel="${f#"$REPO_ROOT"/}"
    if bash -n "$f" 2>/dev/null; then
      $VERBOSE && PASS "bash: $rel"
    else
      FAIL "bash syntax error: $rel"
      ((syntax_errors++)) || true
    fi
  done < <(find packages/bash -name '.bashrc' -o -name '.profile' 2>/dev/null; find scripts/ -name '*.sh')
  [[ $syntax_errors -eq 0 ]] && PASS "bash syntax: all files valid"
else
  SKIP "bash not installed"
fi

# ═══════════════════════════════════════════════════════════════════════
# 2. ShellCheck
# ═══════════════════════════════════════════════════════════════════════
HEADER "2. ShellCheck"

if $QUICK; then
  SKIP "ShellCheck (--quick mode)"
elif command -v shellcheck &>/dev/null; then
  sc_errors=0
  while IFS= read -r f; do
    rel="${f#"$REPO_ROOT"/}"
    if shellcheck "$f"; then
      $VERBOSE && PASS "shellcheck: $rel"
    else
      FAIL "shellcheck: $rel"
      ((sc_errors++)) || true
    fi
  done < <(find scripts/ -name '*.sh'; find .githooks -type f)
  [[ $sc_errors -eq 0 ]] && PASS "ShellCheck: all scripts pass"
else
  SKIP "shellcheck not installed"
fi

# ═══════════════════════════════════════════════════════════════════════
# 3. Package Integrity
# ═══════════════════════════════════════════════════════════════════════
HEADER "3. Package Integrity"

pkg_errors=0
for pkg in packages/*/; do
  name=$(basename "$pkg")
  count=$(find "$pkg" -type f | wc -l)
  if [[ $count -gt 0 ]]; then
    $VERBOSE && PASS "  $name: $count file(s)"
  else
    FAIL "Package '$name' is empty"
    ((pkg_errors++)) || true
  fi
done
[[ $pkg_errors -eq 0 ]] && PASS "All $(ls -d packages/*/ 2>/dev/null | wc -l) packages contain files"

# ═══════════════════════════════════════════════════════════════════════
# 4. Stow Dry-Run
# ═══════════════════════════════════════════════════════════════════════
HEADER "4. Stow Dry-Run"

if command -v stow &>/dev/null; then
  stow_errors=0
  stow_tmp=$(mktemp -d)
  for pkg in packages/*/; do
    name=$(basename "$pkg")
    if stow --simulate --target="$stow_tmp" --dir=packages "$name" 2>/dev/null; then
      $VERBOSE && PASS "stow: $name"
    else
      FAIL "stow dry-run failed: $name"
      ((stow_errors++)) || true
    fi
  done
  rm -rf "$stow_tmp"
  [[ $stow_errors -eq 0 ]] && PASS "All packages stowable"
else
  SKIP "stow not installed"
fi

# ═══════════════════════════════════════════════════════════════════════
# 5. Required Tools
# ═══════════════════════════════════════════════════════════════════════
HEADER "5. Required Tools"

missing=0
for tool in zsh bash git stow tmux rg curl; do
  if command -v "$tool" &>/dev/null; then
    $VERBOSE && PASS "$tool: $(command -v "$tool")"
  else
    FAIL "Required tool not found: $tool"
    ((missing++)) || true
  fi
done
[[ $missing -eq 0 ]] && PASS "All required tools present"

# Optional tools — warn only (skip entirely in CI)
if ! $CI_MODE; then
  for tool in starship eza zoxide delta; do
    if command -v "$tool" &>/dev/null; then
      $VERBOSE && PASS "$tool: $(command -v "$tool")"
    else
      WARN "Optional tool not found: $tool"
    fi
  done
fi

# ═══════════════════════════════════════════════════════════════════════
# 6. Git Hooks Syntax
# ═══════════════════════════════════════════════════════════════════════
HEADER "6. Git Hooks"

if [[ -d .githooks ]]; then
  hook_errors=0
  while IFS= read -r f; do
    rel="${f#"$REPO_ROOT"/}"
    if bash -n "$f" 2>/dev/null; then
      $VERBOSE && PASS "hook: $rel"
    else
      FAIL "Hook syntax error: $rel"
      ((hook_errors++)) || true
    fi
  done < <(find .githooks -type f)
  [[ $hook_errors -eq 0 ]] && PASS "All git hooks valid"
else
  SKIP "No .githooks directory"
fi

# ═══════════════════════════════════════════════════════════════════════
# 7. Dockerfile
# ═══════════════════════════════════════════════════════════════════════
HEADER "7. Dockerfile"

if $QUICK; then
  SKIP "Dockerfile check (--quick mode)"
elif [[ -f Dockerfile ]]; then
  if command -v docker &>/dev/null; then
    if docker build -t dotfiles-validate-test --quiet . &>/dev/null; then
      PASS "Dockerfile: build succeeds"
    else
      FAIL "Dockerfile: build failed"
    fi
  else
    if head -1 Dockerfile | grep -q '^FROM'; then
      PASS "Dockerfile: syntax looks valid"
    else
      FAIL "Dockerfile: invalid format"
    fi
    WARN "docker not installed — using basic check only"
  fi
else
  SKIP "No Dockerfile in repo root"
fi

# ═══════════════════════════════════════════════════════════════════════
# 8. Config File Parsing (JSON / TOML / YAML)
# ═══════════════════════════════════════════════════════════════════════
HEADER "8. Config File Format Validation"

if $QUICK; then
  SKIP "Config format validation (--quick mode)"
else
  config_errors=0

  # JSON
  if command -v python3 &>/dev/null; then
    while IFS= read -r f; do
      rel="${f#"$REPO_ROOT"/}"
      if python3 -c "import json; json.load(open('$f'))" 2>/dev/null; then
        $VERBOSE && PASS "json: $rel"
      else
        FAIL "Invalid JSON: $rel"
        ((config_errors++)) || true
      fi
    done < <(find packages/ -name '*.json' 2>/dev/null)
  else
    WARN "python3 not available — skipping JSON validation"
  fi

  # JSONC — strip // comments before parsing (protect URLs like https://)
  if command -v python3 &>/dev/null; then
    while IFS= read -r f; do
      rel="${f#"$REPO_ROOT"/}"
      if python3 -c "
import json, re, sys
with open('$f') as fh:
    raw = fh.read()
# Remove full-line comments and trailing // comments, but keep ://
stripped = re.sub(r'(?<!:)//.*', '', raw)
try:
    json.loads(stripped)
except json.JSONDecodeError:
    sys.exit(1)
" 2>/dev/null; then
        $VERBOSE && PASS "jsonc: $rel"
      else
        FAIL "Invalid JSONC: $rel"
        ((config_errors++)) || true
      fi
    done < <(find packages/ -name '*.jsonc' 2>/dev/null)
  fi

  # TOML (Python 3.11+ has tomllib)
  if command -v python3 &>/dev/null; then
    while IFS= read -r f; do
      rel="${f#"$REPO_ROOT"/}"
      if python3 -c "
import sys
try:
    import tomllib
except ImportError:
    # fallback for <3.11
    try:
        import tomli as tomllib
    except ImportError:
        sys.exit(2)
with open('$f', 'rb') as fh:
    tomllib.load(fh)
" 2>/dev/null; then
        $VERBOSE && PASS "toml: $rel"
      elif [[ $? -eq 2 ]]; then
        break  # no TOML parser available at all
      else
        FAIL "Invalid TOML: $rel"
        ((config_errors++)) || true
      fi
    done < <(find packages/ -name '*.toml' 2>/dev/null)
  fi

  [[ $config_errors -eq 0 ]] && PASS "All config files parse correctly"
fi

# ═══════════════════════════════════════════════════════════════════════
# 9. Git Working Tree (skip in CI)
# ═══════════════════════════════════════════════════════════════════════
HEADER "9. Git Working Tree"

if $CI_MODE; then
  SKIP "Working-tree check (CI always starts clean)"
elif git rev-parse --git-dir &>/dev/null; then
  if git diff --stat --exit-code &>/dev/null; then
    PASS "Working tree: clean"
  else
    WARN "Working tree: dirty"
    $VERBOSE && git diff --stat
  fi

  untracked=$(git ls-files --others --exclude-standard | wc -l)
  if [[ $untracked -gt 0 ]]; then
    WARN "$untracked untracked file(s)"
    $VERBOSE && git ls-files --others --exclude-standard
  else
    $VERBOSE && PASS "No untracked files"
  fi
else
  SKIP "Not a git repository"
fi

# ═══════════════════════════════════════════════════════════════════════
# 10. Git Sync Status (skip in CI)
# ═══════════════════════════════════════════════════════════════════════
HEADER "10. Git Sync Status"

if $CI_MODE; then
  SKIP "Git sync check (CI always starts fresh)"
else
  upstream=$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || true)
  if [[ -n "$upstream" ]]; then
    if git fetch --quiet 2>/dev/null; then
      behind=$(git rev-list --count "HEAD..@{u}" 2>/dev/null || echo "0")
      if [[ "$behind" -gt 0 ]]; then
        WARN "Branch is BEHIND remote by $behind commit(s)"
      else
        PASS "Branch is synced with remote ($upstream)"
      fi
    else
      WARN "Could not fetch from remote"
    fi
  else
    SKIP "No upstream tracking branch"
  fi
fi

# ═══════════════════════════════════════════════════════════════════════
# 11. Symlink Integrity (skip in CI)
# ═══════════════════════════════════════════════════════════════════════
HEADER "11. Symlink Integrity"

if $CI_MODE; then
  SKIP "Symlink check (CI has no \$HOME stow targets)"
else
  broken=0
  while IFS= read -r link; do
    if [[ ! -e "$link" ]]; then
      WARN "Broken symlink: $link"
      ((broken++)) || true
    fi
  done < <(find "${HOME}" -maxdepth 4 -type l -xtype l 2>/dev/null | head -50)
  [[ $broken -eq 0 ]] && PASS "All symlinks intact"
fi

# ═══════════════════════════════════════════════════════════════════════
# 12. Managed Dotfiles (skip in CI)
# ═══════════════════════════════════════════════════════════════════════
HEADER "12. Managed Dotfiles"

if $CI_MODE; then
  SKIP "Managed dotfiles check (CI has no \$HOME stow targets)"
else
  declare -a managed_dotfiles=(
    ".bashrc" ".profile" ".bash_logout"
    ".zshrc" ".zshenv"
    ".tmux.conf"
    ".gitconfig"
    ".ripgreprc"
    ".pam_environment"
  )

  unknown=0
  for df in "${managed_dotfiles[@]}"; do
    path="${HOME}/${df}"
    if [[ -f "$path" && ! -L "$path" ]]; then
      WARN "Not a symlink: $path (should be stow-managed)"
      ((unknown++)) || true
    fi
  done
  [[ $unknown -eq 0 ]] && PASS "All managed dotfiles are symlinks"
fi

# ═══════════════════════════════════════════════════════════════════════
# 13. XDG Compliance (zsh)
# ═══════════════════════════════════════════════════════════════════════
HEADER "13. XDG Base Directory Compliance"

if [[ -d packages/zsh/.config/zsh ]]; then
  if [[ -f packages/zsh/.config/zsh/.zshrc && -f packages/zsh/.config/zsh/.zshenv ]]; then
    PASS "zsh: XDG-compliant (.config/zsh/)"
  else
    WARN "zsh: missing .zshrc or .zshenv in .config/zsh/"
  fi
else
  WARN "zsh: not using .config/zsh/ (expected XDG layout)"
fi

# ═══════════════════════════════════════════════════════════════════════
# 14. .stow-local-ignore Integrity
# ═══════════════════════════════════════════════════════════════════════
HEADER "14. Stow Ignore File"

if [[ -f .stow-local-ignore ]]; then
  lines=$(grep -cv '^\s*$' .stow-local-ignore 2>/dev/null || echo 0)
  if [[ $lines -gt 0 ]]; then
    PASS ".stow-local-ignore: $lines pattern(s)"
  else
    WARN ".stow-local-ignore: empty or comment-only"
  fi
else
  WARN ".stow-local-ignore: missing"
fi

# ═══════════════════════════════════════════════════════════════════════
# 15. Cross-Reference: packages vs README
# ═══════════════════════════════════════════════════════════════════════
HEADER "15. Cross-Reference (packages ↔ README)"

xref_errors=0
if [[ -f README.md ]]; then
  # Collect package directories
  actual_pkgs=()
  while IFS= read -r d; do
    actual_pkgs+=("$(basename "$d")")
  done < <(ls -d packages/*/ 2>/dev/null)

  # Collect packages listed in README structure table
  readme_pkgs=()
  while IFS= read -r line; do
    if [[ "$line" =~ \|\ *([a-zA-Z0-9_-]+)/\ *\| ]]; then
      readme_pkgs+=("${BASH_REMATCH[1]}")
    fi
  done < <(grep '|.*/.*|' README.md 2>/dev/null || true)

  if [[ ${#readme_pkgs[@]} -gt 0 ]]; then
    for pkg in "${actual_pkgs[@]}"; do
      found=false
      for rp in "${readme_pkgs[@]}"; do
        [[ "$pkg" == "$rp" ]] && { found=true; break; }
      done
      if ! $found; then
        WARN "Package '$pkg' exists but is not listed in README"
        ((xref_errors++)) || true
      fi
    done
    for rp in "${readme_pkgs[@]}"; do
      found=false
      for ap in "${actual_pkgs[@]}"; do
        [[ "$rp" == "$ap" ]] && { found=true; break; }
      done
      if ! $found; then
        WARN "README references '$rp' but no matching packages/$rp/ directory"
        ((xref_errors++)) || true
      fi
    done
    [[ $xref_errors -eq 0 ]] && PASS "All packages referenced in README"
  else
    SKIP "Could not parse package list from README"
  fi
else
  SKIP "No README.md in repo root"
fi

# ═══════════════════════════════════════════════════════════════════════
# Summary
# ═══════════════════════════════════════════════════════════════════════
echo
echo "═══════════════════════════════════════════════════════════════"
echo "  Results"
echo "═══════════════════════════════════════════════════════════════"
echo "  Errors:   ${ERRORS}"
echo "  Warnings: ${WARNINGS}"
echo "  Skipped:  ${SKIPPED}"

if $STRICT && [[ $WARNINGS -gt 0 ]]; then
  ((ERRORS += WARNINGS)) || true
fi

if [[ $ERRORS -eq 0 ]]; then
  echo "  Status:   PASS"
  echo "═══════════════════════════════════════════════════════════════"
else
  echo "  Status:   FAIL (${ERRORS} error(s))"
  echo "═══════════════════════════════════════════════════════════════"
fi

GRP_END
exit "$ERRORS"
