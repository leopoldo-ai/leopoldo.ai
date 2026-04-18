---
name: invoice-template
description: "Use when creating invoices in .docx format with company branding, line items, tax calculations, and payment terms. Reads brand-kit.yaml for consistent styling."
type: technique
version: 0.1.0
layer: userland
category: templates
triggers:
  - pattern: "invoice|fattura|billing document"
dependencies:
  hard: []
  soft:
    - brand-kit
    - docx-reports
metadata:
  author: lucadealbertis
  source: custom
  domain: design
  triggers: invoice,fattura,billing,payment
  role: specialist
  scope: generation
  output-format: docx
  related-skills: brand-kit,quote-template,docx-reports
license: proprietary
---

# Invoice Template — Professional Branded Invoices

Generate professional invoices in .docx format with brand-kit styling. Handles line items, tax calculations, payment terms, and multi-currency support.

## When to Use

- Creating invoices for clients
- Generating recurring invoice series
- Producing pro-forma invoices

## When NOT to Use

- Financial analysis or accounting (use `financial-modeling`)
- Quotes or estimates (use `quote-template`)
- General Word documents (use `docx-reports`)

---

## Brand Integration

1. Read `brand-kit.yaml` via brand-kit discovery protocol (project root → .brand/ → defaults)
2. Apply: logo in header, primary color for header line and table headers, brand fonts, margins from document settings
3. Fallback: Calibri 11pt, #2563eb blue headers, 2.5cm margins (docx-reports defaults)

---

## Invoice Structure

### Header
- **Left:** Company logo (from brand-kit `brand.logo.primary`)
- **Right:** Company details — name, address, VAT/tax ID, phone, email, website

### Invoice Metadata
| Field | Format |
|-------|--------|
| Invoice Number | INV-YYYY-NNNN (auto-incrementing suggested) |
| Invoice Date | DD/MM/YYYY or locale-appropriate |
| Due Date | Calculated from payment terms |
| Payment Terms | Net 30 / Net 60 / Due on receipt / Custom |
| Currency | EUR / USD / GBP / CHF (symbol + ISO code) |

### Client Section
- Client company name (bold)
- Client address
- Client VAT/tax ID
- Attention: contact person name
- Reference: PO number or project reference

### Line Items Table

| # | Description | Qty | Unit Price | VAT % | Amount |
|---|-------------|-----|-----------|-------|--------|
| 1 | Service description | 1 | 1,000.00 | 22% | 1,000.00 |

**Table styling:**
- Header row: brand primary color background, white text
- Alternating rows: neutral-100 / white
- Amounts: right-aligned, 2 decimal places
- Quantity: center-aligned

### Totals Section

```
                          Subtotal:    EUR 10,000.00
                          VAT 22%:     EUR  2,200.00
                          ─────────────────────────
                          TOTAL:       EUR 12,200.00
```

If multiple VAT rates, show breakdown per rate.

### Payment Information
- Bank name
- IBAN
- BIC/SWIFT
- Payment reference (invoice number)
- Payment terms reminder

### Footer
- Legal notices (company registration, VAT registration)
- Brand footer from brand-kit (page number, company name)

---

## Formatting Rules

- Header separator: 2pt line in brand primary color
- Section spacing: 12pt between sections
- Font: brand body font, 11pt (heading font for company name, 14pt)
- Page size: A4 (210x297mm)
- Margins: from brand-kit document settings

---

## Required Inputs

| Input | Required | Default |
|-------|----------|---------|
| Company details | Yes | From brand-kit or ask |
| Client details | Yes | — |
| Line items | Yes | — |
| Payment terms | No | Net 30 |
| Currency | No | EUR |
| Invoice number | No | Auto-suggest |
| Notes | No | — |

---

## Generation

Uses `document-skills:docx` skill or python-docx via Bash, following the same pattern as `docx-reports`.

**Output path:** `docs/invoices/invoice-{number}-{date}.docx`

---

**Version:** 0.1.0
**Dipendenze:** brand-kit (soft), docx-reports (soft)
**Trigger:** Skill-router quando si menziona fattura, invoice, billing
