---
name: pdf-analyzer
version: 0.2.0
description: "Use when extracting data from prospectuses, annual reports, financial statements, or any PDF document for analysis."
type: technique
metadata:
  author: internal
  source: custom
  license: proprietary
  forge_strategy: build
  forge_sources: ["CFA Institute — Financial Reporting and Analysis (CFA Program Curriculum)", "IFRS Foundation — IFRS Standards and Annual Report Disclosure Requirements", "SEC — EDGAR Filing Standards and Prospectus Disclosure Requirements (Regulation S-K)", "Fridson & Alvarez — Financial Statement Analysis: A Practitioner's Guide (Wiley Finance, 5th ed.)"]
---

# PDF Analyzer

Data extraction from prospectuses, annual reports, financial statements, fund fact sheets.
Structured parsing of financial documents in PDF format.

## Why It Exists

| Problem | Solution |
|---------|----------|
| Financial data locked in non-editable PDFs | Structured extraction into tables/markdown |
| Manual reading of 200-page prospectuses | Targeted analysis focused on key sections |
| Comparison between PDF documents impossible | Extraction into comparable format |
| Key data points lost in the mass of text | Extraction template per document type |

## Core Workflow

### Phase 1 — Identify the Document Type

| Type | Key Sections | Output |
|------|-------------|--------|
| Annual report | P&L, BS, CF, notes, management discussion | Financial tables + key findings |
| Fund prospectus | Investment objective, strategy, fees, risks | Summary card with key parameters |
| Fund fact sheet | Performance, allocation, top holdings | Comparative table |
| Offering memorandum | Terms, structure, risks, projections | Extracted term sheet |
| Credit report | Rating, rationale, peers, outlook | Rating summary |

### Phase 2 — Data Extraction

1. **Locate sections**: document index, keyword search
2. **Extract tables**: identify and parse financial tables
3. **Extract key metrics**: KPIs, ratios, performance numbers
4. **Extract narrative text**: management commentary, risk factors
5. **Normalize**: consistent units, currency, number format

### Phase 3 — Output Structuring

1. **Summary card**: 1 page with key data from the document
2. **Extracted tables**: in markdown or xlsx format
3. **Key findings**: 5-10 main insights from the document
4. **Red flags**: identified items of concern
5. **Comparison**: if previous documents exist, highlight variations

### Phase 4 — Quality Check

1. **Number verification**: do totals add up? Do percentages sum to 100%?
2. **Cross-reference**: is data consistent across different sections?
3. **Completeness**: have all key sections been extracted?
4. **Source reference**: every extracted data point must indicate page and section

## Rules

1. **Source reference**: always indicate page and section of the original PDF
2. **Number verification**: check that totals add up after extraction
3. **Document type**: adapt the extraction template to the document type
4. **Do not interpret**: extract data as-is, interpretations are separate
5. **Confidentiality**: extracted documents maintain their original classification

## Anti-patterns

| Anti-pattern | Consequence | Correction |
|-------------|-------------|------------|
| Reading the entire PDF from top to bottom | Inefficient, time wasted on irrelevant sections | Go directly to key sections via index/keyword |
| Numbers extracted without source reference | Not verifiable, not auditable | Always indicate page and section of the original PDF |
| Mixing extraction and interpretation | Bias in extraction, distorted data | Two distinct phases: first extract, then analyze |
| Ignoring financial statement notes | Notes often contain the most important data | Always extract relevant notes along with the numbers |
| Not verifying number reconciliation | Extraction errors not detected | Cross-check totals and percentages after each extraction |

---

> **v0.1.0** | Domain skill | Pack: investment-core
