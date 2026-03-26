---
name: knowledge-base
version: 0.1.0
description: "Use when capturing project knowledge for reuse. Produces case studies, lessons learned, and reusable playbooks from completed projects and engagements."
skillos:
  layer: userland
  category: domain
  pack: essentials
  requires:
    hard: []
    soft: [engagement-manager]
  provides: [case-study, lessons-learned, consulting-playbook]
  triggers:
    - on: "task.category == 'knowledge-capture'"
      mode: suggest
    - on: "task.category == 'engagement-closure'"
      mode: suggest
  config: {}
metadata:
  author: internal
  source: custom
  license: proprietary
  forge_strategy: build
  forge_sources: []
  created: 2026-03-11
---

# Knowledge Base

Captures and structures knowledge produced by every completed project or engagement, transforming it into reusable assets: case studies, lessons learned, and methodological playbooks.

## Why It Exists

| Problem | Impact | Solution | Result |
|---------|--------|----------|--------|
| Knowledge stays in consultants' heads or local files | Every new engagement starts from scratch | Structured post-engagement capture with standard template | Searchable and persistent knowledge base |
| Case studies not anonymized or NDA-compliant | Reputational and legal risk | Template with "anonymized client" and generic sector fields | Safe use in proposals and onboarding |
| Lessons learned are not actionable | They don't improve future processes | Per-phase format with concrete improvement actions | Iterative methodological improvement process |
| New consultants lack reference material | Slow onboarding, repeated mistakes | Playbook per engagement type with checklists and templates | Reduced learning curve |

## Core Workflow

### Phase 1: Engagement Data Collection

Structured data collection before memory disperses.

**Input from engagement-manager (if available):**
- Engagement data: client, sector, type, duration, team
- Deliverable list with completion status
- Formal and informal feedback received

**Manual input (always required):**
- Lead consultant's personal notes
- Problems encountered and solutions adopted
- Deviations from the original plan
- Relevant client quotes (anonymized)

**Data collection checklist:**
- [ ] Engagement profile (type, sector, duration, team size)
- [ ] Original objectives vs results achieved
- [ ] Deliverables produced with links or references
- [ ] Client feedback (formal and informal)
- [ ] Scope or methodology variations
- [ ] Technical or relational issues that emerged
- [ ] Tools and frameworks used

---

### Phase 2: Case Study Generation

**Standard template — Case Study:**

```
TITLE: [Engagement type] in the [Generic sector] sector

CLIENT PROFILE (anonymized)
- Sector: [e.g., B2B Manufacturing, ~500 employees]
- Context: [Starting situation without identifiers]
- Trigger: [Why they engaged us]

PROBLEM
- Main problem: [1 sentence]
- Secondary problems: [2-3 bullet points]
- Constraints: [time, budget, organizational]

APPROACH
- Methodology applied: [framework used]
- Phases and duration: [summary timeline]
- Team and roles: [anonymous size and composition]
- Key decisions: [2-3 relevant methodological choices]

RESULTS
- Main result: [quantified if possible]
- Secondary results: [bullets]
- Metrics: [ROI, timelines, quality — anonymized]

KEY LESSON
- [1 transferable insight applicable to similar engagements]

TAGS: [sector] [engagement-type] [methodology] [client-size]
```

---

### Phase 3: Lessons Learned

**Standard template — Lessons Learned per Phase:**

```
ENGAGEMENT: [Internal ID, not client name]
DATE: [month/year]
TYPE: [Strategy / Operations / Change / Due Diligence / ...]

PHASE: Discovery & Diagnosis
  What worked:
    - [example: Day 1 stakeholder workshop aligned the team quickly]
  What DID NOT work:
    - [example: Preliminary survey not completed — data collected only in meetings]
  What to do differently:
    - [example: Send survey 2 weeks prior with personal follow-up]
  Improvement actions:
    - [ ] Update onboarding template with automatic survey reminder

PHASE: Analysis & Synthesis
  What worked: ...
  What DID NOT work: ...
  What to do differently: ...
  Improvement actions: ...

PHASE: Recommendations & Delivery
  What worked: ...
  What DID NOT work: ...
  What to do differently: ...
  Improvement actions: ...

PHASE: Stakeholder Management
  What worked: ...
  What DID NOT work: ...
  What to do differently: ...
  Improvement actions: ...

OVERALL RATING: [1-5] — explanation in 1 sentence
METHODOLOGY REUSABILITY: High / Medium / Low
```

---

### Phase 4: Playbook Creation

A playbook is created or updated when at least the second engagement of the same type is completed.

**Playbook structure per engagement type:**

```
PLAYBOOK: [Engagement type — e.g., "Organizational Redesign Mid-Market"]
VERSION: x.y
UPDATED: [date]
BASED ON: [n] engagements

WHEN TO USE
- Typical triggers: [list]
- Ideal client size: [range]
- Typical duration: [weeks]

PHASE CHECKLIST
Phase 1 — [Name]:
  [ ] Step 1
  [ ] Step 2
  ...

Phase 2 — [Name]:
  [ ] Step 1
  ...

TEMPLATE REFERENCES
- [Template name] → [path or link]

FIELD TIPS
- [Practical insight from real engagements]

COMMON PITFALLS
- [Frequent mistake] → [How to avoid it]

TYPICAL SUCCESS METRICS
- [KPI 1]: [expected range]
- [KPI 2]: [expected range]
```

---

### Phase 5: Knowledge Organization

**Tagging taxonomy:**

| Dimension | Values |
|-----------|--------|
| Engagement type | strategy, operations, change-management, due-diligence, digital, restructuring |
| Sector | manufacturing, financial-services, healthcare, retail, tech, public-sector |
| Client size | startup, sme, mid-market, enterprise |
| Methodology | lean, agile, design-thinking, six-sigma, mckinsey-7s, custom |
| Outcome | successful, partial, challenged |

**Linking to future proposals:**
- Every tagged case study becomes a reference for proposals on the same type/sector
- Updated playbooks become the basis for the "Our Approach" section in proposals
- Lessons learned feed the risk register of new proposals

---

## Output Adapters

| Adapter | Artifact | Structure | Searchability |
|---------|----------|-----------|---------------|
| **Notion MCP** (primary) | "Case Studies" database + "Playbooks" database + "Lessons" database | Structured properties (type, sector, date, tag), relations between databases | Full-text + property filters, queryable from future proposals |
| **Local Markdown** (fallback) | `knowledge-base/case-studies/`, `knowledge-base/playbooks/`, `knowledge-base/lessons/` | Files with YAML frontmatter + structured body | Grep/fzf on frontmatter, index.md for navigation |

**Notion MCP — database schema:**
- Case Studies: Title, Client Sector, Engagement Type, Date, Tags, Lessons (relation), Status
- Playbooks: Title, Engagement Type, Version, Last Updated, Based On (n engagements), Status
- Lessons Learned: Engagement ID, Date, Type, Phase, Rating, Linked Case Study (relation)

---

## Rules

1. **Mandatory anonymization**: no client name, person name, or identifying data in any artifact. Always use sector + generic size.
2. **Non-negotiable structured format**: always use the templates from Phases 2, 3, 4. Free-form output is not a knowledge base, it's a note.
3. **Actionable lessons learned**: every "what to do differently" must have at least one improvement action with checkbox. Insight without action = lost insight.
4. **Playbook only from 2+ engagements**: do not create a playbook from a single case. Minimum 2 engagements of the same type for reliable patterns.
5. **Fixed taxonomy tagging**: use only the tags from the taxonomy defined in Phase 5. Free tags fragment searchability.
6. **Capture within 72h of closure**: knowledge decays quickly. Capture must happen at most 3 days after formal engagement closure.

---

## Anti-patterns

| Anti-pattern | Why It Is a Problem | Correction |
|-------------|-------------------|------------|
| "I'll do it later" — capture postponed to end of week | 60% of operational details are lost within 48h | Structured capture in the engagement closure session |
| Narrative case study without template | Not searchable, not comparable, not reusable in proposals | Always use Phase 2 template, even if it takes more time |
| Generic lessons learned ("communication is important") | Does not change future behavior | Every lesson must be specific, contextual, and linked to an action |
| Overly detailed and prescriptive playbook | Discourages use, doesn't adapt to contexts | Essential structure + room for adaptation, max 2 pages per phase |
| Knowledge base without owner | Decays, falls out of sync, no one consults it | Assign a knowledge steward responsible for quarterly review |

---

> **v0.1.0** | Domain skill | Pack: senior-consultant
