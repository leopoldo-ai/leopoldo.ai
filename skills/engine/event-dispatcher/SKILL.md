---
name: event-dispatcher
version: 1.0.0
description: Event Layer (L3) core — dispatches events through the trigger pipeline defined in skill-orch.config.json. Evaluates conditions, executes pre/post/blocking/auto hooks, and orchestrates the middleware chain. Every event in SkillOS flows through this dispatcher. Not invoked directly by users — called by skill-router, phase-gate, session-lifecycle, and init.
skillos:
  layer: core
  category: meta
  pack: null
  requires:
    hard: []
    soft: []
  provides: ["event-dispatch", "trigger-evaluation", "middleware-chain"]
  triggers: []
  config: {}
---

# Event Dispatcher — SkillOS Event Layer (L3)

Core skill che implementa il sistema eventi di SkillOS. Legge le trigger rules da `skill-orch.config.json`, valuta condizioni, ed esegue le azioni associate in ordine di priorita'.

## Perche' esiste

| Problema | Soluzione |
|----------|-----------|
| Trigger rules in config ma nessuno le esegue | Dispatcher come punto centrale di esecuzione |
| Skill devono chiamarsi manualmente a vicenda | Eventi disaccoppiano emittente da ricevente |
| dependency-checker e phase-gate sono manuali | Auto-trigger li invoca al momento giusto |
| Nessuna garanzia che le azioni pre/post vengano eseguite | Middleware chain con ordine garantito |

## Architettura

```
                    ┌─────────────────────────┐
   Evento emesso    │    EVENT DISPATCHER      │
   ─────────────►   │                         │
                    │  1. Match trigger rules  │
                    │  2. Evaluate conditions  │
                    │  3. Sort by mode/order   │
                    │  4. Execute chain        │
                    │                         │
                    └─────┬───────────────────┘
                          │
              ┌───────────┼───────────────┐
              ▼           ▼               ▼
          PRE hooks    ACTION         POST hooks
         (blocking)   (esecuzione    (non-blocking)
                      skill/azione)
```

## Eventi SkillOS

### Catalogo eventi standard

| Evento | Emesso da | Payload |
|--------|-----------|---------|
| `session.start` | init | `{ phase, skills_available, config_hash }` |
| `session.end` | utente / session-reporter | `{ summary, tasks, skills_used }` |
| `skill.invoke` | skill-router / utente | `{ skill, trigger, context, layer }` |
| `skill.complete` | post-invocazione | `{ skill, outcome, duration }` |
| `phase.complete` | utente / phase-gate | `{ phase, gate_score, next_phase }` |
| `task.start` | build loop | `{ task_id, description }` |
| `task.complete` | build loop | `{ task_id, outcome }` |
| `error` | qualsiasi skill | `{ skill, error_type, message }` |
| `checkpoint.request` | utente / auto | `{ description }` |

### Convenzione nomi

```
<dominio>.<azione>

dominio: session | skill | phase | task | checkpoint | error
azione:  start | end | invoke | complete | request | advance
```

## Trigger Rule Schema

Trigger rules lette da `skill-orch.config.json.triggers[]`:

```json
{
  "on": "string — nome evento da matchare",
  "condition": "string | null — espressione condizionale (opzionale)",
  "action": "string — skill.metodo o azione da eseguire",
  "mode": "pre | post | blocking | auto | suggest",
  "priority": "number (opzionale, default 50) — ordine esecuzione (1=prima)",
  "description": "string — descrizione leggibile"
}
```

### Modi di esecuzione

| Mode | Comportamento | Blocca flusso? | Fallimento |
|------|--------------|----------------|------------|
| `pre` | Eseguito PRIMA dell'evento/azione | Si | Annulla l'evento |
| `post` | Eseguito DOPO l'evento/azione | No | Warning, non blocca |
| `blocking` | Eseguito e DEVE passare per proseguire | Si | Blocca, richiede fix |
| `auto` | Eseguito automaticamente senza conferma utente | No | Warning |
| `suggest` | Suggerisce all'utente, non esegue | No | N/A |

### Valutazione condizioni

Le condizioni sono espressioni semplici valutate sul payload dell'evento:

```
skill.layer == 'userland'     → verifica proprieta' del payload
phase.current >= 3            → confronto numerico
skill.name != 'init'          → negazione
```

**Operatori supportati:** `==`, `!=`, `>=`, `<=`, `>`, `<`
**Valori:** stringhe (tra apici singoli), numeri, `true`, `false`, `null`

**Regola di sicurezza:** Se la condizione non puo' essere valutata (proprieta' mancante nel payload), la trigger rule viene SKIPPATA con warning — mai errore.

## Dispatch Workflow

### 1. `dispatch(event_name, payload)` — Dispatcha un evento

**Workflow completo:**

#### Step 1: Raccogliere trigger rules applicabili

```
1. Leggere skill-orch.config.json.triggers[]
2. Filtrare: trigger.on == event_name
3. Per ogni trigger con condition:
   - Valutare condition sul payload
   - Se condition == false: skip
   - Se condition non valutabile: skip + warning
4. Risultato: lista trigger attive
```

#### Step 2: Ordinare per priorita' e mode

```
Ordine di esecuzione:
1. mode=pre      (priorita' crescente → priority 1 prima di priority 50)
2. mode=blocking (priorita' crescente)
3. [EVENTO/AZIONE PRINCIPALE]
4. mode=auto     (priorita' crescente)
5. mode=post     (priorita' crescente)
6. mode=suggest  (raccolti e presentati, non eseguiti)
```

#### Step 3: Eseguire catena PRE

```
Per ogni trigger mode=pre (in ordine di priorita'):
  1. Invocare action (es. dependency-checker.verify)
  2. Se outcome = success: proseguire
  3. Se outcome = fail:
     - WARNING all'utente: "[action] ha fallito: [motivo]"
     - ANNULLARE l'evento (non eseguire azione principale)
     - Restituire { dispatched: false, blocked_by: action, reason: motivo }
```

#### Step 4: Eseguire catena BLOCKING

```
Per ogni trigger mode=blocking (in ordine di priorita'):
  1. Invocare action
  2. Se outcome = success: proseguire
  3. Se outcome = fail:
     - BLOCCARE: "[action] richiede correzione: [motivo]"
     - Presentare azioni correttive all'utente
     - Restituire { dispatched: false, blocked_by: action, reason: motivo, remediation: [...] }
```

#### Step 5: Eseguire azione principale

```
L'evento e' considerato "dispatched" — l'azione originale procede.
```

#### Step 6: Eseguire catena POST + AUTO

```
Per ogni trigger mode=auto, poi mode=post (in ordine di priorita'):
  1. Invocare action
  2. Se outcome = success: proseguire
  3. Se outcome = fail:
     - WARNING (non blocca): "[action] post-hook fallito: [motivo]"
     - Continuare con le successive
```

#### Step 7: Raccogliere suggerimenti

```
Per ogni trigger mode=suggest:
  1. Raccogliere: { action, description }
  2. Presentare all'utente come suggerimenti opzionali
```

#### Step 8: Restituire risultato

```json
{
  "dispatched": true,
  "event": "skill.invoke",
  "pre_hooks": [{ "action": "...", "outcome": "success" }],
  "blocking_hooks": [],
  "post_hooks": [{ "action": "...", "outcome": "success" }],
  "suggestions": [{ "action": "...", "description": "..." }],
  "warnings": []
}
```

## Integrazione con le skill core

### skill-router (emette `skill.invoke`)

```
Quando skill-router identifica la skill da invocare:

1. Router chiama: dispatch("skill.invoke", { skill, layer, trigger, context })
2. Dispatcher esegue:
   - PRE: dependency-checker.verify (se layer == 'userland')
   - [INVOCAZIONE SKILL]
   - POST: session-lifecycle.journal-append
3. Se dependency-checker blocca: skill NON viene invocata
```

### phase-gate (consuma e emette `phase.complete`)

```
Quando l'utente chiede di completare una fase:

1. Utente/workflow chiama: dispatch("phase.complete", { phase, gate_score })
2. Dispatcher esegue:
   - BLOCKING: phase-gate.verify
   - [AVANZAMENTO FASE]
   - POST: session-lifecycle.journal-append
3. Se phase-gate.verify fallisce: fase NON avanza
```

### init (emette `session.start`)

```
Durante il boot:

1. Init chiama: dispatch("session.start", { phase, skills_available, config_hash })
2. Dispatcher esegue:
   - AUTO: session-lifecycle.open
   - [SESSIONE APERTA]
```

### session-reporter (emette `session.end`)

```
A fine sessione:

1. Reporter chiama: dispatch("session.end", { summary, tasks, skills_used })
2. Dispatcher esegue:
   - PRE: session-lifecycle.close (chiude journal e aggiorna state)
   - [SESSIONE CHIUSA]
   - POST: session-reporter.generate
```

## Trigger rules di default (in skill-orch.config.json)

```json
[
  {
    "on": "session.start",
    "action": "session-lifecycle.open",
    "mode": "auto",
    "priority": 10
  },
  {
    "on": "skill.invoke",
    "condition": "skill.layer == 'userland'",
    "action": "dependency-checker.verify",
    "mode": "pre",
    "priority": 10
  },
  {
    "on": "skill.invoke",
    "action": "session-lifecycle.journal-append",
    "mode": "post",
    "priority": 90
  },
  {
    "on": "phase.complete",
    "action": "phase-gate.verify",
    "mode": "blocking",
    "priority": 10
  },
  {
    "on": "phase.complete",
    "action": "session-lifecycle.journal-append",
    "mode": "post",
    "priority": 90
  },
  {
    "on": "session.end",
    "action": "session-lifecycle.close",
    "mode": "pre",
    "priority": 10
  },
  {
    "on": "session.end",
    "action": "session-reporter.generate",
    "mode": "post",
    "priority": 50
  }
]
```

## Aggiungere nuove trigger rules

I pack e le skill custom possono aggiungere trigger rules dichiarando nel frontmatter SKILL.md:

```yaml
skillos:
  triggers:
    - on: "task.complete"
      mode: suggest
      description: "Suggerisce code review dopo ogni task"
```

Il dispatcher le scopre durante il boot (init) e le merge con quelle in skill-orch.config.json. Le regole in config hanno priorita' sulle regole in SKILL.md (config vince in caso di conflitto).

## Regole

- **Config e' la fonte di verita'** — Le trigger rules in skill-orch.config.json hanno precedenza
- **Fail-safe** — Se il dispatcher stesso ha un errore, l'evento procede comunque (log warning)
- **Non ricorsivo** — Un'azione triggerata NON emette nuovi eventi (previene loop infiniti)
- **Condizioni opzionali** — Trigger senza condition matchano SEMPRE l'evento
- **Priority default = 50** — Se non specificata
- **Nessun side-effect** — Il dispatcher non modifica stato, le azioni lo fanno

## Anti-pattern

- Trigger rules che triggerano altri trigger (loop infiniti)
- Troppi hook pre/blocking sullo stesso evento (rallenta tutto)
- Condizioni complesse con AND/OR (mantenere semplici, usare piu' trigger)
- Usare mode=blocking per azioni non critiche
- Dispatch di eventi custom senza documentarli nel catalogo

---

**Versione:** 1.0.0
**Tipo:** Core skill (L3 — Event Layer)
**Dipendenze:** Read tool (per leggere skill-orch.config.json), session-lifecycle (per journaling)
**Si integra con:** skill-router, init, phase-gate, session-lifecycle, session-reporter
