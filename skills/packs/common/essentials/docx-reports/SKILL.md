---
name: docx-reports
description: Use when building narrative documents in Word (.docx) format like executive summaries, board reports, phase reports, change management plans, or any deliverable for leadership.
type: technique
user-invocable: true
---

# Word Reports

Skill for generating professional deliverables in .docx format.

## Document Templates

### 1. Executive Summary (for board/stakeholder meetings)
Structure:
1. **Title + Date + Author**
2. **Executive summary** (max 5 lines)
3. **Progress status** (table with traffic lights per area/phase)
4. **Decisions required** (numbered, with options and recommendation)
5. **Next steps** (with owner and deadline)
6. **Attachments / references**

### 2. Phase Report (for each work phase)
Structure:
1. **Header:** Phase N — Title, Area, Date
2. **Phase objective**
3. **Step-by-step process** with table (Activity, Owner, Timing, Tool, Input, Output)
4. **Ready-to-use templates** (email, scorecard, checklist)
5. **Adoption checklist** (what to do from day 1)
6. **Success metrics** (leading + lagging, target 30/60/90)
7. **Technical dependencies** (with status icons ✅/🔄/🔮)
8. **Anticipated FAQ**

### 3. Change Management Brief
Structure:
1. **What changes and why**
2. **Who is impacted**
3. **Change timeline**
4. **Available support** (training, materials, contacts)
5. **FAQ**
6. **Feedback: how and to whom**

### 4. KPI Report (monthly)
Structure:
1. **Visual dashboard** (table with traffic lights)
2. **Analysis by area** (Revenue, Operations, Clients, People)
3. **Trends and comparisons** (vs previous month, vs target, vs LY)
4. **Corrective actions** (if KPI below target)
5. **Forecast** (next month outlook)

## Document Style

- **Font:** Calibri 11pt (body), 16pt bold (H1), 13pt bold (H2)
- **Line spacing:** 1.15
- **Margins:** 2.5 cm all sides
- **Header:** "[Document Title]"
- **Footer:** "Confidential — Page X of Y — [Date]"
- **Colors:** dark blue (#2563eb) for headings, gray (#4a5568) for sub-headings

## Generation Instructions

When generating a .docx file:
1. Use the built-in `document-skills:docx` skill for technical file creation
2. Select the appropriate template from the list above
3. Populate with content from project context
4. Maintain professional but accessible tone
5. Save in `docs/` with descriptive naming
