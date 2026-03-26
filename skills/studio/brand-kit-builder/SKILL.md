---
name: brand-kit-builder
description: "Interactive wizard for creating brand-kit.yaml. Two modes: Discovery (from scratch with preset selection) and Import (extract brand values from existing PDF brand guidelines). Studio-only — never deployed to clients."
version: 0.1.0
layer: studio
triggers:
  - pattern: "create brand kit|setup brand|build brand identity|import brand guidelines"
dependencies:
  hard:
    - brand-kit
  soft:
    - color-palette
    - font-pairing
    - pdf-analyzer
---

# Brand Kit Builder — Interactive Brand Identity Setup

Studio-only skill for creating `brand-kit.yaml` files. Guides operators through brand identity setup via interactive conversation. Two modes: build from scratch or import from existing brand guidelines.

**This skill is NEVER deployed to clients.** It lives in `studio/` and is used only by SkillOS operators when setting up a new client project.

---

## Mode Selection

When invoked, ask the user:

> **How would you like to create the brand kit?**
>
> **A. Discovery** — Build from scratch. I'll guide you through colors, fonts, and layout choices step by step.
>
> **B. Import** — Extract brand identity from an existing brand guidelines PDF. I'll analyze the document and map values to brand-kit.yaml.

---

## Mode A — Discovery (From Scratch)

### Step 1: Company Context

Ask:
1. Company name
2. Industry (finance, tech, healthcare, consulting, etc.)
3. Positioning on a scale: 1 (very conservative) → 5 (very innovative)

### Step 2: Suggest Preset

Based on positioning:
- Score 1-2 → Suggest **corporate-finance** preset
- Score 4-5 → Suggest **tech-startup** preset
- Score 3 → Present both, let user choose

Load the chosen preset from `brand-kit` skill's `references/presets.md`.

### Step 3: Present Initial Kit

Show the user a summary:

```
Brand Kit Summary
─────────────────
Company:    {{name}}
Preset:     corporate-finance

Colors:
  Primary:   #1B3A5C (navy)     ██████
  Secondary: #2E86AB (teal)     ██████
  Accent:    #F18F01 (amber)    ██████

Typography:
  Heading:   Inter 600/700
  Body:      Inter 400/500
  Scale:     1.25 (major third)

Document:
  Margins:   2.5cm all sides
  Logo:      left
  Footer:    page numbers + company name
```

### Step 4: Iterate Refinements

Ask: "Would you like to change anything? Examples: 'change primary to dark green', 'use Playfair Display for headings', 'wider margins'."

Accept changes one at a time. After each change:
1. Update the kit values
2. If color changed → run `color-palette` WCAG validation
3. If font changed → check pairing compatibility via `font-pairing` principles
4. Show updated summary

Repeat until user approves.

### Step 5: Generate brand-kit.yaml

1. Write validated `brand-kit.yaml` to `.brand/brand-kit.yaml` (or project root)
2. Run `brand-kit` schema validation
3. Report: "Brand kit generated at `.brand/brand-kit.yaml`. All values validated."

---

## Mode B — Import (From Existing Brand Guidelines PDF)

### Step 1: Get PDF Path

Ask user for the path to their brand guidelines PDF.

### Step 2: Extract Brand Values

Invoke `pdf-analyzer` to extract document content. Then parse for:

**Colors:**
- Search for hex values (#RRGGBB patterns)
- Search for RGB values (rgb(R, G, B) patterns) → convert to hex
- Search for CMYK values → convert to hex (approximate)
- Search for Pantone references → map to closest hex (note: approximate)
- Identify which colors are primary, secondary, accent based on context ("primary", "main", "brand color", etc.)

**Typography:**
- Search for font family names (e.g., "Heading: Helvetica Neue", "Body copy: Arial")
- Search for weight specifications (Bold, Regular, Light, 400, 700)
- Search for size specifications

**Layout:**
- Search for margin/spacing specifications
- Search for logo usage rules (clear space, minimum size, placement)

### Step 3: Map to Schema

Map extracted values to brand-kit.yaml fields:

| Extracted | Maps To | Confidence |
|-----------|---------|------------|
| "#1B3A5C" labeled "Primary" | `colors.primary` | ✅ High |
| "Helvetica Neue Bold" for headings | `typography.heading.family` + weights | ✅ High |
| RGB(27, 58, 92) | `colors.primary` (converted) | ✅ High |
| Pantone 289 C | `colors.primary` (approximate) | ⚠️ Medium |
| "Body text should be 11pt" | `typography.scale.base` | ⚠️ Medium |
| No margin specs found | `document.margins` | ❌ Missing → use default |

### Step 4: Present Extracted Kit

Show the user the extracted values with confidence indicators:

```
Extracted Brand Kit
───────────────────
✅ colors.primary:     #1B3A5C (from "Primary Brand Color" p.4)
✅ colors.secondary:   #2E86AB (from "Secondary Palette" p.5)
⚠️ colors.accent:      #F18F01 (inferred from highlight usage p.7)
❌ colors.neutral:     Using default scale (not found in PDF)

✅ typography.heading:  Helvetica Neue, weights [400, 700] (from "Typography" p.8)
✅ typography.body:     Arial, weights [400] (from "Body Copy" p.8)
❌ typography.mono:     Using default JetBrains Mono (not found)

❌ document.margins:   Using default 2.5cm (not found)
⚠️ document.header:    Logo left (inferred from header examples p.12)
```

### Step 5: User Review and Correction

Ask user to review and correct:
- ✅ items: "These look correct?"
- ⚠️ items: "These were inferred — please confirm or correct"
- ❌ items: "These weren't found — want to specify or keep defaults?"

### Step 6: Generate brand-kit.yaml

Same as Discovery Mode Step 5.

---

## Error Handling

| Scenario | Action |
|----------|--------|
| PDF has no extractable text (scanned image) | Report: "PDF appears to be image-only. Consider OCR first, or switch to Discovery mode." |
| Less than 50% of fields extracted | Report what was found. Suggest: "Limited extraction. Starting Discovery mode with extracted values as a base." |
| Font not available on Google Fonts | Suggest closest Google Fonts alternative. Note: "Original font may need to be licensed separately." |
| Color values conflict (same color labeled differently) | Present all found values, ask user to resolve |

---

## Output

- `.brand/brand-kit.yaml` (primary output)
- `.brand/assets/` — logo files if provided by user
- Console: validation report (schema compliance + WCAG contrast summary)

---

**Version:** 0.1.0
**Layer:** studio (never deployed)
**Dipendenze:** brand-kit (hard), color-palette (soft), font-pairing (soft), pdf-analyzer (soft)
