# AGENT.md — Dotfiles Repo Agent Guide

This file orients any AI agent (or human moving fast) working in `MBS-ORG/dotfiles`. It does not replace `README.md` — it tells you which doc to trust for which question, and states the guardrails that don't live comfortably in either.

**Last verified against:** commit `d44162a` on `main`.

---

## 1. What this repo is

A Stow-managed, declarative dotfiles repo covering Linux (native + WSL), with Windows support in progress. It consolidates 3 legacy repos into one Stow-managed codebase. It is **not yet** the "cross-platform configuration reconciliation engine" described in the architecture docs — that's the accepted target, not the current implementation. Don't write code as if `dotctl`, host manifests, or a reconciler already exist; they don't yet (see §5).

---

## 2. Which document answers your question

| You're asking... | Read this |
|---|---|
| "How do I run/build/validate this today?" | `README.md` + this file |
| "What does the target architecture look like, and why?" | `docs/src/Dotfiles GitOps Architecture — Source of Truth` |
| "What's the rollout plan / what's shipped vs. not?" | `docs/src/PRD` |
| "How did we get to this design?" | `docs/src/Architecture-Proposal` → `Architecture-Proposal-Audit` → `Architecture-Proposal-Audit-Evaluations_beta` → `Architecture-Proposal-Audit-Evaluations_validation` (read in that order; it's a real design conversation, not duplicate content) |

**Treat `docs/src/*` as a historical record — don't edit those files to "fix" them.** If something in there turns out to be wrong or superseded, say so in the Source of Truth doc or this file, not by rewriting history.

**When README and the Source of Truth doc disagree** (there is one live example — see §6), current README behavior wins for anything you're about to *execute*, and the Source of Truth doc wins for anything you're about to *design*. Flag the conflict to the user rather than silently picking one.

---

## 3. Repository map (verified, not aspirational)

```
dotfiles/
├── packages/          # Stow packages — each mirrors $HOME exactly
│   ├── zsh/ bash/ fish/ git/ tmux/ starship/ ripgrep/ yazi/
│   ├── gh/ vscode/ cursor/ kde/ windows-terminal/ pam/ bin/
│   └── agent/         # → ~/.config/agent/AGENT_VM.md — AI governance for a *different*
│                       #   project (a Proxmox VM guest). Unrelated to this file. Don't confuse them.
├── scripts/
│   ├── bootstrap.sh    # OS/DE detection → deps → clone/pull → stow → tools → shell
│   ├── stow.sh         # Symlinks every package via GNU Stow
│   ├── validate.sh     # Full validation suite (also the pre-commit + CI check)
│   ├── install-tools.sh
│   ├── pull-updates.sh # fetch → rebase staging → rebase machine branch → re-stow
│   ├── push-changes.sh # commit (git add -u) → push to machine/<hostname>
│   └── manifest-gen.sh # regenerates manifests/dpkg.txt, flatpak.txt
├── manifests/          # dpkg.txt, flatpak.txt (package lists actually present today)
├── .github/workflows/  # ci.yml, validate.yml, comprehensive.yml, deploy.yml, release.yml
├── .githooks/          # pre-commit → validate.sh --quick --strict; post-merge → stow.sh
├── Dockerfile          # CI validation image (shellcheck, syntax, package integrity, stow --simulate)
├── docs/
│   ├── src/             # the design-conversation chain — see §2
│   └── architecture/    # (empty today — ADRs belong here per the Source of Truth doc, not yet created)
├── .omo/  .opencode/    # agent session/draft artifacts — gitignored but currently still tracked, see §6
└── README.md            # operational reality — commands, package reference, branch/commit conventions
```

---

## 4. Commands that actually work today

```bash
./scripts/validate.sh              # full validation — run before any commit
./scripts/validate.sh --quick --strict   # what pre-commit runs
./scripts/stow.sh                  # (re-)symlink every package
./scripts/bootstrap.sh --dry-run   # see what a fresh bootstrap would do, without doing it
./scripts/pull-updates.sh          # sync machine branch from staging
./scripts/push-changes.sh          # commit + push machine-specific changes
docker build .                     # runs the same checks CI does, locally
```

There is no `dotctl` yet. There is no `hosts/<id>/host.yaml` manifest yet. If a task needs those, you're implementing part of the target architecture (§2) — say so explicitly rather than assuming the scaffolding exists.

---

## 5. Branching & commits

Follow `README.md`'s documented model as current reality:

```
main              stable, deployable
staging           integration (auto-created by bootstrap)
machine/<host>    per-machine overrides (auto-created by bootstrap on first run)
```

Commit convention: `<type>: <short description>` — types are `feat`, `fix`, `docs`, `refactor`, `chore`. Match this exactly; don't invent Conventional-Commits scopes the repo doesn't use.

**On pushing to `main`:** README currently documents direct pushes to `main` as the intended workflow for this personal repo — no PR required. The accepted Source of Truth architecture calls for server-side branch protection (PR + CI required) as part of the target design, which is **not yet enabled**. Practical rule for an agent: attempt the workflow README describes (commit, push to `main` directly for routine changes). If GitHub rejects the push because a ruleset has since been turned on, that's your signal the target model is now live — switch to branch + PR without needing to ask. Don't preemptively create a PR ceremony that doesn't match current reality, and don't assume direct push always works without checking the result.

---

## 6. Known gaps — current status (verified against live repo)

These came out of the architecture review chain in `docs/src/`. Status as of the last pull:

| Item | Status |
|---|---|
| `.omo/`, `.opencode/` tracked despite being gitignored | **Partially fixed** — `UserNotes.md` was removed (`fe24149`); 8 files across both directories are still tracked. Don't add new files under these paths to git; if you touch them, `git rm --cached` rather than leaving them staged. |
| `Architecture-Proposal-Audit` had its entire content duplicated | **Fixed** (`98a6dc8`) — file is now a single clean copy. |
| Stale `Sabir-test/dotfiles` clone URL vs. actual `MBS-ORG/dotfiles` | **Not fixed** — still present in both `scripts/bootstrap.sh` (`REPO_URL`) and `README.md` (Quick Start + Remote section). Fix both together if you touch either. |
| `ci.yml` / `validate.yml` overlapping triggers on `main` | **Not fixed** — both still trigger on push/PR to `main` and both run `validate.sh`-equivalent checks. Note `validate.yml` isn't even mentioned in README's documented CI/CD section — treat it as the one to fold into `ci.yml`, not the other way around, if asked to consolidate. |
| Dockerfile `stow --simulate` target dir bug | **Fixed** (`b8b3d97`) — was failing on a missing `/tmp/th` path. |

---

## 7. Guardrails

- **Never commit secrets.** `.gitignore` blocks `**/id_*`, `**/*.key`, `**/*.pem`, `**/credentials`, `**/token*`, `**/*secret*` — don't work around these patterns even if a task seems to need it. Machine-specific credentials belong in `local.zsh` / `.gitconfig.local` (gitignored, sourced at runtime), never in a tracked package.
- **Don't stage broadly.** If you're writing or touching sync/commit scripts, stage explicitly (`git add <specific paths>`), not `git add .`. `push-changes.sh` already does this correctly with `git add -u` — match that discipline in anything new.
- **Don't invent target-architecture components as if shipped.** `dotctl`, host manifests, drift detection, and the `config/`/`hosts/`/`modules/` layout in the Source of Truth doc are the *design*, not the *repo*. If a task requires them, build the specific piece needed and say what you built, rather than assuming a larger system is already there.
- **`.omo/` and `.opencode/` are agent scratch space, not deliverables.** Don't treat their contents as authoritative context about the project — cross-check against `docs/src/` and `README.md` instead.
- **KDE and machine-specific files:** don't add hardware-tied files (`kwinoutputconfig.json`, `kdeconnect/`, activity-manager caches) to `packages/kde/` — README explicitly excludes these as machine-specific.
- **Run `./scripts/validate.sh` before considering any change done.** It's what CI and the pre-commit hook both run — if it fails locally, it fails everywhere.

---

## 8. Keeping this file current

Update this file when: a script's behavior changes, a workflow is added/removed/merged, a §6 gap gets fixed, or the branch-protection status in §5 changes. It should always reflect the repo as it actually is right now — if something here goes stale, fix the sentence, don't leave it as aspirational.
