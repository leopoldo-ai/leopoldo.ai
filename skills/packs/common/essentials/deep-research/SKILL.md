---
name: deep-research
version: 0.1.0
description: "Use when performing deep research on a topic requiring multiple sources, source credibility evaluation, and synthesis with citations via structured web research methodology. For domain-specific research (finance, medical) use the relevant domain skill instead."
type: technique
metadata:
  author: internal
  source: custom
  license: proprietary
  forge_strategy: build
  forge_sources:
    - "Inspired by 199-biotechnologies/claude-deep-research-skill pipeline methodology (no license — BUILD, not ADAPT)"
  created: 2026-03-13
tier: essentials
status: ga
---

# Deep Research

Structured methodology for in-depth research on any topic. 6-phase pipeline: Scope → Plan → Retrieve → Evaluate → Synthesize → Deliver. Emphasis on source credibility and traceable citations.

## Why It Exists

| Problem | Solution |
|---------|----------|
| Superficial research with unverified sources | Structured pipeline with credibility evaluation |
| Synthesis without citations | Every claim traceable to a specific source |
| Confirmation bias in research | Deliberate search for contrary sources |
| Scope creep in research | Explicit scoping with research question and limits |

## Core Workflow

### Phase 1 — Scope

Define the research perimeter before starting to search.

**Template — Research Brief:**

| Field | Value |
|-------|-------|
| Research question | [specific question, not vague] |
| Sub-questions | [2-5 sub-questions that compose the answer] |
| Audience | [who will read the result] |
| Required depth | Overview / Analysis / Deep dive |
| Time limits | [reference period: last 6 months / 2 years / historical] |
| Sources to include | [types: academic, industry report, news, official data] |
| Sources to exclude | [e.g., unverified blogs, social media] |
| Expected output | [format: brief, report, comparison table, annotated bibliography] |
| Deadline | |

**Scope rule**: if the research question cannot be formulated in one sentence, it is too broad. Break it into sub-research tasks.

---

### Phase 2 — Plan

Plan the research strategy.

**Search Strategy:**

| # | Sub-question | Search Query | Target Sources | Priority |
|---|-------------|--------------|---------------|----------|
| 1 | | [specific query] | [source type] | High/Medium/Low |
| 2 | | | | |
| 3 | | | | |

**Research techniques:**
1. **Keyword search** — direct queries on the main topic
2. **Snowball** — follow citations and references from found sources
3. **Adversarial** — deliberately search for sources that contradict the main thesis
4. **Expert triangulation** — search for the same data from 3+ independent sources

---

### Phase 3 — Retrieve

Collect sources systematically. For each source found, fill in:

**Template — Source Log:**

| # | Title | Author/Org | Date | URL/DOI | Type | Relevance (1-5) | Notes |
|---|-------|-----------|------|---------|------|-----------------|------|
| S1 | | | | | Academic / Industry / News / Gov / Other | | |
| S2 | | | | | | | |

**Target quantity per depth:**
- Overview: 5-10 sources
- Analysis: 10-20 sources
- Deep dive: 20-40 sources

---

### Phase 4 — Evaluate

Evaluate the credibility of each source. Not all sources carry equal weight.

**Source Credibility Framework:**

| Criterion | Score (0-2) | Description |
|----------|------------|-------------|
| **Authority** | | Author/org recognized in the field? Affiliation? |
| **Accuracy** | | Verifiable data? Declared methodology? Peer-reviewed? |
| **Currency** | | Publication date appropriate for the topic? |
| **Coverage** | | Covers the topic in depth or superficially? |
| **Objectivity** | | Evident bias? Conflict of interest? Sponsorship? |
| **TOTAL** | /10 | |

**Thresholds:**
- **8-10**: Primary source — use as analysis pillar
- **5-7**: Secondary source — use with caution, cross-reference
- **0-4**: Weak source — cite only if no better alternative exists, with caveat

**Source red flags:**
- No identifiable author
- No publication date
- Extraordinary claims without evidence
- Undisclosed sponsorship
- Circularity (sources citing each other without a primary source)

---

### Phase 5 — Synthesize

Synthesize findings into a coherent narrative.

**Synthesis structure:**

1. **Consensus view** — what most credible sources say
2. **Minority/contrarian view** — minority positions with evidence
3. **Gaps** — what is NOT known, where research is inconclusive
4. **Confidence level** — how certain we are of the conclusion

**Confidence Framework:**

| Level | Criteria | Label |
|-------|---------|-------|
| High | 3+ concordant primary sources, no credible contrary source | "Evidence clearly indicates that..." |
| Medium | 2+ concordant sources but with some contrary sources | "Evidence suggests that..., although..." |
| Low | Discordant or insufficient sources | "There is no consensus on... The main positions are..." |
| Inconclusive | No credible sources found | "Research did not find sufficient evidence to..." |

**Synthesis rule**: every factual claim must have at least one citation. Analyst opinions must be labeled as such.

---

### Phase 6 — Deliver

**Output format per depth:**

#### Overview (1-2 pages)

```
RESEARCH BRIEF
==============
Question  : [research question]
Date      : [date]
Sources   : [n] sources consulted, [n] used
Confidence: High / Medium / Low

EXECUTIVE SUMMARY
-----------------
[3-5 paragraphs with inline citations [S1], [S2]]

KEY FINDINGS
------------
1. [finding] [S1, S3]
2. [finding] [S2, S4]
3. [finding] [S1, S5]

GAPS AND LIMITATIONS
--------------------
- [what we don't know]

SOURCES
-------
[S1] Author, Title, Date, URL
[S2] ...
```

#### Analysis (3-5 pages)

Like Overview, plus:
- Section per sub-question with detailed analysis
- Comparison table if applicable
- Evidence-based recommendations

#### Deep Dive (5-15 pages)

Like Analysis, plus:
- Explicit research methodology
- Source credibility assessment per source
- Analysis of contrary positions
- Appendix with annotated bibliography

---

## Rules

1. **Scope before searching**: do not start research without a completed Research Brief
2. **Mandatory citation**: every factual claim must be traceable to a source
3. **Adversarial search**: at least 20% of effort dedicated to searching for contrary sources
4. **Credibility evaluated**: do not cite sources without evaluating them with the framework
5. **Explicit confidence**: every conclusion must have a declared confidence level
6. **Recency check**: for fast-evolving topics, sources > 12 months require verification

## Anti-patterns

| Anti-pattern | Why It Is Wrong |
|-------------|----------------|
| Searching only for confirmations of the initial thesis | Confirmation bias, unreliable conclusions |
| Citing sources without evaluating their credibility | Weak sources contaminate the analysis |
| Synthesis without inline citations | Not verifiable, indistinguishable from opinion |
| Research without defined scope | Rabbit hole, time wasted, scope creep |
| Single source for a critical claim | No triangulation, error risk |
| Ignoring contrary positions | Incomplete analysis, avoidable surprises |

---

> **v0.1.0** | Domain skill | Pack: essentials
