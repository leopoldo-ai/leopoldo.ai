---
name: evolution-scheduler
version: 2.0.0
description: Trigger and state management for Leopoldo's weekly evolution cycle. Checks if evolution-agent should run (Thursday + 7 days since last run), manages state in .state/state.json, and provides /evolve command. The actual evolution logic lives in agents/studio/evolution-agent.md. Studio-only, never distributed.
skillos:
  layer: studio
  category: meta
  pack: null
  requires:
    hard: []
    soft: []
  provides: ["evolution-trigger", "evolution-state"]
  triggers:
    - on: "session.start"
      mode: auto
      condition: "thursday AND days_since_last_run >= 7"
    - on: "manual"
      mode: manual
      command: "/evolve"
  config: {}
metadata:
  author: lucadealbertis
  source: local
  license: proprietary
---

# Evolution Scheduler

Trigger and state layer for Leopoldo's evolution system. This skill handles WHEN to evolve. The evolution-agent handles WHAT to do.

## Architecture

```
evolution-scheduler (this skill)
  → Checks trigger conditions (Thursday, 7+ days)
  → Manages state in .state/state.json
  → Dispatches evolution-agent when conditions are met

evolution-agent (agents/studio/evolution-agent.md)
  → Runs 3 parallel subagents:
     1. Internal retrospective (friction, patches)
     2. GitHub radar (new repos, trends, competitors)
     3. Anthropic watch (SDK, API, features, docs)
  → Synthesizes into Evolution Report
  → Presents for user approval
```

## Trigger Logic

The orchestrator checks this on every session start:

1. **Read** `.state/state.json` → `evolution` block
2. **Check conditions:**
   - Manual (`/evolve`): always proceed
   - Auto: today is Thursday AND `evolution.last_run` is >= 7 days ago (or null)
3. **If triggered:** dispatch `evolution-agent` from `agents/studio/`
4. **If not triggered:** exit silently, zero output

## State Schema

Lives in `.state/state.json` under the `evolution` key:

```json
{
  "evolution": {
    "last_run": "2026-03-24",
    "last_run_day": "monday",
    "runs_total": 2,
    "patches_applied": 3,
    "patches_rejected": 0,
    "pending_tasks": [],
    "history": [
      {
        "date": "2026-03-24",
        "frictions_found": 5,
        "patches_proposed": 3,
        "patches_applied": 3,
        "tasks_proposed": 5,
        "tasks_approved": 4,
        "external_signals": 0
      }
    ]
  }
}
```

### History entry fields (v2.0)

| Field | Type | Description |
|-------|------|-------------|
| `date` | string | ISO date of the run |
| `frictions_found` | number | Internal frictions detected |
| `patches_proposed` | number | Patches generated |
| `patches_applied` | number | Patches user approved |
| `tasks_proposed` | number | Sprint tasks generated |
| `tasks_approved` | number | Sprint tasks user approved |
| `external_signals` | number | Relevant findings from GitHub + Anthropic radar |

### Pending task schema

```json
{
  "id": "evo-YYYY-MM-DD-NN",
  "description": "What needs to be done",
  "type": "new-skill | rewrite | cleanup | release | decision | adaptation",
  "priority": "high | medium | low",
  "source": "internal | github-radar | anthropic-watch",
  "status": "pending | approved | in-progress | done | rejected"
}
```

## Reports

Evolution reports are saved to `.state/evolution/report_YYYY-MM-DD.md` after each cycle.

## Rules

- **This skill only manages trigger and state.** All evolution logic is in the agent.
- **Silent when not triggered** — zero output on non-Thursday sessions
- **History capped at 20** — remove oldest entries when exceeded
- **Pending tasks carry over** — approved tasks persist until done or rejected
- **Remove done/rejected tasks** older than 30 days on each cycle
- **Studio only** — never distributed to clients

---

**Version:** 2.0.0
**Type:** Studio skill (trigger + state)
**Agent:** `agents/studio/evolution-agent.md`
**State:** `.state/state.json` → `evolution` key
