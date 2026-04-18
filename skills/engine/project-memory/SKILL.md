---
name: project-memory
description: Use when the user runs /project-state, asks "stato del progetto", "project state", "cosa abbiamo implementato?", "a che punto siamo?", after completing a task, or before phase gates. Maintains a living PROJECT_STATE.md by scanning the codebase for schema, API routes, components, integrations, test coverage, PRD compliance, architecture decisions.
type: technique
---

# Project Memory — Living Documentation

Meta-skill che scansiona il codebase e mantiene `PROJECT_STATE.md` aggiornato — la fonte di verita' sullo stato reale del progetto.

## Perche' esiste

| Problema | Soluzione |
|----------|-----------|
| MEMORY.md e' manuale, degrada tra sessioni | PROJECT_STATE.md e' generato dal codice reale |
| "Quali tabelle abbiamo?" → devo leggere 10 file | Scan automatico schema |
| PRD dice X ma il codice fa Y | Cross-reference PRD ↔ implementazione |
| Nuova sessione parte da zero | PROJECT_STATE.md da' contesto immediato |

## Quando si attiva

| Trigger | Azione |
|---------|--------|
| `/project-state` o inizio sessione | Scan completo, genera PROJECT_STATE.md |
| Dopo commit (da git-workflow) | Scan incrementale, aggiorna sezioni cambiate |
| Pre phase-gate | Scan + PRD compliance report |
| Pre-deploy | Scan + validazione completezza |
| Fine sessione (da session-reporter) | Includi stato nel report |

## Core Workflow

### Fase 1: Scan Codebase

Usa Glob + Grep + Read per scansionare i layer. Per ogni layer estrai i dati strutturati:

| Layer | Scan pattern | Estrai |
|-------|-------------|--------|
| **Schema DB** | `drizzle/schema/*.ts`, `src/db/schema/*.ts` | Tabelle, colonne (nome, tipo, constraints), relazioni, indici, migrazione |
| **API Routes** | `app/api/**/route.ts` | Path, metodi HTTP, auth middleware, Zod schema |
| **UI Pages/Components** | `app/(dashboard)/**/*.tsx`, `components/**/*.tsx` | Nome, tipo (page/layout/component), "use client" flag |
| **Integrazioni** | `lib/integrations/*/`, `lib/services/*/` | Servizio, funzioni esportate, ultimo file modificato |
| **Config & Env** | `.env.example`, `vercel.json`, `next.config.*` | Variabili richieste (solo nomi, MAI valori), cron, config speciali |
| **Test Coverage** | `**/*.test.ts`, `e2e/**/*.spec.ts` | File testato, numero test, tipo (unit/integration/e2e), moduli senza test |
| **Migrazioni DB** | `drizzle/migrations/*` | Lista cronologica, ultima migrazione |

### Fase 2: PRD Compliance Check

1. Leggere PRD / CLAUDE.md sezione fasi
2. Mappare ogni requisito → check: tabella esiste? route esiste? UI implementata? test presenti?
3. Stato per requisito: ✅ Implementato | 🔄 In progress | ❌ Non iniziato

### Fase 3: Genera PROJECT_STATE.md

Scrivere in root del progetto con queste sezioni:

1. **Schema DB** — tabella (nome, colonne, FK, indici, migrazione)
2. **API Routes** — tabella (route, methods, auth, zod, test)
3. **UI Pages & Components** — tabelle separate
4. **Integrazioni** — tabella (servizio, modulo, funzioni, config, stato)
5. **Configurazione** — variabili env + cron jobs
6. **Test Coverage** — tabella per modulo con unit/integration/e2e
7. **PRD Compliance** — tabella requisiti con stato e file/modulo
8. **Decisioni Architetturali** — summary ADR (data, decisione, rationale)
9. **Cambiamenti dall'ultimo scan** — log diff

### Fase 4: Aggiornamento Incrementale

Per scan dopo commit: `git diff --name-only HEAD~1` → ri-scansionare solo layer toccati → aggiornare sezioni rilevanti → aggiungere entry in "Cambiamenti".

## Integrazione

| Skill | Integrazione |
|-------|-------------|
| git-workflow | Post-commit → scan incrementale |
| phase-completion-checklist | Pre-gate → leggi PRD Compliance |
| session-reporter | Fine sessione → includi summary |
| sprint-planner | Leggi requisiti ❌ per assegnare a sprint |
| coverage-analyzer | Input da sezione Test Coverage |

## Convenzioni

- **Path output:** `PROJECT_STATE.md` (root progetto)
- **Non committare** in git (aggiungere a `.gitignore`) oppure committare come reference (scelta utente)
- ADR opzionali in `docs/decisions/ADR-NNN.md`, PROJECT_STATE tiene solo il summary

## Anti-Patterns

- **MAI** leggere valori da `.env` — solo nomi variabili da `.env.example`
- **MAI** includere secrets, token, o credenziali
- **MAI** sovrascrivere senza prima leggere la versione precedente (per diff)
- **MAI** fare scan completo dopo ogni piccolo cambio — usare scan incrementale
- **MAI** tracciare file in `node_modules/`, `.next/`, o build artifacts
