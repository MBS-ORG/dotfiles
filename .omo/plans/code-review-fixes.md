# Code Review Fixes: Stow Delegation + File Cleanup

## TL;DR

> **Quick Summary**: Fix 2 issues found in code review of commit `161f39a`: rewrite `packages/scripts/deploy-configs.sh` as a Stow wrapper (replacing direct `cp` commands), add `~/.local/bin` PATH check, and commit the unstaged deletion of `gitops-initializing-with-skills.md`.
>
> **Deliverables**:
> - Rewritten `packages/scripts/deploy-configs.sh` (Stow delegation + PATH guard)
> - `gitops-initializing-with-skills.md` deletion committed
> - Clean git status with all pre-commit verification passing
>
> **Estimated Effort**: Short
> **Parallel Execution**: YES — 2 waves
> **Critical Path**: Task 1 + Task 2 (parallel) → Wave FINAL

---

## Context

### Original Request
User ran a code review on commit `161f39a` (`fix: resolve bugs from migration review`) plus staged `.opencode/*` files. The review found 4 issues. User decided to fix 2 of them in this plan and keep the 3rd (fetch MCP server).

### Interview Summary
**Key Discussions**:
- **deploy-configs.sh**: Rewrite as Stow wrapper — delegate to `stow --restow --target="$HOME" packages/*` instead of individual `cp` commands
- **PATH check**: Add warning if `~/.local/bin` is not in `$PATH` after creating helper scripts there
- **File deletion**: Commit the unstaged deletion of `gitops-initializing-with-skills.md`
- **fetch MCP server**: Keep it — intentional alongside firecrawl (no change needed)

**Research Findings**:
- `packages/scripts/deploy-configs.sh` is 137 lines, does direct `cp` of bashrc, tmux.conf, ripgreprc, starship.toml
- Repo uses GNU Stow as canonical deploy method per AGENTS.md
- AGENTS.md pre-commit verification: git status clean, Stow packages valid, syntax checks (`bash -n`, `zsh -n`, `tmux -c "list-keys"`), `.gitignore` covers old repos
- Current branch is `MAIN` (commit `161f39a`), with staged `.opencode/*` files and unstaged deletion

### Metis Review
Metis was unresponsive (timeout). Proceeding without — scope is small and requirements are crystal clear.

---

## Work Objectives

### Core Objective
Fix the code review issues: rewrite deploy-configs.sh to use Stow (not `cp`), add PATH check, and commit the unstaged file deletion — all with passing pre-commit verification.

### Concrete Deliverables
- [x] `packages/scripts/deploy-configs.sh` rewritten with Stow delegation + PATH check
- [x] `gitops-initializing-with-skills.md` deletion committed
- [x] Clean `git status` with zero issues

### Definition of Done
- [ ] `bash -n packages/scripts/deploy-configs.sh` — passes (no syntax errors)
- [ ] `stow --simulate --target="$HOME" packages/*` — exits 0 (all packages valid)
- [ ] `git status` — shows clean working tree (no unstaged changes, no untracked files except allowed ones like `.omo/`)

### Must Have
- `packages/scripts/deploy-configs.sh` MUST use `stow --restow --target="$HOME" packages/*` for file deployment (not `cp`)
- Must preserve backup/rollback behavior (backups still created before deploy)
- Must preserve helper script creation (`reload-terminal`, `edit-terminal`)
- Must preserve Windows Terminal info section (it's informational, not deployable via Stow)
- Must preserve tmux plugin installation section
- `~/.local/bin` PATH check warning MUST be added after helper script creation
- `gitops-initializing-with-skills.md` MUST be removed from tracking (committed deletion)

### Must NOT Have (Guardrails)
- NO changes to any other files beyond `packages/scripts/deploy-configs.sh` and the deletion
- NO additional features or refactoring beyond the Stow delegation
- NO changing branches (work on current branch)
- NO force-push
- NO committing SSH keys, tokens, or machine-specific paths

---

## Verification Strategy

> **ZERO HUMAN INTERVENTION** — ALL verification is agent-executed. No exceptions.

### Test Decision
- **Infrastructure exists**: NO (dotfiles repo, no test framework)
- **Automated tests**: None needed
- **Agent-Executed QA**: MANDATORY — via Bash (syntax checks, Stow dry-run, git status)

### QA Policy
Every task MUST include agent-executed QA scenarios. Evidence saved to `.omo/evidence/task-{N}-{scenario-slug}.{ext}`.

- **Syntax checks**: `bash -n packages/scripts/deploy-configs.sh`
- **Stow validation**: `stow --simulate --target="$HOME" packages/*`
- **Git verification**: `git status`, `git log --oneline -3`

---

## Execution Strategy

### Parallel Execution Waves

```
Wave 1 (Start Immediately — fully parallel):
├── Task 1: Rewrite deploy-configs.sh as Stow wrapper + PATH check [quick]
└── Task 2: Commit gitops-initializing-with-skills.md deletion [quick]

Wave FINAL (After ALL tasks — 4 parallel reviews):
├── Task F1: Plan compliance audit (oracle)
├── Task F2: Code quality review (unspecified-high)
├── Task F3: Real manual QA (unspecified-high)
└── Task F4: Scope fidelity check (deep)
→ Present results → Get explicit user okay

Parallel Speedup: ~50% faster than sequential
Max Concurrent: 2 (Wave 1 — Tasks 1 and 2 are independent)
```

### Dependency Matrix

- **1**: (none) — can start immediately, blocks (none)
- **2**: (none) — can start immediately, blocks (none)
- **F1-F4**: 1, 2 — can start after both tasks complete

### Agent Dispatch Summary

- **Wave 1**: **2** — T1 → `quick`, T2 → `quick`
- **FINAL**: **4** — F1 → `oracle`, F2 → `unspecified-high`, F3 → `unspecified-high`, F4 → `deep`

---

## TODOs

- [ ] 1. Rewrite deploy-configs.sh as Stow Wrapper + Add PATH Check

  **What to do**:
  - Rewrite `packages/scripts/deploy-configs.sh` to delegate file deployment to Stow instead of direct `cp` commands
  - Replace the 4 individual `cp` commands (bashrc, tmux.conf, ripgreprc, starship.toml) with a single Stow command:
    ```bash
    print_success "Deploying all Stow packages..."
    stow --restow --target="$HOME" packages/*
    ```
    (Note: Run from repo root — `$SCRIPT_DIR/..`)
  - Keep the backup section (create backup dir, backup existing configs BEFORE Stow overwrites them)
  - Keep the Windows Terminal informational section (lines 61-72)
  - Keep the tmux plugin installation section (lines 75-82)
  - Keep the helper script creation section (lines 85-121) — `reload-terminal` and `edit-terminal`
  - After the helper script creation block (after line 121), add a PATH check:
    ```bash
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        echo -e "${YELLOW}⚠ $HOME/.local/bin is not in your PATH. Add it to ~/.bashrc:${NC}"
        echo 'export PATH="$HOME/.local/bin:$PATH"'
    fi
    ```
  - Keep the final "NEXT STEPS" and "HELPFUL COMMANDS" section (lines 123-137)

  **Must NOT do**:
  - Do NOT change the backup mechanism
  - Do NOT remove helper scripts or Windows Terminal info
  - Do NOT add deploy of packages not already listed
  - Do NOT change any other files

  **Recommended Agent Profile**:
  > - **Category**: `quick`
  >   - Reason: Single-file edit, well-defined transformation with clear before/after
  > - **Skills**: `[]` (none needed — pure bash script editing, no specialized skills required)
  > - **Skills Evaluated but Omitted**: All — plain bash editing needs no specialized skills

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Task 2)
  - **Blocks**: F1-F4
  - **Blocked By**: None (can start immediately)

  **References**:
  - `packages/scripts/deploy-configs.sh` (full file) — current implementation to modify
  - `AGENTS.md:83-86` — Stow deploy command to use: `stow --restow --target="$HOME" packages/*`
  - `AGENTS.md:76-83` — Verification commands for syntax checking

  **Acceptance Criteria**:

  **QA Scenarios (MANDATORY):**

  ```
  Scenario: Syntax check passes
    Tool: Bash
    Preconditions: deploy-configs.sh is readable
    Steps:
      1. Run: bash -n packages/scripts/deploy-configs.sh
    Expected Result: Exit code 0, no error output
    Failure Indicators: Any bash syntax errors
    Evidence: .omo/evidence/task-1-syntax-check.txt

  Scenario: Script contains Stow delegation
    Tool: Bash (grep)
    Preconditions: File exists at packages/scripts/deploy-configs.sh
    Steps:
      1. Run: grep -c "stow --restow --target" packages/scripts/deploy-configs.sh
    Expected Result: grep exits 0, count >= 1
    Failure Indicators: No stow call found — script still uses cp
    Evidence: .omo/evidence/task-1-stow-call.txt

  Scenario: Script contains PATH check
    Tool: Bash (grep)
    Preconditions: File exists
    Steps:
      1. Run: grep -c '.local/bin.*PATH' packages/scripts/deploy-configs.sh
    Expected Result: grep exits 0, count >= 1
    Failure Indicators: PATH check not present
    Evidence: .omo/evidence/task-1-path-check.txt

  Scenario: No cp commands remain for deployed files
    Tool: Bash (grep)
    Preconditions: File exists
    Steps:
      1. Run: grep -c '^cp .*\.bashrc\|^cp .*\.tmux\.conf\|^cp .*\.ripgreprc\|^cp .*starship\.toml' packages/scripts/deploy-configs.sh
    Expected Result: grep exits 1 (no matches)
    Failure Indicators: Direct cp commands remain
    Evidence: .omo/evidence/task-1-no-cp.txt

  Scenario: Backup section preserved
    Tool: Bash (grep)
    Preconditions: File exists
    Steps:
      1. Run: grep -c 'mkdir -p ~/config-backups' packages/scripts/deploy-configs.sh
    Expected Result: grep exits 0, count >= 1
    Failure Indicators: Backup code removed
    Evidence: .omo/evidence/task-1-backup.txt

  Scenario: Helper scripts preserved
    Tool: Bash (grep)
    Preconditions: File exists
    Steps:
      1. Run: grep -c 'reload-terminal' packages/scripts/deploy-configs.sh && grep -c 'edit-terminal' packages/scripts/deploy-configs.sh
    Expected Result: Both greps exit 0
    Failure Indicators: Helper scripts removed
    Evidence: .omo/evidence/task-1-helpers.txt
  ```

  **Evidence to Capture:**
  - [ ] task-1-syntax-check.txt
  - [ ] task-1-stow-call.txt
  - [ ] task-1-path-check.txt
  - [ ] task-1-no-cp.txt
  - [ ] task-1-backup.txt
  - [ ] task-1-helpers.txt

  **Commit**: YES
  - Message: `fix: rewrite deploy-configs.sh as Stow wrapper, add PATH guard`
  - Files: `packages/scripts/deploy-configs.sh`
  - Pre-commit: `bash -n packages/scripts/deploy-configs.sh && stow --simulate --target="$HOME" packages/*`

---

- [ ] 2. Commit Deletion of gitops-initializing-with-skills.md

  **What to do**:
  - Stage the deletion: `git rm gitops-initializing-with-skills.md`
  - Commit it with an appropriate message
  - Verify git status is clean (only the committed deletion + previously staged `.opencode/*` files + untracked `.omo/` and `var/` should appear)

  **Must NOT do**:
  - Do NOT modify the file or its content — it's already deleted from the working tree
  - Do NOT combine this commit with other changes
  - Do NOT force-push

  **Recommended Agent Profile**:
  > - **Category**: `quick`
  >   - Reason: Trivial git operation — stage deletion + commit
  > - **Skills**: `[]` (none needed)
  > - **Skills Evaluated but Omitted**: `git-master` — overkill for a simple stage-and-commit

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Task 1)
  - **Blocks**: F1-F4
  - **Blocked By**: None (can start immediately)

  **References**:
  - `GITOPS-WORKFLOW.md:100-110` — Commit convention (`<type>: <short description>`)
  - `AGENTS.md:53` — Commit types: `migrate`, `merge`, `feat`, `fix`, `docs`, `refactor`, `chore`
  - `AGENTS.md:56-59` — Pre-commit verification checklist

  **Acceptance Criteria**:

  **QA Scenarios (MANDATORY):**

  ```
  Scenario: File removed from git tracking
    Tool: Bash
    Preconditions: Working tree is clean
    Steps:
      1. Run: git ls-files gitops-initializing-with-skills.md
    Expected Result: Empty output (file no longer tracked)
    Failure Indicators: File still tracked by git
    Evidence: .omo/evidence/task-2-file-untracked.txt

  Scenario: Git status clean (no unstaged changes)
    Tool: Bash
    Preconditions: After commit
    Steps:
      1. Run: git status --porcelain
    Expected Result: No lines starting with ` D` or ` M` (staged files ok, untracked .omo/ var/ ok)
    Failure Indicators: Unstaged changes remain
    Evidence: .omo/evidence/task-2-status.txt

  Scenario: Commit message follows convention
    Tool: Bash
    Preconditions: After commit
    Steps:
      1. Run: git log --oneline -3
    Expected Result: Most recent commit message matches `<type>: <description>` pattern
    Failure Indicators: Message doesn't follow convention
    Evidence: .omo/evidence/task-2-commit-msg.txt
  ```

  **Evidence to Capture:**
  - [ ] task-2-file-untracked.txt
  - [ ] task-2-status.txt
  - [ ] task-2-commit-msg.txt

  **Commit**: YES
  - Message: `chore: remove stale gitops-initializing-with-skills.md`
  - Files: `gitops-initializing-with-skills.md`
  - Pre-commit: `git status --porcelain` (verify clean)

---

## Final Verification Wave (MANDATORY — after ALL implementation tasks)

> 4 review agents run in PARALLEL. ALL must APPROVE. Present consolidated results to user and get explicit "okay" before completing.
>
> **Do NOT auto-proceed after verification. Wait for user's explicit approval before marking work complete.**

- [ ] F1. **Plan Compliance Audit** — `oracle`
  Read the plan end-to-end. For each "Must Have": verify implementation exists (read files, run `grep` for Stow call, PATH check, etc.). For each "Must NOT Have": search codebase for forbidden patterns — reject with file:line if found. Check evidence files exist in `.omo/evidence/`. Compare deliverables against plan.
  Output: `Must Have [N/N] | Must NOT Have [N/N] | Tasks [N/N] | VERDICT: APPROVE/REJECT`

- [ ] F2. **Code Quality Review** — `unspecified-high`
  Run `bash -n packages/scripts/deploy-configs.sh`. Review changed file for: AI slop (excessive comments, over-abstraction, unused variables), console.log in prod scripts, commented-out code. Check the script is readable and well-structured.
  Output: `Syntax [PASS/FAIL] | Files [N clean/N issues] | VERDICT`

- [ ] F3. **Real Manual QA** — `unspecified-high`
  Clone the verification scenarios from tasks and execute them. Start from clean state. Run: `bash -n packages/scripts/deploy-configs.sh`, `stow --simulate --target="$HOME" packages/*`, `git status`. Confirm Stow delegation exists, PATH check exists, backup section preserved, helper scripts preserved, no `cp` commands for deployed files remain. Save evidence to `.omo/evidence/final-qa/`.
  Output: `Scenarios [N/N pass] | Integration [N/N] | VERDICT`

- [ ] F4. **Scope Fidelity Check** — `deep`
  For each task: read "What to do", read actual diff (`git log -1 --format="%H"` + `git diff HEAD~1`). Verify 1:1 — everything in spec was built (no missing), nothing beyond spec was built (no creep). Check "Must NOT do" compliance. Flag unaccounted changes.
  Output: `Tasks [N/N compliant] | Contamination [CLEAN/N issues] | Unaccounted [CLEAN/N files] | VERDICT`

---

## Commit Strategy

- **Task 1**: `fix: rewrite deploy-configs.sh as Stow wrapper, add PATH guard` — `packages/scripts/deploy-configs.sh`, pre-commit: `bash -n packages/scripts/deploy-configs.sh`
- **Task 2**: `chore: remove stale gitops-initializing-with-skills.md` — `gitops-initializing-with-skills.md`, pre-commit: `git status --porcelain`

---

## Success Criteria

### Verification Commands
```bash
# Syntax check
bash -n packages/scripts/deploy-configs.sh

# Stow dry-run
stow --simulate --target="$HOME" packages/*

# Git status
git status --porcelain
```

### Final Checklist
- [ ] `deploy-configs.sh` uses `stow --restow` (no `cp` for deployed files)
- [ ] PATH check present after `~/.local/bin` helper scripts
- [ ] `gitops-initializing-with-skills.md` no longer tracked
- [ ] `bash -n` passes
- [ ] `stow --simulate` passes (exit 0)
- [ ] `git status` shows clean working tree
- [ ] Backup section, helper scripts, Windows Terminal info preserved
