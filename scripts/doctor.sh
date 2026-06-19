#!/usr/bin/env bash
set -euo pipefail

info()  { printf "\033[1;34m[INFO]\033[0m  %s\n" "$*"; }
warn()  { printf "\033[1;33m[WARN]\033[0m  %s\n" "$*"; }
error() { printf "\033[1;31m[ERROR]\033[0m %s\n" "$*" >&2; }

cd "$(dirname "$0")/.."
errors=0

echo "═══════════════════════════════════════════════════"
info "Dotfiles Doctor"
echo "═══════════════════════════════════════════════════"

echo ""
echo "── Tools ──────────────────────────────────────────"
for tool in zsh bash git stow tmux rg curl starship eza zoxide delta; do
  if command -v "$tool" &>/dev/null; then
    info "  ${tool}: $(command -v "$tool")"
  else
    warn "  ${tool}: not found"
    ((errors++))
  fi
done

echo ""
echo "── Shell Syntax ───────────────────────────────────"
if command -v zsh &>/dev/null; then
  while IFS= read -r f; do
    rel="${f#"$(pwd)"/}"
    if zsh -n "$f"; then info "  zsh: OK $rel"; else error "  zsh: FAIL $f"; ((errors++)); fi
  done < <(find packages/zsh -name '*.zsh' -o -name '.zshrc' -o -name '.zshenv' 2>/dev/null)
fi
if command -v bash &>/dev/null; then
  while IFS= read -r f; do
    rel="${f#"$(pwd)"/}"
    if bash -n "$f"; then info "  bash: OK $rel"; else error "  bash: FAIL $f"; ((errors++)); fi
  done < <(find packages/bash -name '.bashrc' -o -name '.profile' 2>/dev/null)
fi

echo ""
echo "── Symlinks ───────────────────────────────────────"
broken=0
while IFS= read -r link; do
  if [[ ! -e "$link" ]]; then
    warn "  Broken: ${link}"
    ((broken++))
  fi
done < <(find "${HOME}" -maxdepth 3 -type l -xtype l 2>/dev/null | head -30)
if [[ $broken -eq 0 ]]; then info "  All symlinks OK"; else warn "  ${broken} broken symlink(s)"; fi

echo ""
echo "── Git Status ─────────────────────────────────────"
if git diff --stat --exit-code &>/dev/null; then
  info "  Working tree: clean"
else
  warn "  Working tree: dirty"
  ((errors++))
fi

echo ""
echo "── Disk Space ─────────────────────────────────────"
df -h / | awk 'NR==2 {printf "  %s free of %s (%s used)\n", $4, $2, $5}'

echo ""
echo "═══════════════════════════════════════════════════"
if [[ $errors -eq 0 ]]; then
  info "All checks passed!"
else
  warn "${errors} issue(s) found"
fi
exit "$errors"
