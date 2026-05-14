---
name: decision-log
version: 0.1.0
description: "Use when capturing a decision made during a meeting, a deal review, an IC, or a client interaction, with rationale, source data, alternatives considered, and audit trail."
type: technique
tier: essentials
status: ga
metadata:
  author: internal
  source: custom
  license: proprietary
---

# Decision Log

## Why it exists

In regulated finance, decisions need a paper trail. An IC voting on a deal, a CFO approving an accrual, a CIO rebalancing the book, a compliance officer accepting a derogation: each decision will be reviewed by an auditor, a regulator, or an LP. Without a structured decision log, the rationale lives in memory and email threads. By the time anyone asks, the rationale is reconstructed (or invented). This skill captures decisions in 30 to 60 seconds with enough structure for an audit-trail queue and feeds compliance-engine and (where applicable) IC memo skills.

## Out of scope

- Not a substitute for IC minutes or board minutes. Those follow firm-specific governance and legal review.
- Not a substitute for compliance sign-off where required by regulation. We capture; compliance approves separately.
- Not a contractual record. Contractual decisions go through legal review and signature, not this log.
- Not a CRM activity. Client interactions feed CRM separately; only the decision portion lands here.

## Core workflow

### Phase 1: Capture trigger

User says one of:

- "Log this decision"
- "Decision: approved deal X for ticket size CHF 10M"
- "We are going long Y at 1 percent"

Or another skill suggests capture (`task-capture` after a decision-driven task, `meeting-prep` after a high-stakes call, `ic-memo-builder` after IC vote).

### Phase 2: Structured fields

Each decision captures:

| Field | Required | Notes |
|---|---|---|
| Decision title | Yes | "Approved deal X at CHF 10M ticket size" |
| Decision date | Yes | Default: today |
| Decision maker(s) | Yes | Named individuals or committee |
| Context | Yes | Brief paragraph: situation, what was decided |
| Rationale | Yes | Why this decision over alternatives |
| Alternatives considered | Yes (1 to 3) | What was rejected and why |
| Source data | Yes | Links: model, memo, deck, market data with citations |
| Conditions / triggers | Optional | What would invalidate or revisit this decision |
| Follow-up tasks | Optional | Routed to `task-capture` with this decision as source |
| Compliance flag | Yes | None / Notify / Approve required |

`[UNSOURCED]` source data blocks the log entry. Decisions cannot be captured without a citable source.

### Phase 3: Routing

Based on compliance flag:

- **None**: stored in user's decision log only.
- **Notify**: stored + notification to compliance officer (Cowork chat or email per firm policy).
- **Approve required**: stored as DRAFT, surfaces in compliance officer's approval queue, decision is not "live" until approval is logged.

For decisions tied to a deal, portco, or fund: routed to the relevant deal log, portco log, or fund decision log.

### Phase 4: Retrieval

Decision log is queryable by:

- Date range
- Decision maker
- Deal / portco / fund
- Compliance flag
- Status (logged / approved / rejected / revisited)

Used by:

- IC memo builder (extracts prior decisions for context)
- Compliance audit (surfaces decision sample for review)
- Investor letters (decision summary for LP transparency)
- Year-end review (pattern analysis on decisions)

## Stop and surface

- Always before storing: confirm rationale is non-empty and source data has citations.
- If compliance flag is "Approve required": decision is DRAFT until compliance officer approves; do not treat as decided.
- If decision contradicts a prior decision in the log within last 90 days: surface explicitly with diff.

## Two artifacts

1. **Decision card** (structured Markdown or JSON): the captured decision, retrievable by query.
2. **Audit-trail entry** (feeds compliance-engine): timestamp, actors, source, retention per firm policy.

## Citation discipline

- Every source citation explicit (model file, memo path, market data ticker + timestamp, regulator publication).
- `[UNSOURCED]` blocks capture entirely. No override.
- `[ESTIMATED]` allowed for forward-looking values (price target, IRR projection) but must include the calculation method.

## Quality bar

- Capture takes under 90 seconds per decision.
- 100 percent of decisions have rationale and source data (enforced).
- Compliance flag set on every decision (None / Notify / Approve required).
- Retrievable within 5 seconds via query.

## Disclaimer

This skill produces an internal decision-tracking artifact. It does not constitute IC minutes, board minutes, or a regulatory record. Where firm policy or regulation requires a specific format (IC minutes signed by chair, board resolutions, MAR-listed insider list), the responsible governance function produces that artifact separately. The decision log supports, does not replace.
