---
description: |
  Report comprehensive Leopoldo system status in a single structured card.
  Trigger with "status", "come va il sistema", "che stato siamo",
  "system status", "dammi lo stato", or "summary del sistema".
argument-hint: ""
---

# /status

## Required Reading — Do This First

Before any output, read these completely:

1. `.state/state.json` — skill count, evolution state, last session
2. `.leopoldo-manifest.json` — installed plugins, environment cache

---

**Scope:** snapshot of current Leopoldo system health — skills, agents, git, infrastructure, state.
**NOT for:** detailed skill inventory (use `/scan-skills`). Not for infra health deep-dive (use `/health`).

## What I Need From You

No arguments required. Runs silently against the filesystem and remote services.

## Output Template

```markdown
LEOPOLDO STATUS — [YYYY-MM-DD]

Skills:      [count] across [N] packs
Agents:      [count] ([comma-separated names])
Branch:      [branch-name] — [clean | dirty with N changes]
Last commit: [short-sha] [message] ([relative time])

Services:
  leopoldo.ai         [🟢 | 🔴] [HTTP status]
  API (Railway)       [🟢 | 🔴] [HTTP status]

Evolution:
  Last run:   [date | "never"]
  Pending:    [N] task(s)

Build:       [ready | not ready — reason]
```

## The Tests

Run before showing the user:

- **The traffic-light test**: Every service has 🟢 or 🔴. No ambiguous status.
- **The freshness test**: Date of "Last run" matches `.state/state.json`; if discrepancy, state it.
- **The scope test**: This is a snapshot, not a deep audit. If the user asks for deeper, redirect to `/health`.

## Flow

1. Count `skills/**/SKILL.md` files and group by pack (read `.state/state.json` first, verify with filesystem if suspect)
2. List agents in `agents/` by filename stem
3. Run `git status --short` and `git log -1 --oneline` for git health
4. curl `https://leopoldo.ai` and the Railway API endpoint, extract HTTP status
5. Read `.state/state.json` for evolution and session info
6. Check `distribution/scripts/build-public-repos.sh` exists and is executable
7. Emit the status card

## Tips

1. If any service returns non-2xx, do not retry inline — just report 🔴 and the status code
2. If `.state/state.json` is missing, skill count falls back to filesystem scan (note this in output)
3. Keep the output under ~20 lines — this is a glance, not a dashboard
