---
name: one-pager
description: "Use when building single-page marketing and sales documents in .docx format. 3 layout variants: product/service sheet, company overview, executive summary. Brand-kit styled."
type: technique
version: 0.1.0
layer: userland
category: templates
triggers:
  - pattern: "one pager|one-pager|sales sheet|product sheet|leave-behind|fact sheet|company overview one page"
dependencies:
  hard: []
  soft:
    - brand-kit
    - docx-reports
metadata:
  author: lucadealbertis
  source: custom
  domain: design
  triggers: one-pager,sales,sheet,product,leave-behind,fact,overview
  role: specialist
  scope: generation
  output-format: docx
  related-skills: brand-kit,business-report,docx-reports,executive-briefing,client-proposal-builder,pitch-deck
license: proprietary
tier: essentials
status: ga
---

# One-Pager — Single-Page Marketing & Sales Documents

Generate single-page branded documents in .docx format. Designed to be printed, emailed, or left behind after meetings. Everything must fit on ONE page — density over length.

## When to Use

- Product/service sales sheets
- Company overviews for prospects
- Executive summary leave-behinds
- Fact sheets for events/conferences

## When NOT to Use

- Multi-page reports (use `business-report`)
- Full proposals (use `client-proposal-builder`)
- Presentations (use `pitch-deck`)
- Detailed executive briefings (use `executive-briefing`)

---

## Brand Integration

Same protocol as all template skills. One-pagers are brand-critical — they are often the first branded document a prospect sees.

1. Logo prominent in header
2. Brand primary for key sections and data highlights
3. Brand accent for CTAs and standout numbers
4. Brand fonts throughout
5. Fallback: docx-reports defaults

---

## Layout Variants

### A. Product/Service One-Pager

```
┌──────────────────────────────────────┐
│  [Logo]          Product/Service Name│
│  ────────────────────────────────────│
│                                      │
│  VALUE PROPOSITION (2 sentences max) │
│                                      │
│  ┌─────────┐ ┌─────────┐ ┌────────┐ │
│  │Feature 1│ │Feature 2│ │Feature3│ │
│  │  desc   │ │  desc   │ │ desc   │ │
│  └─────────┘ └─────────┘ └────────┘ │
│                                      │
│  KEY METRICS                         │
│  ┌──────┬──────┬──────┬──────┐      │
│  │ 99%  │ 50+  │ 3x   │ <1h  │      │
│  │uptime│clients│ ROI  │deploy│      │
│  └──────┴──────┴──────┴──────┘      │
│                                      │
│  CTA: Contact us | website | email   │
└──────────────────────────────────────┘
```

**Sections:**
1. Header: logo + product name
2. Value proposition: 2 sentences max, large font
3. Feature blocks: 3-4 features with title + 1-2 sentence description
4. Key metrics row: 3-4 numbers with labels (brand accent for numbers)
5. Call to action + contact info

### B. Company Overview

```
┌──────────────────────────────────────┐
│  [Logo]              Company Name    │
│  ────────────────────────────────────│
│                                      │
│  MISSION (2 sentences)               │
│                                      │
│  KEY FACTS                           │
│  Founded: 2020  │ HQ: Milan         │
│  Team: 45       │ Revenue: EUR 8M   │
│                                      │
│  CORE SERVICES                       │
│  • Service 1 — brief description     │
│  • Service 2 — brief description     │
│  • Service 3 — brief description     │
│                                      │
│  DIFFERENTIATORS                     │
│  ┌─────────────┐ ┌─────────────┐    │
│  │Differentiator│ │Differentiator│    │
│  │    1         │ │    2         │    │
│  └─────────────┘ └─────────────┘    │
│                                      │
│  Contact: email | phone | website    │
└──────────────────────────────────────┘
```

**Sections:**
1. Header: logo + company name
2. Mission/vision: 2 sentences max
3. Key facts: 4-6 data points in grid layout
4. Core services: 3-4 bullets with brief descriptions
5. Differentiators: 2-3 competitive advantages
6. Contact information

### C. Executive Summary One-Pager

```
┌──────────────────────────────────────┐
│  [Logo]     Executive Summary        │
│  Title of Topic          Date        │
│  ────────────────────────────────────│
│                                      │
│  SITUATION                           │
│  Brief context (2-3 sentences)       │
│                                      │
│  KEY FINDINGS                        │
│  1. Finding one with data            │
│  2. Finding two with data            │
│  3. Finding three with data          │
│                                      │
│  RECOMMENDATION                      │
│  Clear recommendation (2-3 sentences)│
│                                      │
│  NEXT STEPS          │ TIMELINE      │
│  • Step 1            │ Week 1-2      │
│  • Step 2            │ Week 3-4      │
│  • Step 3            │ Week 5-6      │
│                                      │
│  Prepared by: Name | Role | Contact  │
└──────────────────────────────────────┘
```

**Sections:**
1. Header: logo + title + date
2. Situation: 2-3 sentences of context
3. Key findings: 3-5 numbered findings with supporting data
4. Recommendation: clear action statement
5. Next steps with timeline
6. Author attribution

---

## Design Rules

1. **ONE PAGE MAXIMUM** — if content doesn't fit, cut content, don't add pages
2. **Dense but readable** — use smaller font sizes (9-10pt for body) if needed
3. **Two-column layout** where it helps density
4. **Brand accent for numbers** — key metrics should pop visually
5. **Minimal margins** — 1.5-2cm to maximize space (override brand-kit if needed)
6. **No header/footer** — the entire page IS the document (unlike multi-page docs)

---

## Formatting

| Element | Style |
|---------|-------|
| Page | A4, portrait or landscape (user choice) |
| Title | Brand heading font, 16-18pt, brand primary |
| Section headers | Brand heading font, 11-12pt, bold, brand secondary |
| Body | Brand body font, 9-10pt |
| Key numbers | Brand heading font, 18-24pt, brand accent |
| Margins | 1.5-2cm (tighter than standard) |

---

## Required Inputs

| Input | Required | Default |
|-------|----------|---------|
| Variant (A/B/C) | No | Infer from content |
| Content | Yes | — |
| Orientation | No | Portrait |

---

## Generation

Uses `document-skills:docx` or python-docx via Bash, following `docx-reports` pattern.

**Output path:** `docs/one-pagers/one-pager-{title-slug}-{date}.docx`

---

**Version:** 0.1.0
**Dipendenze:** brand-kit (soft), docx-reports (soft)
**Trigger:** Skill-router quando si menziona one-pager, fact sheet, sales sheet, leave-behind
