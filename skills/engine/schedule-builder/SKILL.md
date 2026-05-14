---
name: schedule-builder
description: Use when the user wants to schedule a recurring task in Cowork or Claude Code Desktop, asks "every morning do X", "schedulami Y", or mentions Cowork's Scheduled feature. Conducts a Leopoldo brief interview, applies autonomous-prompt discipline (fail-safe, explicit destinations), then hands off to Anthropic's built-in `/schedule` skill which actually creates the task via the runtime `create_scheduled_task` tool.
type: technique
applies_to: [CONTENT, DEV]
tier: essentials
status: ga
metadata:
  author: internal
  source: custom
  created: 2026-05-05
  forge_strategy: BUILD
  positioning: complementary_to_anthropic_schedule
license: proprietary
upstream:
  url: https://support.claude.com/en/articles/13854387-schedule-recurring-tasks-in-claude-cowork
  last_checked: 2026-05-05
---

# Schedule builder

Leopoldo's prompt-enricher for Anthropic's built-in `/schedule` skill. We do not duplicate `/schedule`. We sit upstream of it: better interview, better prompt discipline, finance-grade fail-safe, then handoff.

## Architecture

`User intent` → `schedule-builder` (interview + Leopoldo discipline) → `prompt + taskName + timing` → `User invokes /schedule` → `/schedule calls create_scheduled_task` → `Cowork registers task`.

We produce the inputs `/schedule` needs. `/schedule` does the registration.

## Why we exist (vs. just /schedule directly)

`/schedule` is a thin 41-line skill: asks for `taskName`, `prompt`, `cronExpression | fireAt | ad-hoc`. It does NOT apply autonomous-prompt discipline, provide finance/legal/consulting templates, surface platform constraints, or embed delivery instructions. Leopoldo adds these layers, then defers to Anthropic.

## When to invoke

- "schedule this", "schedulami", "set up a recurring task"
- "every morning / day / week, do X"
- "remind me to check Y daily"
- "automate this Z"
- User opens Cowork Scheduled and asks for help

## Workflow

1. **Brief interview** (max 4 questions): outcome, inputs, destination, timing.
2. **Apply autonomous-prompt rules** (below).
3. **Decide timing**: a cron expression (e.g. `0 8 * * 1-5`), an ISO 8601 fireAt for one-shot (`2026-05-06T08:00:00`), or one of the natural-language presets `/schedule` accepts.
4. **Choose taskName** in kebab-case.
5. **Output the handoff block** (below).

## Autonomous-prompt rules (mandatory)

A scheduled run has no human in the loop. Generated prompts MUST:
- Specify every input explicitly (which calendar, which mailbox, which file, which account)
- Specify the output destination explicitly (which connector, which recipient)
- Include a fail-safe: "if data X is missing, output 'no data' and stop instead of asking"
- Avoid clarifying questions of any kind
- Never instruct the task to modify its own schedule

## Constraints to surface (always tell the user)

- Cowork desktop must be **awake and open** at trigger time (sleep kills the run).
- Bundled MCPs from Leopoldo plugins do **not** run in Cowork sandbox. Only user's own connectors (Gmail, Slack, Calendar, Notion) are available at runtime.
- Cron expressions evaluate in user's local timezone (per `/schedule` skill spec).
- `/schedule` may not be available on older Cowork versions: fallback is the manual form (Sidebar → Scheduled → New) with the 5 frequency presets.

## Templates

5 reusable prompt patterns in `templates.md` (companion, on-demand): morning-brief, weekly-pipeline-review, monthly-portfolio-snapshot, daily-deal-radar, quarterly-client-report. Each is a finished prompt body following the autonomous-prompt rules, ready to feed `/schedule`.

## Output format

```
LEOPOLDO SCHEDULE PACKAGE — handoff to Anthropic /schedule

taskName: <kebab-case-name>

timing (pick one):
  cron: <expression in local timezone>            # e.g. "0 8 * * 1-5"
  OR fireAt: <ISO 8601>                           # e.g. "2026-05-06T08:00:00"
  OR preset: <Hourly | Daily | Weekdays | Weekly | Manual>

prompt:
<self-contained prompt with explicit inputs, destination, fail-safe>

NEXT STEP
1. Invoke `/schedule` in your Cowork or Claude Code Desktop session.
2. Paste taskName, timing, and prompt when /schedule asks.
3. Confirm. /schedule will call create_scheduled_task and register the task.

REMINDERS
- Keep your desktop awake at trigger time.
- Only your own Cowork-installed connectors are available at runtime.
- If /schedule is unavailable, paste the prompt into the manual form (Sidebar → Scheduled → New) and pick the closest frequency preset.
```

## Anti-patterns

| Don't | Why | Do instead |
|---|---|---|
| Reproduce `/schedule`'s job (call create_scheduled_task) | We have no access to that runtime tool | Hand off to `/schedule` |
| Pretend cron is unsupported | False; `/schedule` accepts cron expressions | Generate cron when timing requires it |
| Output a 6-field form payload | Wrong handoff target | Output 3 things: taskName, timing, prompt |
| Prompt with "which X?" questions | No human at runtime | Specify explicitly |
| Skip fail-safe lines | Run halts on missing data | Always include |
| Reference Leopoldo backend or our Resend | Not reachable from sandbox | User's own connectors only |
| Copy `/schedule`'s SKILL.md text | License unclear, proprietary bundle | Reference behavior conceptually |
