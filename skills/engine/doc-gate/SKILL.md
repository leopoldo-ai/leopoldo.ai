---
name: doc-gate
version: 1.0.0
description: "Use every 3 tasks, as POST hook on verification-gate, or before starting the next task when plan, MEMORY.md, and project docs must be verified fresh relative to completed work. Documentation freshness gate: blocks next task if docs are stale."
type: discipline
---

# Doc Gate — Documentation Freshness Enforcement

Verifica la freschezza della documentazione rispetto al lavoro svolto. Previene deriva documentale nelle sessioni lunghe.

**Problema:** in sessioni lunghe (10+ task), Claude ottimizza per il codice e sacrifica documentazione, memory, piani. Rende il lavoro non tracciabile.

## Quando si attiva

1. **Ogni N task completati** (default: 3) — conteggio da `task.complete` events nel journal
2. **POST hook su verification-gate** — dopo ogni verifica di completamento
3. **Invocazione diretta**

## Workflow

### 1. Conta task dall'ultimo checkpoint

Leggere journal, contare `task.complete` dall'ultimo `checkpoint.done`. Se count < 3 → EXIT OK. Se count >= 3 → Step 2.

### 2. Verifica freschezza

| Asset | Come verificare | Criterio "fresco" |
|---|---|---|
| Piano di lavoro | `piano-*.md`, `plan-*.md`, `TODO.md` | Modificato dopo ultimo task completato |
| MEMORY.md | Root o `.claude/` | Modificato dopo ultimo task completato |
| Docs progetto | File in `docs/` | Coerenti con stato codice |

### 3. Verdetto

- **Tutti freschi:** log `checkpoint.done` → EXIT OK
- **Qualcuno stale:** elenca documenti da aggiornare → **BLOCCA** — aggiornare PRIMA di procedere

## Rules

1. **Mai silenziare il gate** — se dovuto, DEVE essere eseguito
2. **Mai procedere se bloccato** — prossimo task VIETATO finche' docs aggiornati
3. **Reset dopo checkpoint** — contatore riparte da 0
4. **Sessioni corte (< 3 task) esenti**

## Anti-pattern

| Pattern | Perche' sbagliato |
|---|---|
| "Aggiorno alla fine della sessione" | Sessione potrebbe essere troncata |
| "I docs sono abbastanza aggiornati" | Senza verifica, non puoi saperlo |
| "Task piccolo, non serve checkpoint" | Contatore non distingue grandezza |
| "Fix urgente prima" | Urgenza non giustifica saltare |

## Rationalizations — STOP

| Excuse | Reality |
|---|---|
| "Il piano non è cambiato davvero" | Se task.complete è stato loggato, VERIFICA il timestamp |
| "MEMORY.md era aggiornato ieri" | Freschezza = dopo l'ultimo task, non ieri |
| "Aggiorno solo al commit finale" | Gate blocca PRIMA del commit. No scappatoie |
| "Solo 2 task questa volta" | Contatore persiste cross-session. Non resettare mentale |
| "L'utente non chiederà i docs" | Il gate è per la sessione futura, non per l'utente attuale |
| "I docs sono 'abbastanza freschi'" | Fresco = timestamp dopo ultimo task, niente opinioni |
