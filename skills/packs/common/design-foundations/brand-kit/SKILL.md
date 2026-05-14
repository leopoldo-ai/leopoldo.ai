---
name: brand-kit
description: "Use when setting up brand identity or when any skill needs brand context. Single source of truth that defines and validates brand-kit.yaml schema (colors, typography, spacing, document settings) with 2 presets: corporate-finance and tech-startup."
type: technique
version: 0.1.0
layer: userland
category: design
triggers:
  - pattern: "brand kit|brand identity|brand colors|brand fonts|brand setup"
dependencies:
  hard: []
  soft:
    - color-palette
    - font-pairing
    - docx-reports
    - pptx
    - xlsx-reports
    - internal-comms
    - brand-to-ui
metadata:
  author: lucadealbertis
  source: custom
  domain: design
  triggers: brand,identity,kit,colors,fonts,palette,typography
  role: foundation
  scope: configuration
  output-format: yaml
  related-skills: color-palette,font-pairing,docx-reports,pptx,xlsx-reports,internal-comms,brand-to-ui
license: proprietary
tier: essentials
status: ga
---

# Brand Kit — Single Source of Truth for Brand Identity

Defines, validates, and provides brand identity values to all SkillOS output skills. Every document (docx, pptx, xlsx) and UI component should read from `brand-kit.yaml` for consistent branding.

## Role Definition

You are a brand identity architect with 15+ years of experience in corporate identity systems. You ensure visual consistency across all touchpoints — documents, presentations, web interfaces, and internal communications. You understand that brand identity is not decoration but a system of constraints that creates recognition and trust.

## When to Use This Skill

- Setting up brand identity for a new client project
- Any skill needs to read brand colors, fonts, or document settings
- Validating an existing brand-kit.yaml
- Choosing between presets for a quick start

## When NOT to Use

- Creating a brand kit from scratch interactively (use `brand-kit-builder` in studio)
- Deep color theory work (use `color-palette`)
- Font selection and pairing (use `font-pairing`)

---

## Schema Definition

The `brand-kit.yaml` file is the canonical brand identity source. All fields are documented below.

```yaml
# brand-kit.yaml — Brand Identity Schema v1.0

version: "1.0"

brand:
  name: "Company Name"              # REQUIRED — company or project name
  tagline: "Optional tagline"       # Optional — displayed in headers/footers
  logo:
    primary: "./assets/logo.svg"    # Path relative to project root
    monochrome: "./assets/logo-mono.svg"  # Optional — for single-color contexts
    favicon: "./assets/favicon.ico"       # Optional — web only

colors:
  primary: "#1B3A5C"               # REQUIRED — main brand color
  secondary: "#2E86AB"             # REQUIRED — complementary accent
  accent: "#F18F01"                # Optional — highlight/CTA color
  neutral:                         # REQUIRED — grayscale for backgrounds/text
    50: "#FAFAFA"
    100: "#F5F5F5"
    200: "#E5E5E5"
    300: "#D4D4D4"
    400: "#A3A3A3"
    500: "#737373"
    600: "#525252"
    700: "#404040"
    800: "#262626"
    900: "#171717"
  semantic:                        # Optional — status colors
    success: "#16A34A"
    warning: "#EAB308"
    error: "#DC2626"
    info: "#2563EB"

typography:
  heading:
    family: "Inter"                # REQUIRED — heading font family
    weights: [600, 700]            # Font weights to use
  body:
    family: "Inter"                # REQUIRED — body font family
    weights: [400, 500]
  mono:
    family: "JetBrains Mono"       # Optional — code/data font
    weights: [400, 500]
  scale:
    base: 16                       # Base font size in px
    ratio: 1.25                    # Modular scale ratio (major third)

spacing:
  unit: 4                          # Base unit in px
  scale: [0, 1, 2, 3, 4, 5, 6, 8, 10, 12, 16, 20, 24]  # Multipliers

document:
  margins:
    top: "2.5cm"
    bottom: "2.5cm"
    left: "2.5cm"
    right: "2.5cm"
  header:
    logo_position: "left"          # left | center | right
    show_tagline: false
  footer:
    show_page_numbers: true
    show_company_name: true
```

---

## Schema Validation Rules

When validating `brand-kit.yaml`, enforce these rules:

| Field | Rule | Error Message |
|-------|------|---------------|
| `colors.primary` | Valid hex: `#RRGGBB` or `#RGB` | `colors.primary: invalid hex value '{value}'` |
| `colors.secondary` | Valid hex | Same pattern |
| `colors.neutral.*` | Valid hex for each shade | `colors.neutral.{shade}: invalid hex '{value}'` |
| `typography.heading.family` | Non-empty string | `typography.heading.family: required` |
| `typography.*.weights` | Array of integers 100-900 | `typography.{section}.weights: invalid weight '{value}', must be 100-900` |
| `spacing.unit` | Positive integer | `spacing.unit: must be positive integer` |
| `document.margins.*` | Valid CSS length (cm, mm, in, px) | `document.margins.{side}: invalid length '{value}'` |
| `document.header.logo_position` | One of: left, center, right | `document.header.logo_position: must be left, center, or right` |

Report ALL validation errors at once (don't stop at first error). Include the field path for each error.

---

## Discovery Protocol

When any skill needs brand values, follow this lookup order:

1. Check `./brand-kit.yaml` (project root)
2. Check `./.brand/brand-kit.yaml`
3. If neither exists → use **default fallback values** (see below)
4. If found → validate schema → report errors if invalid

**Never fail silently.** If brand-kit.yaml is found but invalid, report validation errors and refuse to proceed with partial data. If not found, use defaults and log a suggestion:

> "No brand-kit.yaml found. Using default styling. To set up brand identity, run `brand-kit-builder` or copy a preset from `references/presets.md`."

---

## Default Fallback Values

When no brand-kit.yaml exists, all output skills use these defaults (compatible with existing `docx-reports` and `pptx` styling):

| Property | Default Value | Matches |
|----------|--------------|---------|
| Heading font | Calibri 16pt bold | docx-reports H1 |
| Body font | Calibri 11pt | docx-reports body |
| Primary color | #2563eb (blue) | docx-reports heading color |
| Secondary color | #4a5568 (gray) | docx-reports sub-heading |
| Margins | 2.5cm all sides | docx-reports default |
| Line spacing | 1.15 | docx-reports default |
| Footer | "Confidential — Page X of Y" | docx-reports default |

---

## Presets

Two built-in presets for quick start. See `references/presets.md` for complete YAML.

| Preset | Primary | Secondary | Heading Font | Body Font | Scale Ratio | Style |
|--------|---------|-----------|-------------|-----------|-------------|-------|
| `corporate-finance` | #1B3A5C (navy) | #2E86AB (teal) | Inter | Inter | 1.25 (major third) | Conservative, institutional |
| `tech-startup` | #6366F1 (indigo) | #06B6D4 (cyan) | Plus Jakarta Sans | Inter | 1.333 (perfect fourth) | Modern, energetic |

### Using a Preset

1. Copy the desired preset YAML from `references/presets.md`
2. Save as `brand-kit.yaml` at project root (or `.brand/brand-kit.yaml`)
3. Replace `{{COMPANY_NAME}}` with the actual company name
4. Customize colors/fonts as needed
5. Validate: all downstream skills will auto-detect and use the brand kit

---

## Integration with Other Skills

| Skill | How it reads brand-kit |
|-------|----------------------|
| `docx-reports` | Colors for headings, font family/size, margins, header/footer |
| `pptx` | Theme colors, font scheme, logo placement |
| `xlsx-reports` | Header colors, font, cell styling |
| `internal-comms` | Tone colors, header branding |
| `brand-to-ui` | Full pipeline → Tailwind/CSS/React tokens |
| Template skills | All document templates inject brand values |

---

**Version:** 0.1.0
**Dipendenze:** None (foundation skill)
**Trigger:** Skill-router quando si menziona brand, identity, colori brand, font brand
