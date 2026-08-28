#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

OS=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --os) OS="$2"; shift 2 ;;
    *)    break ;;
  esac
done
if [[ -n "$OS" ]]; then
  echo "  info: --os '$OS' accepted (OS-specific stow not yet implemented)" >&2
fi

if [[ $# -eq 0 ]]; then
  for pkg in packages/*/; do
    name=$(basename "$pkg")
    echo "  stow: $name"
    stow -R --target="$HOME" --dir=packages "$name"
  done
  echo "All packages stowed."
else
  for name in "$@"; do
    if [[ ! -d "packages/$name" ]]; then
      echo "Error: package '$name' not found" >&2
      exit 1
    fi
    echo "  stow: $name"
    stow -R --target="$HOME" --dir=packages "$name"
  done
fi
