---
name: sprint-planner
description: Use before starting a build loop or sprint, when planning development sprints, or auto-assigning skills to tasks from a task list (task-decomposer output or manual input). Scans skills/ to find the best skill per task, returning a sprint plan with skill assignments, dependencies, and estimated complexity.
type: technique
---

# Sprint Planner — Dynamic Skill Assignment

Pianifica sprint assegnando automaticamente le skill giuste ad ogni task, basandosi su dynamic discovery.

## Core Workflow

### 1. Input — Raccogliere task

Accettare da: output `task-decomposer`, lista manuale, PRD/spec, `PROJECT_STATE.md` sezione PRD Compliance (requisiti ❌).

Per ogni task: nome/descrizione, dominio (frontend/backend/DB/security/AI), dipendenze, complessita' (S/M/L/XL).

### 2. Discovery — Skill per dominio

1. Scansionare `skills/**/SKILL.md`
2. Classificare per dominio:

| Dominio | Pattern keywords |
|---------|-----------------|
| frontend | UI, component, dashboard, shadcn, React |
| backend | API, route, endpoint, middleware, Next.js |
| database | PostgreSQL, Drizzle, schema, migration |
| security | OWASP, audit, vulnerability, pen test |
| testing | test, TDD, coverage, E2E, Playwright |
| ai | RAG, embedding, prompt, LLM |
| deploy | Vercel, CI/CD, preview |
| reporting | report, Excel, Word, presentation |

### 3. Assignment — Skill per task

Per ogni task:
1. Match dominio → skill primarie (1-3)
2. Skill di supporto (sempre): tdd-red-green-refactor/tdd-vertical-slicing, verification-gate, code-reviewer, git-workflow
3. Condizionali: systematic-debugging (se errori), differential-review (se PR/merge)

### 4. Sequencing

1. Rispettare dipendenze (task dipendenti dopo prerequisiti)
2. Parallelismo per task indipendenti (subagent)
3. Raggruppare in fasi logiche: Setup → Core → UI → Integration → Testing & Security
4. `phase-gate` checkpoint dopo ogni gruppo

### 5. Output — Sprint Plan

Tabella: #, task, dominio, complessita', dipendenze, skill primarie, skill supporto.
Sequenza per gruppi con checkpoint. Workflow template per ogni task (tdd → skill primarie → verification → review → commit). Skill non utilizzate con motivo. Rischi sprint con mitigazione.

## Rules

- **Discovery prima** — scansionare skill, non usare liste hardcoded
- **TDD sempre** — ogni task di implementazione DEVE avere tdd assegnato
- **Gate tra gruppi** — phase-gate obbligatorio
- **Skill mancanti** — segnalare come rischio se dominio senza skill
- **Contesto progetto** — rispettare workflow CLAUDE.md (Fasi 0-5)

## Anti-pattern

- 10+ skill a un singolo task (max 3 primarie + supporto)
- Ignorare dipendenze
- Sprint senza gate/checkpoint
- Pianificare senza discovery
