---
name: retrospective
version: 0.1.0
description: "Use when running a retrospective at the end of a project, sprint, phase, or engagement for structured closure reflection. Multiple formats (Start/Stop/Continue, 4Ls, Mad/Sad/Glad, Sailboat). For continuous process improvement use kaizen instead."
type: technique
metadata:
  author: internal
  source: custom
  license: proprietary
  forge_strategy: build
  forge_sources: []
  created: 2026-03-13
---

# Retrospective

Framework for structured retrospectives at the end of a project, phase, sprint, or engagement. Supports 4 different formats to adapt to context. Generates traceable action items and feeds the knowledge base to capitalize on patterns.

## Why It Exists

| Problem | Solution |
|---------|----------|
| Generic retrospectives ("everything's fine") without insight | Structured formats that guide reflection |
| Action items identified but never executed | Template with owner, due date, and mandatory follow-up |
| Repeated patterns across different projects | Cross-retro analysis to identify recurring themes |
| Lessons learned not capitalized | Integration with knowledge base for persistence |

## Format Selection Guide

| Format | When to Use | Ideal Participants | Duration |
|--------|------------|-------------------|----------|
| **Start/Stop/Continue** | Sprint review, short cycles, mature teams | 3-8 people | 30-45 min |
| **4Ls** | End of project, medium teams, first retro | 4-12 people | 45-60 min |
| **Mad/Sad/Glad** | After stressful period, team needing emotional release | 3-10 people | 30-45 min |
| **Sailboat** | Combined planning + retrospective, visual teams | 5-15 people | 60-90 min |

---

## Core Workflow

### Phase 1 — Setup

**Context Header (all formats):**

| Field | Value |
|-------|-------|
| Project/Sprint/Phase | |
| Period | [start date — end date] |
| Facilitator | |
| Participants | |
| Chosen format | Start/Stop/Continue - 4Ls - Mad/Sad/Glad - Sailboat |
| Expected duration | |

**Facilitation rules:**
1. **Safe space**: no judgment, no personal blame — focus on processes and systems
2. **Everyone speaks**: initial round robin, then open discussion
3. **Timeboxing**: respect time per phase
4. **Prioritization**: not everything can be an action item — choose the top 3-5

---

### Phase 2 — Chosen Format

#### Format A: Start / Stop / Continue

| Column | Guiding Question | Examples |
|--------|-----------------|---------|
| **Start** | What should we start doing? | New practice, tool, process |
| **Stop** | What should we stop doing? | Waste, harmful practice, overhead |
| **Continue** | What is working and should we continue? | Best practice, cadence, tool |

**Template:**

```
START (begin doing)
-------------------
1.
2.
3.

STOP (stop doing)
-----------------
1.
2.
3.

CONTINUE (keep doing)
---------------------
1.
2.
3.
```

#### Format B: 4Ls (Liked, Learned, Lacked, Longed for)

| L | Guiding Question |
|---|-----------------|
| **Liked** | What did you like? What worked well? |
| **Learned** | What did you learn? New insights? |
| **Lacked** | What was missing? Resources, info, support? |
| **Longed for** | What would you have wanted? What do you wish for next time? |

**Template:**

```
LIKED
-----
1.
2.

LEARNED
-------
1.
2.

LACKED
------
1.
2.

LONGED FOR
----------
1.
2.
```

#### Format C: Mad / Sad / Glad

| Emotion | Guiding Question |
|---------|-----------------|
| **Mad** | What frustrated you? What made you angry? |
| **Sad** | What disappointed you? What didn't go as hoped? |
| **Glad** | What made you happy? What worked well? |

**Template:**

```
MAD (frustration)
-----------------
1.
2.

SAD (disappointment)
--------------------
1.
2.

GLAD (satisfaction)
-------------------
1.
2.
```

#### Format D: Sailboat

Visual metaphor: the project is a sailboat.

| Element | Meaning | Guiding Question |
|---------|---------|-----------------|
| **Wind** | What pushed us forward | What factors accelerated progress? |
| **Anchor** | What slowed us down | What obstacles held us back? |
| **Rocks** | Risks we avoided or hit | What risks materialized? Which did we avoid? |
| **Island** | Destination / objective | Did we reach the objective? How close are we? |
| **Sun** | What made us optimistic | What gives us confidence for the future? |

**Template:**

```
WIND (pushed us forward)
------------------------
1.
2.

ANCHOR (slowed us down)
-----------------------
1.
2.

ROCKS (risks)
-------------
1.
2.

ISLAND (objective reached?)
----------------------------
Achievement: ___% — [comment]

SUN (optimism)
--------------
1.
2.
```

---

### Phase 3 — Prioritization and Action Items

After collection, vote (dot voting or consensus) to identify the top 3-5 themes. For each, create an action item.

**Template — Action Items:**

| # | Theme | Specific Action | Owner | Due Date | Verification | Status |
|---|-------|----------------|-------|----------|-------------|--------|
| 1 | | | | | How will we verify it was done? | Open |
| 2 | | | | | | |
| 3 | | | | | | |

**Criteria for a good action item:**
- **Specific**: not "communicate better" but "daily 10-min standup at 9:30"
- **With owner**: one person, not "the team"
- **With deadline**: specific date, not "soon"
- **Verifiable**: objective completion criterion

---

### Phase 4 — Pattern Detection (Cross-Retro Analysis)

After 3+ retrospectives, analyze recurring patterns.

**Template — Cross-Retro Pattern Report:**

```
CROSS-RETRO ANALYSIS
====================
Period         : [from retro X to retro Y]
N. retrospectives: [n]
Teams/Projects : [list]

RECURRING THEMES (appeared in 2+ retros)
-----------------------------------------
| Theme | Frequency | Trend | Hypothesized Root Cause | Systemic Action |
|-------|-----------|-------|------------------------|----------------|
| | [n/total] retros | Stable/Worsening/Improving | | |

COMPLETED vs OPEN ACTION ITEMS
-------------------------------
Completed : ___/___  (___%)
Overdue   : ___
Effective : ___/___  (___%)

KEY INSIGHTS
------------
1.
2.

SYSTEMIC RECOMMENDATION
------------------------
[action to take at process/organization level]
```

---

### Phase 5 — Knowledge Base Integration

At retrospective closure, generate an entry for `knowledge-base`:

```
RETROSPECTIVE ENTRY → KNOWLEDGE BASE
=====================================
Project/Sprint  : [name]
Retro date      : [date]
Format used     : [format]
Participants    : [n]

TOP INSIGHTS
-----------
1. [most important insight with context]
2. [second insight]

REUSABLE PATTERNS
-----------------
- [practice that worked and can be replicated]

MISTAKES NOT TO REPEAT
----------------------
- [mistake with context and consequence]

KEY ACTION ITEMS
----------------
- [action] → owner: [name] → due: [date]
```

---

## Rules

1. **One format, not a mix**: choose a format and follow it. Mixing creates confusion
2. **Non-negotiable safe space**: if participants don't feel safe, the retro is useless
3. **Max 5 action items**: better 3 actions done than 10 forgotten
4. **Follow-up in the next retro**: the next retrospective always opens with the status of previous action items
5. **Pattern detection after 3+**: do not draw systemic conclusions from 1-2 retros
6. **Knowledge base at closure**: every retro generates at least one entry for the knowledge base

## Anti-patterns

| Anti-pattern | Why It Is Wrong |
|-------------|----------------|
| Retro only when things go badly | Positive patterns are lost, the retro becomes punitive |
| Facilitator = direct manager | People don't speak freely |
| No action items | Emotional venting without concrete improvement |
| Action items without owner or deadline | They will never be executed |
| Ignoring recurring patterns | The same problem repeats endlessly |
| 2-hour retro without timeboxing | Exhaustion, circular discussions |

---

> **v0.1.0** | Domain skill | Pack: essentials
