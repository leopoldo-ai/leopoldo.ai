---
name: quote-template
description: "Generate professional branded quotes and estimates in .docx format. Use when creating price quotes, proposals, or estimates with company branding, pricing tiers, terms and conditions."
version: 0.1.0
layer: userland
category: templates
triggers:
  - pattern: "quote|preventivo|estimate|proposal|offerta|price quote"
dependencies:
  hard: []
  soft:
    - brand-kit
    - docx-reports
metadata:
  author: lucadealbertis
  source: custom
  domain: design
  triggers: quote,preventivo,estimate,proposal,offerta,pricing
  role: specialist
  scope: generation
  output-format: docx
  related-skills: brand-kit,invoice-template,docx-reports,client-proposal-builder
license: proprietary
---

# Quote Template — Professional Branded Quotes & Estimates

Generate professional quotes, estimates, and pricing proposals in .docx format with brand-kit styling. Supports single pricing, tiered pricing, and optional/conditional line items.

## When to Use

- Creating price quotes for prospects or clients
- Generating estimates with optional items
- Producing formal proposals with pricing (for pricing section — use `client-proposal-builder` for full proposals)

## When NOT to Use

- Full consulting proposals with methodology (use `client-proposal-builder`)
- Invoicing after acceptance (use `invoice-template`)
- General Word documents (use `docx-reports`)

---

## Brand Integration

Same protocol as `invoice-template`:
1. Read brand-kit.yaml → apply logo, colors, fonts, margins
2. Fallback to docx-reports defaults

---

## Quote Structure

### Header
- Logo (left) + Company details (right) — same as invoice-template

### Quote Metadata

| Field | Format |
|-------|--------|
| Quote Number | QUO-YYYY-NNNN |
| Date | DD/MM/YYYY |
| Valid Until | Date (default: 30 days from issue) |
| Prepared By | Name + role + contact |
| Currency | EUR / USD / GBP / CHF |

### Client Section
- Client company name, address, contact person

### Executive Summary (Optional)
2-3 sentences describing the scope of work. Only include if user provides context.

### Line Items Table

| # | Description | Qty | Unit Price | Discount | Amount |
|---|-------------|-----|-----------|----------|--------|
| 1 | Core service | 1 | 5,000.00 | — | 5,000.00 |
| 2 | Optional add-on | 1 | 1,500.00 | 10% | 1,350.00 |

**Optional items:** Mark with "(Optional)" in description. Show subtotal with and without optionals.

### Pricing Tiers (Optional)

When the user wants to present multiple options:

| Feature | Basic | Standard | Premium |
|---------|-------|----------|---------|
| Core service | ✅ | ✅ | ✅ |
| Support | Email | Email + Phone | Dedicated |
| SLA | — | 24h | 4h |
| **Price** | **EUR 3,000** | **EUR 5,000** | **EUR 8,000** |

Highlight recommended tier with brand accent color.

### Totals

```
                          Subtotal:      EUR 6,350.00
                          Discount (10%): -EUR  150.00
                          VAT 22%:       EUR 1,364.00
                          ─────────────────────────────
                          TOTAL:         EUR 7,564.00
```

### Terms & Conditions
- Payment terms (default: 50% upfront, 50% on delivery)
- Delivery timeline
- Validity period
- Scope limitations / exclusions

### Acceptance Block
```
By signing below, the Client accepts this quote and authorizes
the commencement of work under the terms stated above.

Signature: ____________________    Date: ____________________

Name: ________________________    Role: ____________________
```

### Footer
- Legal notices, company registration
- Brand footer (page number, company name)

---

## Formatting Rules

Same as invoice-template: brand colors for headers, alternating row shading, right-aligned amounts, A4, brand margins.

**Recommended tier highlight:** Brand accent color background with white text on the recommended pricing column.

---

## Required Inputs

| Input | Required | Default |
|-------|----------|---------|
| Company details | Yes | From brand-kit or ask |
| Client details | Yes | — |
| Line items / pricing | Yes | — |
| Validity period | No | 30 days |
| Payment terms | No | 50/50 |

---

## Generation

Uses `document-skills:docx` or python-docx via Bash, following `docx-reports` pattern.

**Output path:** `docs/quotes/quote-{number}-{date}.docx`

---

**Version:** 0.1.0
**Dipendenze:** brand-kit (soft), docx-reports (soft)
**Trigger:** Skill-router quando si menziona preventivo, quote, estimate, offerta
