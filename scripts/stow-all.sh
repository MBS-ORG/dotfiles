#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
for pkg in packages/*/; do
  name=$(basename "$pkg")
  echo "  stow: $name"
  stow -R --target="$HOME" --dir=packages "$name"
done
echo "All packages stowed."
