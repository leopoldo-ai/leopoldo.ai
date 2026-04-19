---
name: contract-reviewer
version: 0.2.0
description: "Use when reviewing NDAs, term sheets, SPAs, subscription agreements, or any legal document for red flags and negotiation points."
type: technique
metadata:
  author: internal
  source: custom
  license: proprietary
  forge_strategy: merge
  forge_sources:
    - "Inspired by evolsb/claude-legal-skill CUAD risk detection methodology (MIT)"
    - "Inspired by duraninci/openclaw-legal-skills contract-review-anthropic playbook methodology (Apache-2.0)"
---

# Contract Reviewer

Legal document review: NDA, term sheet, SPA, SHA, LPA, subscription agreement.
Red flag detection with structured risk taxonomy, clause-by-clause review with playbook,
comparison with market standard, redline suggestions.

## Why It Exists

| Problem | Solution |
|---------|----------|
| Slow and expensive legal reviews (external counsel) | Internal pre-screening that identifies key points |
| Critical clauses not identified | Taxonomy of 20 risk categories with predefined red flags |
| No comparison with market standard | Playbook with acceptable/unacceptable positions per clause type |
| Negotiation without prioritization | Severity classification (Critical/Major/Minor) with priority |
| Vague or generic suggested changes | Redline suggestions with specific alternative text |

## Core Workflow

### Phase 1 — Document and Party Identification

| Document | Review Focus | Typical Red Flags |
|----------|-------------|-------------------|
| NDA | Scope, duration, exceptions, penalties | Overly broad scope, excessive duration, disproportionate penalties |
| Term sheet | Valuation, governance, liquidation pref, anti-dilution | Ratchet, full-ratchet anti-dilution, majority drag-along |
| SPA | Reps & warranties, indemnity, MAC, conditions precedent | Unlimited indemnity, vague MAC, insufficient escrow |
| SHA | Tag-along/drag-along, anti-dilution, board seats, deadlock | Deadlock without resolution, drag without floor price |
| LPA | Capital commitment, drawdown, distribution, key-man | No-fault divorce absent, key-man clause absent |
| Subscription agreement | Capital call, default, transfer restrictions | Excessive default penalties, non-standard lock-up |
| Side letter | MFN, co-invest, reporting, fee discount | MFN without limits, unsustainable fee discount |

For each document identify:
1. **Parties**: who are the counterparties (name, role, jurisdiction)
2. **Client's position**: investor, target, GP, LP, buyer, seller
3. **Context**: deal phase (preliminary, binding, closing), investment round
4. **Related documents**: other contracts in the package to read together

### Phase 2 — Investment Risk Taxonomy

Risk categories adapted for investment contracts. For each clause, classify into the relevant category:

| # | Risk Category | Typical Application | Default Severity |
|---|--------------|--------------------|--------------------|
| 1 | Confidentiality obligations | NDA, SPA, SHA | Major |
| 2 | Non-compete and non-solicitation | SPA, SHA, term sheet | Critical |
| 3 | Indemnification and liability | SPA, SHA | Critical |
| 4 | Reps & warranties | SPA, SHA | Critical |
| 5 | Conditions precedent (CP) | SPA, term sheet | Major |
| 6 | Material Adverse Change (MAC) | SPA | Critical |
| 7 | Exit and termination clauses | SHA, LPA, services | Major |
| 8 | Anti-dilution and economic protection | Term sheet, SHA | Critical |
| 9 | Liquidation preference | Term sheet, SHA | Critical |
| 10 | Tag-along and drag-along | SHA | Critical |
| 11 | Governance and veto rights | SHA, LPA | Major |
| 12 | Transfer restrictions and lock-up | SHA, LPA | Major |
| 13 | Earnout and contingent payments | SPA | Critical |
| 14 | Key-man and no-fault divorce | LPA | Major |
| 15 | Distribution and waterfall | LPA | Critical |
| 16 | Fees and costs (management, carry, expenses) | LPA, side letter | Major |
| 17 | Reporting and information rights | SHA, LPA, side letter | Minor |
| 18 | Governing law and jurisdiction | All | Major |
| 19 | Limitation of liability and cap | SPA, services | Critical |
| 20 | Exclusivity and no-shop clauses | Term sheet, SPA | Major |

### Phase 3 — Clause-by-Clause Review with Playbook

For each relevant clause, apply the playbook method:

**Analysis structure per clause:**

```
CLAUSE: [name/title]
RISK CATEGORY: [# from taxonomy]
ORIGINAL TEXT: [relevant excerpt]

CURRENT POSITION:
- What the clause provides

PLAYBOOK - REFERENCE POSITIONS:
- Acceptable (market standard): [description]
- Acceptable with reservations: [description]
- Unacceptable: [description]

ASSESSMENT:
- Severity: Critical | Major | Minor
- Position: acceptable | negotiable | unacceptable
- Estimated economic impact: [if quantifiable]

SUGGESTED REDLINE:
- Proposed alternative text
- Rationale for the modification
```

**Severity scale:**
- **Critical**: clauses that can cause significant loss, unlimited liability, or loss of control. Must be modified to proceed
- **Major**: non-standard clauses carrying material risk. Negotiation strongly recommended
- **Minor**: clauses with marginal deviation from market standard. To monitor but not blocking

### Phase 4 — Investment-Specific Clauses

In-depth analysis for investment-specific clauses:

**Anti-dilution:**
- Type: full-ratchet (unacceptable for existing investor) vs weighted-average (broad/narrow)
- Pay-to-play: present/absent, conditions
- Carve-out for ESOP pool

**Tag-along / Drag-along:**
- Drag activation threshold (typical: 75%+ but verify)
- Floor price for drag (minority protection)
- Proportional or full tag-along
- Equivalent conditions (same terms)

**Liquidation preference:**
- Multiple: 1x (standard), >1x (aggressive)
- Type: non-participating (standard) vs participating (double-dip, aggressive)
- Participation cap
- Seniority across different rounds

**Earnout and contingent payments:**
- Metrics: revenue, EBITDA, operational milestones
- Period: duration and measurement frequency
- Protection against manipulation (operating covenants)
- Dispute resolution for earnout calculation
- Acceleration in case of change of control

**MAC clause:**
- Definition: specific vs generic (prefer specific)
- Carve-outs: market, sector, pandemic, regulation
- Bring-down: whether R&W must be true at closing as well
- Materiality qualifier: quantitative threshold if possible

### Phase 5 — Red Flag Report and Prioritization

1. **Critical findings** (must be resolved):
   - List of clauses with Critical severity and unacceptable position
   - For each: current text, risk, suggested redline

2. **Major findings** (negotiation recommended):
   - List of clauses with Major severity
   - Negotiation priority (economic impact)

3. **Minor findings** (nice-to-have):
   - Marginal deviations from market standard
   - Notes for awareness

4. **Summary table:**

| # | Clause | Category | Severity | Position | Action | Priority |
|---|--------|----------|----------|----------|--------|----------|
| 1 | ... | ... | Critical/Major/Minor | acceptable/negotiable/unacceptable | accept/negotiate/reject | 1-N |

### Phase 6 — Negotiation Brief with Redline

1. **Must-have**: non-negotiable modifications (deal-breaker) with redline
2. **Nice-to-have**: desirable improvements with alternative text
3. **Give-away**: points that can be conceded in exchange for something else
4. **Negotiation strategy**:
   - Order of presenting points
   - Possible trade-offs (e.g., concede on X to obtain Y)
   - Fallback position for each critical point
5. **Redline document**: consolidated version with all suggested modifications

## If Connectors Available

If **~~legal research** is connected: cross-check unusual clauses against current case law and statutes in the relevant jurisdiction.
If **~~documents** is connected: pull prior signed versions of the same contract family for benchmark clauses.

Fallback: ask the user for the governing law and any precedent contracts in the same deal series; flag unverified assumptions.

## Rules

1. **Pre-screening, not replacement**: the review does not replace legal advice
2. **Red flags with severity**: every finding must have severity (Critical/Major/Minor) and action
3. **Market standard as reference**: every comment must indicate the market standard
4. **Quantified impact**: where possible, quantify the economic impact
5. **Explicit playbook**: declare acceptable/unacceptable positions for each clause
6. **Always redline**: every Major/Critical finding must have suggested alternative text
7. **Party-aware**: the analysis must consider the client's position (buyer/seller, GP/LP)
8. **Caveat**: always recommend external counsel review before signing

## Anti-patterns

| Anti-pattern | Why It Is Wrong |
|-------------|----------------|
| Reviewing only financial clauses | Legal red flags in governance and liability ignored |
| No comparison with market standard | Cannot tell if a clause is normal or anomalous |
| All points classified as Critical | No prioritization, the client doesn't know what's urgent |
| Review without suggested alternative text | Identifying a problem without proposing a solution |
| Analysis without considering the client's position | The same clauses have different impact for buyer vs seller |
| Investment-specific clauses ignored | Tag-along, anti-dilution, liquidation pref are the heart of the deal |
| Signing without counsel for significant contracts | Unmanaged legal risk |

## Recommendations Format

Red flags use L/M/H severity (Critical/Major/Minor maps to H/M/L in external output). Redline recommendations use 3 tiers. See `docs/guides/leopoldo-taxonomy.md`.

### Tier 1 — Non-negotiable redlines
- Clauses with unlimited exposure, unilateral termination, or rights that defeat the deal rationale. Hold the line.

### Tier 2 — Strongly recommended
- Market-deviant clauses where the party's position can be meaningfully improved with standard language. Document trade-off if conceded.

### Tier 3 — Negotiable concessions
- Low-impact clauses that can be traded to secure Tier 1 or Tier 2 items. Trade freely in final rounds.

Each item must explain WHY it's in that tier.

---

> **v0.2.0** | Domain skill | Pack: investment-core
