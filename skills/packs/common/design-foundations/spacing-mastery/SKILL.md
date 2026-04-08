---
name: spacing-mastery
description: "Spatial design system with 8pt grid, proximity rules, and optical adjustments. Use when generating any layout (web or document) to ensure professional spacing that distinguishes designed output from AI-assembled output."
version: 0.1.0
layer: userland
category: design
triggers:
  - pattern: "spacing|padding|margin|gap|whitespace|layout|grid system|breathing room|section spacing"
dependencies:
  hard: []
  soft:
    - brand-kit
metadata:
  author: lucadealbertis
  source: custom
  domain: design
  triggers: spacing,padding,margin,gap,whitespace,grid,layout,breathing,proximity,optical
  role: specialist
  scope: generation
  output-format: css
  related-skills: brand-kit,visual-hierarchy,design-audit,frontend-design
license: proprietary
---

# Spacing Mastery — Systematic Spatial Design

Codifies the spacing rules that transform "assembled" layouts into "composed" ones. Provides a complete 8pt spacing system with 4pt micro-steps, proximity principles, optical adjustments, and context-specific scale selection for both web and document output.

## Role Definition

You are a senior spatial designer with deep expertise in grid systems, optical alignment, and the psychology of whitespace. You understand that spacing is the single most impactful factor in perceived design quality — more than color, more than typography. Professional spacing creates instant credibility; arbitrary spacing screams "AI-generated."

## When to Use This Skill

- Generating any web layout (pages, components, sections)
- Producing any document (Word, PowerPoint, PDF)
- Reviewing spacing decisions in existing output
- Setting up a design token system for a project
- Any skill that produces visual output (frontend-design, docx-reports, pptx, templates)

## When NOT to Use

- For color decisions (use `color-palette`)
- For font selection (use `font-pairing`)
- For hierarchy and layout pattern selection (use `visual-hierarchy`)
- For post-generation review (use `design-audit`)

---

## The Spacing Scale (8pt system with 4pt micro)

All spacing values must come from this scale. No exceptions. If brand-kit is present and defines a custom `spacing.unit`, recalculate the scale proportionally (e.g., if unit is 5px: space-1=5, space-2=10, space-4=20, etc.).

Default scale (base unit: 4px):

| Token | Value | Use |
|-------|-------|-----|
| `space-0` | 0px | Reset, collapse |
| `space-1` | 4px | Micro: icon-to-label, inline badge padding, tight inline gaps |
| `space-2` | 8px | Tight: input internal padding, tag gaps, list item internal spacing |
| `space-3` | 12px | Compact: form field gaps, small card padding, compact UI elements |
| `space-4` | 16px | Base: paragraph spacing, standard card padding, button vertical padding |
| `space-5` | 24px | Comfortable: form field groups, card gaps in grid, content group spacing |
| `space-6` | 32px | Spacious: between related content groups, sidebar padding |
| `space-7` | 48px | Section break: between logical page sections |
| `space-8` | 64px | Major break: between macro-sections (hero to content, chapter to chapter) |
| `space-9` | 96px | Page-level: top/bottom page margins, hero vertical padding |
| `space-10` | 128px | Dramatic: landing page breathing room, full-page section separation |

---

## Fundamental Principle: Proximity

The most important rule in spatial design. Related elements use spacing from the lower half of the scale. Separate groups use the upper half. Sections use the top. Never the same value for different types of relationships.

**The hierarchy:**

```
Within an element:     space-1 to space-2  (icon gap, label gap)
Between elements:      space-2 to space-4  (list items, form fields, paragraphs)
Between groups:        space-4 to space-6  (card groups, form sections, content blocks)
Between sections:      space-6 to space-8  (page sections, major content areas)
Between macro-areas:   space-8 to space-10 (hero to body, page-level separation)
```

**Visual diagram:**

```
┌─ Section A ─────────────────────────────┐
│                                          │
│  Heading              ← space-2 (8px)    │
│  Subheading           ← space-4 (16px)   │
│                                          │
│  ┌─ Card ──────────┐                     │
│  │ Title    sp-1    │  ← space-3 padding  │
│  │ Body     sp-2    │                     │
│  │ Action   sp-3    │  ← space-5 gap      │
│  └─────────────────┘    between cards     │
│                                          │
│  ┌─ Card ──────────┐                     │
│  │ ...              │                     │
│  └─────────────────┘                     │
│                                          │
├─── space-7 (48px) ──────────────────────┤
│                                          │
│  Section B                               │
│                                          │
└──────────────────────────────────────────┘
```

---

## Optical Adjustment Rules

These rules correct for how humans perceive space, which differs from mathematical measurement.

### 1. Card Padding Asymmetric

Bottom padding is always one step larger than top padding. Content visually "weighs" downward.

```
padding: space-4 space-4 space-5 space-4
         (top)   (right) (bottom) (left)
```

Not `padding: space-4` on all sides.

### 2. Nested Border-Radius

Inner element radius = outer element radius minus the gap between them. This creates concentric curves that feel "designed."

```
Outer: border-radius: 16px, padding: 12px
Inner: border-radius: 4px  (16 - 12 = 4)

Outer: border-radius: 12px, padding: 8px
Inner: border-radius: 4px  (12 - 8 = 4)
```

If the math gives 0 or negative, use 0 (sharp corners).

### 3. Text Breathing

The space after a heading toward its body text is always less than or equal to the space above the heading. The heading "belongs" to what follows, not what precedes it.

```
                    ← space-6 (32px) above heading
  Section Heading
                    ← space-3 (12px) below heading toward body
  Body text...
```

### 4. Button Padding

Horizontal padding is always at least 2x vertical padding. Buttons need lateral breathing room.

```
Good:  padding: space-2 space-4     (8px 16px)
Good:  padding: space-3 space-6     (12px 32px)
Bad:   padding: space-3 space-3     (12px 12px — looks cramped)
```

### 5. First/Last Child

Remove margin-top of the first element and margin-bottom of the last element inside any container. Prevents double-spacing at container edges where container padding already provides space.

### 6. Touch Target Minimum

All interactive elements (buttons, links, form controls) must have a minimum tappable area of 44x44px on mobile. This is approximately space-7 squared. Achieve via min-height/min-width or padding — the element can be visually smaller as long as the tap area meets the minimum.

---

## Contexts and Scale Selection

Different contexts call for different selections from the same scale. These are NOT multipliers — they are specific token selections.

### Web Contexts

| Context | Internal element | Between groups | Between sections | Container padding |
|---------|-----------------|----------------|------------------|-------------------|
| Landing/Hero | space-3 / space-4 | space-6 / space-7 | space-8 / space-9 | space-9 / space-10 |
| Dashboard | space-1 / space-2 | space-3 / space-4 | space-5 / space-6 | space-4 / space-5 |
| Form | space-2 / space-3 | space-4 / space-5 | space-6 / space-7 | space-4 / space-5 |
| Card content | space-1 / space-2 | space-3 | — | space-3 / space-4 |
| Blog/Article | space-2 / space-3 | space-4 / space-5 | space-7 / space-8 | space-5 / space-6 |
| Navigation | space-1 / space-2 | space-3 | — | space-2 / space-3 |
| Footer | space-2 / space-3 | space-4 / space-5 | space-6 | space-6 / space-7 |

### Document Contexts

Principles for documents. Specific values in pt/cm are derived from the scale. Templates (invoice, pitch-deck, business-report) inherit these principles and apply their own specifics.

| Element | Scale equivalent | Approximate value |
|---------|-----------------|-------------------|
| Page margins | space-9 | 2.5cm |
| Between paragraphs | space-2 | 6pt after |
| Heading to body | space-3 / space-2 | 12pt before, 6pt after |
| Between sections | space-5 | 24pt before |
| Between chapters | page break + space-7 | page break + 36pt top |
| Table cell padding | space-1 / space-2 | 4pt vertical, 8pt horizontal |
| Slide content margins | space-6 / space-7 | 2cm from edges |

---

## Web Implementation Reference (Tailwind CSS)

Mapping from spacing-mastery tokens to Tailwind utilities:

```
space-1  →  gap-1  / p-1   / m-1          (4px)
space-2  →  gap-2  / p-2   / m-2          (8px)
space-3  →  gap-3  / p-3   / m-3          (12px)
space-4  →  gap-4  / p-4   / m-4          (16px)
space-5  →  gap-6  / p-6   / m-6          (24px)
space-6  →  gap-8  / p-8   / m-8          (32px)
space-7  →  gap-12 / py-12 / my-12        (48px)
space-8  →  gap-16 / py-16 / my-16        (64px)
space-9  →  gap-24 / py-24 / my-24        (96px)
space-10 →  gap-32 / py-32 / my-32        (128px)
```

For asymmetric card padding (optical adjustment):

```
p-4 pb-6     (space-4 all sides, space-5 bottom)
pt-4 px-4 pb-6
```

---

## Anti-Patterns (always reject)

These patterns indicate spacing failure. If detected in output, flag for correction:

- **Same spacing for different relationships:** gap-4 between heading-body AND between different sections. These are different relationships requiring different values.
- **Arbitrary values outside scale:** 13px, 15px, 22px, 50px. Every value must map to a token.
- **Uniform spacing on everything:** `margin: 20px` or `gap-4` applied uniformly. Spacing must vary by relationship.
- **Symmetric padding on cards:** `p-4` without bottom optical adjustment. Should be `p-4 pb-5` or `p-4 pb-6`.
- **Zero spacing between sections:** content that "bleeds" from one section into the next with no visual break.
- **Double-spacing at edges:** container padding + first child margin creating excessive space at top/bottom.
- **Ignoring touch targets:** interactive elements under 44px tap area on mobile.

---

## Error Handling

| Scenario | Behavior |
|----------|----------|
| Brand-kit has custom spacing.unit | Recalculate entire scale proportionally. space-4 always = 4 × unit |
| Brand-kit absent | Use default 4px base. All rules apply as documented |
| Value requested outside scale | Reject. Suggest nearest scale value: "15px is not on scale. Use space-4 (16px)" |
| Context not in table | Use "Blog/Article" as default — most balanced selection |

---

**Version:** 0.1.0
**Dependencies:** brand-kit (soft)
**Trigger:** Auto-invoke when any skill generates layout (web or document)
