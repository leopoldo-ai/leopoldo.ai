---
name: color-palette
description: "Use when creating brand colors from a primary color, validating contrast ratios, generating semantic/dark mode palettes, or auditing existing color schemes for WCAG 2.1 AA/AAA compliance."
type: technique
version: 0.1.0
layer: userland
category: design
triggers:
  - pattern: "color palette|color scheme|contrast ratio|wcag|dark mode palette|color theory|color harmony"
dependencies:
  hard: []
  soft:
    - brand-kit
    - accessibility
metadata:
  author: lucadealbertis
  source: custom
  domain: design
  triggers: color,palette,contrast,wcag,dark,mode,scheme,harmony,accessibility
  role: specialist
  scope: generation
  output-format: yaml
  related-skills: brand-kit,font-pairing,accessibility
license: proprietary
tier: essentials
status: ga
---

# Color Palette — Theory-Driven, Accessibility-First Color Generation

Generate, validate, and optimize color palettes with WCAG compliance as a hard requirement. Every color combination produced by this skill passes AA contrast minimum.

## Role Definition

You are a color theory specialist with deep expertise in perceptual color science, WCAG accessibility standards, and brand identity systems. You understand that color is not aesthetic preference — it is a functional system that must work for all users, including those with color vision deficiencies.

## When to Use This Skill

- Generating a full color palette from a single primary color
- Validating contrast ratios for existing palettes
- Creating dark mode variants
- Generating semantic colors (success/warning/error/info) harmonized with a brand
- Auditing accessibility of an existing color scheme

## When NOT to Use

- If you just need to look up existing brand colors (use `brand-kit`)
- For font selection (use `font-pairing`)
- For full brand identity setup (use `brand-kit-builder`)

---

## Palette Generation Methods

Given a single primary hex color, generate a full palette using one of these harmonies:

### 1. Complementary (2 colors)
Opposite on the color wheel. Maximum contrast. Use for primary + accent.

### 2. Analogous (3-5 colors)
Adjacent on the wheel (30deg apart). Harmonious, low contrast. Use for gradient-like palettes.

### 3. Triadic (3 colors)
120deg apart. Vibrant, balanced. Use for multi-brand or complex UIs.

### 4. Split-Complementary (3 colors)
Primary + two colors adjacent to its complement. Less tension than complementary, more variety.

### Generation Process

1. Convert input hex to HSL
2. Apply harmony formula to get hue(s)
3. Adjust saturation/lightness for each role:
   - Primary: as-is
   - Secondary: shift hue per harmony, reduce saturation 10-20%
   - Accent: highest saturation, contrasting hue
4. Generate neutral scale (see below)
5. Generate semantic colors (see below)
6. Validate ALL combinations for WCAG contrast
7. Output updated `brand-kit.yaml` colors section

---

## Neutral Scale Generation

From any base gray, generate a perceptually uniform 10-step scale:

```
Step:  50    100   200   300   400   500   600   700   800   900
L*:    97    95    90    82    65    46    37    30    20    13
```

Where L* is CIELAB lightness. Steps should feel evenly spaced to the human eye (not mathematically even in hex).

**Process:**
1. Input: any gray hex (or auto-derive from primary at 5% saturation)
2. Keep hue and minimal saturation constant
3. Vary lightness along the L* curve above
4. Output: 10 hex values

---

## Semantic Color Generation

Generate status colors harmonized with the brand primary:

| Semantic | Hue Range | Default | Rule |
|----------|-----------|---------|------|
| Success | 120-150 (green) | #16A34A | Must contrast with white (AA) |
| Warning | 40-55 (yellow/amber) | #EAB308 | Must contrast with neutral-900 (AA) |
| Error | 0-10 (red) | #DC2626 | Must contrast with white (AA) |
| Info | 200-230 (blue) | #2563EB | Must contrast with white (AA) |

Adjust saturation to match brand palette "feel" (corporate = lower saturation, startup = higher).

---

## Dark Mode Derivation

Generate dark mode palette from light mode:

| Light Mode | Dark Mode Rule |
|-----------|---------------|
| `primary` | Lighten 15-20% (increase L*) |
| `secondary` | Lighten 10-15% |
| `neutral.50` (background) | → `neutral.900` |
| `neutral.900` (text) | → `neutral.50` |
| Neutral scale | Reverse order |
| Semantic colors | Lighten 10% for dark backgrounds |

**Constraint:** All text/background combinations must still pass WCAG AA after inversion.

---

## WCAG Contrast Validation

### Formulas

**Relative Luminance:**
```
L = 0.2126 * R + 0.7152 * G + 0.0722 * B
where R, G, B are linearized (sRGB → linear):
  if C <= 0.04045: C / 12.92
  else: ((C + 0.055) / 1.055) ^ 2.4
```

**Contrast Ratio:**
```
ratio = (L_lighter + 0.05) / (L_darker + 0.05)
```

### Thresholds

| Level | Normal Text (<18pt) | Large Text (>=18pt or >=14pt bold) |
|-------|--------------------|------------------------------------|
| AA | 4.5:1 | 3:1 |
| AAA | 7:1 | 4.5:1 |

### Contrast Matrix Output

Test every foreground against every background:

```
             bg:white  bg:50   bg:100  bg:primary  bg:900
text:primary  ✅ 8.2    ✅ 7.9   ✅ 7.1   —           ✅ 4.8
text:900      ✅ 18.1   ✅ 17.4  ✅ 15.8  ✅ 12.3      —
text:white    —         ❌ 1.1   ❌ 1.3   ✅ 8.2       ✅ 18.1
```

Report FAIL combinations with suggested alternative (lighter/darker) that would pass.

---

## Error Handling

| Scenario | Behavior |
|----------|----------|
| Invalid hex input | Report error: "'{value}' is not a valid hex color. Expected #RGB or #RRGGBB" |
| Contrast failure | Report failing pair + suggest adjustment: "primary on neutral-100 fails AA (3.8:1). Darken primary to #15304D for 4.5:1" |
| Impossible contrast | If no adjustment preserves brand feel: "Cannot achieve AA contrast between {color1} and {color2} without significant hue shift. Consider different background." |

---

**Version:** 0.1.0
**Dipendenze:** brand-kit (soft)
**Trigger:** Skill-router quando si menziona colori, palette, contrasto, WCAG, dark mode
