---
name: calendar-prep
version: 0.1.0
description: "Use when planning the day or the week, surfacing meetings that need preparation time, identifying conflicts, and proposing prep blocks before high-stakes calls."
type: technique
tier: essentials
status: ga
metadata:
  author: internal
  source: custom
  license: proprietary
---

# Calendar Prep

## Why it exists

A senior professional spends 15 to 25 hours per week in scheduled meetings. Half of those need prep (read the deck, brief the team, review the file); the other half do not. Most calendars do not distinguish. The user walks into client pitches under-prepped and into status calls over-prepped. This skill surfaces which meetings need prep, how much, and when to block it. It does not own the calendar; Outlook or Google Calendar remain the booking surface.

## Out of scope

- Not a calendar app. We read, we propose, we do not write events without explicit user confirmation.
- Not a meeting prep producer. Use `meeting-prep` agent or `meeting-prep-pack` skill for the briefing pack.
- Not an availability finder for external scheduling. Use Calendly / Cal.com for that.

## Core workflow

### Phase 1: Time horizon

Default: today plus the next 5 working days. User can extend to 2 weeks.

### Phase 2: Meeting classification

For each event in the window:

| Class | Signal | Prep need |
|---|---|---|
| HIGH-STAKES | External attendee from VIP segment (LP, regulator, key client, prospect, board) | 30 to 60 min prep |
| DECISION | Meeting title contains decision keywords (IC, vote, approval, sign-off) | 20 to 45 min prep |
| WORKING | Internal, recurring, status update | 5 to 10 min prep |
| FLOW | 1:1, recurring catch-up, no agenda change | 0 prep |
| AT-RISK | Conflict, double-booked, missing room or dial-in | Resolve before classifying |

### Phase 3: Conflict detection

Surface:

- Hard conflicts (overlapping events)
- Soft conflicts (back-to-back without buffer)
- Logistics gaps (no dial-in, no room, no attendee list)
- Travel implications (in-person events without travel time blocked)

### Phase 4: Prep block proposal

For each HIGH-STAKES and DECISION meeting, propose a prep block 24 to 48 hours before. Default duration scales with stakes (HIGH-STAKES 45-60 min, DECISION 20-30 min). User confirms before block is added to calendar.

### Phase 5: Output

Produce a structured weekly view:

- Today: meetings, prep status, action items
- Next 2 days: HIGH-STAKES needing prep, conflicts to resolve
- Rest of week: DECISION meetings to review, prep blocks to confirm

Each entry: time, title, classification, prep need, suggested next step.

### Phase 6: Integration

- HIGH-STAKES meetings auto-route to `meeting-prep` agent for briefing pack assembly.
- Conflicts and AT-RISK items auto-flag for user resolution.
- Prep blocks added to `task-capture` if user wants them tracked alongside other work.

## Stop and surface

- Before adding any block to the actual calendar: user confirms.
- Before declassifying a HIGH-STAKES meeting: user explicit override required.
- For meetings with regulators or auditors: never auto-classify as WORKING; default to HIGH-STAKES until user confirms otherwise.

## Two artifacts

1. **Weekly calendar view** (Markdown or rendered card): classification + prep status across the horizon.
2. **Prep block queue** (added to user's actual calendar after confirmation): the time blocks reserved for high-stakes prep.

## Citation discipline

- Every classification cites the trigger (attendee VIP segment, keyword match, recurrence pattern).
- Conflicts cite the overlapping events explicitly.
- `[UNSOURCED]` if classification is heuristic without explicit signal.

## Quality bar

- Calendar prep view delivered in under 30 seconds for a typical week.
- Zero false-negative on HIGH-STAKES (user reviews before any classification override).
- Prep blocks proposed at least 24 hours before the meeting.
- Conflicts surfaced before they create logistics failures.

## Disclaimer

This skill assists with calendar planning. It does not own the calendar; the user remains responsible for accepting, declining, and attending events. Information on external attendees is sourced from the meeting invite and CRM; verify accuracy where it matters.
