---
name: coverage-analyzer
description: Use before production deploy, during audit preparation, when checking which areas of the codebase are covered by which skills, identifying uncovered areas, or requesting a coverage matrix mapping skills to files/directories. Scans skills/ and the project codebase.
type: discipline
applies_to: [DEV, STUDIO]
tier: essentials
status: ga
---

# Coverage Analyzer — Skill-to-Code Coverage Matrix

Mappa quali aree del codebase sono coperte da quali skill, identificando zone non protette.

## Core Workflow

### 1. Mappare il codebase

Leggere `PROJECT_STATE.md` (se esiste) per accelerare. Altrimenti scansionare:

| Area | Pattern file | Skill domain |
|------|-------------|--------------|
| API Routes | `app/api/**` | backend, security |
| Pages/UI | `app/(routes)/**` | frontend |
| Components | `components/**` | frontend |
| DB Schema | `db/**`, `drizzle/**` | database |
| Auth | `auth/**`, `lib/auth*` | security |
| Integrations | `lib/integrations/*` | backend, security |
| Config | `*.config.*`, `.env*` | security |
| Tests | `__tests__/**`, `*.test.*` | testing |

### 2. Skill disponibili per area

Scansionare `skills/**/SKILL.md` → matchare skill → area basandosi su description keywords.

### 3. Matrice copertura

Per ogni area, classificare:

| Livello | Criteri |
|---------|---------|
| **Full** | 1+ skill development + 1+ security + 1+ quality |
| **Partial** | Manca una delle 3 categorie |
| **Minimal** | Solo 1 skill |
| **None** | Nessuna skill |

### 4. Report

Tabella: area, file count, dev/security/quality skills, coverage level.
Gap analysis: aree senza security, senza quality, aree critiche privacy/PII.
Raccomandazioni prioritizzate. Heatmap testuale (### = 3+, ## = 2, # = 1, . = 0).

## Rules

- **Tre dimensioni** — sempre verificare Dev + Security + Quality per area
- **Privacy focus** — segnalare SEMPRE aree con PII non coperte da security
- **Discovery entrambi** — scansionare codebase e skill a runtime
- **Actionable** — ogni gap deve avere skill suggerita

## Anti-pattern

- Analisi solo security (ignorare dev e quality)
- Non considerare privacy per aree con dati personali
- Report senza raccomandazioni actionable
- Assumere "semgrep copre tutto"

## Rationalizations — STOP

| Excuse | Reality |
|---|---|
| "Semgrep copre tutto" | Semgrep = solo static SAST. Servono anche dev e quality |
| "PII non applicabile qui" | Flag se area contiene dati personali. Niente opinioni |
| "Report senza raccomandazioni va bene" | Ogni gap richiede skill suggerita actionable |
| "2 dimensioni bastano" | Sempre 3: Dev + Security + Quality. Non negoziabile |
| "Uso PROJECT_STATE.md senza verifica" | Se stale, scansione piena. Non fidarsi ciecamente |
