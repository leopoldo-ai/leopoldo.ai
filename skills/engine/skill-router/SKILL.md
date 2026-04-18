---
name: skill-router
version: 2.1.0
description: Use when unsure which skill to invoke for a user request, at session start to identify the right tools for the task, or whenever dynamic skill routing is needed. Scans skills/**/SKILL.md at runtime, extracts name+description, matches semantically to user intent, dispatches skill.invoke events through event-dispatcher.
type: technique
---

# Skill Router — Dynamic Discovery, Matching & Event Dispatch

Scansiona skill installate, suggerisce le 2-5 piu' rilevanti, e dispatcha eventi `skill.invoke` attraverso l'event-dispatcher.

## Core Workflow

### 1. Discovery

**A runtime, mai liste hardcoded.**

1. Scansionare `skills/**/SKILL.md` (pattern da skill-orch.config.json)
2. Per ogni SKILL.md estrarre: name, description, skillos.layer, skillos.requires, prima riga body
3. Costruire indice runtime: [{ name, description, layer, domain }]

### 2. Classificazione richiesta

Analizzare richiesta utente → classificare in domini:

| Dominio | Keywords |
|---------|---------|
| strategy | strategia, roadmap, SWOT, priorita' |
| development | codice, build, feature, bug, fix, API |
| database | query, schema, migrazione, PostgreSQL, Drizzle |
| frontend | UI, dashboard, componente, shadcn, Tremor |
| security | sicurezza, audit, vulnerabilita', OWASP |
| testing | test, TDD, coverage, E2E, Playwright |
| email | campagna, deliverability, newsletter |
| ai | RAG, embedding, prompt, scoring |
| deploy | Vercel, preview, produzione, CI/CD |
| planning | sprint, task, backlog, PRD |
| reporting | report, Excel, Word, presentazione |
| orchestration | board, meta-skill, fase, gate |
| quality | review, refactoring, debugging |

### 2.5. Intent Preset Boost

1. Leggere `intent_presets` da config
2. Match case-insensitive su word boundary (non substring: "fund" NON matcha "refunding")
3. Match trovato → skill dei pack indicati ricevono priority boost in Fase 3
4. Piu' preset matchano → pack si sommano (union)
5. Pack non installati → ignorati con warning

**I preset arricchiscono, non sostituiscono la discovery dinamica.**

### 3. Matching

1. **Match primario:** description contiene keyword dominio
2. **Match secondario:** name corrisponde parzialmente
3. **Ranking:** description > name > domain generico
4. **Priority boost:** skill da pack matchati in 2.5
5. **Filtro:** max 5, min 2
6. **Cross-ref:** state.json per fase corrente → priorita' a skill fase attiva
7. **Health:** de-prioritizzare skill con status degraded/broken

### 4. Output

Tabella: #, skill, perche', priorita'. Workflow suggerito (ordine invocazione). Fase corrente da state.json.

### 5. Dispatch evento

Utente conferma → costruire payload (skill, layer, trigger, context) → `dispatch("skill.invoke", payload)`.

**Middleware chain:**
- **PRE:** dependency-checker.verify (se userland) — se BLOCK: skill non invocata, mostrare prerequisiti
- **AZIONE:** invocazione skill
- **POST:** session-lifecycle.journal-append

Al completamento → `dispatch("skill.complete", { skill, outcome, duration })`.

### 6. Gestione blocco PRE-hook

Se dependency-checker blocca: mostrare tabella prerequisiti mancanti (tipo HARD/SOFT, stato) + azioni suggerite in ordine.

## Rules

- **Discovery SEMPRE a runtime** — mai hardcodare la lista skill
- **Dispatch SEMPRE via event-dispatcher** — per middleware chain
- **Non auto-invocare** — suggerire e attendere conferma (tranne mode=auto)
- **Contesto progetto** — usare state.json per fase e skill health
- **Skill mancanti** — segnalare esplicitamente se nessuna matcha
- **Meta-skill incluse** — il router puo' suggerire anche meta-skill
- **No dispatch ricorsivo** — il router NON dispatcha per se' stesso

## Anti-pattern

- Suggerire piu' di 5 skill
- Suggerire skill non installate localmente
- Invocare senza conferma utente
- Ignorare fase corrente del workflow
- Bypassare event-dispatcher
- Ignorare blocco dependency-checker
