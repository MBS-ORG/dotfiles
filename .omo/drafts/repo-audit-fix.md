# Draft: Repo Audit & Fix Plan

## Decisions Made
- Auto-discover packages: YES (change install.sh + deploy-configs.sh to `stow */`)
- Self-update on envs: Via KDE login/logout/battery hooks (not cron, not now)
- Branch protection via gh: PENDING (user deciding)

## Bugs Found

### CRITICAL — CI fails
1. validate.yml:52 — `stow packages/*` — Stow 2.4.0 rejects slashes
2. deploy.yml:19 — `packages/scripts/deploy-configs.sh` — stale path (moved to scripts/)
3. deploy.yml:28 — same stow slash bug

### HIGH — Wrong behavior
4. .gitignore:2-7 — secret patterns need `packages/` prefix (won't match otherwise)
5. agent package — VM 200-specific, shouldn't be deployed elsewhere
6. bin package — .gitkeep only, creates pointless symlink
7. windows-terminal — stowed on Linux, useless

### MEDIUM — Robustness
8. deploy-configs.sh backs up 4/15 packages
9. install-tools.sh — GitHub API rate limits

### LOW — Workflow
10. No MAIN branch protection

## Fix Plan (to be generated)
