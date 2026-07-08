#!/usr/bin/env bash
# pull-updates.sh — pull latest updates from staging and re-stow
# Intended to run at shell startup (or first shell of the day).
set -euo pipefail

cd "$(dirname "$0")/.."
REPO_ROOT="$(pwd)"
HOSTNAME="$(hostname -s | tr '[:upper:]' '[:lower:]')"
MACHINE_BRANCH="machine/${HOSTNAME}"

TIMESTAMP="$(date '+%Y-%m-%d %H:%M')"

echo "=== Pull updates ($TIMESTAMP) ==="

# Stash any local changes before switching branches
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "Stashing local changes..."
  git stash push -m "auto-stash before pull ${TIMESTAMP}"
  stashed=true
else
  stashed=false
fi

# Update staging branch
git fetch origin staging
git checkout staging
git pull --rebase origin staging
echo "staging updated to $(git rev-parse --short HEAD)"

# Rebase machine branch on staging
if git show-ref --quiet "refs/heads/${MACHINE_BRANCH}"; then
  git checkout "${MACHINE_BRANCH}"
  git rebase staging
  echo "${MACHINE_BRANCH} rebased on staging"
else
  git checkout -b "${MACHINE_BRANCH}" staging
  git push -u origin "${MACHINE_BRANCH}"
  echo "${MACHINE_BRANCH} created from staging"
fi

# Return to machine branch
git checkout "${MACHINE_BRANCH}"

# Re-stow
echo "Re-stowing packages..."
"${REPO_ROOT}/scripts/stow-all.sh" 2>/dev/null || echo "Warning: stow-all.sh not found, skipping"

# Pop stash if any
if [[ "$stashed" == true ]]; then
  git stash pop 2>/dev/null || echo "Note: stash pop had conflicts — resolve manually"
fi

echo "=== Pull complete ==="
