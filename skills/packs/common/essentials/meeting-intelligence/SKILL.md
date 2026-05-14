---
name: meeting-intelligence
version: 0.2.0
description: "Use when preparing IC memos, capturing meeting minutes, tracking action items, or managing follow-up workflows."
type: technique
metadata:
  author: internal
  source: custom
  license: proprietary
  forge_strategy: build
  forge_sources: ["Harvard Business Review — Making Every Meeting Matter (HBR Meeting Best Practices Collection)", "Schwarz — The Skilled Facilitator: A Comprehensive Resource for Consultants, Facilitators, Coaches (Jossey-Bass, 3rd ed.)", "CFA Institute — Investment Committee Best Practices (CFA Institute Research Foundation)", "Rogelberg — The Surprising Science of Meetings: How You Can Lead Your Team to Peak Performance (Oxford UP)"]
tier: essentials
status: ga
---

# Meeting Intelligence

IC memo, meeting minutes, action items tracking, follow-up workflow.
Structures information from meetings to make it actionable and traceable.

## Why It Exists

| Problem | Solution |
|---------|----------|
| Meetings without minutes — decisions lost | Meeting minutes template with highlighted decisions |
| Inconsistent IC memos across analysts | Standard framework for IC memos |
| Action items not tracked — follow-ups forgotten | Centralized tracker with owner and deadline |
| Too much time spent writing minutes | Pre-defined structure that accelerates drafting |

## Core Workflow

### Phase 1 — Pre-meeting

1. **Agenda**: define and distribute the agenda T-1 day
2. **Materials**: collect and distribute supporting materials
3. **IC memo** (if investment committee): prepare the memo with recommendation
4. **Participants**: confirm attendance and quorum (if required)

### Phase 2 — IC Memo (Investment Committee)

1. **Deal summary**: name, sector, size, type, source
2. **Investment thesis**: why to invest — 3-5 bullet points
3. **Key risks**: 3-5 main risks with mitigations
4. **Valuation**: range with methodology
5. **Portfolio fit**: impact on allocation and concentration
6. **Recommendation**: invest / pass / more info needed
7. **Conditions**: any conditions to proceed
8. **Attachments**: DD report, financial model, comparables

### Phase 3 — Meeting minutes

1. **Header**: date, time, location, attendees, absent
2. **Per agenda item**: discussion (key points), decision made, votes (if formal)
3. **Action items**: action, owner, deadline — in separate table
4. **Next meeting**: date and preliminary agenda
5. **Distribution**: within 24h of the meeting

### Phase 4 — Follow-up tracking

1. **Action item register**: all open actions from all meetings
2. **Status**: open / in progress / completed / overdue
3. **Review**: weekly check on overdue actions
4. **Escalation**: actions overdue > 7 days -> escalation to the owner's manager

## Rules

1. **Minutes within 24h**: distribute the minutes by the next day
2. **Decisions highlighted**: decisions must be visually distinct from discussion
3. **SMART action items**: specific, measurable, assigned, with deadline
4. **IC memo pre-distributed**: at least T-2 days to allow reading time
5. **Systematic follow-up**: weekly review of open actions

## Anti-patterns

| Anti-pattern | Consequence | Correction |
|-------------|-------------|------------|
| Meeting without agenda | Unfocused discussion, decisions not made | Agenda distributed T-1 day with items and timings |
| Minutes distributed after 1 week | Decisions forgotten, actions start late | Minutes within 24h of the meeting |
| Action items without owner or deadline | Nobody feels responsible | Every action: what, who, by when |
| IC memo distributed 30 minutes before the meeting | Members don't have time to prepare | IC memo distributed at least T-2 days |
| No tracking of decided actions | Decisions don't turn into actions | Action item register with weekly review |

---

> **v0.1.0** | Domain skill | Pack: investment-core
