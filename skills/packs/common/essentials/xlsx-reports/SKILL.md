---
name: xlsx-reports
description: Create professional reports and deliverables in Excel (.xlsx) format. Use when generating spreadsheets with RICE scoring, roadmaps, KPI dashboards, tabular comparisons, or any structured output for stakeholders in Excel format.
user-invocable: true
---

# Excel Reports

Skill for generating professional deliverables in .xlsx format.

## When to Use Excel vs Other Formats

| Scenario | Format |
|----------|--------|
| RICE scoring with dynamic calculations | **xlsx** |
| KPI dashboard with periodic updates | **xlsx** |
| Roadmap with timeline and dependencies | **xlsx** |
| Tool/vendor comparison with weights | **xlsx** |
| Narrative report for leadership | docx |
| Board presentation | pptx |
| Process documentation (wiki-style) | md |

## Available Excel Templates

### 1. RICE Prioritization Matrix
Sheet with:
- Columns: Initiative, Area, Phase, Reach, Impact, Confidence, Effort, RICE Score (formula), Priority
- Conditional formatting: green (>50), yellow (20-50), red (<20)
- Horizontal bar chart for RICE score
- Active filters for Area and Priority

### 2. KPI Dashboard
Sheet with:
- KPIs by area (Revenue, Operations, Clients, People)
- Columns: KPI, Target, Actual, Variance, Trend (sparkline)
- Monthly view with 12-month history
- Visual summary with traffic lights

### 3. Project Tracker
Sheet with:
- All planned phases/sessions
- Columns: Phase, Area, Status, Owner, Start, End, % Complete, Notes, Dependencies
- Simplified Gantt chart
- Filtered view by phase

### 4. Comparison Matrix
Sheet with:
- Side-by-side tool/vendor/option comparison
- Criteria: Status, Features, Integration, Cost, Gaps, Required Action
- Feature completeness matrix

### 5. Team Allocation Matrix
Sheet with:
- People per row, Activities per column
- RACI for each process (Responsible, Accountable, Consulted, Informed)
- Estimated workload

## Formatting Style

- **Font:** Calibri 11pt (body), 14pt bold (headings)
- **Header colors:** #2563eb (blue) with white text
- **Row alternation:** #f7fafc / white
- **Borders:** thin light gray
- **Footer:** generation date + "Confidential"

## Generation Instructions

When generating an .xlsx file:
1. Use the built-in `document-skills:xlsx` skill for technical file creation
2. Apply the appropriate template from the list above
3. Populate with project data when available
4. Add formulas for dynamic calculations (RICE, % variations, totals)
5. Apply conditional formatting where relevant
6. Include a "Legend" sheet with conventions used
7. Save in `docs/` with descriptive naming
