---
name: phase-completion-checklist
description: Use when the user requests "/complete-phase", "checklist fase X", "siamo pronti per la fase successiva?", or needs structured verification that all deliverables for a development phase are complete and working. Coordinates validation, testing, documentation, and review skills.
type: technique
---

# Phase Completion Checklist

Coordinates specialized skills to verify that all deliverables for a development phase are complete, tested, documented, and reviewed before moving to the next phase.

## Development Phases Reference

Source: PRD (in `docs/`) + `CLAUDE.md`

**Nota:** Le fasi specifiche dipendono dal progetto. Leggere il PRD e `CLAUDE.md` per identificare le fasi e i deliverable applicabili. La tabella sotto e' un template generico — adattare al progetto corrente.

| Phase | Name | Key Deliverables |
|-------|------|-----------------|
| 1 | Project Setup | Framework, ORM, DB, Auth, UI library |
| 2 | Schema & DB | Tabelle core, migrazioni |
| 3-5 | Integrazioni | API client, webhook handler, sync |
| 6-9 | Dashboard | Viste dati, filtri, ricerca, metriche, grafici |
| 10 | Security & GDPR | Input validation, rate limiting, audit log, consensi |
| 11 | Testing & QA | Unit test, integration test, E2E, performance |
| 12 | Deploy & Launch | Production deploy, monitoring, scheduling |

## Core Workflow

### Phase 1: Load Phase Requirements

1. **Leggere `PROJECT_STATE.md`** (se esiste) — Stato tecnico reale: schema, routes, test, PRD compliance
2. **Leggere il PRD** — Cercare in `docs/` il PRD piu' recente, estrarre deliverable per la fase target
3. **Leggere `CLAUDE.md`** — Cross-reference requisiti, stack, convenzioni
4. **Scan codebase** (o usare PROJECT_STATE.md se aggiornato) — Identify implemented vs. missing features
5. **Build checklist** — Dynamic checklist based on phase

### Phase 2: Multi-Layer Verification

Invoke skills in parallel using Task tool:

#### Implementation Check (`nextjs-developer` + `typescript-pro`)
- Tutte le API routes implementate e funzionanti
- Componenti UI creati e funzionali (shadcn/ui + Tremor)
- Schema DB supporta tutte le feature (Drizzle + Neon)
- Error handling con Zod validation
- Server Components default, `"use client"` solo dove necessario

#### Architecture Review (`senior-architect`)
- Codice segue i pattern del progetto (da CLAUDE.md)
- Nessun anti-pattern architetturale
- Separazione di responsabilita' corretta
- Performance e sicurezza (GDPR)

#### Testing (`e2e-testing-patterns` + `test-master`)
- Unit test passano
- E2E test coprono happy path
- Edge case testati
- Nessuna regressione in funzionalita' esistenti

#### Security Check (`secure-code-guardian`)
- Input validation Zod su ogni endpoint
- Webhook signature verification
- No secrets in code
- GDPR compliance per dati personali

#### Documentation Check (manual)
- API documentation aggiornata
- CLAUDE.md riflette nuovi pattern (se presenti)

### Phase 3: Generate Checklist Report

```markdown
# Phase [N] Completion Report: [Phase Name]

**Date:** [YYYY-MM-DD]
**Status:** ✅ READY / ⚠️ BLOCKED / ❌ NOT READY

## Checklist

### Implementation [X/Y complete]
- [x] API route: POST /api/projects/{id}/scenarios
- [x] UI: Scenario list page
- [ ] UI: Scenario comparison view

### Architecture [X/Y pass]
- [x] Follows soft-delete pattern
- [ ] Deep copy transaction (missing 2 tables)

### Testing [X/Y pass]
- [x] Unit tests: 12/12 passing
- [ ] E2E tests: 8/10 passing (2 flaky)

### Documentation [X/Y complete]
- [x] API docs updated
- [ ] Component docs missing

## Blockers
1. **[Blocker]** — [description]

## Action Items
1. [ ] [action]

## Recommendation
[✅ READY / ⚠️ BLOCKED / ❌ NOT READY] — [rationale]
```

### Phase 4: Gate Decision

| Status | Criteria | Action |
|--------|----------|--------|
| ✅ **READY** | All checks pass | Proceed to next phase |
| ⚠️ **BLOCKED** | Minor issues | Fix items, then re-validate |
| ❌ **NOT READY** | Major gaps | Continue current phase |

## Optional: Board Review

Per fasi critiche (6, 10, 12), trigger `board-orchestrator`:

```
/complete-phase 7 --with-board-review
```

## Usage

```
/complete-phase 3
/complete-phase 7 --with-board-review
/complete-phase 11 --strict
```

## Anti-Patterns

❌ Skipping testing layer
❌ Marking phase complete with known blockers
❌ Not reading DEVELOPMENT_PLAN.md before checking
❌ Checking only code, not documentation
❌ Running checklist without recent git pull
