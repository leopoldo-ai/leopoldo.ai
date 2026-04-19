---
description: Build all plugin packages (Claude Code + Cowork) for public distribution.
argument-hint: ""
---

# /build

## Required Reading — Do This First

1. `distribution/scripts/build-public-repos.sh` — the build script
2. `api/builder/assembler.py` — the assembler that generates plugin.json + marketplace.json

---

**Scope:** local build of all 11 plugin packages for both platforms.
**NOT for:** publishing to GitHub (use `/release`). Not for client delivery builds (use `distribution/scripts/build-leopoldo-full.sh`).

## What I Need From You

No arguments. Runs against the current branch state.

## Output Template

```markdown
BUILD — [YYYY-MM-DD]

| Plugin | CC size | Cowork size | Status |
| --- | --- | --- | --- |
| investment-core | [KB] | [KB] | [🟢 | 🔴] |
| ... | ... | ... | ... |

Total skills packaged: [N]
Assembler warnings: [N oversize / 0]
Output dir: distribution/output/
```

## The Tests

- **The pre-flight test**: `distribution/scripts/build-public-repos.sh` exists and is executable. If not, report what is missing and STOP.
- **The coverage test**: All 11 plugins present in output. If any missing, flag 🔴 with reason.
- **The no-push test**: This command MUST NOT push to any remote. If the script has a push step, confirm with user before invoking.

## Flow

1. Verify `distribution/scripts/build-public-repos.sh` exists and is executable
2. Run the script; capture stdout/stderr
3. Parse output for per-plugin build result
4. Check `distribution/output/claude-code/plugins/` and `distribution/output/cowork/plugins/` directory listings
5. Read `assembler.py` oversize warnings (if any)
6. Emit the build table with sizes and status

## Tips

1. If the build fails for one plugin, the rest usually succeed. Don't abort on first failure, report all.
2. Sizes help spot anomalies: a plugin suddenly 10x larger than previous build is a red flag.
3. `[WARN]` lines from assembler about oversize skills are diagnostic, not blocking.
