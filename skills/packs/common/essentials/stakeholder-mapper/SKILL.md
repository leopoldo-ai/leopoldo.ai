---
name: stakeholder-mapper
version: 0.1.0
description: "Use when mapping stakeholders, building influence matrices, or designing communication plans. Produces Mendelow 2x2 matrix, RACI, and communication plan."
type: pattern
metadata:
  author: internal
  source: custom
  license: proprietary
  forge_strategy: build
  forge_sources: []
  created: 2026-03-11
---

# Stakeholder Mapper

Structured stakeholder mapping with influence/interest analysis, RACI per deliverable, and communication plan. Transforms a list of names into an operational map that specifies who to manage how, when, and with what message.

## Why It Exists

| Problem | Solution |
|---------|----------|
| We don't know who can block the project | Mendelow 2x2: "Manage Closely" quadrant identifies critical stakeholders |
| Roles and responsibilities on deliverables are ambiguous | RACI matrix per workstream: clarifies who decides, who does, who is consulted |
| Communications go to everyone the same way | Personalized communication plan by audience, channel, and frequency |
| Champions and blockers are not identified in advance | Champion/Blocker analysis with motivation, risk, and approach angle |

## Core Workflow

### Phase 1 — Stakeholder Identification

Collect the complete list and classify each person by role and organizational level.

**Accepted inputs:**
- Free-form list of names (paste and I classify)
- Structured output from `people-intelligence` (profile card)
- Informal org chart provided by the client

**Classification table:**

| Name | Organization | Role / Title | Level | Type |
|------|-------------|-------------|-------|------|
| XX | Client | CEO | C-suite | Decision-maker |
| XX | Client | CFO | C-suite | Decision-maker |
| XX | Client | Head of IT | Director | Influencer |
| XX | Client | Project Sponsor | VP | Champion |
| XX | Client | Legal Counsel | Senior | Gate-keeper |
| XX | Supplier | Account Manager | Mid | Influencer |
| XX | Board | Independent Director | Board | Decision-maker |

**Stakeholder types:**

| Type | Definition |
|------|-----------|
| Decision-maker | Signs, approves, has veto |
| Champion | Actively supports, does internal lobbying |
| Blocker | Active or passive resistance, can slow down/stop |
| Influencer | Doesn't decide but steers those who do |
| Gate-keeper | Controls access to resources or information |
| Implementer | Executes, impact on adoption |
| Observer | Informed, no active power |

---

### Phase 2 — Influence / Interest Matrix (Mendelow)

Position each stakeholder in the 2x2 matrix based on **power/influence** (Y axis) and **interest in the project** (X axis).

**Mendelow Matrix:**

```
                    INTEREST
                  Low          High
              +-------------+--------------+
High          |  KEEP       |   MANAGE     |
POWER /       |  SATISFIED  |   CLOSELY    |
INFLUENCE     |             |              |
              +-------------+--------------+
Low           |   MONITOR   |   KEEP       |
              |             |   INFORMED   |
              +-------------+--------------+
```

**Tabular template:**

| Stakeholder | Power (1-5) | Interest (1-5) | Quadrant | Strategy |
|-------------|------------|----------------|----------|----------|
| XX (CEO) | 5 | 4 | Manage Closely | Direct involvement, frequent updates |
| XX (CFO) | 4 | 3 | Keep Satisfied | Periodic financial reporting |
| XX (Head IT) | 2 | 5 | Keep Informed | Technical newsletter, workshop |
| XX (Legal) | 3 | 2 | Keep Satisfied | Brief on legal risks when relevant |
| XX (Board) | 5 | 2 | Keep Satisfied | Quarterly executive summary |
| XX (Client PM) | 2 | 4 | Keep Informed | Weekly standup, Slack channel |

**Evaluation scale:**

| Dimension | 1 | 3 | 5 |
|-----------|---|---|---|
| Power / Influence | No authority | Indirect influence | Veto or final sign-off |
| Interest | Marginally involved | Affected by some outputs | Outcome critical for them |

---

### Phase 3 — RACI Matrix

Assign roles for each key deliverable or workstream.

**RACI Legend:**

| Code | Role | Definition |
|------|------|-----------|
| R | Responsible | Who performs the work |
| A | Accountable | Who has final ownership (only one per row) |
| C | Consulted | Who is consulted before decisions |
| I | Informed | Who receives updates after decisions |

**RACI Template (adapt for project deliverables):**

| Deliverable / Workstream | CEO | CFO | Head IT | Legal | Sponsor | Project PM |
|--------------------------|-----|-----|---------|-------|---------|------------|
| Project Charter | A | C | C | C | R | R |
| Budget Approval | A | R | I | I | C | I |
| Technical Architecture | I | I | A | I | C | R |
| Contract Review | I | C | I | A/R | I | I |
| Steering Committee | A | C | C | I | R | R |
| Final Deliverable | A | I | C | C | R | R |
| Change Request | A | C | C | C | R | R |

**RACI rule:** each row must have exactly one **A**. If there are multiple A's, the process is ambiguous — clarify or escalate.

---

### Phase 4 — Champion / Blocker Analysis

Identify stakeholders with an active position (pro or against) and define the approach.

**Champion/Blocker Template:**

| Stakeholder | Position | Motivation | Risk if Not Managed | Recommended Approach |
|-------------|----------|-----------|---------------------|---------------------|
| XX (Sponsor) | Champion | Internal visibility, career move | May lose interest if not nurtured | Co-authorship on key deliverables |
| XX (CEO) | Neutral | Not yet convinced of ROI | Becomes blocker if CFO raises concerns | Early win + quantitative data |
| XX (Head IT) | Blocker | Concerned about operational workload | Slows technical adoption | Involve in architectural design |
| XX (Legal) | Gate-keeper | Protecting against regulatory risk | Last-minute contractual block | Preventive brief, early draft review |
| XX (CFO) | Neutral | Focus on cost control | Budget veto if numbers unclear | Detailed business case with sensitivity |

**Blocker risk levels:**

| Level | Definition | Action |
|-------|-----------|--------|
| High | Formal veto or active sabotage | Dedicated mitigation plan, sponsor escalation |
| Medium | Passive resistance, delays, silos | Direct engagement, data sharing, quick wins |
| Low | Skepticism, disinterest | Newsletter, proof of concept, social proof |

---

### Phase 5 — Communication Plan

Define who receives what, when, on which channel, with what frequency.

**Communication Plan Template:**

| Stakeholder | Quadrant | Key Message | Channel | Frequency | Responsible | Notes |
|-------------|----------|------------|--------|-----------|-------------|------|
| CEO | Manage Closely | Strategic progress + risks | 1:1 meeting | Bi-weekly | Partner / Sponsor | Max 30 min, 1-page exec summary |
| CFO | Keep Satisfied | Budget status, forecast | Email + call | Monthly | Project PM | Financial dashboard attached |
| Head IT | Keep Informed | Technical updates, roadmap | Slack / Teams | Weekly | Tech Lead | Dedicated channel #project-it |
| Legal | Keep Satisfied | Contractual milestones, risks | Formal email | As needed + milestone | Project PM | Cc General Counsel if relevant |
| Board | Keep Satisfied | Executive summary | Written report | Quarterly | Partner | Max 2 pages, charts |
| Client PM | Manage Closely | Task status, blockers, decisions | Standup + email | Daily / bi-weekly | Project PM | Shared RACI tracking |
| Implementers | Keep Informed | What changes for them, support | Workshop + FAQ | Per milestone | Change Manager | Separate training plan |

**Communication calendar (monthly view):**

```
Week       | Mon | Tue | Wed | Thu | Fri
-----------+-----+-----+-----+-----+-----
W1         |     |1:1  |     |     | Report
           |     |CEO  |     |     | CFO
W2         |STD  |     |STD  |     |
           |PM   |     |IT   |     |
W3         |     |1:1  |     |     |
           |     |CEO  |     |     |
W4         |STD  |     |STD  |     | Monthly
           |PM   |     |IT   |     | Summary
```

*(STD = standup; 1:1 = direct meeting; adapt to the project's actual cadences)*

---

## Output Adapters

| Adapter | If Available | Fallback |
|---------|-------------|----------|
| Notion MCP | Interactive stakeholder database with views filtered by quadrant, RACI board per deliverable, communication log with dates and status | Markdown tables (Mendelow + RACI + communication plan) |
| Google Drive | XLSX export with separate sheets: Mendelow, RACI, Comm Plan, Champion/Blocker log | Markdown inline, manual export |
| Excel / xlsx-reports | Structured workbook with conditional formatting by quadrant and risk | Plain text with tables |

**Notion MCP — database structure:**

```
Database: Stakeholder Map — [Project Name]
Properties:
  Name (title) | Organization | Role | Level | Quadrant
  Power (1-5)  | Interest (1-5) | Position | Risk | Approach
  Comm channel | Comm frequency | Owner | Last contact
Views:
  - By Quadrant (grouped)
  - By Position (Champion/Blocker/Neutral)
  - Communication Calendar (by frequency)
```

---

## Rules

1. **One A per RACI row**: if there are multiple accountable, the process is broken — force clarity before delivering the matrix.
2. **Evidence-based Mendelow positioning**: not based on team perceptions. Verify with direct questions or data from `people-intelligence`.
3. **Champion/Blocker is dynamic**: re-evaluate at every milestone. A person can shift from Neutral to Blocker with a change in context.
4. **Communication plan = service contract**: every stakeholder must know what they receive and when. Present the plan at kick-off.
5. **No over-communication on Monitor**: stakeholders in the bottom-left should not be overloaded — risk of elevating their interest on undesirable aspects.
6. **Separate Influence Map from Org Chart**: formal power (title) and real power (influence) are often different — annotate discrepancies explicitly.

---

## Anti-patterns

| Anti-pattern | Why It Is Wrong | What to Do Instead |
|-------------|----------------|-------------------|
| RACI with all A's on every row | Means "everyone accountable" = nobody is | Choose a single owner per deliverable, even if uncomfortable |
| Static Mendelow for the entire project | Power and interest change with phases | Re-run the matrix at every phase gate or context change |
| Same communication plan for everyone | One-size-fits-all doesn't work for C-suite and implementers | Differentiate channel, frequency, and depth by quadrant |
| Ignoring "low-level" blockers | A middle manager with access to critical data can silently block | Map informal power as well, not just title |
| Confusing Champion with personal ally | The internal champion has their own goals — not unconditional | Understand their agenda and explicitly align incentives |

---

> **v0.1.0** | Domain skill | Pack: senior-consultant
