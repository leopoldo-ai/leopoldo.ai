---
name: pitch-deck
description: "Use when creating investor-ready pitch decks in .pptx format for fundraising, partnerships, or business development. 12-slide framework with brand-kit styling."
type: technique
version: 0.1.0
layer: userland
category: templates
triggers:
  - pattern: "pitch deck|pitch presentation|startup deck|investor pitch|fundraising deck"
dependencies:
  hard: []
  soft:
    - brand-kit
    - pptx
metadata:
  author: lucadealbertis
  source: custom
  domain: design
  triggers: pitch,deck,fundraising,startup,investor,presentation
  role: specialist
  scope: generation
  output-format: pptx
  related-skills: brand-kit,investor-deck,pptx,client-proposal-builder
license: proprietary
---

# Pitch Deck — Investor-Ready Branded Presentations

Generate compelling pitch decks in .pptx format using the `pptx` skill's html2pptx workflow with brand-kit styling. Follows a proven 12-slide framework optimized for investor audiences.

## When to Use

- Fundraising pitch (seed, Series A-C, PE)
- Partnership proposals
- Business development presentations
- Competition/accelerator pitches

## When NOT to Use

- Quarterly investor reports (use `investor-deck`)
- Internal presentations (use `pptx` directly)
- Full consulting proposals (use `client-proposal-builder`)

---

## Brand Integration

1. Read brand-kit.yaml → set slide background, accent colors, heading/body fonts, logo placement
2. Primary color: slide titles, key metrics, section headers
3. Accent color: CTAs, highlight boxes, key numbers
4. Logo: title slide + small logo on subsequent slides (top-right or bottom-left per brand-kit header.logo_position)
5. Fallback: pptx skill's default color selection based on content analysis

---

## 12-Slide Framework

### Slide 1: Title
- Company name (large, brand heading font)
- Tagline or one-line value proposition
- Logo (centered or per brand-kit)
- Presenter name + date

### Slide 2: Problem
- Clear problem statement (1-2 sentences, large text)
- Supporting data point or statistic
- Optional: visual/icon representing the pain point
- **Rule:** Make the audience feel the pain

### Slide 3: Solution
- How your product/service solves the problem
- 3 key differentiators (max)
- Optional: product screenshot or diagram
- **Rule:** Simple, clear, memorable

### Slide 4: Market Opportunity
- TAM / SAM / SOM with concentric circles or stacked bars
- Market size in currency (EUR/USD)
- Growth rate (CAGR)
- Source citation for market data

### Slide 5: Product / Service
- Product overview with visual (screenshot, diagram, or mockup)
- Key features (max 4-5)
- "How it works" in 3 steps if applicable

### Slide 6: Business Model
- Revenue model (subscription, transaction, licensing, etc.)
- Pricing tiers if applicable
- Unit economics: CAC, LTV, LTV/CAC ratio
- Path to profitability

### Slide 7: Traction / Metrics
- Key metrics dashboard (MRR, users, growth rate, retention)
- Growth chart (hockey stick preferred)
- Key milestones achieved
- **Rule:** Numbers speak louder than words

### Slide 8: Competitive Landscape
- 2x2 matrix positioning (e.g., ease of use vs. functionality)
- Key competitors listed
- Your differentiation highlighted (brand accent color)
- **Rule:** Don't trash competitors — show your unique position

### Slide 9: Team
- Founders + key team (photo, name, role, relevant credential)
- Advisory board if notable
- **Rule:** 4-6 people max. Show relevant domain expertise.

### Slide 10: Financial Projections
- 3-5 year revenue projections (bar or line chart)
- Key assumptions listed
- Break-even timeline
- **Rule:** Conservative base case. Optimistic upside optional.

### Slide 11: The Ask
- Funding amount (large, bold, brand accent)
- Use of funds breakdown (pie chart or stacked bar)
- Expected milestones with the funding
- Timeline to next round

### Slide 12: Thank You / Contact
- "Thank you" or company tagline
- Contact information (email, phone, website)
- Logo
- QR code to website (optional)

---

## Design Rules

1. **One message per slide** — if you need two messages, you need two slides
2. **Max 6 bullet points, max 8 words each** — audiences read slides, not documents
3. **Data over text** — charts, metrics, visuals wherever possible
4. **Consistent layout** — same title position, same margin, same font sizes across all slides
5. **White space** — don't fill every corner. Let content breathe.
6. **Brand primary for key numbers** — revenue, growth rate, ask amount in brand primary or accent

---

## Generation

Uses `pptx` skill's html2pptx workflow:
1. Generate HTML slides with brand-kit CSS (colors, fonts)
2. Convert to .pptx via html2pptx
3. Apply brand theme colors

**Output path:** `docs/presentations/pitch-deck-{date}.pptx`

---

**Version:** 0.1.0
**Dipendenze:** brand-kit (soft), pptx (soft)
**Trigger:** Skill-router quando si menziona pitch deck, presentazione investitori, fundraising
