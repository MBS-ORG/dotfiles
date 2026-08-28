#!/usr/bin/env bash
# pull-updates.sh — pull latest updates from staging, rebase, re-stow, validate
set -euo pipefail

cd "$(dirname "$0")/.."

HOSTNAME="$(hostname -s | tr '[:upper:]' '[:lower:]')"
MACHINE_BRANCH="machine/${HOSTNAME}"

echo "=== Pull updates ==="

echo "1. Fetching all remotes..."
git fetch --all

echo "2. Rebasing staging..."
if git show-ref --quiet "refs/heads/staging"; then
  git checkout staging
  if git show-ref --verify "refs/remotes/origin/staging" &>/dev/null; then
    git rebase origin/staging
  else
    echo "WARNING: origin/staging not found, skipping rebase"
  fi
elif git show-ref --verify "refs/remotes/origin/staging" &>/dev/null; then
  git checkout -b staging origin/staging
else
  echo "No staging branch found — staying on current branch"
fi

echo "3. Rebasing machine branch on staging..."
if git show-ref --quiet "refs/heads/${MACHINE_BRANCH}"; then
  git checkout "${MACHINE_BRANCH}"
  git rebase staging
else
  git checkout -b "${MACHINE_BRANCH}" staging
  git push -u origin "${MACHINE_BRANCH}"
fi

echo "4. Re-stowing all packages..."
./scripts/stow.sh

echo "5. Running validation..."
./scripts/validate.sh

echo "=== Pull complete ==="
