# Draft: Code Review Fixes

## Requirements (confirmed)
- Create a work plan to fix MEDIUM and MINOR issues found in code review of commit `161f39a` + staged changes

## Issues to Address
1. **MEDIUM**: `packages/scripts/deploy-configs.sh` uses `cp` instead of Stow — add Stow disclaimer/warning
2. **MINOR**: `deploy-configs.sh` creates `~/.local/bin` but doesn't check PATH
3. **MINOR**: `gitops-initializing-with-skills.md` deletion is unstaged
4. **LOW**: `.opencode/opencode.json` - `fetch` MCP may overlap with firecrawl

## Technical Decisions
- **deploy-configs.sh**: Rewrite as Stow wrapper (delegate to `stow --restow --target="$HOME" packages/*`)
- **PATH check**: Add warning after `~/.local/bin` creation if not in PATH
- **fetch MCP**: Keep it (intentional alongside firecrawl)
- **gitops-initializing-with-skills.md**: Commit deletion as part of this plan

## Scope Boundaries
- IN: deploy-configs.sh rewrite, PATH check, commit deletion, pre-commit verification
- OUT: fetch MCP (keeping it), any other unrelated config changes

## Test Strategy
- No test infrastructure in repo
- No automated tests needed
- Agent-Executed QA via bash commands (dry-run stow, syntax checks)
