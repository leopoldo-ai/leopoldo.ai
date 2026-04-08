---
name: font-pairing
description: "Typography pairing rules and curated catalog. Use when selecting fonts for a brand, validating font combinations, calculating type scales, or optimizing text readability."
version: 0.1.0
layer: userland
category: design
triggers:
  - pattern: "font pairing|typography|type scale|font combination|readability|line height|font selection"
dependencies:
  hard: []
  soft:
    - brand-kit
    - color-palette
metadata:
  author: lucadealbertis
  source: custom
  domain: design
  triggers: font,pairing,typography,type,scale,readability,line-height,modular
  role: specialist
  scope: generation
  output-format: yaml
  related-skills: brand-kit,color-palette,frontend-design
license: proprietary
---

# Font Pairing — Theory-Driven Typography Selection

Select, pair, and validate fonts for brand identity and document production. Provides a curated catalog of 12 pairings, modular scale calculator, and readability validation.

## Role Definition

You are a typography specialist with deep knowledge of typeface classification, optical sizing, and reading ergonomics. You understand that typography is the backbone of visual communication — the right pairing creates instant credibility, while a poor choice undermines even the best content.

## When to Use This Skill

- Selecting heading + body font combination for a brand
- Calculating a modular type scale
- Validating readability (line-height, measure, spacing)
- Choosing between Google Fonts for web or system fonts for documents

## When NOT to Use

- For color selection (use `color-palette`)
- For full brand identity (use `brand-kit-builder`)
- For CSS/code implementation (use `frontend-design` or `brand-to-ui`)

---

## Pairing Principles

### 1. Contrast

Pair fonts from **different classifications** to create visual hierarchy:
- Serif + Sans-serif (classic combination)
- Geometric + Humanist (modern contrast)
- Display/Decorative + Clean body (editorial feel)

### 2. Concordance

Despite different classifications, paired fonts should share **structural traits**:
- Similar x-height (relative size of lowercase letters)
- Compatible proportions (wide + wide, or narrow + narrow)
- Comparable stroke contrast (both high-contrast, or both low)

### 3. Anti-Patterns — Never Pair

- Two decorative/display fonts (visual chaos)
- Two fonts from the same sub-classification with similar weight (no hierarchy)
- Fonts with clashing proportions (e.g., very condensed heading + very wide body)
- More than 3 font families in one project

---

## Modular Scale Calculator

A modular scale creates harmonious size relationships. Given base size + ratio, calculate the full scale.

### Common Ratios

| Name | Ratio | Character | Best For |
|------|-------|-----------|----------|
| Major Second | 1.125 | Subtle, tight | Dense data UIs, dashboards |
| Minor Third | 1.200 | Balanced | Most web applications |
| Major Third | 1.250 | Clear hierarchy | Corporate documents, reports |
| Perfect Fourth | 1.333 | Strong contrast | Marketing sites, presentations |
| Perfect Fifth | 1.500 | Dramatic | Editorial, landing pages |

### Scale Output

For base=16px, ratio=1.25 (major third):

| Token | Size | rem | Use |
|-------|------|-----|-----|
| xs | 10px | 0.64 | Captions, fine print |
| sm | 13px | 0.80 | Labels, metadata |
| base | 16px | 1.00 | Body text |
| lg | 20px | 1.25 | Lead paragraphs, H4 |
| xl | 25px | 1.56 | H3 |
| 2xl | 31px | 1.95 | H2 |
| 3xl | 39px | 2.44 | H1 |
| 4xl | 49px | 3.05 | Display, hero |
| 5xl | 61px | 3.81 | Display large |

---

## Readability Rules

### Body Text

| Property | Optimal Range | Rule |
|----------|--------------|------|
| Font size | 16-18px (web), 11-12pt (print) | Minimum 16px for screens |
| Line height | 1.4-1.6 | Wider for longer lines |
| Measure (line length) | 45-75 characters | 65ch is ideal |
| Paragraph spacing | 0.5-1.0em | Match line-height rhythm |
| Letter spacing | 0 to +0.01em | Body rarely needs adjustment |

### Headings

| Property | Optimal Range | Rule |
|----------|--------------|------|
| Line height | 1.1-1.3 | Tighter than body |
| Letter spacing | -0.02 to 0em | Slightly negative for large sizes |
| Weight | 600-700 | Semi-bold to bold |

### Document-Specific

| Context | Font | Size | Notes |
|---------|------|------|-------|
| Word (.docx) | Calibri, Inter, Georgia | 11pt body, 16pt H1 | System fonts preferred for compatibility |
| Slides (.pptx) | Any Google Font | 24pt body, 44pt title | Must be readable from 3m distance |
| Web | Google Fonts or variable fonts | 16px base | Load max 2 families, 4 weights |

---

## Font Availability

### Google Fonts (web + presentations)

All 12 catalog pairings use Google Fonts. Free, widely supported, easy to embed.

### System Fonts (documents)

For .docx/.xlsx output where font embedding is unreliable:
- **Windows:** Calibri, Segoe UI, Arial, Times New Roman, Consolas
- **macOS:** SF Pro, Helvetica Neue, Georgia, Menlo
- **Cross-platform safe:** Arial, Times New Roman, Courier New, Verdana, Georgia

**Rule:** If a brand uses a Google Font for web, map to the closest system font for documents. Document the mapping in brand-kit.yaml comments.

---

## Catalog

See `references/pairing-catalog.md` for 12 curated pairings with complete specifications, CSS examples, and use-case guidance.

---

## Output

When recommending a pairing, output the `typography` section for `brand-kit.yaml`:

```yaml
typography:
  heading:
    family: "Recommended Heading Font"
    weights: [600, 700]
  body:
    family: "Recommended Body Font"
    weights: [400, 500]
  mono:
    family: "JetBrains Mono"
    weights: [400, 500]
  scale:
    base: 16
    ratio: 1.25
```

Include rationale for the pairing choice and the scale ratio.

---

**Version:** 0.1.0
**Dipendenze:** brand-kit (soft)
**Trigger:** Skill-router quando si menziona font, tipografia, pairing, type scale, leggibilita'
