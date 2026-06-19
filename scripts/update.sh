#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "=== Update ==="

echo "1. Pulling latest..."
git pull --rebase

echo "2. Re-stowing all packages..."
./scripts/stow-all.sh

echo "3. Running drift detection..."
./scripts/drift-detect.sh

echo "=== Update complete ==="
