---
name: structured-note
version: 0.1.0
description: "Use when capturing notes during a call or a review with structured fields (attendees, key points, decisions, action items, follow-ups) ready for routing to CRM, decision log, or task capture."
type: technique
tier: essentials
status: ga
metadata:
  author: internal
  source: custom
  license: proprietary
---

# Structured Note

## Why it exists

Notes taken during calls and reviews are the input to half of Leopoldo's downstream skills (decision-log captures the decisions, task-capture captures the actions, meeting-prep-pack updates the next-meeting briefing, CRM logs the interaction). Free-text notes are useful for the moment; structured notes are useful for the system. This skill captures notes in 1 to 2 minutes after a call with enough structure for clean routing, without forcing the user into a template-heavy form during the call itself.

## Out of scope

- Not a transcription tool. Granola, Otter, native Cowork transcription handle the audio-to-text. We structure what's already typed or transcribed.
- Not a meeting recording. We work from notes the user already has.
- Not the CRM activity write itself. We prepare; user reviews; CRM write happens via Manatal or equivalent MCP if configured.

## Core workflow

### Phase 1: Capture trigger

User says one of:

- "Note from this call"
- "Structure these notes" (pasting raw text)
- "I just spoke with X, here are the points"

Or skill is invoked at the end of a Granola transcript (where transcript exists, the structured note is generated automatically and presented for review).

### Phase 2: Structured fields

Standard fields, in order:

| Field | Required | Notes |
|---|---|---|
| Date and time | Yes | Default: now |
| Attendees | Yes | Named individuals + roles, internal vs external flagged |
| Topic | Yes | One sentence: what the call was about |
| Key points | Yes | 3 to 7 bullets, observations and statements |
| Decisions made | Optional | Routed to `decision-log` if non-empty |
| Action items | Optional | Routed to `task-capture` if non-empty |
| Follow-ups (us to them) | Optional | What we owe them |
| Follow-ups (them to us) | Optional | What they owe us |
| Sensitivities | Optional | Flagged topics (compliance, personnel, restricted-list) |
| Free text | Optional | Anything that does not fit above |

### Phase 3: Auto-routing

After user reviews and confirms:

- Decisions → `decision-log` with this note as source
- Action items → `task-capture` with project / deal tag inherited from the call context
- Follow-ups (us to them) → `task-capture` with due date suggested
- Follow-ups (them to us) → `task-capture` with reminder (no due date, prompt for follow-up if overdue)
- Sensitivities → flagged in compliance queue if compliance-related
- Free text → kept as note attachment

### Phase 4: CRM write (optional)

If Manatal or another CRM MCP is configured, the user can confirm to push the note to the relevant account / contact / deal.

If not configured, the note is saved to the project / deal folder in standard format.

## Stop and surface

- Before any auto-routing: user reviews and edits.
- Before CRM write: explicit confirmation. Write is durable.
- If sensitivities flag is set: surface to compliance before any external action.

## Two artifacts

1. **Structured note** (Markdown card): the captured content, ready to share.
2. **Routed entries** (in `decision-log`, `task-capture`, optional CRM): the downstream artifacts created from this note.

## Citation discipline

- Every key point cites its source (transcript timestamp, attendee statement, document referenced).
- Information attributed to specific attendees uses their name, not "the client said".
- `[UNSOURCED]` for points that the user added without a clear source (own observation, hypothesis): allowed but flagged for the audit trail.

## Quality bar

- Note structuring takes under 2 minutes for a 30-minute call.
- All required fields completed (Date, Attendees, Topic, Key points).
- Decisions and Actions correctly routed to dedicated skills, no double-entry.
- Sensitivities never silently dropped.

## Disclaimer

This skill structures notes for internal use and downstream routing. It does not constitute a formal record of the meeting; where formal minutes are required (board, IC, regulator-facing), produce them separately per firm governance. Notes about individuals are sourced from the meeting; respect data protection rules (GDPR, FADP) when handling them.
