---
name: risk-assessment
version: 0.1.0
description: "Use when identifying, evaluating, and mitigating risks for projects, operations, strategy, or reputation using a generic risk assessment framework. Not finance-specific. For investment risk use risk-framework in investment-core."
type: technique
metadata:
  author: internal
  source: custom
  license: proprietary
  forge_strategy: build
  forge_sources: []
  created: 2026-03-13
---

# Risk Assessment

Generic framework for risk identification, evaluation, and mitigation. Applicable to any domain: project, operations, strategy, reputation, compliance.

## Why It Exists

| Problem | Solution |
|---------|----------|
| Risks identified only after the fact | Structured preventive identification process |
| No risk prioritization | Probability/impact matrix with quantitative scoring |
| Generic and untracked mitigations | Strategy selection framework + register with owner |
| Risk appetite not defined | Template to define acceptable thresholds per category |

## Core Workflow

### Phase 1 — Context and Risk Appetite

Before identifying risks, define the context:

**Risk Context:**

| Field | Value |
|-------|-------|
| Project/Initiative | |
| Perimeter | |
| Key stakeholders | |
| Time horizon | |
| Risk tolerance | Conservative / Moderate / Aggressive |

**Risk Appetite per category:**

| Category | Acceptable Threshold | Escalation Trigger |
|----------|---------------------|-------------------|
| Financial | Max loss EUR___ or ___% of budget | Threshold exceeded |
| Operational | Max downtime ___ hours/month | Recurring incident |
| Reputational | No public damage | Negative media coverage |
| Compliance | Zero regulatory violations | Audit finding |
| Strategic | Max ___ months slippage on objectives | Critical milestone missed |

---

### Phase 2 — Risk Identification

**Identification techniques:**

1. **Structured brainstorming** — facilitated session with key stakeholders, by category
2. **Domain checklist** — predefined list per project/operation type
3. **SWOT-derived** — risks extracted from the Threats + Weaknesses quadrant (see strategy-advisor)
4. **Historical analysis** — risks that materialized in similar projects/initiatives (see knowledge-base)
5. **Pre-mortem** — imagine failure and reconstruct causes in reverse

**Template — Risk Identification:**

| # | Risk | Description | Category | Identification Source |
|---|------|-------------|----------|---------------------|
| R1 | | | Financial / Operational / Reputational / Compliance / Strategic | Brainstorming / Checklist / SWOT / Historical / Pre-mortem |
| R2 | | | | |

---

### Phase 3 — Evaluation and Prioritization

**Probability x Impact Matrix (5x5):**

| | Impact 1 (Negligible) | Impact 2 (Minor) | Impact 3 (Moderate) | Impact 4 (Major) | Impact 5 (Catastrophic) |
|---|---|---|---|---|---|
| **Prob 5 (Almost certain)** | 5 - Medium | 10 - High | 15 - Critical | 20 - Critical | 25 - Critical |
| **Prob 4 (Likely)** | 4 - Low | 8 - Medium | 12 - High | 16 - Critical | 20 - Critical |
| **Prob 3 (Possible)** | 3 - Low | 6 - Medium | 9 - High | 12 - High | 15 - Critical |
| **Prob 2 (Unlikely)** | 2 - Low | 4 - Low | 6 - Medium | 8 - Medium | 10 - High |
| **Prob 1 (Rare)** | 1 - Low | 2 - Low | 3 - Low | 4 - Low | 5 - Medium |

**Risk levels:**
- **Critical (>=15)**: Immediate action, escalation to leadership
- **High (9-14)**: Mitigation plan within 1 week, owner assigned
- **Medium (5-8)**: Active monitoring, planned mitigation
- **Low (1-4)**: Conscious acceptance, periodic monitoring

**Impact criteria:**

| Level | Financial | Operational | Reputational | Compliance |
|-------|-----------|-----------|-------------|------------|
| 1 - Negligible | <1% budget | No interruption | No visibility | Minor observation |
| 2 - Minor | 1-5% budget | <1 day delay | Isolated complaint | Minor non-conformity |
| 3 - Moderate | 5-10% budget | 1-5 day delay | Local media coverage | Non-conformity with corrective action |
| 4 - Major | 10-25% budget | 1-4 week delay | National media coverage | Sanction/fine |
| 5 - Catastrophic | >25% budget | >1 month delay or block | Reputational crisis | Legal action/license revocation |

---

### Phase 4 — Risk Register

**Template — Risk Register:**

| # | Risk | Cat. | Prob (1-5) | Impact (1-5) | Score | Level | Strategy | Mitigation Action | Owner | Due Date | Residual Risk | Status |
|---|------|------|-----------|-------------|-------|-------|----------|-------------------|-------|----------|---------------|--------|
| R1 | | | | | | | Avoid/Transfer/Mitigate/Accept | | | | | Open/In progress/Closed |

**Response strategies:**

| Strategy | When to Use | Example |
|----------|------------|---------|
| **Avoid** | Unacceptable risk, we can eliminate the cause | Change supplier, modify scope, postpone |
| **Transfer** | Risk transferable to third parties | Insurance, outsourcing, contractual clause |
| **Mitigate** | We can reduce probability or impact | Additional controls, redundancy, training, buffer |
| **Accept** | Low risk or mitigation cost > impact | Monitoring, contingency fund, no action |

---

### Phase 5 — Bowtie Analysis (for critical risks)

For each risk with score >= 15, build a bowtie analysis:

```
CAUSES                    EVENT                     CONSEQUENCES
------                    -----                     ------------
Cause 1 --> Barrier -->                --> Barrier --> Consequence 1
Cause 2 --> Barrier -->   RISK         --> Barrier --> Consequence 2
Cause 3 -->            -->             --> Barrier --> Consequence 3

[Preventive barriers]    [Top event]    [Reactive barriers]
```

**Template:**

| Side | Element | Barrier | Barrier Status | Owner |
|------|---------|---------|---------------|-------|
| Preventive | Cause 1: ___ | Barrier: ___ | Active / Degraded / Absent | |
| Preventive | Cause 2: ___ | Barrier: ___ | | |
| Reactive | Consequence 1: ___ | Barrier: ___ | | |
| Reactive | Consequence 2: ___ | Barrier: ___ | | |

---

### Phase 6 — Monitoring and Review

**Review cadence:**

| Risk Level | Review Frequency | Action |
|-----------|-----------------|--------|
| Critical | Weekly | Status update to leadership, re-evaluation |
| High | Bi-weekly | Verify mitigation progress |
| Medium | Monthly | Check status, update register |
| Low | Quarterly | Confirm the risk is still low |

**Escalation triggers:**
- Score increases by >= 4 points from previous evaluation
- Preventive barrier becomes "Degraded" or "Absent"
- Residual risk exceeds risk appetite threshold
- New risk identified with score >= 15

**Template — Risk Review Log:**

```
RISK REVIEW
===========
Date         : [date]
Reviewer     : [name]
Period       : [since last review]

CRITICAL/HIGH RISKS - STATUS
-----------------------------
R[n]: [name] — Score [x] → [y] — [comment]

NEW RISKS IDENTIFIED
--------------------
-

CLOSED RISKS
------------
-

OVERDUE OR LATE ACTIONS
-----------------------
-

NEXT REVIEW: [date]
```

---

## Rules

1. **Risk appetite first, identification after**: do not evaluate risks without having defined acceptable thresholds
2. **Mandatory owner**: every risk with score >= 9 must have a named owner
3. **Explicit residual risk**: after mitigation, re-evaluate and document the residual risk
4. **Bowtie for criticals**: every risk score >= 15 requires bowtie analysis
5. **Cadenced review**: the register is not a static document — follow the review cadence
6. **Transparent escalation**: escalation triggers are predefined, not discretionary

## Anti-patterns

| Anti-pattern | Why It Is Wrong |
|-------------|----------------|
| Recording risks without score | No prioritization, all seem equally urgent |
| Mitigation without owner | Nobody feels responsible, the action is not executed |
| Risk register compiled once and never updated | False security, new risks not captured |
| All risks classified as "High" | No discrimination, leadership ignores the register |
| Only negative risks | Opportunities (positive risks) are not captured |
| Bowtie only as theoretical exercise | Barriers must be actively monitored |

---

> **v0.1.0** | Domain skill | Pack: essentials
