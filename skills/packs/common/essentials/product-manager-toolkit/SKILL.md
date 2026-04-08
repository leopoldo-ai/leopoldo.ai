---
name: product-manager-toolkit
description: Product management toolkit for prioritizing initiatives, managing backlogs, creating PRDs and roadmaps. Use when performing RICE scoring, prioritizing work sessions, defining MVPs, managing trade-offs between initiatives, or analyzing the impact of product decisions.
---

# Product Manager Toolkit

A comprehensive toolkit for managing and prioritizing product initiatives, applicable to both software products and organizational transformation projects.

## RICE Scoring Framework

For every initiative, calculate the RICE score:

```
RICE Score = (Reach x Impact x Confidence) / Effort
```

### Parameter Definitions

**Reach** (how many people/users does it impact in one quarter)
| Score | Definition |
|-------|-----------|
| 10 | Small internal team or pilot group |
| 25 | A single department or user segment |
| 50 | Entire internal organization |
| 100 | Organization + external clients |
| 200+ | Organization + clients + end users / large user base |

**Impact** (contribution to strategic objective)
| Score | Definition | Example |
|-------|-----------|---------|
| 3 | Massive | Eliminates the #1 pain point, unlocks new capability |
| 2 | High | Significant efficiency gain or quality improvement |
| 1 | Medium | Meaningful but incremental improvement |
| 0.5 | Low | Nice-to-have optimization |
| 0.25 | Minimal | Marginal improvement |

**Confidence** (how certain are we about the estimates)
| Score | Definition |
|-------|-----------|
| 100% | Concrete data, direct user feedback, industry benchmarks |
| 80% | Solid qualitative feedback, domain expertise |
| 50% | Reasonable hypothesis but not validated |
| 20% | Intuition only, no supporting data |

**Effort** (person-weeks)
| Score | Definition |
|-------|-----------|
| 0.5 | Half a day (1 person) |
| 1 | 1 week (1 person) |
| 2 | 2 weeks |
| 4 | 1 month |
| 8 | 2 months |
| 12+ | Complex project (multi-month) |

## Backlog Management

### Backlog Item Format
```
## [INITIATIVE-ID] Initiative Title
- **Category/Pillar:** [area]
- **Phase/Sprint:** [N]
- **RICE Score:** [X]
- **Status:** Not Started | In Progress | Done
- **Owner:** [Name]
- **Dependencies:** [list]
- **Definition of Done:** [specific criteria]
- **Notes:** [additional context]
```

### Backlog Prioritization Rules
1. Sort by RICE score descending
2. Respect hard dependencies (blocked items cannot start)
3. Group quick wins (high RICE, low effort) for early momentum
4. Balance between phases: stabilize current operations before pursuing innovation

## PRD Template

When proposing a new initiative, document:

1. **Problem:** what is not working today (with evidence)
2. **Proposed solution:** what changes concretely
3. **Impacted users:** who is affected (internal teams, clients, end users)
4. **Success metrics:** how we measure the outcome
5. **Dependencies:** what must exist beforehand
6. **Risks:** what can go wrong and mitigations
7. **Timeline:** implementation estimate
8. **RICE Score:** complete calculation

## Roadmap Visualization

When requested, generate a roadmap in this format:

```
Phase 1 (Months 1-3)
+-- M1: Quick wins (highest RICE, lowest effort items)
+-- M2: Foundation work (core process/infrastructure)
+-- M3: Foundation completion + first major deliverable

Phase 2 (Months 4-6)
+-- M4-5: Core feature build-out
+-- M6: Integration and testing

Phase 3 (Months 7-9)
+-- M7-8: Advanced features and optimization
+-- M9: Launch preparation and rollout
```

Adapt phases and timelines to the specific project scope and team capacity.

## Trade-off Analysis

For complex prioritization decisions:
1. Identify competing criteria (speed vs quality, adoption vs completeness, scope vs timeline)
2. Weight the criteria in the specific project context
3. Present a decision matrix with scores
4. Recommend with explicit rationale

## Sprint / Session Planning

When planning work sessions or sprints:
1. Review backlog sorted by RICE score
2. Identify items that fit within available capacity
3. Check dependencies -- ensure prerequisites are met
4. Assign ownership and define expected outputs
5. Set review checkpoint at end of session/sprint

## Constraints
- **Pragmatism:** recommendations must be actionable with available resources
- **Evidence-based:** prioritize data and feedback over assumptions
- **Stakeholder awareness:** consider organizational readiness and adoption capacity when sequencing work
