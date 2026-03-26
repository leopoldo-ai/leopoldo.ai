---
name: decision-toolkit
version: 0.1.0
description: "Universal quantitative decision framework. Use when comparing alternatives with weighted criteria, ROI analysis, make-vs-buy, cost-benefit analysis, or scenario modeling. For product/feature decisions with RICE use feature-impact-analyzer instead."
skillos:
  layer: userland
  category: domain
  pack: essentials
  requires:
    hard: []
    soft: [data-visualization, strategy-advisor]
  provides: [decision-matrix, roi-analysis, cost-benefit, scenario-model]
  triggers:
    - on: "task.category == 'decision-analysis'"
      mode: suggest
    - on: "task.category == 'make-vs-buy'"
      mode: suggest
  config: {}
metadata:
  author: internal
  source: custom
  license: proprietary
  forge_strategy: build
  forge_sources:
    - "Inspired by lyndonkl/claude decision-matrix methodology (no license — BUILD, not ADAPT)"
  created: 2026-03-13
---

# Decision Toolkit

Universal framework for quantitative decisions. Supports weighted decision matrix, ROI analysis, cost-benefit analysis, make-vs-buy, and scenario modeling. Produces a structured recommendation with confidence level and explicit trade-offs.

## Why It Exists

| Problem | Solution |
|---------|----------|
| Decisions based on "gut feeling" without structure | Quantitative frameworks with replicable scoring |
| Unweighted criteria — everything seems equally important | Weighted scoring with explicit and justified weights |
| No sensitivity analysis — the decision seems certain | Sensitivity analysis to test robustness |
| Undeclared trade-offs — surprises post-decision | Explicit trade-off matrix for each option |

## Tool Selection Guide

| Tool | When to Use | Output |
|------|------------|--------|
| **Weighted Decision Matrix** | 3+ options, 4+ criteria, complex decision | Ranked scoring with sensitivity |
| **ROI Analysis** | Investment with quantifiable costs and benefits | ROI %, payback period, NPV |
| **Cost-Benefit Analysis** | Single option go/no-go, mixed benefits (quant + qual) | B/C ratio, recommendation |
| **Make vs Buy** | Internal build vs purchase/outsourcing | TCO comparison, risk-adjusted |
| **Scenario Modeling** | High uncertainty, 2-3 plausible scenarios | Expected value per option |

---

## Core Workflow

### Phase 1 — Framing

**Template — Decision Frame:**

| Field | Value |
|-------|-------|
| Decision to make | [specific question] |
| Decision-maker | [who has authority to decide] |
| Deadline | [when the decision is needed] |
| Reversibility | Reversible (low cost) / Partially reversible / Irreversible |
| Identified options | [list of options, min 2 max 6] |
| Chosen tool | WDM / ROI / CBA / Make-vs-Buy / Scenario |

**Framing rule**: if the decision has only 2 options, verify there aren't others. Often the third option is "do nothing" or "do something different".

---

### Phase 2 — Weighted Decision Matrix (WDM)

#### Step 2.1 — Define criteria and weights

**Criteria categories:**

| Category | Examples |
|----------|---------|
| Financial | Cost, ROI, payback, TCO |
| Performance | Quality, speed, scalability |
| Risk | Implementation risk, vendor lock-in, compliance |
| Strategic | Strategic alignment, competitive, future |
| Operational | Complexity, maintenance, training |
| Stakeholder | Team acceptance, client, partner |

**Weighting methods:**

1. **Direct allocation** — distribute 100 points among criteria (simplest)
2. **Pairwise comparison** — compare each pair of criteria (more rigorous)

**Template — Criteria & Weights:**

| # | Criterion | Category | Weight (%) | Weight Justification |
|---|----------|----------|----------|---------------------|
| C1 | | | | |
| C2 | | | | |
| C3 | | | | |
| | **TOTAL** | | **100%** | |

#### Step 2.2 — Scoring

Rate each option on each criterion from 1 to 10.

**Scale:**

| Score | Meaning |
|-------|---------|
| 1-2 | Very weak, does not satisfy the criterion |
| 3-4 | Below average, significant shortcomings |
| 5-6 | Average, acceptable |
| 7-8 | Above average, strength |
| 9-10 | Excellent, best-in-class |

**Template — Decision Matrix:**

| Criterion | Weight | Option A (score) | A (weighted) | Option B (score) | B (weighted) | Option C (score) | C (weighted) |
|----------|------|------------------|-------------|------------------|-------------|------------------|-------------|
| C1 | ___% | /10 | | /10 | | /10 | |
| C2 | ___% | /10 | | /10 | | /10 | |
| C3 | ___% | /10 | | /10 | | /10 | |
| **TOTAL** | 100% | | **___** | | **___** | | **___** |

#### Step 2.3 — Sensitivity Analysis

Test the robustness of the decision by varying the weights of the top 3 criteria:

| Scenario | Variation | Winner | Changes? |
|----------|----------|--------|----------|
| Baseline | Original weights | Option ___ | — |
| +Financial | Financial weight +10pp | Option ___ | Yes/No |
| +Risk | Risk weight +10pp | Option ___ | Yes/No |
| +Strategic | Strategic weight +10pp | Option ___ | Yes/No |

**Robustness rule**: if the winner changes in 2+ scenarios, the decision is not robust — further examine the contested criteria.

---

### Phase 3 — ROI Analysis

**Template:**

```
ROI ANALYSIS
============
Investment: [name]
Horizon: [months/years]

COSTS
-----
Initial cost (one-time)      : EUR___
Recurring costs (annual)     : EUR___
Opportunity costs             : EUR___
Total cost (horizon)          : EUR___

BENEFITS
--------
Incremental revenue           : EUR___/year
Cost savings                  : EUR___/year
Intangible benefits           : [qualitative description]
Total benefit (horizon)       : EUR___

METRICS
-------
ROI = (Benefit - Cost) / Cost = ___%
Payback period                = ___ months
NPV (discount rate ___%)      = EUR___
IRR                           = ___%

RECOMMENDATION: [Go / No-Go / Conditional]
Confidence: [High / Medium / Low]
Key assumptions: [list]
```

---

### Phase 4 — Make vs Buy

**Template — TCO Comparison:**

| Item | Make (internal) | Buy (external) | Notes |
|------|---------------|--------------|------|
| **Initial costs** | | | |
| Setup/development | EUR___ | EUR___ | |
| Integration | EUR___ | EUR___ | |
| Training | EUR___ | EUR___ | |
| **Recurring costs (annual)** | | | |
| Maintenance/licenses | EUR___ | EUR___ | |
| Dedicated personnel | EUR___ | EUR___ | |
| Support | EUR___ | EUR___ | |
| **TCO (3 years)** | **EUR___** | **EUR___** | |
| **Risks** | | | |
| Vendor lock-in | Low | High | |
| Time-to-market | ___ months | ___ months | |
| Control/customization | High | Low | |
| Scalability | To be validated | Proven | |

---

### Phase 5 — Output

**Template — Decision Report:**

```
DECISION REPORT
===============
Decision      : [question]
Date          : [date]
Analyst       : [name]
Tool          : [WDM / ROI / CBA / MvB / Scenario]

RECOMMENDATION
--------------
[Recommended option] with confidence [High/Medium/Low]

RATIONALE (3 bullets)
---------------------
1. [main reason with data]
2. [secondary reason]
3. [differentiating reason vs alternative]

ACCEPTED TRADE-OFFS
--------------------
By choosing [option], we accept:
- [trade-off 1]: [impact and mitigation]
- [trade-off 2]: [impact and mitigation]

DECISION RISKS
--------------
| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| | | | |

VALIDITY CONDITIONS
-------------------
The recommendation assumes that:
1. [assumption 1]
2. [assumption 2]
If these assumptions change, re-evaluate.

NEXT STEPS
----------
1. [action] — owner: [name] — by: [date]
2. [action] — owner: [name] — by: [date]
```

---

## Rules

1. **Frame before analyzing**: do not skip the decision frame — options and criteria must be explicit
2. **Justified weights**: every weight must have a reason, not "it seems right"
3. **Mandatory sensitivity for WDM**: a decision not tested for sensitivity is fragile
4. **Declared trade-offs**: every recommendation must declare what is being given up
5. **Explicit confidence level**: never present a recommendation as certainty
6. **Reversibility as input**: irreversible decisions require more rigorous analysis

## Anti-patterns

| Anti-pattern | Why It Is Wrong |
|-------------|----------------|
| Using WDM for decisions with 2 obvious options | Over-engineering, wasting time |
| Uniform weights (all 20%) | Does not discriminate, hides true priority |
| Scoring without shared scale | Scores not comparable across evaluators |
| Ignoring sensitivity | False certainty about the decision |
| WDM without explicit trade-offs | The decision-maker doesn't know what they're giving up |
| ROI without declared assumptions | Illusion of precision |

---

> **v0.1.0** | Domain skill | Pack: essentials
