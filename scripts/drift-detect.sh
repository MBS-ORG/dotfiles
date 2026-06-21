#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
errors=0

echo "=== Drift Detection ==="

echo -n "1. Symlink integrity... "
while IFS= read -r link; do
  if [[ ! -e "$link" ]]; then
    echo "BROKEN: $link"
    ((errors++))
  fi
done < <(find "${HOME}" -type l -xtype l 2>/dev/null | head -50)
if [[ $errors -eq 0 ]]; then echo "OK"; else echo "${errors} broken symlink(s)"; fi

echo -n "2. Git working tree... "
if git diff --stat --exit-code &>/dev/null; then
  echo "CLEAN"
else
  echo "DIRTY"
  git diff --stat
  ((errors++))
fi

echo -n "3. Git behind remote... "
if git fetch --quiet 2>/dev/null; then
  local_behind=$(git rev-list --count "HEAD..@{u}" 2>/dev/null || echo "0")
  if [[ "$local_behind" -gt 0 ]]; then
    echo "BEHIND by ${local_behind} commit(s)"
    ((errors++))
  else
    echo "SYNCED"
  fi
else
  echo "SKIPPED (no remote)"
fi

echo -n "4. Unknown dotfiles in HOME... "
unknown=0
while IFS= read -r f; do
  base="$(basename "$f")"
  if [[ "$base" =~ ^\.(config|local|cache|gnupg|ssh|npm|docker|mozilla|vscode) ]]; then
    continue
  fi
  if [[ "$base" =~ ^\.(bashrc|profile|zshrc|zshenv|tmux\.conf|gitconfig|ripgreprc)$ ]]; then
    if [[ ! -L "$f" ]]; then
      echo "NOT SYMLINK: $f"
      ((unknown++))
    fi
  fi
done < <(find "${HOME}" -maxdepth 1 -name '.*' -type f 2>/dev/null)
[[ $unknown -eq 0 ]] && echo "OK" || echo "${unknown} non-symlink dotfile(s)"

echo "=== Done. Errors: ${errors} ==="
exit "$errors"
