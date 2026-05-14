---
name: value-attribution
description: "Use after producing a deliverable to attribute the Leopoldo-only capabilities that contributed. Reads the orchestrator's session ledger and inventory.yaml, produces Form A (compact list) or Form B (weighted score) showing what Leopoldo did that vanilla Claude could not."
type: technique
version: 1.0.0
tier: essentials
status: ga
applies_to: [CONTENT, DEV, STUDIO]
---

# Value Attribution

Differential attribution skill. For each Leopoldo deliverable, compute and display which **Leopoldo-only** capabilities were used (things vanilla Claude could not have done). Answers the commercial question "is it worth it?" with concrete data.

Depends on the `leopoldo-introspection` skill to read the orchestrator ledger (same data source).

## Out of scope

- Does not compute "hours saved" (Form C counterfactual). Over-claim risk, deferred.
- Does not generate external certifications. Score is an internal claim verifiable via audit signing.
- Does not modify pricing tiers. Score is informational only.

## Stop and surface

- If the score is below `display_threshold` (50% by default): DO NOT show attribution. Minimal responses with few capabilities would be dishonest auto-promo.
- If the user explicitly requests (`/leopoldo score`) even on thin output: produce anyway, but with honest framing ("minimal output, X capabilities used").

## Two artifacts

1. **Form A footer** appended to deliverables >500 words (compact list)
2. **Form B breakdown** printed on `/leopoldo score` or explicit request (weighted table)

## Citation discipline

Every capability in the score MUST correspond to an event in the orchestrator ledger. Capabilities not present in the ledger cannot be counted. Score derived from versioned inventory.yaml (externally citable).

## Quality bar

- Full-loaded IC memo deliverable score: 85-95% (not higher: room needed for "even vanilla Claude can produce narrative content")
- Chat reply without skill score: <50% (below threshold, not displayed)
- Same deliverable produces deterministic score (identical inputs → identical output)
- Form A appended without explicit user request, on deliverables >500 words
- Works identically on Claude Code and Cowork

## Trigger

- **Auto:** orchestrator post-deliverable hook on output >500 words with at least 1 action in ledger. Default: appends Form A.
- **Manual Form B:** user says `/leopoldo score`, "what's the score?", "how much Leopoldo value?", "what did you do beyond what Claude does?"
- **Manual for specific deliverable:** user asks "score of this output" → reference to the most recent deliverable in the ledger.

## Workflow

### Step 1: Read sources

1. **Orchestrator ledger** (in-conversation): list of skills, agents, gates, audits, memory writes from the current session up to the target deliverable.
2. **Inventory file**: `skills/engine/value-attribution/inventory.yaml`. Contains capabilities with labels and weights.

### Step 2: Map ledger to capabilities

For each event in the ledger, map it to an inventory entry:

| Ledger event | Inventory entry | Note |
|---|---|---|
| Skill invoked: <name> | `skill_invocation` with `{skill_name}` | Per-skill weight, capped at `weight_cap` |
| Agent dispatched: <name> | `workflow_agent` with `{agent_name}` | Per-agent weight |
| Quality gate Quality Agent | `quality_agent` | Fixed weight |
| Quality gate Safety Agent (<profile>) | `safety_agent` with `{domain}` | Fixed weight |
| Audit signature: <id> | `audit_signing` | Fixed weight |
| Memory write: brand-kit.yaml | `brand_kit_application` | Only if applied to the deliverable |
| Source labels in deliverable | `citation_discipline` | See "Citation discipline detection" below |
| Preference loaded | `preference_memory` | If preferences applied to the deliverable |
| Always present | `orchestrator` | The orchestrator itself is a Leopoldo capability |

### Step 3: Compute the score

```
total = sum(weight for each mapped capability)
total = min(total, total_weight_cap)  # cap at 100
percent = total / total_weight_cap * 100
```

### Step 4: Select Form

- If `percent < display_threshold` (default 50%) AND not explicitly requested: skip output (honesty threshold)
- If Form A (default deliverable footer): produce compact
- If Form B (`/leopoldo score` or explicitly requested): produce full breakdown

### Step 5: Output

#### Form A (footer compact, 1 line, 4 signals)

```markdown
*Leopoldo: {N} capability used · Quality {status} · Safety {status} · Audit {status} · `/leopoldo score`*
```

Status values: `PASS` (gate ran clean), `FIX` (gate found issues, auto-fixed), `n/a` (gate did not run), `unavail` (gate could not run due to platform/connectivity, e.g. Cowork offline or audit endpoint 503).

Real examples:
```markdown
*Leopoldo: 6 capability used · Quality PASS · Safety PASS · Audit PASS · `/leopoldo score`*
*Leopoldo: 4 capability used · Quality FIX · Safety n/a · Audit n/a · `/leopoldo score`*
*Leopoldo: 5 capability used · Quality PASS · Safety PASS · Audit unavail · `/leopoldo score`*
```

**Rationale**: 4 signals in one line (capability count, quality, safety, audit). Audit added 2026-05-09 (B-NEW-4): without audit visibility, regulated-finance deliverables could ship with `Quality PASS · Safety PASS` while the witness marker silently fails on a 503 endpoint. Procurement-grade lock broken. With Audit visible, the user always sees whether the deliverable carries attestation.

#### Form B (full breakdown)

```markdown
**Leopoldo Contribution Score: {percent}%**

| Capability | Weight | Note |
|---|---|---|
| Multi-skill orchestration | 15% | Routing across domain-vertical skills and workflow agents |
| Skill: ic-memo-builder | 7% | PE-standard memo structure |
| Skill: dcf-builder | 7% | DCF with sensitivity |
| Workflow agent: deal-execution | 12% | End-to-end orchestration |
| Quality Agent | 8% | Automatic gate, PASS |
| Safety Agent (BUSINESS-finance) | 10% | Source flag, numeric consistency, PASS |
| Audit signing | 12% | Witness marker `ld-2026-05-09-7f3a2c` |
| Brand-kit applied | 6% | brand-kit.yaml applied to docx |
| Citation discipline | 8% | 3 source labels present (if detected) |
| Narrative content (also vanilla Claude) | 13% | Base capability |
| **Total** | **{percent}%** | (capped at 100) |

Weights updated 2026-05-09 (skill_invocation 8→7, weight_cap 40→30) to avoid saturation.

Without Leopoldo, this deliverable would be free narrative, without standard structure, without source labels [UNSOURCED]/[ESTIMATED], without verifiable audit signature, without applied brand, without quality check.

Audit verification: trust.leopoldo.ai/v/{audit_id}
```

**N capability used — canonical definition** (B-NEW-11, 2026-05-09):

N = number of **distinct inventory entries** that (a) have score > 0 in the current deliverable AND (b) have `vanilla_claude_equivalent: false`.

**Concrete rules:**

1. `skill_invocation` counts as **1 entry** even if 5 different skills fired (the entry is the category, not the per-skill count)
2. `workflow_agent` counts as **1 entry** even if multiple agents dispatched
3. `narrative_content` (vanilla=true) is ALWAYS excluded from N
4. `orchestrator` (always_active) is always included (it is what differentiates from "raw" vanilla Claude)
5. Capabilities with score 0 (e.g. preference_memory not loaded) are excluded

**Example** (T1 from 2026-05-09 test):
- Ledger: 3 skills + 1 workflow agent + Quality PASS + Safety PASS + audit + brand-kit + citation marker present
- Active inventory entries: orchestrator(1) + skill_invocation(1, groups 3 skills) + workflow_agent(1) + quality_agent(1) + safety_agent(1) + audit_signing(1) + brand_kit_application(1) + citation_discipline(1) = **8 entries**
- N = **8** (narrative excluded, preference_memory not active)

**Resulting footer:**
```
*Leopoldo: 8 capability used · Quality PASS · Safety PASS · Audit PASS · `/leopoldo score`*
```

This convention is SOURCE OF TRUTH. SKILL.md, orchestrator.md, and all forms must respect it. Score (sum of weights) and N (count of entries) are distinct but derived from the same ledger.

### Citation discipline detection (mechanism)

`citation_discipline` is not an event of the orchestrator ledger (unlike skill/agent/gate/audit), but a **property of the deliverable text**. To count it:

1. After the deliverable is composed and before computing the score, scan the text for the markers:
   - `[UNSOURCED]` (case-sensitive, exact)
   - `[ESTIMATED]` (case-sensitive, exact)
   - `[CRM]` (case-sensitive, exact)
2. If AT LEAST ONE marker is present, `citation_discipline` is active → count the weight (8) in the score.
3. If no marker is present, `citation_discipline` is not active → 0 to the score.

**Rationale**: the markers are the signal that the skill applied the discipline (recognizing that some numbers do not have certified sources). A deliverable without markers can mean: (a) all numbers have a source but it is not declared (rare, underperforming), or (b) the skill did not apply the discipline (more common, must cost). In both cases 0 weight is honest.

**Edge case**: a marker cited descriptively (e.g., "the [UNSOURCED] marker signals...") without being applied to a number. For now, we count it as present (minimal acceptable over-attribution). Future version: more sophisticated parsing.

### Step 6: Update ledger

Add to the ledger:
```
Memory writes: + value-attribution computed: {percent}% for {deliverable_type}
```

## Inventory file structure

See `skills/engine/value-attribution/inventory.yaml`. Structured to be editable without touching code. Every weight tunable. Internal versioning.

## Adaptation

| User phrasing (intent) | Form |
|---|---|
| "/leopoldo score" | B |
| "what's the score?" | B |
| "how much value?" | B |
| "what did you do beyond what Claude does?" | B with explicit differential framing |
| "why is it worth it?" | B with 2-line lead |
| Implicit (post-deliverable >500 words) | A |

## Anti-patterns

- Score >100%: never. Cap strictly.
- Showing Form A on chat reply without Leopoldo actions: violation of honesty threshold.
- Inventing capabilities not in the ledger: violation of citation discipline.
- Inflating the score by counting the same skill twice (respect `weight_cap` per category).
- Form B with table without weight: the number is needed to be credible.

## Disclaimer

The score is an internal tunable claim. It is not certified by third parties. External verification is available via audit signing (witness marker → trust.leopoldo.ai). Weights are editable to reflect perceived value at target client; revisit at least quarterly.

## Language note

This SKILL.md is documented entirely in English (project convention). At runtime, the orchestrator delivers Form A and Form B in the user's language. The structure (capability count, weights, score) is universal.
