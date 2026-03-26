---
name: sprint-planner
description: Plans development sprints by discovering available skills and auto-assigning them to tasks. Takes a task list (from task-decomposer or manual input), scans skills/ to find the best skill for each task (path configurable via skill-orch.config.json), and produces a sprint plan with skill assignments, dependencies, and estimated complexity. Use before starting a build loop or sprint.
---

# Sprint Planner — Dynamic Skill Assignment

Meta-skill che pianifica sprint assegnando automaticamente le skill giuste ad ogni task, basandosi su dynamic discovery.

**Contesto:** Build loop con skill multiple. Ogni task ha bisogno delle skill giuste nel giusto ordine.

## Core Workflow

### Fase 1: Input — Raccogliere i task

Accettare task da una di queste fonti:

1. **Output di `task-decomposer`** — Grafo task con dipendenze gia' definite
2. **Lista manuale** — L'utente fornisce una lista di task
3. **PRD/spec** — Estrarre task direttamente dal documento
4. **`PROJECT_STATE.md`** (da `project-memory`) — Leggere sezione "PRD Compliance" per identificare requisiti ❌ ancora da implementare

Per ogni task, identificare:
- Nome/descrizione
- Dominio (frontend, backend, DB, security, AI, ecc.)
- Dipendenze (da altri task)
- Complessita' stimata (S/M/L/XL)

### Fase 2: Discovery — Skill disponibili per dominio

1. **Scansionare `skills/**/SKILL.md`** con Glob
2. **Estrarre frontmatter** (name, description)
3. **Classificare skill per dominio:**

   | Dominio | Pattern nella description |
   |---------|--------------------------|
   | frontend | UI, component, design, dashboard, shadcn, Tremor, React |
   | backend | API, route, server, endpoint, middleware, Next.js |
   | database | PostgreSQL, Drizzle, schema, query, migration, Neon |
   | security | OWASP, audit, vulnerability, pen test, security |
   | testing | test, TDD, coverage, E2E, Playwright |
   | ai | RAG, embedding, prompt, LLM, scoring |
   | deploy | deploy, Vercel, CI/CD, preview |
   | planning | sprint, task, backlog, PRD, decompose |
   | quality | review, debugging, refactoring |
   | comms | email, marketing, campaign, newsletter |
   | strategy | strategy, SWOT, roadmap, decision |
   | reporting | report, Excel, Word, presentation |

4. **Costruire mappa dominio → skill[]**

### Fase 3: Assignment — Skill per task

Per ogni task:

1. **Matchare dominio del task** con la mappa skill
2. **Selezionare skill primarie** (1-3) — Le piu' rilevanti per il task
3. **Aggiungere skill di supporto** — Sempre presenti per il workflow:
   - `tdd-red-green-refactor` o `tdd-vertical-slicing` → per qualsiasi task di implementazione
   - `verification-gate` → alla fine di ogni task
   - `code-reviewer` → tra un task e il successivo
   - `git-workflow` → per il commit dopo ogni task
4. **Skill condizionali:**
   - `systematic-debugging` / `debugging-wizard` → solo se emergono errori
   - `differential-review` → solo per PR/merge

### Fase 4: Sequencing — Ordine di esecuzione

1. **Rispettare dipendenze** — Task dipendenti vanno dopo i prerequisiti
2. **Parallelismo** — Task indipendenti possono essere eseguiti in parallelo (con subagent)
3. **Fasi logiche** — Raggruppare task in mini-fasi:
   - Setup (DB schema, config)
   - Core logic (API, business logic)
   - UI (componenti, pagine)
   - Integration (collegamento componenti)
   - Testing & Security
4. **Checkpoint** — Inserire `phase-gate` dopo ogni gruppo logico

### Fase 5: Output — Sprint Plan

```markdown
# Sprint Plan: [Nome Sprint]
**Data:** [YYYY-MM-DD]
**Task totali:** [N]
**Skill coinvolte:** [N]
**Complessita' stimata:** [S/M/L/XL]

## Panoramica

| # | Task | Dominio | Complessita' | Dipendenze | Skill primarie | Skill supporto |
|---|------|---------|-------------|------------|----------------|----------------|
| 1 | Setup DB schema | database | M | — | postgres-pro, neon-postgres-setup, drizzle-orm-patterns | tdd-red-green-refactor, verification-gate |
| 2 | API /candidates CRUD | backend | L | Task 1 | api-designer, nextjs-app-router-fundamentals | typescript-pro, tdd-red-green-refactor |
| 3 | Dashboard candidati | frontend | L | Task 2 | shadcnblocks-components, tremor-design-system, frontend-design | react-best-practices |
| ... |

## Sequenza di esecuzione

### Gruppo 1: Foundation (parallelo dove possibile)
- [x] Task 1: Setup DB schema
- [ ] Task 2: API /candidates CRUD (dipende da 1)
→ **Checkpoint:** `phase-gate` mini-verifica

### Gruppo 2: UI Layer
- [ ] Task 3: Dashboard candidati (dipende da 2)
- [ ] Task 4: Form candidato (dipende da 2) ← parallelizzabile con Task 3
→ **Checkpoint:** `phase-gate` mini-verifica

### Gruppo 3: Integration & Polish
- [ ] Task 5: Collegamento dashboard-API (dipende da 3, 4)
→ **Checkpoint:** `phase-gate` verifica completa

## Workflow per task (template)

Per ogni task nel piano:
1. `tdd-red-green-refactor` → Scrivere test
2. [Skill primarie] → Implementazione
3. `verification-gate` → Verifica completamento
4. `code-reviewer` → Quality gate
5. `git-workflow` → Commit atomico
6. (se errore) `systematic-debugging` → Fix

## Skill non utilizzate in questo sprint

| Skill | Motivo |
|-------|--------|
| `email-marketing-bible` | Sprint non include task email |
| `strategy-advisor` | Sprint tecnico, non strategico |
| ... |

## Rischi sprint

| Rischio | Probabilita' | Impatto | Mitigazione |
|---------|-------------|---------|-------------|
| Schema DB cambia dopo Task 1 | Media | Alto | Validare schema con board-orchestrator prima |
| API esterna non disponibile | Bassa | Alto | Mock per sviluppo, test E2E separato |
```

## Regole

- **Discovery prima** — Scansionare skill prima di assegnare, non usare liste hardcoded
- **TDD sempre** — Ogni task di implementazione DEVE avere tdd-red-green-refactor assegnato
- **Gate tra gruppi** — phase-gate obbligatorio tra gruppi logici
- **Skill mancanti** — Se un task richiede un dominio senza skill, segnalarlo come rischio
- **Contesto progetto** — Rispettare il workflow CLAUDE.md (Fasi 0-5) e le convenzioni del progetto

## Anti-pattern

- Assegnare 10+ skill a un singolo task (max 3 primarie + supporto)
- Ignorare le dipendenze (task paralleli che dipendono l'uno dall'altro)
- Sprint senza gate/checkpoint (scoprire problemi troppo tardi)
- Pianificare senza discovery (skill nuove non vengono considerate)

---

**Versione:** 1.1 (aggiornato 2026-02-28: integrazione project-memory per task discovery da PRD compliance)
**Tipo:** Meta-skill con dynamic discovery
**Dipendenze:** Glob tool, Read tool, project-memory (PROJECT_STATE.md)
**Si integra con:** task-decomposer (input), phase-gate (checkpoint), audit-coordinator (security sprint), project-memory (stato PRD compliance)
