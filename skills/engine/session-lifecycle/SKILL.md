---
name: session-lifecycle
version: 1.1.0
description: Use when opening or closing Leopoldo sessions, loading system.md at start, proposing system.md updates at end, journaling events, creating checkpoints, or restoring from a checkpoint. Manages `.state/` and `.leopoldo/system.md`.
type: technique
applies_to: [STUDIO]
tier: essentials
status: ga
---

# Session Lifecycle

Driver for session open/close, journaling, checkpoints, and the narrative state artifact `.leopoldo/system.md`. Operates on `.state/` (machine) and `.leopoldo/system.md` (human).

## Files managed

| Path | Role |
|---|---|
| `.state/state.json` | Persistent machine state |
| `.state/journal/*.jsonl` | Append-only event log |
| `.state/snapshots/cp_*.json` | Checkpoints for restore |
| `.leopoldo/system.md` | Narrative state (direction, personas, patterns, decisions) |

## Operations

### session.open

1. Load `.state/state.json` (create from template if missing).
2. Generate `session_id = ses_YYYYMMDD_HHMMSS` (UTC).
3. Append `session.start` to today's journal.
4. **Load `.leopoldo/system.md`** — if present, inject content into `additionalContext`. If missing, create empty stub (see Migration) and continue silently.
5. Surface last-session context ("Prima sessione" if none).

### journal.append

Append `{ts, type, session_id, data}` to current journal. Event types: `skill.invoke`, `skill.complete`, `task.start`, `task.complete`, `phase.advance`, `decision.made`, `pattern.observed`, `system_md.created`, `system_md.updated`, `error`.

On `decision.made` → queue for system.md Decisions table.
On repeated correction signals → queue a pattern candidate.

### checkpoint.create

Generate `cp_YYYYMMDD_HHMM`, copy state.json to `.state/snapshots/`, register, GC to max 10. Journal `checkpoint.created`.

### session.close

1. Summarise skills used, tasks done, duration.
2. **Diff system.md candidates**: if new patterns or decisions emerged, present them and ask the user "Save to system.md? [Y/n]". On confirm, append via `session-end.sh`. Never silently overwrite existing sections.
3. Append `session.end` to journal.
4. Update state.json: increment `sessions.total`, rotate `last_session` into `history[]` (max 20 FIFO).
5. Auto-create checkpoint if tasks completed.

### checkpoint.restore

List snapshots, back up current state, copy chosen snapshot → state.json, journal `checkpoint.restored`.

### state.query

`current_phase`, `last_session`, `skill_health(name)`, `decisions(filter?)`, `session_history(n?)`, `checkpoints`, `system_md.direction`, `system_md.patterns`.

## system.md details

Schema, fields, and lifecycle: `references/system-md-template.md`. Never exceed 2,000 words; split decisions to sub-files when needed.

## Migration (v2.0.0 → v2.1.0)

First post-update session on a v2.0.0 client: create empty `.leopoldo/system.md` populated with domain from `.leopoldo-manifest.json` and defaults (depth: balanced, tone: consultative). Journal `system_md.created`. Never blocks.

## Integration

| Skill / hook | Integration |
|---|---|
| `session-start.sh` | Calls session.open, loads system.md |
| `session-end.sh` | Proposes system.md save |
| `session-reporter` | Reads journal, invokes session.close |
| `phase-gate` | `journal.append(phase.advance)` |
| `skill-router` | `journal.append(skill.invoke)` |
| `skill-postmortem` | `journal.append(error)` |
| `scripts/state_sync.py` | Reports drift between manifest and system.md |

## Rules

- Append-only journal. Never rewrite past events.
- `state.json` always valid JSON. Idempotent open.
- `system.md` is user-editable; never overwrite silently — always confirm.
- All timestamps ISO 8601 UTC.
- Graceful degradation: missing `system.md` is a valid state.

## Anti-patterns

- Journal events for every keystroke (only significant events).
- Writing to `system.md` without user confirmation.
- Duplicating manifest fields in system.md.
- Restoring a checkpoint without backing up current state first.
