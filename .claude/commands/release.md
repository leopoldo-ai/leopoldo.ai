---
description: Run the full Leopoldo release pipeline. Validates, builds, tags, publishes.
argument-hint: "<patch | minor | major>"
---

# /release

## Required Reading — Do This First

1. `distribution/scripts/build-public-repos.sh` and `build-public-monorepo.sh`
2. `CHANGELOG.md` — previous entries for format
3. `distribution/scripts/validate-coherence.sh` (if present)

---

**Scope:** unified release pipeline across private repo, public monorepo, plugin packages, GitHub release, optional backend publish.
**NOT for:** ad-hoc deploy (use `/deploy`). Not for plugin build only (use `/build`).

## What I Need From You

- `$ARGUMENTS`: `patch`, `minor`, or `major`. If missing, prompt the user.

## Output Template

```markdown
RELEASE vX.Y.Z — [YYYY-MM-DD]

Phase 1 — Pre-flight:
  Current version:   vX.Y.Z
  Commits since tag: [N]
  Coherence:         [🟢 | 🔴 block]

Phase 2 — Build:
  Plugin repos:      [🟢 13/13 | 🔴]
  Public monorepo:   [🟢 | 🔴 path not found]

Phase 3 — Version & Tag:
  Bump:              vX.Y.Z → vA.B.C
  Commit + tag:      [🟢 | 🔴]

Phase 4 — Publish:
  Private push:      [🟢 | 🔴]
  Monorepo push:     [🟢 | 🔴]
  GitHub Release:    [🟢 URL | 🔴]
  Backend publish:   [🟢 N zips | ⏭️ skipped (no ADMIN_KEY)]

Phase 5 — Verify:
  Tag on remote:     [🟢 | 🔴]
  Release page live: [🟢 | 🔴]
```

## The Tests

- **The confirmation-gate test**: User explicitly confirms BEFORE Phase 3 (tag creation). No silent release.
- **The stop-on-fail test**: If any phase fails, STOP immediately. Do NOT proceed to push. Report what succeeded and what failed.
- **The no-force test**: Never `git push --force` on master or tags. If push conflicts, diagnose and report.

## Flow

1. **Phase 1**: read latest tag, summarize commits since, run coherence check, show summary, ask for confirmation
2. **Phase 2**: run `build-public-repos.sh` then `build-public-monorepo.sh <path>` (default `../leopoldo.ai`, prompt if missing). Verify output dirs populated.
3. **Phase 3**: compute new version from bump type. `git commit -m "release: vX.Y.Z"` then `git tag vX.Y.Z`.
4. **Phase 4**: push private `master` + tags, cd to monorepo and push, `gh release create vX.Y.Z` with changelog. If `LEOPOLDO_ADMIN_KEY` is set, POST plugin ZIPs to backend publish endpoint.
5. **Phase 5**: `git ls-remote --tags origin` to verify, curl GitHub release URL, report live status.

## Tips

1. Monorepo push is a separate git repo. `cd <path>`, `git add -A`, `git commit -m "release: vX.Y.Z"`, `git push origin master`, `cd -` back.
2. Include skill count and plugin list in the GitHub release notes — marketing-relevant.
3. Release notes format: `vX.Y.Z — [title]` followed by the Phase 1 commits summary, grouped by type (feat/fix/docs/refactor).
