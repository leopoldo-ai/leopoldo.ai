---
name: threat-modeler
version: 0.2.0
description: Use when planning security for a new module, building threat models (STRIDE, attack trees), or preparing to run audit-coordinator. Maps threats to available defenses, scans skills/ to identify which security analyses can run, and produces a prioritized threat matrix with recommended skill invocations.
type: technique
---

# Threat Modeler — STRIDE + Dynamic Skill Mapping

Meta-skill che genera threat model specifici per il codebase e mappa ogni minaccia alle skill di difesa disponibili nel progetto.

**Contesto:** Applicazione web con dati personali (GDPR), API esterne, autenticazione multi-ruolo.

## Core Workflow

### Fase 1: Discovery — Asset e superficie d'attacco

1. **Scansionare il codebase** (se esistente):
   - API routes: `Glob: src/app/api/**/route.ts`
   - Middleware: `Glob: src/middleware.ts`
   - Auth: `Grep: auth|session|token|cookie|jwt`
   - DB schema: `Glob: src/db/**/*.ts` o `drizzle/**/*.ts`
   - Integrazioni esterne: `Grep: fetch|axios|api\.|webhook`
   - Form/input utente: `Grep: useForm|FormData|searchParams|input`
2. **Se codebase non ancora creato**, usare il PRD (cercare in `docs/`) per identificare:
   - Moduli pianificati
   - Flussi dati
   - Ruoli utente
   - Integrazioni

### Fase 2: Discovery — Skill security disponibili

1. **Scansionare `skills/**/SKILL.md`**
2. **Filtrare skill security** (stesse keyword di `audit-coordinator`):
   `security`, `audit`, `vulnerability`, `OWASP`, `pen test`, `static analysis`, `insecure`, `threat`, `review`, `sharp-edges`, `secrets`
3. **Costruire mappa difese disponibili:**
   ```
   defenses = {
     "static_analysis": ["semgrep"],
     "config_audit": ["insecure-defaults"],
     "api_review": ["sharp-edges", "secure-code-guardian"],
     "pr_review": ["differential-review"],
     "dynamic_test": ["performing-security-testing"],
     "audit_prep": ["audit-prep-assistant"],
     "code_quality": ["code-reviewer"]
   }
   ```

### Fase 3: Analisi STRIDE

Per ogni asset identificato, applicare il framework STRIDE:

| Categoria | Domanda | Esempio |
|-----------|---------|---------|
| **S**poofing | Chi puo' impersonare un utente legittimo? | Token JWT rubato, session hijacking |
| **T**ampering | Cosa puo' essere modificato senza autorizzazione? | Dati utente, score, configurazioni servizi esterni |
| **R**epudiation | Quali azioni non sono tracciate? | Modifiche DB senza audit log, email inviate |
| **I**nformation Disclosure | Quali dati possono essere esposti? | PII utenti, credenziali API, dati sensibili |
| **D**enial of Service | Cosa puo' essere reso non disponibile? | API rate limiting, connection pool DB |
| **E**levation of Privilege | Chi puo' ottenere accesso non autorizzato? | Ruolo admin, accesso cross-tenant |

### Fase 4: Attack Trees

Per ogni minaccia STRIDE ad alta severita', costruire un attack tree:

```
[Obiettivo attaccante]
├── [Metodo 1]
│   ├── [Prerequisito 1.1] → Difesa: [skill]
│   └── [Prerequisito 1.2] → Difesa: [skill]
├── [Metodo 2]
│   └── [Prerequisito 2.1] → Difesa: [skill]
└── [Metodo 3] → Nessuna difesa disponibile → GAP
```

### Fase 5: Threat Matrix

Produrre la matrice finale:

```markdown
# Threat Model: [Modulo/Scope]
**Data:** [YYYY-MM-DD]
**Metodologia:** STRIDE + Attack Trees
**Asset analizzati:** [N]

## Executive Summary

| Categoria STRIDE | Minacce | Critiche | Coperte | Gap |
|-----------------|---------|----------|---------|-----|
| Spoofing | [N] | [N] | [N] | [N] |
| Tampering | [N] | [N] | [N] | [N] |
| Repudiation | [N] | [N] | [N] | [N] |
| Info Disclosure | [N] | [N] | [N] | [N] |
| DoS | [N] | [N] | [N] | [N] |
| Elev. Privilege | [N] | [N] | [N] | [N] |

## Threat Register

| ID | Asset | STRIDE | Minaccia | Severita' | Skill difesa | Stato |
|----|-------|--------|----------|-----------|-------------|-------|
| T-001 | API /candidates | I | SQL injection espone PII | CRITICAL | semgrep, performing-security-testing | Coperta |
| T-002 | Auth middleware | S | JWT non validato | HIGH | secure-code-guardian, sharp-edges | Coperta |
| T-003 | Audit log | R | Nessun logging azioni admin | MEDIUM | — | GAP |

## Gap Analysis

### Minacce senza difesa skill
| ID | Minaccia | Skill necessaria | Disponibile? | Azione |
|----|----------|-----------------|-------------|--------|
| T-003 | No audit logging | monitoring-observability | No (non installata) | Installare o implementare manualmente |

### Raccomandazioni
1. **Installare skill mancanti** per coprire gap
2. **Priorita' audit-coordinator** — Lanciare sulle minacce CRITICAL prima
3. **GDPR specifico** — Verificare data retention, consent management, right to deletion

## Attack Trees (top 3 minacce critiche)

### T-001: SQL Injection su /candidates
[Attack tree dettagliato]

## Mapping Minacce → Skill Pipeline

| Priorita' | Minacce | Skill da invocare | Ordine |
|-----------|---------|-------------------|--------|
| P0 | T-001, T-002 | semgrep → secure-code-guardian → performing-security-testing | 1 |
| P1 | T-004, T-005 | insecure-defaults → sharp-edges | 2 |
| P2 | T-003 | (manuale) | 3 |

**Nota:** Usare `audit-coordinator` per eseguire la pipeline in ordine.
```

## Regole

- **STRIDE completo** — Analizzare TUTTE e 6 le categorie, non solo le ovvie
- **Discovery prima** — Mappare difese disponibili PRIMA di identificare gap
- **GDPR sempre** — Se l'applicazione gestisce dati personali, Information Disclosure include SEMPRE PII utenti
- **Gap espliciti** — Segnalare CHIARAMENTE dove non ci sono skill per coprire una minaccia
- **Collegamento audit-coordinator** — Il threat model alimenta la pipeline di audit

## Anti-pattern

- Threat model generico (deve essere specifico per il codebase/PRD)
- Ignorare Repudiation e DoS (spesso sottovalutati)
- Non mappare minacce a skill (threat model inutile senza piano d'azione)
- Assumere che tutte le minacce siano coperte (identificare i gap e' il valore principale)

---

**Versione:** 1.0
**Tipo:** Meta-skill con dynamic discovery
**Dipendenze:** Glob tool, Read tool, Grep tool (per scansione codebase)
**Si integra con:** audit-coordinator (output di threat-modeler → input di audit-coordinator)
