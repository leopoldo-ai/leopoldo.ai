---
name: change-management
version: 0.1.0
description: "Use when planning, communicating, and tracking adoption of organizational changes (restructuring, process redesign, digital transformation, culture change). NOT technical change management. For release/deploy use release-manager."
type: technique
metadata:
  author: internal
  source: custom
  license: proprietary
  forge_strategy: build
  forge_sources: []
  created: 2026-03-13
---

# Change Management

Framework for managing organizational change: from readiness diagnosis to post-implementation sustainability. Covers restructuring, digital transformation, process redesign, and culture change.

## Why It Exists

| Problem | Solution |
|---------|----------|
| 70% of change initiatives fail | Structured process based on Kotter + ADKAR |
| Resistance not mapped or managed | Systematic resistance analysis with response strategies |
| Inconsistent and late communication | Structured communication plan by stakeholder |
| Adoption declared but not verified | Adoption metrics and systematic tracking |

## Core Workflow

### Phase 1 — Change Readiness Assessment

Before planning the change, assess the organization's readiness.

**Template — Readiness Assessment:**

| Dimension | Score (1-5) | Evidence | Required Action |
|-----------|------------|----------|-----------------|
| **Leadership commitment** | | Sponsor identified? Budget allocated? Dedicated time? | |
| **Urgency** | | Does the organization perceive the need for change? | |
| **Vision clarity** | | Is the future state clear and communicable in 1 sentence? | |
| **Capacity** | | Does the organization have resources/time for the change? | |
| **Culture** | | Does the culture support change or will it hinder it? | |
| **Track record** | | Were past changes managed well? | |

**Scoring:**
- **25-30**: High readiness — proceed with full plan
- **18-24**: Moderate readiness — strengthen weak dimensions before starting
- **<18**: Low readiness — high risk of failure, address prerequisites first

---

### Phase 2 — Kotter 8-Step Framework

| Step | Phase | Key Activities | Output | Check |
|------|-------|----------------|--------|-------|
| 1 | **Create urgency** | Data on the cost of inaction, competitive benchmark, burning platform | Case for change (1 pager) | [ ] Leadership aligned on urgency |
| 2 | **Build guiding coalition** | Identify champions per function, form the change team | Coalition map with roles | [ ] Coalition representative and committed |
| 3 | **Form strategic vision** | Define future state, benefits for each stakeholder group | Vision statement + elevator pitch | [ ] Vision tested with 3 target groups |
| 4 | **Enlist volunteer army** | Recruit early adopters, create change ambassadors | Change agent network | [ ] At least 1 agent per team/function |
| 5 | **Enable action** | Remove barriers (processes, tools, skills, incentives) | Barrier removal plan | [ ] Top 3 barriers addressed |
| 6 | **Generate short-term wins** | Plan and celebrate visible results within 30-60 days | Win tracker with communication | [ ] At least 2 quick wins communicated |
| 7 | **Sustain acceleration** | Consolidate progress, address the second wave of resistance | Momentum dashboard | [ ] Metrics trending positively |
| 8 | **Institute change** | Embed in norms, policies, processes, performance evaluation | Updated policy/process | [ ] Change embedded in BAU |

---

### Phase 3 — ADKAR Model (per individual)

ADKAR works at the individual level, complementing Kotter (which works at the organizational level).

| Phase | Key Question | Tools | Indicator |
|-------|-------------|-------|-----------|
| **A** — Awareness | Does the person understand WHY the change is necessary? | Town hall, FAQ, 1:1 | Can explain the reasons in 2 sentences |
| **D** — Desire | Does the person WANT to support the change? | WIIFM (What's In It For Me), listening to objections | Expresses active support or at least non-resistance |
| **K** — Knowledge | Does the person KNOW HOW to operate in the new way? | Training, coaching, documentation | Passes assessment / demonstrates competence |
| **A** — Ability | Is the person ABLE to implement the change day-to-day? | Practice, mentoring, on-the-job support | Performance in the new way stable for 2+ weeks |
| **R** — Reinforcement | Is the change SUSTAINED over time? | Feedback, recognition, metrics, consequences | No regression at 90 days |

**Template — ADKAR Assessment per group:**

| Group | A (1-5) | D (1-5) | K (1-5) | A (1-5) | R (1-5) | Bottleneck | Action |
|-------|---------|---------|---------|---------|---------|-----------|--------|
| Management | | | | | | | |
| Middle management | | | | | | | |
| Operations | | | | | | | |
| IT/Support | | | | | | | |

**ADKAR rule**: Phases are sequential. Training (K) is pointless without desire (D). Always intervene on the first phase with a low score.

---

### Phase 4 — Resistance Analysis

**Types of resistance and strategies:**

| Type | Signals | Response Strategy |
|------|---------|-------------------|
| **Logical** (rational) | "It doesn't make sense because...", supporting data | Respond with better data, open dialogue, incorporate valid feedback |
| **Psychological** (emotional) | Anxiety, fear, sense of loss | Empathetic listening, accompaniment, time to process |
| **Sociological** (group) | "The team disagrees", resistance coalitions | Engage opinion leaders, positive peer pressure, visible quick wins |
| **Passive** | Silence, surface compliance, slowdown | 1:1, safe space to express objections, aligned incentives |

**Template — Resistance Map:**

| Stakeholder/Group | Change Impact | Resistance Level (1-5) | Resistance Type | Specific Action | Owner |
|-------------------|--------------|------------------------|----------------|-----------------|-------|
| | High/Medium/Low | | Logical/Psychological/Sociological/Passive | | |

---

### Phase 5 — Communication Plan

**Template — Communication Schedule:**

| Date | Audience | Key Message | Channel | Sender | Required Action | Feedback Loop |
|------|----------|------------|--------|--------|-----------------|--------------|
| T-30 | Leadership | Rationale and vision | Board meeting | CEO/Sponsor | Approval | Q&A in meeting |
| T-14 | Middle management | Impact and timeline | Workshop | Change lead | Prepare the teams | Feedback form |
| T-7 | Everyone | Official announcement | Town hall + email | CEO | Awareness | FAQ + dedicated channel |
| T | Everyone | Go-live | Email + intranet | Change lead | Specific action | Help desk |
| T+7 | Everyone | First results | Newsletter | Change lead | Continue | Survey |
| T+30 | Management | Status and metrics | Dashboard review | Change lead | Decisions | Retro |

**Communication principles:**
1. **Managers first, then the team**: managers must know first so they can answer questions
2. **Frequency > perfection**: communicate often, even if information is partial
3. **Two-way**: every communication must have a feedback channel
4. **Consistency**: the same message from all levels of leadership

---

### Phase 6 — Adoption Tracking

**Adoption metrics:**

| Metric | How to Measure | Target | Frequency |
|--------|---------------|--------|-----------|
| **Awareness** | Survey: "Do you know why we are changing?" | >90% | Pre and post announcement |
| **Training completion** | Training records | 100% target group | Weekly |
| **Behavioral adoption** | Observation: % using the new process | >70% at T+30, >90% at T+90 | Weekly |
| **Proficiency** | Assessment or performance KPI | Baseline reached | Monthly |
| **Satisfaction** | Post-change survey | NPS >= 0 | T+30 and T+90 |
| **Sustainability** | No regression at 90 days | 0 regressions | T+90 |

**Template — Adoption Dashboard:**

```
ADOPTION DASHBOARD
==================
Change          : [name]
Go-live date    : [date]
Week            : T+[n]

METRICS
-------
Awareness       : ___% (target: 90%)   [🟢/🟡/🔴]
Training        : ___% (target: 100%)  [🟢/🟡/🔴]
Adoption        : ___% (target: 70%)   [🟢/🟡/🔴]
Proficiency     : ___% (target: base)  [🟢/🟡/🔴]
Satisfaction    : NPS ___ (target: 0)   [🟢/🟡/🔴]

TREND: [improving / stable / declining]

CORRECTIVE ACTIONS
------------------
-
```

---

## Rules

1. **Readiness first**: do not start without a readiness assessment (score >= 18)
2. **Kotter + ADKAR together**: Kotter for the organization, ADKAR for individuals — they are not alternatives
3. **Mandatory communication plan**: no change without a structured communication plan
4. **Resistance is information**: do not ignore it, analyze it. Logical resistance often improves the plan
5. **Quick win within 60 days**: without visible early results, momentum dies
6. **Adoption measured, not declared**: use objective metrics, not managers' "feeling"

## Anti-patterns

| Anti-pattern | Why It Is Wrong |
|-------------|----------------|
| Announcing the change via email and nothing else | No dialogue, resistance not intercepted |
| Training without Awareness and Desire | Waste of resources, people don't understand why |
| Ignoring middle management | Managers are the bottleneck for adoption |
| Declaring victory too early | The change is not sustainable without Kotter steps 7-8 |
| Treating all resistance as irrational | Logical resistance often signals real problems in the plan |
| One-size-fits-all communication plan | Different groups have different information needs |

---

> **v0.1.0** | Domain skill | Pack: essentials
