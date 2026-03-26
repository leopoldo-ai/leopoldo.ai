---
name: design-foundations
version: 0.1.0
description: "Design Foundations — brand identity, color theory, typography, and document templates. Single source of truth for brand consistency across all output skills."
author: lucadealbertis
license: proprietary
skillos_min_version: "0.3.0"
skills:
  - brand-kit
  - color-palette
  - font-pairing
  - invoice-template
  - quote-template
  - pitch-deck
  - investor-deck
  - business-report
  - one-pager
dependencies:
  packs: ["essentials"]
tags: ["brand", "identity", "templates", "color", "typography", "design"]
---

# Design Foundations — Brand Identity & Document Templates

Pack per la gestione dell'identita' visiva e dei template documentali. 9 skill che definiscono brand kit, palette colori, tipografia e template per documenti professionali (fatture, preventivi, pitch deck, investor deck, report, one-pager).

## Target

- Qualsiasi professionista che produce documenti branded
- Complemento a `essentials` (che fornisce i motori docx/pptx/xlsx)
- Fondazione per i pack verticali (investment-core, advisory-desk, etc.)

## Skill incluse

### Brand Identity (3 skills)

| Skill | Scopo | Priorita' |
|-------|-------|-----------|
| `brand-kit` | Schema YAML per brand identity, validazione, 2 preset (corporate-finance, tech-startup) | P0 |
| `color-palette` | Generazione palette da colore primario, WCAG AA/AAA, dark mode, semantici | P0 |
| `font-pairing` | 12 abbinamenti curati, regole di pairing, modular scale, validazione leggibilita' | P0 |

### Document Templates (6 skills)

| Skill | Scopo | Priorita' |
|-------|-------|-----------|
| `invoice-template` | Fatture professionali branded (.docx) via pattern docx-reports | P0 |
| `quote-template` | Preventivi professionali branded (.docx) via pattern docx-reports | P0 |
| `pitch-deck` | Pitch deck per startup/aziende (.pptx) via pattern pptx html2pptx | P1 |
| `investor-deck` | Report investitori, quarterly letter, NAV chart (.pptx) via pattern pptx | P1 |
| `business-report` | Report multi-sezione con TOC, header/footer branded (.docx) | P1 |
| `one-pager` | One-pager marketing/sales (.docx) — singola pagina, brand-critical | P1 |
