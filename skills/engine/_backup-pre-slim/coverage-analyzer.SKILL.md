---
name: coverage-analyzer
description: Analyzes which areas of the codebase are covered by which skills. Maps skills to files/directories they should analyze, identifies uncovered areas, and produces a coverage matrix. Scans skills/ and the project codebase (path configurable via skill-orch.config.json). Use before production deploy or during audit preparation.
---

# Coverage Analyzer — Skill-to-Code Coverage Matrix

Meta-skill che mappa quali aree del codebase sono coperte da quali skill, identificando zone non protette.

**Contesto:** Progetti con moduli multipli. Ogni area del codice dovrebbe essere coperta da skill appropriate.

## Core Workflow

### Fase 1: Discovery — Mappare il codebase

1. **Leggere `PROJECT_STATE.md`** (se esiste) — Usare schema, routes, e test coverage gia' calcolati per accelerare l'analisi
2. **Scansionare la struttura del progetto** (o validare PROJECT_STATE.md se recente):
   ```
   Glob: src/**/*.ts, src/**/*.tsx
   ```
2. **Classificare per area:**

   | Area | Pattern file | Skill domain |
   |------|-------------|--------------|
   | API Routes | `src/app/api/**` | backend, security |
   | Pages/UI | `src/app/(routes)/**` | frontend |
   | Components | `src/components/**` | frontend |
   | DB Schema | `src/db/**`, `drizzle/**` | database |
   | Middleware | `src/middleware.ts` | security, backend |
   | Auth | `src/auth/**`, `src/lib/auth*` | security |
   | Integrations | `src/lib/integrations/*` | backend, security |
   | Config | `*.config.*`, `.env*` | security |
   | Tests | `__tests__/**`, `*.test.*` | testing |
   | Types | `src/types/**` | backend |

### Fase 2: Discovery — Skill disponibili per area

1. **Scansionare `skills/**/SKILL.md`**
2. **Matchare skill → area** basandosi sulle description:

   | Skill | Aree coperte |
   |-------|-------------|
   | `nextjs-developer` | API Routes, Pages, Middleware |
   | `postgres-pro` | DB Schema |
   | `semgrep` | Tutte (static analysis) |
   | `sharp-edges` | API Routes, Integrations, Config |
   | `secure-code-guardian` | Auth, API Routes, Middleware |
   | `shadcnblocks-components` | Components, Pages |
   | `insecure-defaults` | Config, Auth |
   | ... |

### Fase 3: Costruire matrice di copertura

Per ogni area del codebase:

1. **Contare i file** nell'area
2. **Identificare skill applicabili** (dal matching Fase 2)
3. **Classificare copertura:**
   - **Full** — Almeno 1 skill development + 1 skill security + 1 skill quality
   - **Partial** — Manca una delle 3 categorie
   - **Minimal** — Solo 1 skill copre l'area
   - **None** — Nessuna skill copre l'area

### Fase 4: Report

```markdown
# Skill Coverage Analysis — [Scope]
**Data:** [YYYY-MM-DD]
**File analizzati:** [N]
**Aree identificate:** [N]

## Coverage Matrix

| Area | File | Dev Skills | Security Skills | Quality Skills | Coverage |
|------|------|------------|-----------------|----------------|----------|
| API Routes | [N] | nextjs-developer, api-designer | semgrep, secure-code-guardian, sharp-edges | tdd-red-green-refactor, code-reviewer | Full |
| Components | [N] | shadcnblocks-components, frontend-design | — | code-reviewer | Partial (no security) |
| DB Schema | [N] | postgres-pro, neon-postgres-setup | semgrep | tdd-red-green-refactor | Full |
| Auth | [N] | nextjs-developer | secure-code-guardian, insecure-defaults | tdd-red-green-refactor | Full |
| Integrations | [N] | api-designer | sharp-edges | — | Partial (no quality) |
| Config | [N] | — | insecure-defaults | — | Minimal |

## Sommario copertura

| Coverage Level | Aree | % |
|---------------|------|---|
| Full | [N] | [%] |
| Partial | [N] | [%] |
| Minimal | [N] | [%] |
| None | [N] | [%] |

## Gap Analysis

### Aree senza copertura security
| Area | File | Rischio | Skill suggerita |
|------|------|---------|-----------------|
| Components | [N] | Medio (XSS in render) | secure-code-guardian |

### Aree senza copertura quality
| Area | File | Rischio | Skill suggerita |
|------|------|---------|-----------------|
| Integrations | [N] | Alto (no test su API esterne) | test-master, e2e-testing-patterns |

### Aree critiche privacy/compliance senza copertura adeguata
| Area | Dato sensibile | Skill necessarie |
|------|---------------|-----------------|
| [Area] | PII utenti | secure-code-guardian + semgrep (privacy rules) |

## Raccomandazioni

1. **Priorita' 1:** Coprire tutte le aree con dato PII con security skill
2. **Priorita' 2:** Aggiungere quality skill alle integrazioni esterne
3. **Priorita' 3:** Coprire config con skill development (non solo security)

## Heatmap (text-based)

| Area          | Dev | Sec | Qual | Overall |
|---------------|-----|-----|------|---------|
| API Routes    | ### | ### | ##   | HIGH    |
| Components    | ### | .   | #    | MEDIUM  |
| DB Schema     | ### | ##  | ##   | HIGH    |
| Auth          | ##  | ### | ##   | HIGH    |
| Integrations  | ##  | #   | .    | LOW     |
| Config        | .   | #   | .    | LOW     |

Legenda: ### = 3+ skill, ## = 2 skill, # = 1 skill, . = 0 skill
```

## Regole

- **Tre dimensioni** — Sempre verificare Dev + Security + Quality per ogni area
- **Privacy focus** — Segnalare SEMPRE aree con PII non coperte da security
- **Discovery entrambi** — Scansionare sia codebase che skill a runtime
- **Actionable** — Ogni gap deve avere una skill suggerita per risolverlo

## Anti-pattern

- Analisi solo security (ignorare dev e quality)
- Non considerare privacy/compliance per aree con dati personali
- Report senza raccomandazioni actionable
- Assumere che "semgrep copre tutto" (static analysis non sostituisce review manuale)

---

**Versione:** 1.1 (aggiornato 2026-02-28: integrazione project-memory per accelerare scan codebase)
**Tipo:** Meta-skill con dynamic discovery
**Dipendenze:** Glob tool, Read tool, Grep tool, project-memory (PROJECT_STATE.md)
**Si integra con:** audit-coordinator (pre-audit), phase-gate (verifica fase), project-memory (stato codebase)
