---
name: email-triage
version: 0.1.0
description: "Use when reviewing the inbox for the day, categorizing email by urgency and topic, surfacing items that need response within 24 hours, and routing the rest to follow-up queues."
type: technique
tier: essentials
status: ga
metadata:
  author: internal
  source: custom
  license: proprietary
---

# Email Triage

## Why it exists

A senior professional in regulated finance receives 80 to 200 emails per day. Triage decides which 5 to 10 are worth opening now, which 30 to 50 can wait, which 100+ are noise. Done in 5 minutes from the user's stated context (deals in flight, pending decisions, regulatory deadlines), triage saves the rest of the day. Done badly or not at all, the inbox runs the day.

## Out of scope

- Not an email client. Outlook / Gmail remain the source.
- Not auto-reply. Skill suggests; user sends.
- Not a spam filter. We assume the inbox is already filtered upstream.
- Not a substitute for inbox-zero discipline. Triage is daily; methodology is weekly.

## Core workflow

### Phase 1: Context

Pull from native memory or ask once:

- Open deals or projects (top 5)
- Pending decisions awaiting input
- Regulatory deadlines in the next 14 days
- VIP correspondents (LP, regulator, key client, board)

### Phase 2: Inbox scan

For each unread email, classify:

| Tag | Meaning | Action |
|---|---|---|
| `URGENT` | VIP correspondent OR contains "deadline", "today", "EOD", or known critical project keyword | Read now, respond today |
| `RESPONSE-DUE-24H` | Direct request to user, named project context | Read today, schedule response |
| `FYI` | Cc only, status update, newsletter from must-read source | Quick scan, file |
| `LATER` | No clear action required, informational | Defer to weekly review |
| `NOISE` | Marketing, vendor outreach, generic newsletter | Archive, suggest filter rule |

### Phase 3: Output

Produce a single-screen triage view:

- Top section: URGENT (max 5)
- Middle: RESPONSE-DUE-24H (max 10)
- Lower: FYI (collapsed count)
- Bottom: LATER and NOISE (counts only, not listed)

Each URGENT and RESPONSE-DUE-24H entry shows: sender, subject, 1-line topic, suggested action.

### Phase 4: Suggested actions

For URGENT and RESPONSE-DUE-24H:

- Short reply (under 3 sentences): generate draft for user review
- Longer response needed: flag for dedicated time block (use `calendar-prep`)
- Decision required: log via `decision-log` after response sent
- Task arises: capture via `task-capture`

## Stop and surface

- Before any draft response: user reviews and edits.
- Never auto-send. Send is irreversible.
- If a regulator, auditor, or LP email is detected: flag explicitly, do not draft response without compliance review path.

## Two artifacts

1. **Triage view** (rendered in chat or saved as Markdown): the prioritized inbox snapshot.
2. **Action queue** (added to `task-capture`): the items requiring follow-up beyond the triage window.

## Citation discipline

- Every classification cites the trigger (sender VIP, keyword match, project tag).
- `[UNSOURCED]` tag if classification is heuristic without explicit signal: user reviews before action.

## Quality bar

- Triage completes in under 5 minutes for inboxes up to 200 unread.
- URGENT count under 10 percent of total (otherwise threshold is too loose).
- Suggested drafts respect the user's house tone (learned from native memory over time).
- Zero false-negative on regulator / LP / auditor correspondents.

## Disclaimer

This skill assists with email management. It does not constitute legal, regulatory, or contractual advice. The user is responsible for the content and timeliness of all sent communications.
