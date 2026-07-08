#!/usr/bin/env bash
# push-changes.sh — auto-commit and push machine-specific changes
# Intended to be triggered by system events: restart, logout, power profile changes.
set -euo pipefail

cd "$(dirname "$0")/.."
REPO_ROOT="$(pwd)"
HOSTNAME="$(hostname -s | tr '[:upper:]' '[:lower:]')"
MACHINE_BRANCH="machine/${HOSTNAME}"

# Ensure we're on the machine branch
current_branch="$(git rev-parse --abbrev-ref HEAD)"
if [[ "$current_branch" != "$MACHINE_BRANCH" ]]; then
  echo "Not on machine branch ($current_branch != $MACHINE_BRANCH) — skipping auto-push"
  exit 0
fi

# Nothing to commit?
if git diff --quiet && git diff --cached --quiet; then
  echo "Nothing to commit"
  exit 0
fi

TIMESTAMP="$(date '+%Y-%m-%d %H:%M')"
git add -A
git commit -m "auto: ${TIMESTAMP} — ${HOSTNAME} sync"
git push origin "${MACHINE_BRANCH}"
echo "Pushed ${MACHINE_BRANCH} at ${TIMESTAMP}"
