---
description: Deploy Leopoldo services (website + API) via git push to master.
argument-hint: ""
---

# /deploy

## Required Reading — Do This First

1. `CLAUDE.md` — infrastructure section (Vercel + Railway auto-deploy)
2. Current git state — `git status` and current branch

---

**Scope:** guided deployment of leopoldo.ai (Vercel) and the Railway API. Auto-deploy triggered by `git push origin master`.
**NOT for:** plugin release (use `/release`). Not for client delivery builds.

## What I Need From You

No arguments. Operates on current branch state.

## Output Template

```markdown
DEPLOY — [YYYY-MM-DD]

Pre-flight:
  Working tree:    [🟢 clean | 🔴 dirty — N changes]
  Current branch:  [master | 🔴 other: <name>]
  Build check:     [🟢 passed | 🔴 failed]

Push result:       [🟢 pushed to origin/master | 🔴 blocked: reason]

Post-deploy verification (automatic 60s wait):
  leopoldo.ai         [🟢 HTTP 200 | 🔴 status]
  API /health         [🟢 HTTP 200 | 🔴 status]
```

## The Tests

- **The clean-tree test**: `git status --short` returns empty. If not, STOP and ask user to commit or stash.
- **The branch test**: Current branch is `master`. If not, STOP and confirm with user before proceeding.
- **The build test**: `cd web && ./node_modules/.bin/next build` passes. If it fails, do NOT push.
- **The no-force test**: Never use `--force` or `--force-with-lease` on `git push` without explicit user instruction.

## Flow

1. Run `git status --short`; if dirty, stop and report
2. Verify current branch is `master`
3. Run `cd web && ./node_modules/.bin/next build`; if fails, stop
4. Show a summary of commits about to push: `git log origin/master..HEAD --oneline`
5. Ask user for explicit confirmation
6. Run `git push origin master` (triggers Vercel + Railway auto-deploy in parallel)
7. Wait 60s, then curl both endpoints and report status codes

## Never Say / Instead

| Never say | Instead |
|---|---|
| "Let me force push to fix this" | Never. Ask user. |
| "Deploy done" (without verify) | Always verify post-deploy HTTP 200 |
