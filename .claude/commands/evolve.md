---
description: |
  Trigger the Leopoldo weekly evolution cycle manually.
  Trigger with "fai evolve", "run evolution cycle", "trigger evolution",
  "avvia retrospettiva settimanale", or "quali sono le ultime novità Anthropic".
argument-hint: ""
---

# /evolve

## Required Reading — Do This First

Before any output, read these completely:

1. `agents/studio/evolution-agent.md` — agent definition and dispatch rules
2. `.state/state.json` — current evolution state (last_run, pending_tasks)

Do not skip.

---

**Scope:** weekly evolution cycle (internal retrospective + GitHub radar + Anthropic watch).
**NOT for:** postmortems of specific failures (use `/postmortem`). Not for publishing release notes (use `/release`).

## What I Need From You

No arguments required. Runs against the current system state.

## Output Template

```markdown
EVOLUTION CYCLE — [YYYY-MM-DD]

Internal Retrospective:
  - Friction points detected: [N]
  - Patch proposals: [N] (capped at 5)
  - State drift: [list or "none"]

GitHub Radar:
  - New repos/MCP/plugins: [brief list with links]
  - Competitor moves: [brief]

Anthropic Watch:
  - SDK/API changes: [brief]
  - New features / deprecations: [brief]

Recommended actions (awaiting approval):
  - [1] ...
  - [2] ...

Report saved to: .state/evolution/report_[date].md
```

## The Tests

Run before showing the user:

- **The cap test**: No more than 5 patches + 5 sprint tasks proposed per cycle. If more, rank and trim.
- **The approval test**: Nothing is applied until the user explicitly approves each item.
- **The carryover test**: Pending tasks from previous cycles are still listed (never silently dropped).

## Flow

1. Read `.state/state.json` evolution section
2. Dispatch `evolution-agent` with 3 parallel subagents (retrospective, github-radar, anthropic-watch)
3. Wait for all 3 to complete
4. Synthesize findings into a single evolution report
5. Save full report to `.state/evolution/report_<YYYY-MM-DD>.md`
6. Present the cycle card above
7. For each recommended action, wait for explicit user approval
8. Save approved items as `pending_tasks` in `.state/state.json`

## Tips

1. If the last run was more than 7 days ago, the session-start hook already suggested this command — proceed
2. Skip this command if the last run was less than 48h ago unless the user explicitly insists
3. Evolution is read-mostly: it proposes, never mutates without approval
