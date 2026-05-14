---
name: investor-deck
description: "Use when building fund and family office investor communication presentations in .pptx format. 5 document variants: quarterly reports, LP meeting decks, capital call notices, annual letters, family office portfolio overviews."
type: technique
version: 0.1.0
layer: userland
category: templates
triggers:
  - pattern: "investor deck|quarterly report|LP report|investor letter|fund report|capital call|family office report|investor presentation"
dependencies:
  hard: []
  soft:
    - brand-kit
    - pptx
    - investor-letter
    - lp-reporting
    - nav-calculator
    - attribution-engine
    - portfolio-monitor
metadata:
  author: lucadealbertis
  source: custom
  domain: design
  triggers: investor,quarterly,fund,LP,capital,call,family,office,NAV,performance
  role: specialist
  scope: generation
  output-format: pptx
  related-skills: brand-kit,pitch-deck,pptx,investor-letter,lp-reporting,nav-calculator,attribution-engine,portfolio-monitor
license: proprietary
tier: essentials
status: ga
---

# Investor Deck — Fund & Family Office Communication Presentations

Generate investor-facing presentations in .pptx format for fund managers, family offices, and wealth managers. 5 document variants covering the full investor communication cycle.

## When to Use

- Quarterly/annual investor reporting
- LP meeting preparation
- Capital call/distribution notices
- Annual investor letters (slide companion)
- Family office portfolio reviews

## When NOT to Use

- Fundraising pitches (use `pitch-deck`)
- Written investor letters without slides (use `investor-letter`)
- Internal fund operations (use `fund-suite` skills directly)
- General presentations (use `pptx`)

---

## Brand Integration

Same protocol as all template skills:
1. Read brand-kit.yaml → apply fund/company branding
2. Primary color for section headers, secondary for charts, accent for key metrics
3. Logo on title slide + recurring position on all slides
4. Fallback to pptx defaults

---

## Document Variants

### A. Quarterly Fund Report (15-20 slides)

| Slide | Content |
|-------|---------|
| 1 | Cover: fund name, period (Q1-Q4 YYYY), disclaimer |
| 2 | Disclaimer / legal notices (full page) |
| 3 | Executive summary: key metrics table (NAV, return, benchmark delta) |
| 4-5 | Market commentary: macro environment, sector trends |
| 6-7 | Fund performance vs benchmark: line chart + table |
| 8 | Attribution analysis: sector/geography/factor contribution bar chart |
| 9 | Portfolio composition: sector allocation pie + top 10 holdings table |
| 10 | Geographic allocation: world map or regional bar chart |
| 11 | Risk metrics: volatility, Sharpe, max drawdown, VaR |
| 12 | Investment activity: new positions, exits, changes |
| 13 | Outlook: market view, portfolio positioning |
| 14-15 | Appendix: detailed holdings, methodology notes |

### B. LP Meeting Deck (10-12 slides)

| Slide | Content |
|-------|---------|
| 1 | Cover + meeting agenda |
| 2 | Fund overview: strategy, AUM, vintage, fund life |
| 3-4 | Performance update: IRR, MOIC, DPI, RVPI charts |
| 5-6 | Investment activity: new deals, follow-ons, exits |
| 7 | Pipeline: opportunities under review |
| 8 | Portfolio summary: companies, sectors, stages |
| 9 | Operational update: team changes, regulatory, admin |
| 10 | Fundraising update (if applicable) |
| 11 | Q&A slide |

### C. Capital Call / Distribution Notice (3-5 slides)

| Slide | Content |
|-------|---------|
| 1 | Notice type (Capital Call / Distribution), date, fund name |
| 2 | Details: total amount, per-LP breakdown (table), due date, wire instructions |
| 3 | Fund status: total committed, called to date, remaining commitment |
| 4 | Purpose (capital call: investment name; distribution: exit details) |

### D. Annual Investor Letter (Slide Companion, 8-10 slides)

| Slide | Content |
|-------|---------|
| 1 | Cover: year in review, fund name |
| 2-3 | Year highlights: key metrics, achievements |
| 4-5 | Performance: annual vs inception, vs benchmark |
| 6 | Portfolio milestones: exits, notable events |
| 7 | Strategic outlook: market thesis, positioning for next year |
| 8 | Team: updates, new hires, recognitions |
| 9 | Thank you + contact |

### E. Family Office Portfolio Overview (8-10 slides)

| Slide | Content |
|-------|---------|
| 1 | Cover: family office name, report date |
| 2 | Total AUM summary: single number, YoY change |
| 3 | Asset allocation: pie chart (equities, fixed income, alternatives, real estate, cash) |
| 4-5 | Performance by asset class: table + bar chart |
| 6 | Liquidity profile: stacked bar (liquid, semi-liquid, illiquid) |
| 7 | Income/cashflow: dividend, coupon, rental income summary |
| 8 | Upcoming events: maturities, fund commitments, distributions expected |
| 9 | Recommendations: rebalancing suggestions, new opportunities |

---

## Data Integration

This skill provides **structure and presentation**. Data comes from:
- `nav-calculator` — NAV and performance figures
- `attribution-engine` — performance attribution
- `lp-reporting` — LP-specific data
- `portfolio-monitor` — portfolio composition
- `investor-letter` — narrative content for letter variant

When these skills are available, reference them. When not, ask the user to provide the data directly.

---

## Design Rules

1. **Disclaimer slide is mandatory** for fund reports (regulatory requirement)
2. **Charts over tables** where possible — investors scan visually
3. **Consistent color coding** across all charts in a deck (same sector = same color)
4. **Key metrics in large font** — NAV, return, Sharpe should be immediately visible
5. **Benchmark always shown** alongside fund performance (side-by-side)
6. **Confidential footer** on every slide

---

## Generation

Uses `pptx` skill's html2pptx workflow with brand-kit styling.

**Output path:** `docs/investor/investor-deck-{variant}-{period}-{date}.pptx`
Example: `docs/investor/investor-deck-quarterly-Q4-2025-2026-01-15.pptx`

---

**Version:** 0.1.0
**Dipendenze:** brand-kit (soft), pptx (soft), investor-letter (soft)
**Trigger:** Skill-router quando si menziona investor deck, quarterly report, LP meeting, capital call, family office
