---
name: doc-gate
version: 1.0.0
description: Documentation freshness gate. Verifies that plan, MEMORY.md, and project docs are up-to-date relative to completed work. Triggered automatically every 3 tasks or as POST hook on verification-gate. Blocks next task if docs are stale.
skillos:
  layer: core
  category: enforcement
  pack: null
  requires:
    hard: []
    soft: ["verification-gate", "session-lifecycle"]
  provides: ["doc-enforcement", "checkpoint-verification"]
  triggers:
    - on: "checkpoint.due"
      mode: blocking
      priority: 5
    - on: "task.complete"
      mode: auto
      priority: 20
  config:
    checkpoint_interval: 3
    max_staleness_tasks: 5
---

# Doc Gate — Documentation Freshness Enforcement

Skill di enforcement che verifica la freschezza della documentazione rispetto al lavoro svolto. Previene la deriva documentale nelle sessioni lunghe.

## Problema che risolve

In sessioni lunghe (10+ task), Claude ottimizza per il codice e sacrifica tutto il resto: documentazione, memory, piani di lavoro. Questo rende il lavoro non tracciabile e le sessioni successive partono senza contesto.

**Caso reale:** In una sessione T4U_APP con `workflow-discipline`, `verification-gate`, `doc-sync` installate, nessuna di queste skill e' stata invocata. 8+ fix completati senza mai aggiornare il piano ne' MEMORY.md.

## Quando si attiva

1. **Ogni N task completati** (default: 3) — conteggio basato su `task.complete` events nel journal
2. **Come POST hook su `verification-gate`** — dopo ogni verifica di completamento
3. **Su invocazione diretta** — `skill-orch invoke-start doc-gate`

## Workflow

### Step 1: Conta task completati dall'ultimo checkpoint

```
Leggi .state/journal/YYYY-MM-DD.jsonl
Conta eventi {"type": "task.complete"} dall'ultimo {"type": "checkpoint.done"}
Se count < checkpoint_interval → EXIT OK (non ancora dovuto)
Se count >= checkpoint_interval → PROCEDI a Step 2
```

### Step 2: Verifica freschezza documenti

Controlla 3 asset documentali:

| Asset | Come verificare | Criterio "fresco" |
|-------|----------------|-------------------|
| **Piano di lavoro** | Cerca file `piano-*.md`, `plan-*.md`, `TODO.md`, o todo list attiva | Modificato dopo l'ultimo task completato |
| **MEMORY.md** | Controlla `MEMORY.md` nella root o in `.claude/` | Modificato dopo l'ultimo task completato |
| **Docs di progetto** | File in `docs/` o `docs/` referenziati nel piano | Coerenti con lo stato attuale del codice |

### Step 3: Emetti verdetto

```
Se TUTTI freschi:
  → Log {"type": "checkpoint.done"} nel journal
  → EXIT OK — "Checkpoint superato. Procedi."

Se QUALCUNO stale:
  → Elenca i documenti da aggiornare
  → BLOCCA — "Aggiorna i seguenti documenti PRIMA di procedere al prossimo task:"
  → Lista documenti stale con istruzioni specifiche
  → NON procedere finche' i documenti non sono aggiornati
```

## Output format

### Checkpoint superato

```
[doc-gate] Checkpoint (task 3/3) ✅
  Piano:    aggiornato (2 min fa)
  MEMORY:   aggiornato (5 min fa)
  Docs:     coerenti
  → Procedi al prossimo task.
```

### Checkpoint fallito (BLOCCANTE)

```
[doc-gate] Checkpoint (task 3/3) ❌ BLOCCATO
  Piano:    ⚠️ STALE — ultimo aggiornamento 5 task fa
  MEMORY:   ⚠️ STALE — non aggiornato in questa sessione
  Docs:     ✅ OK

  ⛔ AZIONE RICHIESTA prima di procedere:
  1. Aggiorna il piano di lavoro con lo stato dei task completati
  2. Aggiorna MEMORY.md con decisioni e pattern emersi

  Dopo l'aggiornamento, ri-esegui doc-gate per sbloccare.
```

## Integrazione con hook system

Il `hook-post` di skill-orch traccia ogni tool call. Il doc-gate usa questi dati per:

1. **Contare i task** — ogni sequenza Edit → verification-gate = 1 task
2. **Verificare timestamps** — confronta timestamp dell'ultimo Edit su docs vs ultimo task.complete
3. **Emettere reminder** — dopo N Edit senza doc update, il hook-post emette un warning visibile

## Regole

1. **Mai silenziare il gate** — se il checkpoint e' dovuto, DEVE essere eseguito
2. **Mai procedere se bloccato** — il prossimo task e' VIETATO finche' i docs non sono aggiornati
3. **Il gate si resetta dopo il checkpoint** — completato il checkpoint, il contatore riparte da 0
4. **Sessioni corte (< 3 task) sono esenti** — il gate non si attiva se non si raggiunge la soglia

## Anti-pattern

| Pattern | Perche' e' sbagliato |
|---------|---------------------|
| "Aggiorno i docs alla fine della sessione" | La sessione potrebbe essere troncata per context window |
| "I docs sono gia' abbastanza aggiornati" | Senza verifica, non puoi saperlo |
| "Questo task e' piccolo, non serve checkpoint" | Il contatore non distingue task grandi e piccoli |
| "Faccio prima questo fix urgente" | L'urgenza non giustifica saltare il checkpoint |
