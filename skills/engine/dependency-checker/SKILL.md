---
name: dependency-checker
version: 2.0.0
description: Verifies that prerequisite skills have been executed before dependent ones. Maintains a dependency graph between skills and checks execution order at runtime. Scans skills/ to discover skills and their relationships (path configurable via skill-orch.config.json). Can be invoked directly or auto-triggered via event-dispatcher on skill.invoke events. Use during build loops to ensure correct workflow sequencing.
skillos:
  layer: core
  category: meta
  pack: null
  requires:
    hard: []
    soft: []
  provides: ["dependency-verification", "execution-order-check"]
  triggers:
    - on: "skill.invoke"
      condition: "skill.layer == 'userland'"
      mode: pre
      priority: 10
  config: {}
---

# Dependency Checker — Skill Execution Order Validator

Meta-skill che verifica che le skill siano state eseguite nell'ordine corretto, rispettando le dipendenze tra di loro.

**Contesto:** Workflow a 6 fasi con 75+ skill, alcune hanno dipendenze strette.

## Modalita' di invocazione

### Auto-trigger (via event-dispatcher)

Il dependency-checker e' registrato come hook `pre` sull'evento `skill.invoke` quando `skill.layer == 'userland'`. L'event-dispatcher lo invoca automaticamente prima di ogni skill di dominio.

```
Flusso automatico:
1. skill-router dispatcha skill.invoke
2. event-dispatcher trova trigger pre: dependency-checker.verify
3. dependency-checker.verify(skill_payload)
4. Se PASS → skill viene invocata
5. Se BLOCK → skill NON viene invocata, utente informato
```

### Invocazione diretta

L'utente o un'altra skill puo' invocarlo direttamente per:
- Verificare un intero piano di esecuzione prima di iniziare
- Report completo delle dipendenze dopo un blocco di lavoro
- Debugging dell'ordine di esecuzione

## Core Workflow

### Fase 1: Discovery — Costruire grafo dipendenze

1. **Scansionare `skills/**/SKILL.md`** con Glob
2. **Estrarre frontmatter** (name, description, skillos.requires)
3. **Costruire grafo da:**
   - Campo `skillos.requires.hard[]` e `skillos.requires.soft[]` nel frontmatter
   - Workflow definito in CLAUDE.md (Fasi 0-5)
   - Regole hardcoded di fallback (sotto)

4. **Grafo dipendenze predefinito (dal workflow CLAUDE.md):**

   ```
   research-before-scaffold → project-scaffolder → [build loop]
   task-decomposer → project-scaffolder → [build loop]

   Build loop per task:
   tdd-red-green-refactor ──→ [implementazione] ──→ verification-gate ──→ code-reviewer ──→ git-workflow
       │                                                │
       └── tdd-vertical-slicing (opzionale)             └── Se fallisce: systematic-debugging → skill-postmortem (opzionale) → retry

   Security pipeline:
   threat-modeler → audit-coordinator → [skill security in sequenza]

   Meta-skill:
   skill-router → [qualsiasi skill]
   sprint-planner → [build loop]
   phase-gate → [fine fase]

   Memory & improvement:
   skill-postmortem → skill-retrospective (input per friction analysis)
   context-persistence → session-reporter (input per report)
   ```

5. **Arricchire con discovery** — Nuove skill con `skillos.requires` vengono aggiunte al grafo automaticamente

### Fase 2: Definire regole di dipendenza

| Regola | Tipo | Descrizione |
|--------|------|-------------|
| **HARD** | Bloccante | La skill B NON PUO' essere eseguita prima della skill A |
| **SOFT** | Consigliata | La skill B DOVREBBE essere eseguita dopo A, ma non e' bloccante |
| **MUTEX** | Mutuamente esclusiva | Le skill A e B non dovrebbero essere usate insieme |

#### Regole HARD (bloccanti)

| Prerequisito | Dipendente | Motivo |
|-------------|-----------|--------|
| `tdd-red-green-refactor` o `tdd-vertical-slicing` | Implementazione | Test-first e' obbligatorio |
| Implementazione | `verification-gate` | Non verificare prima di implementare |
| `verification-gate` | `code-reviewer` | Verificare prima di fare review |
| `code-reviewer` | `git-workflow` (commit) | Review prima di committare |
| `task-decomposer` | `sprint-planner` | Decomporre prima di pianificare sprint |
| `threat-modeler` | `audit-coordinator` | Threat model prima di audit |
| `secure-code-guardian` | `audit-prep-assistant` | Fix OWASP prima di preparare audit formale |

#### Regole SOFT (consigliate)

| Prerequisito | Dipendente | Motivo |
|-------------|-----------|--------|
| `skill-router` | Qualsiasi skill | Router aiuta a scegliere la skill giusta |
| `semgrep` | `performing-security-testing` | Static prima di dynamic |
| `insecure-defaults` | `sharp-edges` | Config prima di API |
| `sprint-planner` | Build loop | Pianificare prima di costruire |
| `research-before-scaffold` | `project-scaffolder` | Ricerca best practice prima di scaffoldare |
| `skill-postmortem` | `skill-retrospective` | Postmortem specifico prima della retrospective |
| `context-persistence` | `session-reporter` | Notes di sessione come input per il report |

#### Regole MUTEX

| Skill A | Skill B | Motivo |
|---------|---------|--------|
| `tdd-red-green-refactor` | `tdd-vertical-slicing` | Scegliere uno dei due, non entrambi per lo stesso task |

### Fase 3: Verifica (`verify` — usato da event-dispatcher)

Questa e' la funzione chiamata come PRE-hook dall'event-dispatcher.

**Input:** Payload dell'evento `skill.invoke`:
```json
{
  "skill": "nome-skill-da-invocare",
  "layer": "userland",
  "trigger": "user",
  "context": "..."
}
```

**Workflow verify:**

1. **Leggere storico invocazioni dalla sessione corrente:**
   - Da `.state/state.json.skills.invocation_log` (sessione corrente)
   - Dal journal corrente (`.state/journal/session_*.jsonl`): tutti eventi `skill.invoke`

2. **Controllare prerequisiti HARD:**
   - La skill da invocare ha prerequisiti HARD?
   - Sono stati soddisfatti (skill prerequisita gia' invocata nella sessione)?
   - Se NO: restituire `{ outcome: "block", reason: "...", missing: [...] }`

3. **Controllare prerequisiti SOFT:**
   - La skill ha prerequisiti SOFT?
   - Se non soddisfatti: aggiungere warning (non blocca)

4. **Controllare MUTEX:**
   - La skill e' in conflitto con una gia' invocata?
   - Se SI: warning (non blocca, ma segnala)

5. **Restituire risultato:**
   ```json
   // PASS
   { "outcome": "pass", "warnings": [] }

   // BLOCK
   { "outcome": "block", "reason": "Prerequisito HARD mancante", "missing": ["tdd-red-green-refactor"], "remediation": "Invocare tdd-red-green-refactor prima di procedere" }

   // WARN
   { "outcome": "pass", "warnings": [{ "type": "soft", "missing": "semgrep", "suggestion": "Consigliato static analysis prima" }] }
   ```

### Fase 4: Report completo (invocazione diretta)

Se invocato direttamente (non come pre-hook), produce un report completo:

```markdown
# Dependency Check Report
**Sessione:** [session_id da state.json]
**Skill verificate:** [N]

## Ordine di esecuzione

| # | Skill | Prerequisiti | Stato |
|---|-------|-------------|-------|
| 1 | task-decomposer | — | OK |
| 2 | sprint-planner | task-decomposer | OK |
| 3 | tdd-red-green-refactor | — | OK |
| 4 | nextjs-developer | tdd-red-green-refactor | OK |
| 5 | git-workflow | verification-gate, code-reviewer | BLOCK — mancano verification-gate e code-reviewer |

## Violazioni

### BLOCK (da correggere)
| Skill | Prerequisito mancante | Azione |
|-------|-----------------------|--------|
| `git-workflow` | `verification-gate` | Eseguire verification-gate prima del commit |

### WARN (consigliate)
| Skill | Prerequisito suggerito | Azione |
|-------|-----------------------|--------|
| `performing-security-testing` | `semgrep` | Consigliato: static analysis prima di dynamic |

### MUTEX (conflitti)
Nessun conflitto rilevato.

## Verdetto: PASS / BLOCK
```

## Regole

- **HARD = bloccante** — Non procedere se una regola HARD e' violata
- **SOFT = warning** — Segnalare ma non bloccare
- **Discovery sempre** — Nuove skill con `skillos.requires` vengono integrate nel grafo
- **Non rallentare** — Il check deve essere veloce (solo lettura)
- **Fail-safe** — Se il checker non riesce a leggere il journal, PASS con warning (non bloccare il workflow)
- **Sessione-scoped** — Le verifiche considerano solo le invocazioni della sessione corrente

## Anti-pattern

- Ignorare violazioni BLOCK "per fretta"
- Aggiungere troppe regole HARD (rallenta il workflow)
- Non aggiornare il grafo quando si aggiungono nuove skill
- Usare come sostituto di phase-gate (sono complementari)
- Bloccare su regole SOFT (devono restare consigliate)

---

**Versione:** 2.0.0 (Fase C — Event Layer integration)
**Tipo:** Core meta-skill con dynamic discovery + event-dispatcher hook
**Dipendenze:** Glob tool, Read tool, .state/state.json, .state/journal/
**Si integra con:** event-dispatcher (come pre-hook), phase-gate, sprint-planner, skill-router
**Changelog:**
- v1.1: Nuove dipendenze research-before-scaffold, skill-postmortem, context-persistence
- v2.0: Funzione verify() come pre-hook per event-dispatcher, lettura journal per storico sessione, skillos.requires nel frontmatter
