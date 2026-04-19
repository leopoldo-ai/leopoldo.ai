---
name: doc-coauthoring
version: 0.1.0
description: "Use when co-writing proposals, specs, white papers, decision docs, or any document requiring multiple drafting passes and reader testing through iterative collaborative writing. For one-shot report generation use docx-reports instead."
type: technique
metadata:
  author: internal
  source: custom
  license: proprietary
  forge_strategy: build
  forge_sources:
    - "Inspired by Anthropic doc-coauthoring workflow methodology (source-available — BUILD, not ADAPT)"
  created: 2026-03-13
---

# Doc Co-Authoring

Iterative workflow for co-writing complex documents: proposals, specs, white papers, position papers, decision documents. Works section by section with checkpoints, reader testing, and progressive refinement.

## Why It Exists

| Problem | Solution |
|---------|----------|
| Documents generated in a single pass with logical gaps | Iterative multi-pass process with checkpoints |
| No readability testing | Reader testing to identify ambiguities |
| Inconsistent tone and structure across sections | Defined and enforced style guide |
| Content not aligned with target audience | Explicit context gathering on audience and purpose |

## Coexistence

| Skill | When to Use |
|-------|------------|
| `docx-reports` | One-shot structured report (final deliverable, template-driven) |
| `doc-coauthoring` | Complex document requiring iteration (proposal, spec, white paper) |

Often the flow is: `doc-coauthoring` to develop the content → `docx-reports` for the final format.

## Core Workflow

### Phase 1 — Context Gathering

Before writing a single word, collect the complete context.

**Template — Document Brief:**

| Field | Value |
|-------|-------|
| Document type | Proposal / Spec / White paper / Decision doc / Position paper / Other |
| Primary audience | [who will read — role, level, background] |
| Secondary audience | [who might read — forward chain] |
| Objective | [what should happen after reading] |
| Tone | Formal / Semi-formal / Conversational |
| Target length | [pages or words] |
| Constraints | [deadline, brand guidelines, mandatory template, language] |
| Input materials | [existing documents, data, interviews, notes] |
| Decisions already made | [what is already defined vs what is open] |

**Probing questions (ask if missing):**
1. Who is the most skeptical reader? What would convince them?
2. What foreseeable objections must we anticipate?
3. Is there a similar document already approved to use as reference?
4. Which section is most critical / requires the most attention?

---

### Phase 2 — Structure

Define the structure before writing. For each section, declare its purpose.

**Template — Document Outline:**

| # | Section | Purpose | Estimated Length | Priority | Required Inputs |
|---|---------|---------|-----------------|----------|----------------|
| 1 | | [what this section must communicate] | [% of total] | Must / Should / Nice | [data, documents] |
| 2 | | | | | |
| 3 | | | | | |

**Structure rules:**
1. **Inverted pyramid**: conclusion/recommendation first, details after
2. **Every section has a purpose**: if you don't know why a section exists, remove it
3. **Logical flow**: the reader should never wonder "why am I reading this now?"
4. **Executive summary always**: for documents > 3 pages, the executive summary is mandatory

**Checkpoint**: share the outline with the human co-author before proceeding. Correcting the structure now costs 10x less than later.

---

### Phase 3 — Drafting (section by section)

Write one section at a time. For each section:

1. **Contextualize**: re-read brief + outline + already written sections
2. **Brainstorm key points**: list 5-10 points the section must cover
3. **Curate**: select the 3-5 most important points, order logically
4. **Write**: first draft of the section
5. **Self-review**: re-read for coherence, completeness, tone

**Per-section checkpoint:**

```
SECTION [n]: [title]
Status: Draft / In review / Final

POINTS COVERED:
- [x] Point 1
- [x] Point 2
- [ ] Point 3 (deferred to next section)

OPEN QUESTIONS:
- [question requiring co-author input]

NEXT STEP: [what to do after feedback]
```

**Drafting rule**: do not over-polish in the first draft. The goal is to have a complete draft, not a perfect one. Perfection comes in subsequent passes.

---

### Phase 4 — Refinement (iterative passes)

After the complete draft, make focused passes. Each pass has a specific objective.

| Pass | Focus | Guiding Question |
|------|-------|-----------------|
| **Pass 1: Completeness** | Missing information? Logical gaps? | "Would a skeptical reader find this section convincing?" |
| **Pass 2: Clarity** | Are sentences comprehensible on first reading? Necessary jargon? | "Would a colleague from another department understand?" |
| **Pass 3: Conciseness** | Repetitions? Removable paragraphs? | "If I cut this sentence, does the document lose something?" |
| **Pass 4: Coherence** | Uniform tone? Consistent terminology? Consistent numbers? | "Does it seem written by the same person?" |
| **Pass 5: Flow** | Do transitions between sections work? Is the flow natural? | "Does the reader always know why they're reading this section?" |

**Not all passes are always necessary.** For short documents (< 3 pages), Pass 1 + Pass 2 are sufficient.

---

### Phase 5 — Reader Testing

Test the document with a fresh perspective. The goal is to find ambiguities and gaps that the author cannot see.

**Method:**

1. **Summarize test**: ask someone (or a separate instance) to summarize the document in 3 sentences. If the summary doesn't match the intent → the message isn't getting through
2. **Objection test**: identify the 3 main objections a critical reader would raise. For each, verify the document anticipates them
3. **Action test**: does the reader know what to do after reading? Is the required action clear and specific?

**Template — Reader Test Results:**

```
READER TEST
===========
Document: [title]
Tester: [name/role]

SUMMARIZE TEST
--------------
Tester's summary: [3 sentences]
Matches intent? [Yes / Partially / No]
Identified gaps: [what's missing from the summary]

OBJECTION TEST
--------------
1. Objection: [text] → Anticipated in doc? [Yes (section X) / No]
2. Objection: [text] → Anticipated? [Yes / No]
3. Objection: [text] → Anticipated? [Yes / No]

ACTION TEST
-----------
Action perceived by tester: [what they think they need to do]
Matches intent? [Yes / No]

REQUIRED FIXES
--------------
1. [fix]
2. [fix]
```

---

### Phase 6 — Finalization

1. **Incorporate feedback** from the reader test
2. **Formatting**: titles, table of contents, numbering, header/footer
3. **Executive summary**: write LAST (after content is stable)
4. **Citations**: verify all sources are cited
5. **Final proofreading**: typos, formatting, links
6. **Handoff**: if final format needed (Word, PDF, PPTX), pass to `docx-reports` or `pptx`

---

## Rules

1. **Context gathering before writing**: do not skip Phase 1
2. **Approved outline before writing**: do not start the draft without a shared structure
3. **Section by section with checkpoints**: do not write everything and then review everything
4. **Focused passes**: each revision has ONE objective, not "improve everything"
5. **Reader test for important documents**: documents > 5 pages or for external audience
6. **Executive summary last**: never write it before the content

## Anti-patterns

| Anti-pattern | Why It Is Wrong |
|-------------|----------------|
| Writing everything in a single pass | Logical gaps, inconsistencies, variable tone |
| Perfecting the first section before having the complete draft | You lose the big picture, risk rewriting |
| No reader test | The author is blind to their own logical gaps |
| Executive summary written first | It inevitably changes, double work |
| Revising without specific focus | "Improve" = no objective criterion |
| Ignoring uncomfortable feedback | The most useful feedback is the one that hurts |

---

> **v0.1.0** | Domain skill | Pack: essentials
