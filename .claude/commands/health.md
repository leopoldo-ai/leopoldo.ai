---
description: Check Leopoldo services and infrastructure health with traffic lights.
argument-hint: ""
---

# /health

## Required Reading — Do This First

1. `CLAUDE.md` — infrastructure table (services, URLs)
2. `.state/state.json` — local state sanity check

---

**Scope:** deep infrastructure health — website, API, GitHub repos, database, local state, symlinks.
**NOT for:** quick status glance (use `/status`). Not for service-level monitoring (use `/monitor`).

## What I Need From You

No arguments. Checks everything.

## Output Template

```markdown
LEOPOLDO HEALTH — [YYYY-MM-DD]

| Component | Status | Detail |
| --- | --- | --- |
| Website (Vercel) | [🟢 | 🔴] | HTTP [code] |
| API (Railway) | [🟢 | 🔴] | HTTP [code] |
| Repo: leopoldo-ai/leopoldo.ai | [🟢 | 🔴] | updated [date] |
| Repo: leopoldo-ai/leopoldo-private | [🟢 | 🔴] | updated [date] |
| Database (Neon) | [🟢 | 🟡 | 🔴] | [status] |
| State file | [🟢 | 🔴] | [valid JSON / malformed] |
| Skills symlink | [🟢 | 🔴] | [.claude/skills -> skills/] |
| Agents symlink | [🟢 | 🔴] | [.claude/agents -> agents/] |
```

## The Tests

- **The traffic-light test**: Every component has explicit 🟢/🟡/🔴. No ambiguity.
- **The grounding test**: HTTP codes come from real curl, dates from real `gh repo view`. No hallucination.
- **The privacy test**: Do not print database connection string, API keys, or tokens in output.

## Flow

1. `curl -s -o /dev/null -w "%{http_code}" https://leopoldo.ai` → website status
2. `curl -s -o /dev/null -w "%{http_code}" https://leopoldo-api-production.up.railway.app/health` → API status
3. `gh repo view leopoldo-ai/leopoldo.ai --json name,updatedAt` and same for `leopoldo-ai/leopoldo-private`
4. Check Neon connection via `postgres` MCP server or env var presence (do not print the string)
5. Validate `.state/state.json` is parseable JSON
6. Verify `.claude/skills` and `.claude/agents` resolve as symlinks to the correct source dirs
7. Emit the health table

## Tips

1. 🟡 for database means "configured but not tested this run" — use when MCP is unavailable but env var exists
2. If a symlink is broken, that's 🔴 regardless of anything else working — suggest `ln -s skills .claude/skills` to fix
3. Keep output under 15 rows. This is for humans to scan.
