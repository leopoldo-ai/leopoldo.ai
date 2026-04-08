# RICE Scoring & Decision Matrix Guide

Detailed methodology for scoring features using RICE prioritization and the weighted decision matrix.

## Table of Contents

1. [RICE Framework](#rice-framework)
2. [Weighted Decision Matrix](#weighted-decision-matrix)
3. [Dimension Scoring Rubrics](#dimension-scoring-rubrics)
4. [Weight Profiles](#weight-profiles)
5. [Comparison Mode](#comparison-mode)
6. [Worked Examples](#worked-examples)

---

## RICE Framework

### What is RICE?

RICE is a prioritization framework that scores features across four factors:

| Factor | Question | Unit |
|--------|----------|------|
| **Reach** | How many users/sessions will this impact per quarter? | Users or events |
| **Impact** | How much will it move the target metric per user? | Score 0.25-3 |
| **Confidence** | How sure are we about reach, impact, and effort estimates? | Percentage |
| **Effort** | How many person-days to implement? | Person-days |

### RICE Score Formula

```
RICE = (Reach × Impact × Confidence) / Effort
```

### Reach Scoring (1-5 scale for this tool)

| Score | Reach | Description |
|-------|-------|-------------|
| 5 | 100% of users | Affects every user of the tool |
| 4 | 50-80% of users | Affects most users (core feature) |
| 3 | 20-50% of users | Affects a significant segment |
| 2 | 5-20% of users | Niche feature, power users only |
| 1 | < 5% of users | Edge case, very few users |

**For FSE context:** "Users" = financial operators building plans. Small user base → focus on use-case coverage rather than raw numbers.

### Impact Scoring (1-5 scale)

| Score | Impact | Description |
|-------|--------|-------------|
| 5 | Massive | 3× or more improvement on key metric |
| 4 | High | 2× improvement, removes major pain point |
| 3 | Medium | Notable improvement, saves significant time |
| 2 | Low | Minor improvement, nice-to-have |
| 1 | Minimal | Barely noticeable impact |

**Key metrics for FSE:**
- Time to complete a financial plan (target: 1 day vs 1 month)
- Accuracy of financial projections
- Number of scenarios an operator can manage
- Export quality and completeness

### Confidence Scoring

| Score | Confidence | Description |
|-------|-----------|-------------|
| 5 | 90-100% | Strong data, proven concept, team has expertise |
| 4 | 70-89% | Good data, reasonable estimates |
| 3 | 50-69% | Some data, educated guesses |
| 2 | 30-49% | Mostly assumptions, new territory |
| 1 | < 30% | Pure speculation, high uncertainty |

**How to assess confidence:**
- Do we have user feedback requesting this? (+20%)
- Has competitor implemented it? (+10%)
- Does the team have implementation experience? (+20%)
- Is the technical approach validated? (+20%)
- Do we have data to estimate reach? (+15%)
- Do we have data to estimate effort? (+15%)

### Effort Scoring (1-5 scale, inverted)

| Score | Effort | Description |
|-------|--------|-------------|
| 5 | < 2 days | Trivial, quick change |
| 4 | 2-5 days | Small feature, limited scope |
| 3 | 1-2 weeks | Medium feature, multi-file |
| 2 | 2-4 weeks | Large feature, multi-module |
| 1 | > 1 month | Epic, significant rearchitecture |

**Note:** In the decision matrix, higher score = less effort = better. This inverts the raw effort number.

---

## Weighted Decision Matrix

### Standard Weights

| Dimension | Weight | Skill Used | What It Measures |
|-----------|--------|-----------|-----------------|
| Product (RICE) | 25% | `product-manager-toolkit` | User value, reach, impact |
| Technical Feasibility | 20% | `senior-architect` + `fullstack-developer` | Complexity, effort, tech debt |
| Financial ROI | 25% | `cfo` or `financial-analyst` | Cost, revenue impact, ROI |
| Strategic Alignment | 20% | `strategy-advisor` | Market positioning, vision fit |
| UX Impact | 10% | `ux-researcher-designer` | Usability, design effort |

### Final Score Calculation

```
Final Score = Σ (Dimension Score × Weight)

Example:
Product:    4/5 × 0.25 = 1.00
Technical:  3/5 × 0.20 = 0.60
Financial:  5/5 × 0.25 = 1.25
Strategic:  4/5 × 0.20 = 0.80
UX:         3/5 × 0.10 = 0.30
                  Total = 3.95 → Go ✅
```

### Verdict Thresholds

| Range | Verdict | Action |
|-------|---------|--------|
| 4.0-5.0 | ⭐ **Strong Go** | Prioritize immediately, start next sprint |
| 3.0-3.9 | ✅ **Go** | Schedule for next sprint/phase |
| 2.0-2.9 | ⚠️ **Conditional** | Needs refinement, reduce scope or improve ROI |
| 1.0-1.9 | ❌ **No Go** | Defer or discard, not worth investment now |

---

## Dimension Scoring Rubrics

### Product Score (1-5)

| Score | Criteria |
|-------|----------|
| 5 | RICE > 80th percentile, solves top user pain point, part of core value prop |
| 4 | RICE > 60th percentile, addresses known need, enhances core flow |
| 3 | RICE > 40th percentile, useful but not urgent |
| 2 | RICE > 20th percentile, marginal user benefit |
| 1 | RICE < 20th percentile, unclear user benefit |

### Technical Feasibility Score (1-5)

| Score | Criteria |
|-------|----------|
| 5 | < 2 days, no new deps, uses existing patterns, no tech debt |
| 4 | 2-5 days, minor architecture changes, well-understood |
| 3 | 1-2 weeks, moderate architecture changes, some unknowns |
| 2 | 2-4 weeks, significant changes, new patterns needed, adds tech debt |
| 1 | > 1 month, major rearchitecture, high risk of breaking changes |

### Financial ROI Score (1-5)

| Score | Criteria |
|-------|----------|
| 5 | ROI > 300% in 6 months, directly generates revenue |
| 4 | ROI > 150% in 6 months, enables revenue or reduces costs |
| 3 | ROI > 50% in 12 months, indirect revenue impact |
| 2 | ROI < 50% in 12 months, cost with limited return |
| 1 | Negative ROI, pure cost with no measurable return |

### Strategic Alignment Score (1-5)

| Score | Criteria |
|-------|----------|
| 5 | Core to company vision, competitive moat, market differentiator |
| 4 | Strongly aligned with roadmap, addresses market need |
| 3 | Somewhat aligned, supports general direction |
| 2 | Tangentially related, not on roadmap |
| 1 | Misaligned with strategy, distracting from core mission |

### UX Impact Score (1-5)

| Score | Criteria |
|-------|----------|
| 5 | Dramatically improves core workflow, delightful experience |
| 4 | Simplifies existing flow, removes friction |
| 3 | Minor UX improvement, slightly better experience |
| 2 | Neutral UX impact, necessary but not user-facing |
| 1 | Adds complexity, potential confusion, more cognitive load |

---

## Weight Profiles

Different decision contexts may require different weight profiles:

### Default (Balanced)

```
Product: 25%, Technical: 20%, Financial: 25%, Strategic: 20%, UX: 10%
```
Best for: Most feature decisions.

### Early Stage / MVP

```
Product: 30%, Technical: 25%, Financial: 15%, Strategic: 20%, UX: 10%
```
Best for: Product-market fit phase, speed matters most.

### Revenue Focus

```
Product: 20%, Technical: 15%, Financial: 35%, Strategic: 20%, UX: 10%
```
Best for: Post-PMF, optimizing for revenue and growth.

### Technical Excellence

```
Product: 15%, Technical: 35%, Financial: 15%, Strategic: 20%, UX: 15%
```
Best for: Platform stability phase, reducing tech debt.

### User Experience

```
Product: 20%, Technical: 15%, Financial: 15%, Strategic: 15%, UX: 35%
```
Best for: Design-led products, consumer-facing features.

---

## Comparison Mode

When comparing multiple features side-by-side:

### Comparison Matrix Template

```markdown
| Dimension (Weight) | Feature A | Feature B | Feature C |
|--------------------|-----------|-----------|-----------|
| Product (25%) | 4 → 1.00 | 3 → 0.75 | 5 → 1.25 |
| Technical (20%) | 3 → 0.60 | 4 → 0.80 | 2 → 0.40 |
| Financial (25%) | 5 → 1.25 | 3 → 0.75 | 4 → 1.00 |
| Strategic (20%) | 4 → 0.80 | 5 → 1.00 | 3 → 0.60 |
| UX (10%) | 3 → 0.30 | 2 → 0.20 | 4 → 0.40 |
| **Total** | **3.95** ✅ | **3.50** ✅ | **3.65** ✅ |
| **Rank** | **#1** | **#3** | **#2** |
```

### Ranking Rules

1. Primary sort: Final weighted score (descending)
2. Tiebreaker: Financial ROI score (higher wins)
3. Second tiebreaker: Technical feasibility score (easier wins)
4. If still tied: User chooses

### Visual Ranking

```
#1 ⭐ Feature A (3.95) — Strong financial ROI, technically feasible
#2 ✅ Feature C (3.65) — Best product fit but harder to build
#3 ✅ Feature B (3.50) — Strategic but lower ROI
```

---

## Worked Examples

### Example 1: "Add AI Chat Assistant to Planning Tool"

**Phase 1 — RICE:**
| Factor | Score | Rationale |
|--------|-------|-----------|
| Reach | 4/5 | 70% of users interact with data input daily |
| Impact | 4/5 | Saves ~30 min per session via smart suggestions |
| Confidence | 3/5 | 60% — team has limited AI integration experience |
| Effort | 2/5 | ~3 weeks (API integration, prompt engineering, UI) |

**Phase 2 — Decision Matrix:**
| Dimension | Score | Rationale |
|-----------|-------|-----------|
| Product | 4/5 | Strong RICE, addresses pain of manual data entry |
| Technical | 2/5 | New dependency (Claude API), prompt engineering, streaming UI |
| Financial | 3/5 | Indirect revenue (feature differentiation), API costs ~€500/mo |
| Strategic | 5/5 | Core differentiator vs Excel, positions as AI-first tool |
| UX | 4/5 | Conversational UI reduces learning curve |

**Result:** `(4×0.25) + (2×0.20) + (3×0.25) + (5×0.20) + (4×0.10) = 3.55` → **Go** ✅

### Example 2: "Add Dark Mode"

**Phase 2 — Decision Matrix:**
| Dimension | Score | Rationale |
|-----------|-------|-----------|
| Product | 2/5 | Nice-to-have, not blocking any workflow |
| Technical | 4/5 | ~3 days with CSS variables + Tailwind dark: |
| Financial | 1/5 | No revenue impact |
| Strategic | 1/5 | Not a differentiator |
| UX | 3/5 | Some users prefer dark mode for long sessions |

**Result:** `(2×0.25) + (4×0.20) + (1×0.25) + (1×0.20) + (3×0.10) = 2.05` → **Conditional** ⚠️

---

## Quick Analysis Mode

For `/feature-impact --quick`, skip UX and Strategic, redistribute weights:

```
Product: 35%, Technical: 30%, Financial: 35%
```

Faster analysis using only 2-3 skills instead of 5.

---

**Note:** This reference is loaded into context by the feature-impact-analyzer skill. Keep SKILL.md lean by referencing this file for detailed methodology.
