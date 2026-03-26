---
name: phase-gate
version: 2.0.0
description: Dynamic phase completion gate that verifies ALL relevant skills for a workflow phase were actually used. Scans skills/ at runtime (path configurable via skill-orch.config.json), maps skills to phases, and reports coverage gaps. Registered as blocking hook on phase.complete events via event-dispatcher. Use at the end of any development phase to verify completeness.
skillos:
  layer: core
  category: meta
  pack: null
  requires:
    hard: []
    soft: ["event-dispatcher", "project-memory"]
  provides: ["phase-verification", "coverage-check"]
  triggers:
    - on: "phase.complete"
      mode: blocking
      priority: 10
  config: {}
---

# Phase Gate — Dynamic Completion Verification

Meta-skill che verifica a runtime se tutte le skill rilevanti per una fase del workflow sono state effettivamente utilizzate. Previene gap di copertura.

**Contesto:** Workflow di sviluppo a 6 fasi (Fase 0-5), con skill installate per ogni fase.

## Modalita' di invocazione

### Auto-trigger (via event-dispatcher)

Il phase-gate e' registrato come hook `blocking` sull'evento `phase.complete`. L'event-dispatcher lo invoca automaticamente quando si richiede l'avanzamento di fase.

```
Flusso automatico:
1. Utente/workflow dispatcha phase.complete
2. event-dispatcher trova trigger blocking: phase-gate.verify
3. phase-gate.verify(phase_payload)
4. Se PASS → fase avanza, journal registra phase.advance
5. Se FAIL → fase NON avanza, utente riceve report con gap
```

### Invocazione diretta

L'utente puo' invocare direttamente per:
- Verifica anticipata dello stato di copertura mid-fase
- Report di copertura senza effettivamente avanzare la fase
- Analisi gap prima di decidere se completare

## Core Workflow

### Fase 1: Identificare la fase da verificare

1. **Se auto-trigger:** estrarre fase dal payload evento `phase.complete`:
   ```json
   { "phase": 3, "next_phase": 4 }
   ```
2. **Se invocazione diretta:** l'utente indica quale fase verificare
3. **Leggere `.state/state.json`** per la fase corrente e lo storico fasi
4. **Mappa fasi → skill previste** (da skill-orch.config.json `phases[]` + CLAUDE.md):

   | Fase | Nome | Skill previste |
   |------|------|----------------|
   | 0 | PRD Closure | product-closure-loop |
   | 1 | Pianificazione | task-decomposer, git-workflow |
   | 2 | Scaffold | project-scaffolder |
   | 3 | Build Loop | tdd-red-green-refactor, tdd-vertical-slicing, nextjs-developer, next-best-practices, react-best-practices, typescript-pro, postgres-pro, neon-postgres-setup, drizzle-orm-patterns, database-optimizer, api-designer, nextjs-app-router-fundamentals, nextjs-server-client-components, shadcnblocks-components, tremor-design-system, dashboard-builder, frontend-design, frontend-ui-ux, verification-gate, code-reviewer, git-workflow, systematic-debugging, debugging-wizard |
   | 4 | Sicurezza, Red Team & AI | secure-code-guardian, semgrep, performing-security-testing, insecure-defaults, sharp-edges, differential-review, audit-prep-assistant, rag-architect, prompt-engineer |
   | 5 | Deploy & Chiusura | vercel-deploy, product-closure-loop |

### Fase 2: Discovery dinamica — Skill effettivamente disponibili

**Scansionare a runtime, non usare la mappa statica come unica fonte.**

1. **Scansionare `skills/**/SKILL.md`** con Glob
2. **Estrarre frontmatter** (name, description) da ogni SKILL.md
3. **Classificare ogni skill per fase** in base a:
   - Menzione esplicita in CLAUDE.md per la fase
   - Keywords nella description che matchano il dominio della fase
   - Skill nuove non ancora mappate in CLAUDE.md (segnalare come "non assegnate")
4. **Confrontare** mappa CLAUDE.md vs. discovery — identificare discrepanze

### Fase 3: Verificare copertura (`verify` — usato da event-dispatcher)

**Input (se auto-trigger):** Payload dell'evento `phase.complete`
**Fonte dati invocazioni:** Journal della sessione corrente + state.json

Per ogni skill prevista nella fase:

1. **Verificare invocazione** consultando:
   - `.state/journal/session_*.jsonl` — eventi `skill.invoke` e `skill.complete`
   - `.state/state.json.skills.invocation_log` — log recenti
   - Contesto conversazione corrente (fallback se journal non disponibile)
2. **Classificare stato:**
   - **Coperta** — Invocata e outcome=success nel journal
   - **Parziale** — Invocata ma outcome=warning o non completata
   - **Mancante** — Nessuna invocazione trovata
   - **N/A** — Non applicabile per questo specifico task
   - **Nuova** — Skill scoperta via discovery ma non prevista in CLAUDE.md
3. **Calcolare gate_score:**
   ```
   gate_score = (coperte + parziali * 0.5) / (totale - N/A)
   ```

### Fase 4: Gate Decision

**Leggere soglie** da `skill-orch.config.json.gate_thresholds`:
```json
{
  "default": 0.80,
  "security": 1.00,
  "deploy": 1.00
}
```

**Applicare soglia per fase:**
- Fase 0-2: `default` (0.80)
- Fase 3: `default` (0.80)
- Fase 4: `security` (1.00) — ZERO tolleranza
- Fase 5: `deploy` (1.00)

**Verdetto:**
- `gate_score >= soglia` → **PASS**
- `gate_score >= soglia * 0.9` → **CONDITIONAL** (quasi, serve piano)
- `gate_score < soglia * 0.9` → **FAIL**

**Risultato restituito all'event-dispatcher:**
```json
// PASS
{ "outcome": "pass", "gate_score": 0.92, "phase": 3, "verdict": "PASS" }

// FAIL (blocking)
{ "outcome": "block", "gate_score": 0.65, "phase": 4, "verdict": "FAIL", "missing": ["semgrep", "audit-prep-assistant"], "remediation": "Invocare le skill mancanti prima di procedere" }
```

### Fase 5: Report

```markdown
# Phase Gate Report: Fase [N] — [Nome]

## Copertura Skill

| Skill | Stato | Invocazione | Note |
|-------|-------|-------------|------|
| `skill-name` | Coperta | session_20260301_1000 | outcome=success |
| `skill-name` | Mancante | — | Da invocare |
| `skill-name` | N/A | — | Nessun bug → debugging non necessario |

## Metriche

- **Skill previste:** [N]
- **Coperte:** [N] ([%])
- **Parziali:** [N]
- **Mancanti:** [N]
- **N/A:** [N]

## Gate Decision

| Soglia | Valore | Gate Score | Risultato |
|--------|--------|------------|-----------|
| [tipo soglia] | [soglia] | [score] | PASS / FAIL |

## Verdetto: PASS / CONDITIONAL / FAIL

### Se PASS:
Fase [N] completata. Avanzamento a Fase [N+1] — [nome].
Gate score [score] registrato in state.json.

### Se FAIL o CONDITIONAL:
**Azioni richieste:**
1. [Skill mancante] — Invocare prima di procedere
2. [Skill parziale] — Completare

### Skill scoperte non mappate:
- [Skill nuova] — Considerare aggiunta alla mappa fase
```

### Fase 6: Aggiornamento stato (se PASS)

Quando il gate passa:

1. **Aggiornare `.state/state.json`:**
   - `phase.history[]` ← aggiungere fase completata con gate_score
   - `phase.current` ← next_phase
   - `phase.name` ← nome next_phase
   - `phase.started_at` ← now

2. **L'event-dispatcher dispatcha automaticamente:**
   - POST: `session-lifecycle.journal-append` con tipo `phase.advance`

3. **Se `auto_checkpoint_on` include `phase.complete`:**
   - Creare checkpoint automatico via session-lifecycle

## Regole

- **Gate obbligatorio** — Non procedere alla fase successiva senza PASS o CONDITIONAL con piano
- **Fase 4 = zero tolleranza** — Tutte le skill security DEVONO essere coperte
- **Discovery sempre** — Scansionare a runtime, non fidarsi solo della mappa statica
- **Journal come fonte** — Usare il journal per verificare invocazioni
- **Fail-safe** — Se journal non leggibile, fallback a conversazione + warning
- **Segnalare skill orfane** — Skill installate ma non mappate a nessuna fase
- **Non bloccare per N/A** — Se una skill non e' applicabile, classificarla N/A con motivazione

## Anti-pattern

- Marcare skill come "Coperta" senza evidenza nel journal
- Saltare il gate per "fretta"
- Ignorare skill scoperte via discovery ma non in CLAUDE.md
- Applicare le stesse soglie a tutte le fasi
- Avanzare fase senza aggiornare state.json

---

**Versione:** 2.0.0 (Fase C — Event Layer integration)
**Tipo:** Core meta-skill con dynamic discovery + event-dispatcher blocking hook
**Dipendenze:** Glob tool, Read tool, AskUserQuestion, .state/state.json, .state/journal/, skill-orch.config.json
**Si integra con:** event-dispatcher (blocking hook), skill-router, session-lifecycle, dependency-checker
**Sostituisce:** phase-completion-checklist (mantenuta come fallback statico)
**Changelog:**
- v1.0: Gate statico con discovery e report
- v2.0: Blocking hook per event-dispatcher, journal-based verification, gate_score in state.json, auto-checkpoint, gate_score formula
