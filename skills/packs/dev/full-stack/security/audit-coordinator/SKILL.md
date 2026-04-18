---
name: audit-coordinator
version: 0.2.0
description: Use when running a complete security audit on the codebase or any module. Orchestrates the full audit pipeline by discovering and sequencing all installed security skills, covering static analysis, config audit, API review, dynamic testing, and aggregated reporting.
type: technique
---

# Audit Coordinator — Security Pipeline Orchestrator

Meta-skill che scopre dinamicamente tutte le skill di sicurezza installate e le orchestra in una pipeline logica per produrre un audit completo e aggregato.

**Contesto:** Applicazione web con dati personali (GDPR), integrazioni API esterne. La sicurezza non e' opzionale.

## Core Workflow

### Fase 1: Discovery — Skill security disponibili

**Scoprire a runtime, mai hardcodare.**

1. **Scansionare `skills/**/SKILL.md`** con Glob
2. **Filtrare skill security** — Cercare nelle description keywords:
   `security`, `audit`, `vulnerability`, `OWASP`, `injection`, `pen test`, `static analysis`, `insecure`, `threat`, `review`, `sharp-edges`, `hardcoded`, `secrets`
3. **Classificare per tipo di analisi:**

   | Tipo | Skill tipiche | Ordine |
   |------|---------------|--------|
   | **Static Analysis** | semgrep, semgrep-rule-creator | 1 (prima) |
   | **Config Audit** | insecure-defaults | 2 |
   | **API & Code Review** | sharp-edges, secure-code-guardian | 3 |
   | **Differential Review** | differential-review | 4 |
   | **Dynamic Testing** | performing-security-testing | 5 |
   | **Audit Prep** | audit-prep-assistant | 6 (ultima) |

4. **Costruire pipeline** — Ordinare le skill scoperte nella sequenza logica sopra

### Fase 2: Scoping — Definire il perimetro

1. **Chiedere all'utente** (AskUserQuestion):
   - **Scope:** Intero codebase / Modulo specifico / Solo API / Solo frontend
   - **Profondita':** Quick scan (top 3 skill) / Standard (tutte) / Deep (tutte + regole custom)
   - **Focus:** Generico / GDPR-specifico / API integration / Authentication
2. **Identificare i file target:**
   - Scansionare la struttura del progetto
   - Identificare entry point (API routes, middleware, auth)
   - Mappare integrazioni esterne (API endpoints di terze parti)

### Fase 3: Esecuzione pipeline

Eseguire ogni skill nella sequenza. Per ogni step:

1. **Invocare la skill** con contesto specifico:
   - Scope definito in Fase 2
   - Finding delle skill precedenti (context cascading)
   - Focus area specifiche
2. **Raccogliere i finding** in formato strutturato:
   ```
   {
     skill: "semgrep",
     severity: "HIGH",
     finding: "SQL injection in /api/candidates/search",
     file: "src/app/api/candidates/search/route.ts",
     line: 42,
     recommendation: "Use parameterized query"
   }
   ```
3. **Context cascading** — Passare i finding della skill precedente alla successiva:
   - `semgrep` trova un pattern → `sharp-edges` verifica se l'API e' footgun-prone
   - `insecure-defaults` trova config debole → `performing-security-testing` testa l'exploit

### Fase 4: Aggregazione e deduplicazione

1. **Raccogliere tutti i finding** da tutte le skill
2. **Deduplicare** — Stesso file+linea segnalato da skill diverse → unificare
3. **Classificare per severity:**

   | Severity | Definizione | SLA |
   |----------|-------------|-----|
   | **CRITICAL** | Exploit immediato, data breach, auth bypass | Fix prima del deploy |
   | **HIGH** | Vulnerabilita' sfruttabile con effort moderato | Fix entro sprint corrente |
   | **MEDIUM** | Weakness che richiede condizioni specifiche | Fix entro prossimo sprint |
   | **LOW** | Best practice non seguita, hardening | Backlog |
   | **INFO** | Osservazione, suggerimento migliorativo | Opzionale |

4. **Calcolare metriche:**
   - Totale finding per severity
   - Finding per area (API, auth, frontend, DB, config)
   - Skill coverage (quante skill hanno prodotto finding)

### Fase 5: Report aggregato

```markdown
# Security Audit Report — [Scope]
**Data:** [YYYY-MM-DD]
**Profondita':** [Quick / Standard / Deep]
**Pipeline:** [N] skill eseguite su [M] file

## Executive Summary

| Severity | Count | Stato |
|----------|-------|-------|
| CRITICAL | [N] | [Bloccante / Risolto] |
| HIGH | [N] | [Da risolvere] |
| MEDIUM | [N] | [Pianificato] |
| LOW | [N] | [Backlog] |
| INFO | [N] | [Opzionale] |

**Verdetto complessivo:** PASS / CONDITIONAL / FAIL
**GDPR Compliance:** [Stato specifico]

## Finding per Area

### Authentication & Authorization
| # | Severity | Finding | File | Skill | Recommendation |
|---|----------|---------|------|-------|----------------|
| 1 | HIGH | ... | ... | semgrep | ... |

### API Security
[Stessa struttura]

### Data Protection (GDPR)
[Stessa struttura]

### Configuration
[Stessa struttura]

### Frontend Security
[Stessa struttura]

## Pipeline Execution Log

| Step | Skill | Durata | Finding | Status |
|------|-------|--------|---------|--------|
| 1 | semgrep | ... | [N] | Completato |
| 2 | insecure-defaults | ... | [N] | Completato |
| ... |

## Remediation Plan

### Priorita' 1 — CRITICAL (fix immediato)
1. [Finding] → [Fix suggerito] → [File da modificare]

### Priorita' 2 — HIGH (sprint corrente)
1. [Finding] → [Fix suggerito] → [File da modificare]

### Priorita' 3 — MEDIUM (prossimo sprint)
1. [Finding] → [Fix suggerito]

## Metriche Copertura

- **Skill security installate:** [N]
- **Skill eseguite:** [N] ([%])
- **File analizzati:** [N] su [M] totali ([%])
- **Entry point coperti:** [N] su [M]
- **Integrazioni testate:** [Lista integrazioni esterne]
```

### Fase 6: Opzioni post-audit

Dopo il report, offrire all'utente:

1. **Fix automatico** — Per finding LOW/MEDIUM con fix ovvio, applicare direttamente
2. **Salva report** — `docs/SecurityAudit_v[X.Y]_[YYYYMMDD].md`
3. **Crea issue** — Generare task per ogni finding HIGH/CRITICAL
4. **Re-audit** — Dopo le fix, rieseguire solo le skill che avevano trovato problemi

## Regole

- **Discovery SEMPRE a runtime** — Nuove skill security vengono automaticamente incluse
- **Sequenza logica** — Static prima di dynamic (trovare i bug facili prima)
- **Context cascading** — Ogni skill riceve i finding delle precedenti
- **GDPR sempre** — Se l'applicazione gestisce dati personali, includere SEMPRE verifica GDPR compliance
- **Conferma scope** — Mai lanciare audit senza conferma utente sul perimetro
- **Report naming** — Seguire convenzione progetto: `SecurityAudit_v[X.Y]_[YYYYMMDD].md`

## Anti-pattern

- Lanciare tutte le skill in parallelo (perdere il context cascading)
- Ignorare finding duplicati (gonfia le metriche)
- Report senza remediation plan (inutile per il team)
- Saltare skill per "velocita'" (l'audit deve essere completo)
- Non salvare il report (audit senza traccia = audit non fatto)

---

**Versione:** 1.0
**Tipo:** Meta-skill con dynamic discovery + pipeline orchestration
**Dipendenze:** Glob tool, Read tool, Skill tool (per invocare le skill security), AskUserQuestion (per scope)
