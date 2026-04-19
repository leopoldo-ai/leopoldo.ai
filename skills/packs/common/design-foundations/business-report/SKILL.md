---
name: business-report
description: "Use for annual reports, strategic reports, management reports, or white papers. Builds multi-section branded professional reports in .docx format with table of contents, headers/footers, and consistent styling."
type: technique
version: 0.1.0
layer: userland
category: templates
triggers:
  - pattern: "business report|annual report|management report|strategic report|white paper|formal report"
dependencies:
  hard: []
  soft:
    - brand-kit
    - docx-reports
metadata:
  author: lucadealbertis
  source: custom
  domain: design
  triggers: business,report,annual,management,strategic,white,paper
  role: specialist
  scope: generation
  output-format: docx
  related-skills: brand-kit,docx-reports,one-pager,executive-briefing
license: proprietary
---

# Business Report — Multi-Section Branded Professional Reports

Generate formal multi-section business documents in .docx format with table of contents, branded headers/footers, and professional styling. For substantial documents that require structured navigation.

## When to Use

- Annual reports
- Strategic analysis reports
- Management reports
- White papers
- Due diligence reports (structure — content from DD skills)
- Regulatory compliance reports

## When NOT to Use

- Single-page documents (use `one-pager`)
- Executive summaries for board (use `executive-briefing`)
- Standard phase reports or KPI reports (use `docx-reports` templates)
- Presentations (use `pitch-deck` or `investor-deck`)

---

## Brand Integration

1. Read brand-kit.yaml → apply throughout document
2. Cover page: logo centered, title in heading font, company name, date
3. Headers: logo (per brand-kit position) + document title
4. Footers: "Confidential" + page number + company name
5. Heading colors: H1 in primary, H2 in secondary
6. Fallback: docx-reports default styling

---

## Report Structure

### Cover Page
- Company logo (centered, large)
- Document title (heading font, 28pt, brand primary)
- Subtitle (optional, 18pt, brand secondary)
- Author name(s) and role(s)
- Date
- Classification: Confidential / Internal / Public
- Version number (optional)

### Table of Contents
Auto-generated from H1 and H2 headings with page numbers. Update before final save.

### Executive Summary
- Max 1 page
- Key findings in 3-5 bullet points
- Overall recommendation (1-2 sentences)
- **Rule:** Someone who reads only this page should understand the core message

### Body Sections (User-Defined)
Each section follows this pattern:
- **H1:** Section title (heading font, 18pt, brand primary)
- **H2:** Subsection title (heading font, 14pt, brand secondary)
- Body text: body font, 11pt, line-height 1.15
- Tables: header row in brand primary background (white text), alternating rows (neutral-100/white)
- Charts/figures: numbered (Figure 1, Figure 2...), captioned below
- Key callout boxes: light brand primary background (10% opacity) with left border in primary

### Conclusions & Recommendations
- Numbered recommendations
- Each with: recommendation text + rationale + priority (P0/P1/P2) + owner (if known)

### Appendices (Optional)
- Detailed data tables
- Methodology notes
- Glossary
- Source references

---

## Formatting Rules

| Element | Style |
|---------|-------|
| H1 | Brand heading font, 18pt, bold, brand primary color |
| H2 | Brand heading font, 14pt, bold, brand secondary color |
| H3 | Brand heading font, 12pt, semi-bold, neutral-700 |
| Body | Brand body font, 11pt, neutral-900, line-height 1.15 |
| Table header | Brand primary background, white text, bold |
| Table body | Alternating neutral-100/white rows |
| Page size | A4 (210x297mm) |
| Margins | From brand-kit (default 2.5cm) |
| Header | Logo (left) + document title (right), 9pt |
| Footer | "Confidential — Page X of Y — Company Name", 9pt |

---

## Required Inputs

| Input | Required | Default |
|-------|----------|---------|
| Document title | Yes | — |
| Section structure | Yes | — |
| Section content | Yes | — |
| Author(s) | No | From brand-kit company name |
| Classification | No | Confidential |
| Date | No | Today |

---

## Generation

Uses `document-skills:docx` or python-docx via Bash, following `docx-reports` pattern.

**Output path:** `docs/reports/business-report-{title-slug}-{date}.docx`

---

**Version:** 0.1.0
**Dipendenze:** brand-kit (soft), docx-reports (soft)
**Trigger:** Skill-router quando si menziona report aziendale, annual report, white paper
