#!/usr/bin/env bash
set -euo pipefail

KDE_SRC="${HOME}/.config"
KDE_DST="$(cd "$(dirname "$0")/.." && pwd)/packages/kde/.config"

backup() {
  echo "Backing up KDE settings → packages/kde/.config/"
  for f in kdeglobals plasmarc kwinrc konsolerc dolphinrc \
           kscreenlockerrc krunnerrc klipperrc spectaclerc \
           systemmonitorrc kcmfonts kxkbrc .gtkrc-2.0; do
    if [[ -f "${KDE_SRC}/${f}" ]]; then
      cp "${KDE_SRC}/${f}" "${KDE_DST}/${f}"
      echo "  ${f}"
    fi
  done
  echo "Done."
}

restore() {
  echo "Restoring KDE settings from packages/kde/.config/"
  if [[ ! -d "$KDE_DST" ]]; then
    echo "No KDE config package found." >&2
    exit 1
  fi
  for f in "${KDE_DST}"/*; do
    local name
    name="$(basename "$f")"
    cp "$f" "${KDE_SRC}/${name}"
    echo "  ${name}"
  done
  echo "Done. Restart Plasma: systemctl --user restart plasma-plasmashell"
}

case "${1:-}" in
  backup)  backup ;;
  restore) restore ;;
  *)
    echo "Usage: $0 {backup|restore}" >&2
    exit 1
    ;;
esac
