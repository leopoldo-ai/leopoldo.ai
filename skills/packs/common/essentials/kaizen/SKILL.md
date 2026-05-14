---
name: kaizen
version: 0.1.0
description: "Use when analyzing process inefficiencies, performing root cause analysis (5 Whys, Ishikawa), running PDCA cycles, or planning Kaizen events for continuous improvement of business processes. For code debugging use systematic-debugging. For discrete project reflection use retrospective."
type: technique
metadata:
  author: internal
  source: custom
  license: proprietary
  forge_strategy: build
  forge_sources:
    - "Inspired by NeoLabHQ/context-engineering-kit kaizen methodology (license unclear — BUILD, not ADAPT)"
  created: 2026-03-13
tier: essentials
status: ga
---

# Kaizen

Continuous improvement methodology for business processes. Based on the Japanese Lean/Kaizen philosophy: small incremental improvements, consistently repeated, produce transformative results over time.

## Why It Exists

| Problem | Solution |
|---------|----------|
| Inefficient processes tolerated as "normal" | Systematic observation (Gemba) + structured analysis |
| Problems solved at symptom level, not root cause | 5 Whys + Ishikawa to find the true cause |
| Sporadic improvements, not sustainable | PDCA cycle with verification and standardization |
| No culture of improvement | Kaizen events as regular practice |

## Coexistence

| Skill | Focus | When |
|-------|-------|------|
| `kaizen` | Continuous process improvement | Ongoing, proactive |
| `retrospective` | Discrete reflection at project/phase end | Event-based, reactive |
| `systematic-debugging` | Debugging technical/code problems | Bug-triggered |

## Core Workflow

### Phase 1 — Gemba (Observation)

"Gemba" = go where the work happens. Observe the process before analyzing it.

**Template — Gemba Walk:**

| Field | Value |
|-------|-------|
| Process observed | |
| Observation date | |
| Observer | |
| Duration | |
| Process participants | |

**Observation guide:**

| What to Observe | Questions | Notes |
|----------------|---------|------|
| **Flow** | Does work flow without interruption? Where does it stop? | |
| **Waiting** | Where do people wait? What are they waiting for? | |
| **Rework** | Where are things done that were already done? Why? | |
| **Handoff** | How does work pass between people/teams? Is information lost? | |
| **Variability** | Is the process executed the same way every time? | |
| **Waste** | Activities that add no value for the customer? | |

**The 7 wastes (Muda) — checklist:**

1. **Overproduction**: doing more than necessary
2. **Waiting**: idle time between activities
3. **Transportation**: unnecessary movement of materials/information
4. **Over-processing**: doing more than what the customer requires
5. **Inventory**: accumulation of work in progress (WIP)
6. **Motion**: unnecessary movement of people
7. **Defects**: errors requiring rework

---

### Phase 2 — Root Cause Analysis

#### 5 Whys

For each identified problem, ask "why?" 5 times (or until the root cause is found).

**Template — 5 Whys:**

```
PROBLEM: [specific problem description]

Why 1: [answer] → verified? [Yes/No]
  Why 2: [answer] → verified? [Yes/No]
    Why 3: [answer] → verified? [Yes/No]
      Why 4: [answer] → verified? [Yes/No]
        Why 5: [answer] → verified? [Yes/No]

ROOT CAUSE: [answer to the last "why"]
TYPE: Process / People / Technology / Policy / Environment
```

**5 Whys rules:**
- Every "why" must be verifiable with data or observation
- If at the 3rd "why" you arrive at "people don't do X", ask yourself "why doesn't the process make it easy to do X?"
- Often the root cause is in the process or system, not in people
- If the problem has multiple causes, run 5 Whys for each branch (branching)

#### Ishikawa (Fishbone) Diagram

For complex problems with multiple causes.

```
         People           Processes        Technology
            \                |                /
             \               |               /
              \              |              /
               ============ PROBLEM ============
              /              |              \
             /               |               \
            /                |                \
       Materials/          Policy/           Environment/
       Information         Metrics           Context
```

**Template — Ishikawa per category:**

| Category | Potential Causes | Evidence | Priority |
|----------|-----------------|----------|----------|
| **People** | Skills, training, motivation, workload | | |
| **Processes** | Missing, redundant, unclear, undocumented steps | | |
| **Technology** | Inadequate tools, bugs, integration, performance | | |
| **Materials/Info** | Incomplete inputs, incorrect data, missing documentation | | |
| **Policy/Metrics** | Contradictory rules, misaligned KPIs, perverse incentives | | |
| **Environment** | Organizational context, culture, time pressure, resources | | |

---

### Phase 3 — PDCA Cycle

**Plan-Do-Check-Act** — the fundamental cycle of continuous improvement.

**Template — PDCA:**

```
PDCA CYCLE #___
===============
Process     : [name]
Problem     : [description]
Root cause  : [from 5 Whys / Ishikawa]
Start date  : [date]

PLAN — Plan the countermeasure
-------------------------------
Countermeasure     : [what we will do]
Expected result    : [target metric]
Current baseline   : [current metric]
Responsible        : [owner]
Timeline           : [start date — end test date]
Required resources : [what is needed]

DO — Execute (on reduced scale)
--------------------------------
Execution date     : [date]
Test scope         : [where/on whom we test — not the entire org]
Observations       : [what happened]
Deviations from plan: [what went differently]

CHECK — Verify results
------------------------
Baseline metric    : [pre value]
Post-test metric   : [post value]
Delta              : [improvement %]
Target reached?    : [Yes / Partially / No]
Side effects       : [positive or negative, unplanned]

ACT — Standardize or adjust
-----------------------------
[ ] STANDARDIZE — the improvement works:
    - Update process documentation
    - Communicate the new standard
    - Train those who did not participate in the test
    - Monitor for 30 days

[ ] ADJUST — the improvement does not work:
    - Analyze why it did not work
    - Modify the countermeasure
    - Start a new PDCA cycle

NEXT CYCLE: [date] — [focus]
```

---

### Phase 4 — Kaizen Event (for structured improvements)

A Kaizen Event is a focused 1-5 day workshop to solve a specific problem.

**Template — Kaizen Event Charter:**

| Field | Value |
|-------|-------|
| Target process | |
| Problem/opportunity | |
| Scope (in/out) | |
| Target metric | [from X to Y] |
| Team | [3-7 cross-functional people] |
| Sponsor | |
| Duration | [1-5 days] |
| Date | |

**Typical agenda (3 days):**

| Day | Activities | Output |
|-----|----------|--------|
| **Day 1** | Gemba walk + AS-IS process mapping + 5 Whys/Ishikawa | Current state map + root causes |
| **Day 2** | Countermeasure brainstorming + TO-BE process design + PDCA plan | Future state map + action plan |
| **Day 3** | Quick win implementation + testing + standardization | Improved process + metrics |

**Mandatory follow-up:**
- T+7: metrics check
- T+30: sustainability verification
- T+90: standardization confirmation

---

### Phase 5 — Improvement Tracker

Track all improvements in a central register.

**Template — Improvement Log:**

| # | Date | Process | Problem | Root Cause | Countermeasure | Owner | PDCA Status | Pre Metric | Post Metric | Delta |
|---|------|---------|---------|-----------|---------------|-------|-------------|-----------|------------|-------|
| K1 | | | | | | | P/D/C/A/Done | | | |
| K2 | | | | | | | | | | |

---

## Rules

1. **Gemba before analyzing**: observe the real process, not the documented one
2. **Root cause, not symptom**: use 5 Whys or Ishikawa — do not stop at the surface
3. **Test before standardizing**: PDCA requires a reduced-scale test before rollout
4. **Small and frequent**: prefer 10 small improvements over 1 large transformation
5. **Data, not opinions**: every improvement must have a measurable metric
6. **Follow-up at 30 days**: an unverified improvement is not an improvement

## Anti-patterns

| Anti-pattern | Why It Is Wrong |
|-------------|----------------|
| Skipping Gemba and analyzing "from the desk" | Working on assumptions, not reality |
| 5 Whys ending with "people are lazy" | Blame game, not root cause. Does the system make it easy to do the right thing? |
| Implementing without testing (no PDCA) | Risk of making things worse, no verification |
| Kaizen event without follow-up | The improvement regresses within 2 weeks |
| Improvement without metric | You don't know if you improved or worsened |
| Only big-bang transformation, never small kaizen | High risk, slow, organizational resistance |

---

> **v0.1.0** | Domain skill | Pack: essentials
