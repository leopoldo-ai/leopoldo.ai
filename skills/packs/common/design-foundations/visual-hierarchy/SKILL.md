---
name: visual-hierarchy
description: "Use when generating any visual output to ensure clear reading order, proper type scale, and intentional layout composition via visual hierarchy rules, advanced typography, and layout pattern selection."
type: technique
version: 0.1.0
layer: userland
category: design
triggers:
  - pattern: "hierarchy|heading size|font size|type scale|layout pattern|visual weight|reading order|emphasis|text hierarchy"
dependencies:
  hard:
    - spacing-mastery
  soft:
    - font-pairing
metadata:
  author: lucadealbertis
  source: custom
  domain: design
  triggers: hierarchy,heading,type,scale,layout,weight,emphasis,reading,order,level
  role: specialist
  scope: generation
  output-format: css
  related-skills: spacing-mastery,font-pairing,design-audit,frontend-design
license: proprietary
---

# Visual Hierarchy — Systematic Reading Order and Emphasis

Codifies the rules for visual order: what the user sees first, second, last. Controls hierarchy levels, advanced typography, layout pattern selection, and visual weight distribution for both web and document output.

## Role Definition

You are a senior visual designer with deep expertise in typographic hierarchy, layout composition, and information architecture. You understand that hierarchy is not decoration — it is the mechanism that makes content scannable, comprehensible, and actionable. Without clear hierarchy, even well-written content fails to communicate.

## When to Use This Skill

- Generating any page layout (web or document)
- Selecting heading sizes and weights for a design
- Choosing layout patterns for a page or section
- Reviewing visual emphasis and reading order
- Any skill that produces multi-level content (frontend-design, docx-reports, pptx, templates)

## When NOT to Use

- For spacing values and spatial rules (use `spacing-mastery`)
- For font selection and pairing (use `font-pairing`)
- For color decisions (use `color-palette`)
- For post-generation review (use `design-audit`)

---

## The 4 Hierarchy Levels

Every page, document, or slide has exactly 4 levels. Never more, never fewer. If content seems to need 5+ levels, the information architecture is wrong — restructure the content, don't add levels.

| Level | Function | Visual Weight | Example |
|-------|----------|--------------|---------|
| **L1 — Dominant** | One single thing per viewport | Maximum: size + weight + color | Hero heading, primary KPI, slide title |
| **L2 — Supporting** | Supports L1, guides toward content | High: size OR weight OR color (never all three) | Subheading, secondary metric, subtitle |
| **L3 — Body** | The main content | Medium: readable, neutral | Paragraphs, tables, lists, form fields |
| **L4 — Tertiary** | Metadata, notes, helper text | Low: reduced size + muted color | Caption, timestamp, placeholder, footnote |

### The Golden Rule

> Every level must be distinguishable from the previous one WITHOUT reading the text. If you must read to understand the hierarchy, the hierarchy does not exist.

### Level Differentiation

At least 2 of these 4 factors must change between adjacent levels:

| Factor | L1 → L2 | L2 → L3 | L3 → L4 |
|--------|---------|---------|---------|
| **Size** | ≥1.5x ratio | ≥1.25x ratio | ≥0.85x ratio (L4 smaller) |
| **Weight** | 700-800 → 600 | 600 → 400 | 400 → 400 |
| **Color** | Primary/full black → primary/dark gray | Dark gray → base text | Base text → medium gray |
| **Spacing** | space-5+ after L1 | space-3 / space-4 after L2 | space-2 after L3 |

Changing only one factor (e.g., only size) creates weak hierarchy. The levels blur together.

---

## Advanced Typography

### Fluid Type (suggested defaults)

These are starting points. Override with font-pairing or brand-kit values when present. The principle matters more than the exact values: size, line-height, and letter-spacing are inversely correlated with text size.

| Level | Mobile (min) | Desktop (max) | line-height | letter-spacing |
|-------|-------------|---------------|-------------|----------------|
| L1 | 32px | 64px | 1.05–1.1 | −0.02em |
| L2 | 20px | 32px | 1.15–1.2 | −0.01em |
| L3 | 16px | 18px | 1.5–1.6 | 0 |
| L4 | 12px | 14px | 1.4 | +0.01em |

Reference `clamp()` formulas (adapt to project needs):

```css
--text-l1: clamp(2rem, 5vw + 1rem, 4rem);
--text-l2: clamp(1.25rem, 2vw + 0.75rem, 2rem);
--text-l3: clamp(1rem, 0.5vw + 0.875rem, 1.125rem);
--text-l4: clamp(0.75rem, 0.25vw + 0.7rem, 0.875rem);
```

### Typography Rules

1. **Large headings (L1):** letter-spacing **negative** — tighter tracking is more elegant at large sizes
2. **Body text (L3):** letter-spacing **zero** — maximum readability at reading sizes
3. **Small text (L4):** letter-spacing **slightly positive** — opens up characters, compensates for small size
4. **Line-height inversely proportional to size:** larger text = tighter leading. A 64px heading at line-height 1.5 wastes enormous vertical space
5. **Max measure (line width):** 65-75 characters for L3 body text. Never full-width on screens wider than 768px. Use `max-w-prose` (65ch) or equivalent
6. **Heading weight progression:** L1 heaviest (bold/800), decreasing through levels. Never all headings at the same weight

---

## Layout Patterns (5 Primitives)

visual-hierarchy defines **when to use each pattern** — the design decision. Implementation code (Tailwind classes, CSS, document structure) is produced by frontend-design or document templates consulting these rules.

Every layout is composed from combinations of these 5 patterns:

### 1. Stack

Vertical elements with consistent gap. The most common pattern.

```
When: main content areas, forms, article body, lists, vertical card layouts
Gap: space-3 (tight) / space-4 (default) / space-5 (comfortable)
Rule: ONE gap value per stack. Never mix gap sizes within a single stack.
Nesting: stacks can nest. Inner stack uses tighter gap than outer stack.
```

### 2. Cluster

Inline elements that wrap naturally.

```
When: tag groups, badge collections, breadcrumbs, button groups, metadata lines
Gap: space-2 (tight) / space-3 (default)
Rule: align-items center. Never baseline on elements with different heights.
Wrap: flex-wrap always enabled. Never force single-line with overflow.
```

### 3. Sidebar

Content area paired with a narrower side panel.

```
When: main page layout, card with side image, content + table of contents
Ratio: content 2/3 – sidebar 1/3 (intentional asymmetry, never 50/50)
Gap: space-5 / space-6 between content and sidebar
Breakpoint: below 768px → vertical stack, sidebar moves below content
Exception: dashboard sidebar (navigation) can be fixed width (240-280px)
```

### 4. Switcher

Columns that automatically collapse below a threshold.

```
When: card grids, feature grids, pricing tables, team grids
Rule: use min-width per child (e.g., min 300px), not media queries.
       Let CSS figure out column count: 3 on desktop, 2 on tablet, 1 on mobile.
Gap: space-4 / space-5 between items
Alignment: stretch height within row unless content varies dramatically
```

### 5. Cover

Vertically centered content with optional header and footer.

```
When: hero sections, login pages, error pages, empty states, splash screens
Structure: header (optional) + centered content + footer (optional)
Min-height: 100vh for hero/full-page, 60vh for internal section covers
Padding: space-9 / space-10 vertical
Rule: content is always vertically AND horizontally centered
```

### Context-to-Pattern Mapping

| Context | Pattern sequence | Notes |
|---------|-----------------|-------|
| Landing page | Cover (hero) → Stack (sections) → Switcher (features/pricing) | Hero is full Cover, rest is stacked sections |
| Dashboard | Sidebar (nav) → Grid of Stacks (widget cards) | Fixed sidebar, content area is card grid |
| Blog/article | Stack with max-width | Single column, max 65ch, generous vertical spacing |
| Form page | Stack with grouped sections | Form groups separated by space-6, fields by space-3 |
| Document (Word) | Stack with heading hierarchy | Heading 1-4 map to L1-L4, sections separated by spacing |
| Slide (PPT) | Cover or Split (sidebar variant) | One idea per slide, L1 title always present |

---

## Visual Weight: The Balance

### Principles

1. **Intentional asymmetry > generic symmetry.** A 60/40 layout is more dynamic and professional than 50/50. Symmetric layouts are a signal of "AI-generated" output.

2. **One focus point per viewport.** If two elements compete for attention (both large, both bold, both colorful), one must yield. Demote it to L2 or reduce its visual weight.

3. **Whitespace is a design element.** It is not "empty space" — it directs the eye, creates breathing room, and signals importance. Generous whitespace around an element increases its perceived importance.

4. **Information density limit:** maximum 3-4 content groups per viewport. If there are more, the user should scroll to see them — do not compress everything into view. Compression destroys hierarchy.

5. **Visual gravity:** heavier elements (larger, darker, bolder) anchor to the top or left. Lighter elements (smaller, lighter color, thinner weight) flow to the bottom or right. This follows natural reading patterns (F-pattern for web, Z-pattern for marketing).

---

## Context-Specific Level Values

### Web Contexts

| Context | L1 | L2 | L3 | L4 | Dominant layout |
|---------|----|----|----|----|-----------------|
| Landing page | 48-64px, bold, tracking-tight | 24-32px, medium | 18px, regular | 14px, gray | Cover → Stack → Switcher |
| Dashboard | 24-28px, semibold | 16-18px, medium | 14px, regular | 12px, gray | Sidebar → Card grid |
| Blog/article | 36-48px, bold | 20-24px, semibold | 18px, regular, max 65ch | 14px, gray | Stack with max-width |
| Form page | 24px, semibold | 16px, medium | 14-16px, regular | 12px, helper text | Stack with groups |
| E-commerce | 28-36px, bold | 18-20px, medium | 16px, regular | 13px, gray | Switcher (product grid) |
| SaaS app | 20-24px, semibold | 16px, medium | 14px, regular | 12px, muted | Sidebar → Stack |

### Document Contexts

| Context | L1 | L2 | L3 | L4 |
|---------|----|----|----|----|
| Report (Word) | 18-24pt, bold | 14-16pt, semibold | 11-12pt, regular | 9-10pt, gray |
| Slide (PPT) | 36-44pt, bold | 24-28pt, medium | 18-20pt, regular | 14pt, gray |
| One-pager | 24-28pt, bold | 14-16pt, semibold | 10-11pt, regular | 8-9pt, gray |
| Invoice/Quote | 16-20pt, bold | 12-14pt, semibold | 10-11pt, regular | 8-9pt, gray |

---

## Anti-Patterns (always reject)

- **More than 4 hierarchy levels:** confuses rather than clarifies. Restructure content instead.
- **Difference between levels only in size:** weight and color must also change. Size-only hierarchy is weak.
- **Body text full-width on wide screens (>75ch):** unreadable. Always constrain measure.
- **Two L1 elements in the same viewport:** they compete. One must become L2.
- **All headings same weight:** flattens hierarchy. L1 must be visually heavier than L2.
- **Uniform line-height (1.5 everywhere):** headings at 1.5 look airy and unprofessional. L1 needs 1.05-1.1.
- **50/50 layout everywhere:** generic symmetry is a hallmark of AI-generated design.
- **Cards forced to identical height:** distorts content that varies naturally. Allow natural height unless the grid specifically requires uniform cards.
- **Letter-spacing positive on large headings:** large text should be tracked tighter (-0.01 to -0.03em), not looser.

---

## Error Handling

| Scenario | Behavior |
|----------|----------|
| Font-pairing defines a type scale | Use font-pairing values for sizes, apply visual-hierarchy rules for weight/color/spacing |
| Font-pairing absent | Use suggested defaults from this skill |
| Content needs 5+ levels | Do not add levels. Flag: "Content has too many levels. Restructure: merge L3 sub-levels or split into separate sections" |
| Context not in table | Default to "Blog/article" for content pages, "SaaS app" for application UIs |
| Conflicting L1 elements | Flag: "Two L1 elements detected. Demote one to L2 or split into separate viewports" |

---

**Version:** 0.1.0
**Dependencies:** spacing-mastery (hard), font-pairing (soft)
**Trigger:** Auto-invoke with spacing-mastery when any skill generates visual output
