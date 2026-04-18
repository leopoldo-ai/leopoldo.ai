---
name: phase-gate
version: 2.0.0
description: "Use at the end of any development phase, on phase.complete events, or when verifying all relevant skills for a workflow phase were actually invoked. Dynamic phase completion gate: scans skills/ at runtime, maps skills to phases, reports coverage gaps. Registered as blocking hook via event-dispatcher."
type: discipline
---

# Phase Gate — Dynamic Completion Verification

Meta-skill che verifica a runtime se tutte le skill rilevanti per una fase del workflow sono state effettivamente utilizzate. Previene gap di copertura.

## Invocazione

**Auto-trigger:** registrato come `blocking` su `phase.complete` via event-dispatcher. Se PASS → fase avanza. Se FAIL → fase NON avanza, utente riceve report.

**Diretta:** verifica anticipata mid-fase, report senza avanzare, analisi gap.

## Core Workflow

### 1. Identificare fase da verificare

Auto-trigger: estrarre fase dal payload. Diretta: utente indica. Leggere `.state/state.json` per fase corrente.

**Mappa fasi → skill:**

| Fase | Nome | Skill previste |
|------|------|----------------|
| 0 | PRD Closure | product-closure-loop |
| 1 | Pianificazione | task-decomposer, git-workflow |
| 2 | Scaffold | project-scaffolder |
| 3 | Build Loop | tdd-*, nextjs-*, react-*, typescript-pro, postgres-pro, drizzle-orm-patterns, database-optimizer, api-designer, shadcnblocks, tremor, dashboard-builder, frontend-*, verification-gate, code-reviewer, git-workflow, systematic-debugging |
| 4 | Sicurezza | secure-code-guardian, semgrep, performing-security-testing, insecure-defaults, sharp-edges, differential-review, audit-prep-assistant, rag-architect, prompt-engineer |
| 5 | Deploy | vercel-deploy, product-closure-loop |

### 2. Discovery dinamica

Scansionare `skills/**/SKILL.md` a runtime (mai solo mappa statica). Estrarre frontmatter, classificare per fase (menzione CLAUDE.md + keywords description). Segnalare skill non assegnate.

### 3. Verificare copertura

Per ogni skill prevista, consultare journal (`.state/journal/`) e state.json per invocazioni:

| Stato | Significato |
|---|---|
| **Coperta** | Invocata, outcome=success |
| **Parziale** | Invocata, outcome=warning o non completata |
| **Mancante** | Nessuna invocazione |
| **N/A** | Non applicabile per questo task |
| **Nuova** | Scoperta via discovery, non prevista |

**Gate score:** `(coperte + parziali * 0.5) / (totale - N/A)`

### 4. Gate Decision

**Soglie** (da skill-orch.config.json):

| Fase | Tipo soglia | Valore |
|------|------------|--------|
| 0-3 | default | 0.80 |
| 4 | security | **1.00** (zero tolleranza) |
| 5 | deploy | **1.00** |

**Verdetto:**
- `score >= soglia` → **PASS**
- `score >= soglia * 0.9` → **CONDITIONAL** (serve piano)
- `score < soglia * 0.9` → **FAIL**

### 5. Report

Tabella: skill, stato, invocazione, note. Metriche: previste, coperte, parziali, mancanti, N/A. Gate decision con soglia e score. Se FAIL: azioni richieste per skill mancanti.

### 6. Aggiornamento stato (se PASS)

Aggiornare `.state/state.json`: `phase.history[]`, `phase.current`, `phase.name`, `phase.started_at`. L'event-dispatcher dispatcha POST: `session-lifecycle.journal-append` con tipo `phase.advance`.

## Rules

- **Gate obbligatorio** — non procedere senza PASS o CONDITIONAL con piano
- **Fase 4 = zero tolleranza** — tutte le skill security coperte
- **Discovery sempre** — scansionare a runtime, non fidarsi solo della mappa statica
- **Journal come fonte** — usare journal per verificare invocazioni
- **Fail-safe** — journal non leggibile → fallback a conversazione + warning
- **Segnalare skill orfane** — installate ma non mappate
- **N/A con motivazione** — non bloccare per skill non applicabili

## Anti-pattern

- Marcare skill come "Coperta" senza evidenza nel journal
- Saltare il gate per "fretta"
- Ignorare skill scoperte via discovery
- Stesse soglie per tutte le fasi
- Avanzare fase senza aggiornare state.json

## Rationalizations — STOP

| Excuse | Reality |
|---|---|
| "Siamo quasi alla soglia" | 0.79 < 0.80 = FAIL. Nessuna tolleranza |
| "La skill non si applica qui" | Marca N/A con motivazione scritta, non saltare |
| "L'utente ha fretta" | Solo l'utente può dire "skip gate" esplicitamente |
| "Fase 4 è troppo rigida al 100%" | Security = zero tolerance. Non negoziabile |
| "Lo registro dopo come coperto" | Evidenza nel journal O non coperto. No retrofit |
| "Era implicito nella conversazione" | Implicito ≠ journal entry. No evidenza = FAIL |
| "Procedo e aggiorno state.json dopo" | PASS richiede aggiornamento atomico, non deferred |
