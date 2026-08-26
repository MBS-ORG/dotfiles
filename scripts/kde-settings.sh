#!/usr/bin/env bash
set -euo pipefail

warn()  { printf "\033[1;33m[WARN]\033[0m %s\n" "$*"; }

KDE_SRC="${HOME}/.config"
KDE_DST="$(cd "$(dirname "$0")/.." && pwd)/packages/kde/.config"

backup() {
  echo "Backing up KDE settings → packages/kde/.config/"
  for f in kdeglobals plasmarc kwinrc kwinrulesrc kglobalshortcutsrc \
           konsolerc dolphinrc kscreenlockerrc krunnerrc klipperrc \
           spectaclerc systemmonitorrc kcmfonts kxkbrc kcminputrc \
           katerc plasma-localerc plasmakeyboardrc kwalletrc \
           .gtkrc-2.0 gtkrc; do
    if [[ -f "${KDE_SRC}/${f}" ]]; then
      cp "${KDE_SRC}/${f}" "${KDE_DST}/${f}" || warn "Failed to copy ${f}"
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

sync() {
  backup

  local repo_root
  repo_root="$(cd "$(dirname "$0")/.." && pwd)"

  if ! git -C "$repo_root" diff --quiet packages/kde/ 2>/dev/null; then
    echo ""
    echo "Changes detected in KDE config:"
    git -C "$repo_root" diff --stat packages/kde/
    echo ""
    echo "To save: cd $repo_root && git add packages/kde/ && git commit -m 'kde: update config'"
  else
    echo ""
    echo "No changes detected."
  fi
}

case "${1:-}" in
  backup)  backup ;;
  restore) restore ;;
  sync)    sync ;;
  *)
    echo "Usage: $0 {backup|restore|sync}" >&2
    exit 1
    ;;
esac
