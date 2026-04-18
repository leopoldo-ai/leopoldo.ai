---
name: output-integrity
version: 0.1.0
description: Use when about to deliver any document, report, paper, or analysis to the user. Content quality gate that detects placeholder text, ungrounded numbers, internal inconsistencies, and AI-slop patterns. Complements verification-gate (process evidence) with content evidence.
type: discipline
metadata:
  author: lucadealbertis
  source: local
  license: proprietary
  inspiration: "AutoResearchClaw paper_verifier.py, quality.py, verified_registry.py patterns"
  created: 2026-03-25
---

# Output Integrity — Content Quality Gate

Verifies the **content** of generated output before delivery. Catches what process gates miss: placeholder text, fabricated numbers, internal contradictions, and formulaic AI patterns.

## Why It Exists

| Problem | Solution |
|---------|----------|
| Generated text contains `[INSERT...]` or `[TODO...]` placeholders | Regex-based placeholder detection with line-level reporting |
| Numbers in results sections have no traceable source | Numeric grounding check: every data point must have a stated origin |
| Abstract says one thing, body says another | Cross-section consistency verification |
| Output reads like generic AI: hedging, superlatives, filler | Pattern detection for 6 categories of AI-slop |
| Process gates pass but delivered content is hollow | Content gate runs AFTER process gates, BEFORE delivery |

## Position in the Gate Stack

```
verification-gate    Process evidence: did you run the commands?
phase-gate           Skill coverage: did you use the right skills?
doc-gate             Documentation: are docs up to date?
output-integrity     Content quality: is the output real? <-- THIS
                     ↓
                  DELIVER TO USER
```

`output-integrity` is the last gate before the user sees the output. It answers: "Process was correct, but is the content trustworthy?"

## When to Use

- BEFORE delivering any report, paper, memo, analysis, or proposal
- AFTER generating documents with `docx-reports`, `scientific-publishing`, `xlsx-reports`, or `pptx`
- When the output contains data, citations, or quantitative claims
- When the output will be used externally (client, journal, regulator, investor)

**Not needed for:** conversational answers, code, configuration files, internal notes.

## Core Workflow

### Check 1 — Placeholder Detection

Scan the full output for template remnants. Any match is a blocker.

**Patterns (case-insensitive):**

| Category | Patterns |
|----------|----------|
| Explicit placeholder | `[INSERT ...]`, `[TODO ...]`, `[PLACEHOLDER ...]`, `[ADD ...]` |
| Instructional remnant | `Replace this text`, `Add your content here`, `Your [section] goes here` |
| Future-tense filler | `This section will describe...`, `We will discuss in this section...` |
| Generic header | `Section 1`, `Chapter X`, `Sample abstract`, `Template introduction` |
| Lorem ipsum | `Lorem ipsum`, `dolor sit amet` |
| Incomplete marker | `TBD`, `TBC`, `XXX`, `???`, `FIXME` (outside code comments) |

**Severity:**
- Any match in a deliverable section = BLOCKED. Fix before delivery.
- Matches in author notes (`<!-- ... -->`) or draft annotations = WARNING only.

**Output format:**

```
PLACEHOLDER SCAN: [PASS / FAIL]
  Line 42: "[INSERT primary endpoint result here]" — explicit placeholder
  Line 87: "This section will describe the methodology" — future-tense filler
  Total: 2 issues found. BLOCKED.
```

### Check 2 — Numeric Grounding

Every quantitative claim in the output must be traceable. This check applies to sections that present data or results.

**What to verify:**

| Number type | Grounding requirement | Example |
|-------------|----------------------|---------|
| Study result | Source citation or data reference | "Response rate was 68% (Smith et al., 2024)" |
| Statistical test | Method stated, parameters visible | "p = 0.003, 95% CI [1.2, 3.4]" |
| Market size | Source and year | "TAM $4.2B (Gartner, 2025)" |
| Financial metric | Derivation or source | "EBITDA margin 23% (company filings)" |
| Sample/population | Study or dataset reference | "N = 342 patients enrolled" |
| Percentage | Numerator/denominator recoverable | "34% (117/342) achieved remission" |

**Red flags:**

- Round numbers without source: "approximately 90% of patients..." (which study?)
- Precision without CI: "efficacy was 73.2%" (no confidence interval)
- Comparative without baseline: "35% improvement" (over what?)
- Numbers that change between sections (abstract vs results)
- Suspiciously clean results: multiple metrics all ending in .0

**Severity:**
- Ungrounded number in Results/Conclusions = BLOCKED
- Ungrounded number in Introduction/Background = WARNING (common for context-setting)
- Approximate figures with hedging ("roughly", "about") in narrative = OK if not in results

**Output format:**

```
NUMERIC GROUNDING: [PASS / WARNING / FAIL]
  Line 23: "Response rate was 68%" — no source citation. BLOCKED.
  Line 45: "approximately 2 million patients" — acceptable hedged estimate. OK.
  Line 78: "EBITDA margin 23%" — source: company filings (line 12). GROUNDED.
  Grounded: 12/14 (86%). Ungrounded in results: 2. BLOCKED.
```

### Check 3 — Internal Consistency

Cross-reference sections to detect contradictions in the same document.

**What to verify:**

| Check | How |
|-------|-----|
| Abstract vs Body | Key numbers in abstract must appear in results. No number in abstract that is absent from the body |
| Methods vs Results | Statistical method described in Methods must match what Results reports (e.g., Methods says "Cox regression" but Results reports odds ratios) |
| Tables vs Text | Numbers cited in text must match the corresponding table cell |
| Executive summary vs Detail | Claims in summary must be supported by the detailed sections |
| Conclusion vs Evidence | Conclusions must not exceed what the evidence supports |

**Severity:**
- Numeric mismatch between sections = BLOCKED
- Method-result mismatch = BLOCKED
- Conclusion exceeding evidence = WARNING

**Output format:**

```
CONSISTENCY CHECK: [PASS / FAIL]
  Abstract says "p = 0.002" but Results section says "p = 0.02" — MISMATCH. BLOCKED.
  Methods describes "logistic regression" but Results reports "hazard ratio" — MISMATCH. BLOCKED.
  Conclusion claims "superior efficacy" but primary endpoint was non-significant — OVERREACH. WARNING.
```

### Check 4 — AI-Slop Detection

Detect formulaic patterns that signal low-quality AI-generated content. These patterns are not wrong per se, but they indicate the output lacks substance.

**Pattern categories:**

| Category | Examples | Action |
|----------|----------|--------|
| **Hedging cascade** | "It may potentially be possible that perhaps..." | WARNING. Rewrite with a clear position |
| **Empty superlatives** | "groundbreaking", "revolutionary", "game-changing", "cutting-edge" without evidence | WARNING. Remove or substantiate |
| **Filler transitions** | "It's important to note that", "It's worth mentioning that", "Interestingly," | WARNING. Delete the filler, keep the content |
| **Formulaic structure** | Every paragraph starts with "Furthermore," / "Additionally," / "Moreover," | WARNING. Vary structure |
| **Echo repetition** | Same concept rephrased 3+ times in different sections | WARNING. Consolidate |
| **False balance** | "On one hand... on the other hand..." without taking a position | WARNING. State the evidence-based position |

**Severity:**
- 0-2 patterns = PASS (acceptable in long documents)
- 3-5 patterns = WARNING with suggestions
- 6+ patterns = FAIL. Output needs substantive rewrite, not cosmetic edits

**Output format:**

```
AI-SLOP SCAN: [PASS / WARNING / FAIL]
  Line 12: "It's important to note that" — filler transition. Remove.
  Line 34: "groundbreaking approach" — empty superlative. Substantiate or remove.
  Line 56: "Furthermore," (4th consecutive paragraph) — formulaic structure. Vary.
  Total: 3 patterns. WARNING. Suggest targeted rewrites.
```

## Aggregate Report

After all 4 checks, produce one summary:

```
OUTPUT INTEGRITY REPORT
=======================
Document: [title/filename]
Type: [report / paper / memo / analysis / proposal]
Sections scanned: [N]

Check 1 — Placeholders:    [PASS/FAIL]  (0 issues)
Check 2 — Numeric Ground:  [PASS/FAIL]  (2 ungrounded in results)
Check 3 — Consistency:     [PASS/FAIL]  (1 mismatch)
Check 4 — AI-Slop:         [PASS/WARN]  (3 patterns)

VERDICT: [PASS / BLOCKED]

Issues requiring fix before delivery:
  1. Line 23: ungrounded number in results — add source
  2. Line 45: abstract/results p-value mismatch — verify correct value
  3. ...

Suggestions (non-blocking):
  1. Line 12: remove filler phrase "It's important to note that"
  2. ...
```

## Verdict Logic

```
ANY placeholder in deliverable section     → BLOCKED
ANY ungrounded number in results/conclusions → BLOCKED
ANY numeric mismatch between sections       → BLOCKED
AI-slop count >= 6                          → BLOCKED
Everything else                             → PASS (with warnings if applicable)
```

Only the user can override a BLOCKED verdict ("skip gate" / "procedi").

## Domain-Specific Extensions

The core checks above work for any output. Domain skills can extend with specific checks:

| Domain | Additional check | Skill that provides it |
|--------|-----------------|----------------------|
| Medical research | Citation existence via API (arXiv, CrossRef, Semantic Scholar) | `scientific-publishing` |
| Finance | DCF assumptions vs market data consistency | `investment-core` skills |
| Legal | Statute/regulation reference verification | `legal-core` skills |
| Consulting | Methodology claim vs actual methodology used | `senior-consultant` skills |

These extensions are NOT part of this skill. They live in the domain skill and are triggered by the domain workflow agent when `output-integrity` reports PASS. This keeps `output-integrity` lightweight and universal.

## Integration with Orchestrator

The orchestrator can invoke `output-integrity` automatically:

1. Any workflow agent produces a deliverable document
2. Orchestrator runs `output-integrity` before presenting to user
3. If BLOCKED: orchestrator reports issues, requests fix, re-runs gate
4. If PASS: delivers to user with integrity score

This is opt-in per workflow. Workflow agents that produce external-facing documents (reporting-output, medical-research, advisory-desk) should enable it by default.

## Anti-patterns

- Running output-integrity on draft/WIP content (it is for pre-delivery only)
- Using it as a writing guide (use domain skills for that)
- Treating warnings as blockers (only BLOCKED items must be fixed)
- Skipping it because "the content is obviously fine" (verification-gate principle: evidence, not confidence)

## Rules

1. **Placeholder = always blocked.** No exceptions. A placeholder in a delivered document is a professional failure.
2. **Ungrounded numbers in results = always blocked.** The user's reputation depends on traceable data.
3. **Warnings are suggestions, not demands.** AI-slop patterns are style issues. The user decides.
4. **Domain extensions are separate.** This skill is the universal layer. Domain checks are additive.
5. **Last gate, not first.** Run AFTER the document is otherwise complete. Not during drafting.
