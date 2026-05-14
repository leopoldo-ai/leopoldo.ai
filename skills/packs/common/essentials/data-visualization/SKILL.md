---
name: data-visualization
description: Use when creating comparison tables, decision matrices, visual scorecards, graphic roadmaps, KPI dashboards, tabular outputs, or any visually structured output.
type: technique
tier: essentials
status: ga
---

# Data Visualization

Skill for creating structured outputs and data visualizations for any project context.

## Output Types

### 1. Comparison Tables
For comparing options, tools, processes:

```markdown
| Criterion | Option A | Option B | Option C |
|-----------|----------|----------|----------|
| Cost      | €X/mo    | €Y/mo    | €Z/mo    |
| Effort    | 🟢 Low   | 🟡 Medium| 🔴 High  |
| Impact    | ⭐⭐⭐   | ⭐⭐     | ⭐⭐⭐⭐ |
```

### 2. Decision Matrices
For prioritizing initiatives (Effort vs Impact):

```
              LOW EFFORT              HIGH EFFORT
HIGH     ┌─────────────────────┬─────────────────────┐
IMPACT   │   ⭐ QUICK WINS     │   🎯 STRATEGIC      │
         │                     │   PROJECTS           │
         ├─────────────────────┼─────────────────────┤
LOW      │   ✅ FILL-INS       │   ❌ AVOID           │
IMPACT   │                     │                      │
         └─────────────────────┴─────────────────────┘
```

### 3. Text-based Timelines & Gantt
For roadmaps and phase planning:

```
       Q1           Q2           Q3           Q4
       ├────PHASE 1──────────────┤
       │ Quick wins ▓▓▓          │
       │ Core setup    ▓▓▓▓▓▓▓  │
                                  ├──────PHASE 2──────────────┤
                                  │ Advanced features ▓▓▓▓▓▓  │
                                  │ Integrations       ▓▓▓▓▓▓ │
```

### 4. KPI Dashboards
For scorecards and performance monitoring:

```
┌─────────────────────────────────────────────────────────┐
│  📊 KPI DASHBOARD — Period XXXX                         │
├─────────────────┬─────────────────┬─────────────────────┤
│ 💰 REVENUE      │ 📋 OPERATIONS   │ 👥 PIPELINE        │
│ €XXX,XXX        │ XX active       │ XXX total           │
│ ▲ +XX% vs LY    │ XX% completion  │ XX in progress      │
├─────────────────┴─────────────────┴─────────────────────┤
│ ⏱️ EFFICIENCY                                           │
│ Avg completion: XX days  │  Throughput: X.X/week        │
│ Items processed: XXX     │  Response rate: XX%           │
├─────────────────────────────────────────────────────────┤
│ 🔄 PROCESS ADOPTION                                     │
│ Templates used: XX%      │  Tools adopted: XX%           │
│ Data updated: XX%        │  Structured notes: XX%        │
└─────────────────────────────────────────────────────────┘
```

### 5. Flowcharts / Process Diagrams (ASCII)
For process mapping:

```
[Input] → [Process A] → [Process B] → [Process C] → [Output]
   │           │              │             │            │
 Owner A    Owner B        Owner C       Owner D      Delivery
```

### 6. Text-based Heatmaps
For gap analysis and maturity assessment:

```
                    Missing   Basic   Structured   Optimized
Process A               🔴
Process B               🔴
Process C               🟡
Process D                       🟡
Process E               🔴
```

## Icons and Conventions

| Icon | Meaning |
|------|---------|
| ✅ | Already possible with current tools |
| 🔄 | Requires setup completion |
| 🔮 | Future roadmap |
| 🟢 | On track / Completed |
| 🟡 | In progress / Needs attention |
| 🔴 | Not started / Critical |
| ⭐ | High priority |

## Formatting Rules

1. **Tables:** always with header and alignment
2. **Numbers:** formatted with thousands separator (€125,000 not €125000)
3. **Percentages:** always with direction sign (▲ +15%, ▼ -5%)
4. **Comparisons:** vs LY (last year), vs LM (last month), vs target
