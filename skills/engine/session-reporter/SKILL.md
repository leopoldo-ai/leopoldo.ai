---
name: session-reporter
description: Generates end-of-session reports by discovering which skills were used, what tasks were completed, and what findings emerged. Scans skills/ for context (path configurable via skill-orch.config.json), analyzes conversation history, and produces professional deliverables (markdown, docx, xlsx) following project naming conventions. Use at the end of any work session for stakeholder visibility.
---

# Session Reporter — Automatic Session Deliverables

Meta-skill che genera report professionali a fine sessione, documentando skill usate, task completati, finding e next steps.

**Contesto:** Gli stakeholder vogliono visibilita' sullo stato di avanzamento. Report strutturati dopo ogni sessione.

## Core Workflow

### Fase 1: Discovery — Skill e contesto sessione

1. **Leggere `PROJECT_STATE.md`** (se esiste) per avere lo stato tecnico aggiornato del codebase
2. **Scansionare `skills/**/SKILL.md`** per avere la mappa completa skill disponibili
3. **Analizzare la conversazione corrente** per identificare:
   - Skill invocate (cercando pattern "Using [skill]" o invocazioni Skill tool)
   - Task completati (dalla TodoWrite history)
   - Decisioni prese
   - Finding/problemi emersi
   - File creati/modificati
3. **Identificare la sessione di lavoro** dal CLAUDE.md o dalla fase di sviluppo (Fase 0-5)
4. **Leggere file context-persistence** (se attivo): Cercare `docs/wip/session_*/notes.md` e `task_plan.md` per arricchire il report con dati strutturati della sessione
5. **Leggere contesto progetto** da CLAUDE.md e PROJECT_STATE.md

### Fase 2: Strutturare il report

```markdown
# Report Sessione: [Data] — [Tema principale]

## Contesto
- **Sessione:** [N] / Fase [N]
- **Obiettivo:** [Obiettivo della sessione]
- **Durata indicativa:** [Stima]

## Skill utilizzate

| Skill | Scopo nella sessione | Output |
|-------|---------------------|--------|
| `skill-name` | Cosa ha fatto | Risultato sintetico |

## Task completati

| # | Task | Stato | Note |
|---|------|-------|------|
| 1 | [Descrizione] | Completato | [Dettaglio] |
| 2 | [Descrizione] | Parziale | [Blocco/motivo] |

## Decisioni prese

| Decisione | Motivazione | Impatto |
|-----------|-------------|---------|
| [Decisione] | [Perche'] | [Su cosa impatta] |

## Finding & Osservazioni

### Positivi
- [Cosa ha funzionato bene]

### Criticita'
- [Problemi emersi, blocchi, rischi]

### Da approfondire
- [Temi aperti che richiedono ulteriore analisi]

## File creati/modificati

| File | Azione | Descrizione |
|------|--------|-------------|
| `path/file` | Creato / Modificato | [Cosa contiene/cosa e' cambiato] |

## Next Steps

| # | Azione | Priorita' | Sessione suggerita |
|---|--------|-----------|-------------------|
| 1 | [Prossimo passo] | Alta | Sessione [N+1] |
| 2 | [Prossimo passo] | Media | [Quando] |

## Stato progetto (da PROJECT_STATE.md)

| Metrica | Valore |
|---------|--------|
| Tabelle DB | [N] |
| API routes | [N] |
| PRD compliance | [N]% ([X]/[Y] requisiti) |
| Test coverage | [N]% |

## Metriche sessione

| Metrica | Valore |
|---------|--------|
| Skill utilizzate | [N] su [M] disponibili |
| Task completati | [N] su [M] pianificati |
| File modificati | [N] |
| Fase workflow | [X] → [Y] (avanzamento) |

## Working Memory (se context-persistence attivo)

*(Compilata automaticamente se `context-persistence` e' stato usato nella sessione)*

- **Directory sessione:** [docs/wip/session_YYYYMMDD_HHMM/]
- **Decisioni chiave:** [estratte da task_plan.md]
- **Note di ricerca:** [N] entries in notes.md
- **Deliverable:** [stato e path del deliverable]

## Retrospective — Skill Improvements

*(Compilata automaticamente se `skill-retrospective` e' invocata nella stessa sessione)*

| Friction | Severity | Skill | Fix | Status |
|----------|----------|-------|-----|--------|
| [descrizione] | Critical/High | [skill-name] | [tipo fix] | Applied/Proposed/Rejected |

**Friction score:** [N] Critical, [N] High, [N] Medium
**Skills migliorate:** [N]
```

### Fase 3: Output — Formato deliverable

Chiedere all'utente il formato desiderato (AskUserQuestion):

| Formato | Skill da invocare | Output |
|---------|-------------------|--------|
| **Markdown** (default) | — | Presentato in chat |
| **Word (.docx)** | `docx-reports` | `docs/SessionReport_v1.0_[YYYYMMDD].docx` |
| **Excel (.xlsx)** | `xlsx-reports` | `docs/SessionReport_v1.0_[YYYYMMDD].xlsx` |
| **Tutti** | Entrambi | Markdown in chat + docx + xlsx |

### Fase 4: Archiviazione

- Salvare in `docs/` con naming convention: `SessionReport_v1.0_[YYYYMMDD].[ext]`
- Se esiste gia' un report per la stessa data, incrementare versione: v1.1, v1.2, ...

## Regole

- **Discovery sempre** — Scansionare skill per avere mappa aggiornata
- **Naming convention** — Rispettare la naming convention del progetto per i deliverable
- **Non inventare** — Reportare solo cio' che e' effettivamente accaduto nella sessione
- **Next steps actionable** — Ogni next step deve essere collegabile a una sessione/fase
- **Formato utente** — Chiedere prima quale formato, non generare tutti automaticamente

## Anti-pattern

- Report generico senza dettagli specifici della sessione
- Inventare task o finding non emersi nella conversazione
- Generare docx/xlsx senza che l'utente lo chieda
- Report di 10 pagine (deve essere conciso, max 2 pagine equivalenti)
- Dimenticare i next steps (il valore principale per i partner)

---

**Versione:** 1.3 (aggiornato 2026-03-01: integrazione context-persistence + sezione Working Memory)
**Tipo:** Meta-skill con dynamic discovery
**Dipendenze:** Glob tool, Read tool, project-memory (PROJECT_STATE.md), skill-retrospective (opzionale), docx-reports (opzionale), xlsx-reports (opzionale), context-persistence (opzionale, input)
