---
name: task-capture
version: 0.1.0
description: "Use when capturing a task that arose during a meeting, an email, or a call, with structured tagging by project, deal, or portfolio company, and a due date."
type: technique
tier: essentials
status: ga
metadata:
  author: internal
  source: custom
  license: proprietary
---

# Task Capture

## Why it exists

Tasks arise faster than they get captured. Most senior professionals carry 30 to 80 open tasks at any time across deals, portcos, internal projects, regulator follow-ups, partner commitments. Without structured capture (with project tag, owner, due date, source context), tasks live in scattered emails, paper notes, and memory. They miss deadlines or get done twice. This skill captures fast (5 to 10 seconds per task) with enough structure to route correctly.

## Out of scope

- Not a project management replacement. Notion, Asana, Linear, Jira remain the source of truth; this skill captures and routes.
- Not a personal kanban. We capture; we do not own workflow state.
- Not a Gantt chart. Dependency tracking is project-management territory.
- Not a substitute for delegation discipline. We capture the task; the user decides who owns it.

## Core workflow

### Phase 1: Capture trigger

User says one of:

- "Add a task to follow up with X"
- "Note: review the Q3 model by Friday"
- "Open: send the term sheet to the LP"

Or task is suggested by another skill (`email-triage` proposes tasks from URGENT items, `calendar-prep` proposes tasks from action items in meetings, `decision-log` proposes follow-up tasks from decisions).

### Phase 2: Structured capture

Each task captures:

| Field | Required | Notes |
|---|---|---|
| Title | Yes | Imperative sentence: "Send Q3 forecast to LP X" |
| Owner | Yes | User by default; can delegate |
| Due date | Yes (default: end of week) | Absolute date, not "soon" |
| Project / deal / portco tag | Yes | Routes to correct context |
| Source context | Yes | Where the task arose (email, meeting, decision) |
| Estimated effort | Optional | Under 15 min / 15 to 60 min / over 1 hour |
| Notes | Optional | Free text |

If any required field is missing, ask the user once. If still missing, default sensibly and flag `[INCOMPLETE]`.

### Phase 3: Routing

Tasks get routed by tag:

| Tag domain | Routing |
|---|---|
| Deal name | Adds to deal-folder task list |
| Portco name | Adds to portfolio-monitoring follow-up |
| Project / engagement | Adds to project task list |
| Personal / admin | Adds to personal task list |
| Compliance / regulatory | Surfaces in compliance-engine queue |

If the user has external task system (Notion, Asana), task is also pushed there with reference; capture stays in Leopoldo.

### Phase 4: Daily and weekly views

- **Daily**: tasks due today + tomorrow, sorted by tag and effort.
- **Weekly**: tasks due this week, grouped by project / deal / portco.
- **Aged**: tasks past due (highlighted, prompted for re-prioritization).

## Stop and surface

- Before deleting any task: explicit user confirmation.
- For tasks tagged compliance / regulatory: never auto-close; surface for compliance review.
- If aged tasks accumulate (over 10 past due): surface a backlog review.

## Two artifacts

1. **Task list** (Markdown or rendered card): the daily/weekly view.
2. **External system push** (when configured): same task in Notion, Asana, Linear, or Jira via their MCP or API.

## Citation discipline

- Every task cites its source (email-id, meeting date, decision-id, free-text origin).
- Estimated effort flagged `[ESTIMATED]` until the task is closed and actual effort logged.
- `[INCOMPLETE]` flag for tasks missing required fields, blocks routing.

## Quality bar

- Capture takes under 10 seconds per task.
- Required fields complete on more than 95 percent of captures.
- Aged tasks surfaced weekly without exception.
- Compliance / regulatory tasks never auto-closed.

## Disclaimer

This skill captures tasks. It does not deliver them. Operational accountability remains with the assigned owner and the project sponsor.
