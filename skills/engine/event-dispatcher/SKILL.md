---
name: event-dispatcher
description: Use when a SkillOS event fires (skill.invoke, phase.complete, session.start) and pre/post/blocking/auto hooks must be evaluated through the trigger pipeline. Event Layer (L3) core; not invoked directly by users, called by skill-router, phase-gate, session-lifecycle, and init.
type: technique
---

# Event Dispatcher — Event Layer (L3)

Core skill che implementa il sistema eventi. Legge trigger rules da `skill-orch.config.json`, valuta condizioni, ed esegue azioni in ordine di priorita'.

## Architettura

```
Evento emesso → EVENT DISPATCHER → Match rules → Evaluate conditions → Sort by mode/order → Execute chain
                                         |
                         PRE hooks (blocking) → ACTION → POST hooks (non-blocking)
```

## Eventi Standard

| Evento | Emesso da | Payload |
|--------|-----------|---------|
| `session.start` | init | phase, skills_available, config_hash |
| `session.end` | utente / session-reporter | summary, tasks, skills_used |
| `skill.invoke` | skill-router / utente | skill, trigger, context, layer |
| `skill.complete` | post-invocazione | skill, outcome, duration |
| `phase.complete` | utente / phase-gate | phase, gate_score, next_phase |
| `task.start` / `task.complete` | build loop | task_id, description, outcome |
| `error` | qualsiasi skill | skill, error_type, message |
| `checkpoint.request` | utente / auto | description |

Naming: `<dominio>.<azione>` (session, skill, phase, task, checkpoint, error).

## Trigger Rule Schema

```json
{
  "on": "event name to match",
  "condition": "optional expression evaluated on payload",
  "action": "skill.method to execute",
  "mode": "pre | post | blocking | auto | suggest",
  "priority": "number (default 50, lower = first)"
}
```

### Modi di esecuzione

| Mode | Blocca flusso? | Se fallisce |
|------|----------------|------------|
| `pre` | Si | Annulla l'evento |
| `blocking` | Si | Blocca, richiede fix |
| `auto` | No | Warning |
| `post` | No | Warning |
| `suggest` | No | N/A (solo suggerimento) |

### Condizioni

Espressioni semplici sul payload: `skill.layer == 'userland'`, `phase.current >= 3`, `skill.name != 'init'`.
Operatori: `==`, `!=`, `>=`, `<=`, `>`, `<`. Valori: stringhe (apici singoli), numeri, `true`, `false`, `null`.
Proprieta' mancante nel payload → skip con warning (mai errore).

## Dispatch Workflow

Ordine di esecuzione per ogni evento:

1. **Raccogliere** trigger rules dove `on == event_name` e condition soddisfatta
2. **PRE** (priorita' crescente) → se fallisce: annulla evento, return `dispatched: false`
3. **BLOCKING** (priorita' crescente) → se fallisce: blocca, presenta remediation
4. **AZIONE PRINCIPALE** → evento dispatched
5. **AUTO + POST** (priorita' crescente) → se fallisce: warning, continua
6. **SUGGEST** → raccolti e presentati all'utente
7. **Return** risultato con esito per ogni hook + warnings

## Integrazione

| Evento | PRE/BLOCKING | POST |
|--------|-------------|------|
| `skill.invoke` | dependency-checker.verify (se userland) | session-lifecycle.journal-append |
| `phase.complete` | phase-gate.verify (blocking) | session-lifecycle.journal-append |
| `session.start` | — | session-lifecycle.open (auto) |
| `session.end` | session-lifecycle.close (pre) | session-reporter.generate |

Pack e skill custom possono aggiungere trigger rules via frontmatter `skillos.triggers[]`. Regole in config.json hanno precedenza su quelle in SKILL.md.

## Regole

- **Config e' la fonte di verita'** per trigger rules
- **Fail-safe** — se il dispatcher ha un errore, l'evento procede (log warning)
- **Non ricorsivo** — azione triggerata NON emette nuovi eventi (previene loop)
- **Condizioni opzionali** — trigger senza condition matcha SEMPRE
- **Priority default = 50**
- **Nessun side-effect** — il dispatcher non modifica stato, le azioni lo fanno

## Anti-pattern

- Trigger che triggerano altri trigger (loop infiniti)
- Troppi hook pre/blocking sullo stesso evento
- Condizioni complesse con AND/OR (usare piu' trigger semplici)
- mode=blocking per azioni non critiche
- Eventi custom non documentati nel catalogo
