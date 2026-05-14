---
name: session-reporter
description: Use at the end of any work session for stakeholder visibility, or when an end-of-session report is needed covering which skills were used, tasks completed, and findings that emerged. Scans skills/ for context, analyzes conversation history, and outputs professional deliverables (markdown, docx, xlsx).
type: technique
applies_to: [STUDIO]
tier: essentials
status: ga
---

# Session Reporter — Automatic Session Deliverables

Genera report professionali a fine sessione: skill usate, task completati, finding, next steps.

## Core Workflow

### 1. Discovery

1. Leggere `.state/state.json` per stato tecnico (Leopoldo state file)
2. Scansionare `skills/**/SKILL.md` per mappa skill disponibili
3. Analizzare conversazione: skill invocate, task completati, decisioni, finding, file creati/modificati
4. Leggere file context-persistence (se attivo): `docs/wip/session_*/notes.md` + `task_plan.md`

### 2. Strutturare il report

Sezioni: Contesto (sessione, obiettivo, durata) → Skill utilizzate (tabella) → Task completati (tabella con stato) → Decisioni prese → Finding (positivi, criticita', da approfondire) → File creati/modificati → Next steps (con priorita') → Stato progetto (da `.state/state.json`) → Metriche sessione → Working Memory (se context-persistence attivo) → Retrospective (se skill-retrospective invocata).

### 3. Formato deliverable

Chiedere all'utente (AskUserQuestion):

| Formato | Skill | Output |
|---|---|---|
| Markdown (default) | — | In chat |
| Word (.docx) | `docx-reports` | `docs/SessionReport_v1.0_[YYYYMMDD].docx` |
| Excel (.xlsx) | `advanced-excel-analyst` | `docs/SessionReport_v1.0_[YYYYMMDD].xlsx` |

Naming: `SessionReport_v1.0_[YYYYMMDD].[ext]`. Se esiste, incrementare versione.

## Rules

- **Discovery sempre** — scansionare skill per mappa aggiornata
- **Naming convention** — rispettare naming del progetto
- **Non inventare** — solo cio' che e' effettivamente accaduto
- **Next steps actionable** — collegabili a sessione/fase
- **Formato utente** — chiedere prima, non generare tutti

## Anti-pattern

- Report generico senza dettagli specifici
- Inventare task o finding
- Generare docx/xlsx senza richiesta
- Report di 10 pagine (max 2 pagine equivalenti)
- Dimenticare next steps
