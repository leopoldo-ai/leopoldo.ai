---
name: session-lifecycle
version: 1.0.0
description: Gestisce il ciclo di vita delle sessioni SkillOS — apertura, journaling, checkpoint, chiusura, restore. Opera su .state/state.json e .state/journal/. Usare per aprire/chiudere sessioni, creare checkpoint, restore da checkpoint, registrare eventi nel journal.
skillos:
  layer: driver
  category: reporting
  pack: null
  requires:
    hard: []
    soft: ["init"]
  provides: ["session-management", "journaling", "checkpoint", "restore"]
  triggers:
    - on: "session.start"
      mode: auto
    - on: "session.end"
      mode: auto
  config: {}
metadata:
  author: lucadealbertis
  source: local
  license: proprietary
---

# Session Lifecycle — Gestione Ciclo di Vita Sessioni

Driver skill che gestisce apertura, journaling, checkpoint, chiusura e restore delle sessioni SkillOS. Opera sui file del Persistence Layer (L2).

## Perche' esiste

| Problema | Soluzione |
|----------|-----------|
| Ogni sessione parte da zero (cold boot) | state.json mantiene contesto tra sessioni |
| Nessuno storico di cosa e' successo | journal JSONL registra ogni evento |
| Se qualcosa va storto, si perde tutto | Checkpoint/restore per tornare a uno stato noto |
| session-reporter non ha dati strutturati | Journal come fonte dati per report |

## File gestiti

| File | Tipo | Scopo |
|------|------|-------|
| `.state/state.json` | JSON | Stato persistente del progetto |
| `.state/journal/session_*.jsonl` | JSONL | Log eventi sessione (append-only) |
| `.state/snapshots/cp_*.json` | JSON | Copie di state.json per restore |
| `STATE_SCHEMA.md` | Markdown | Documentazione schema (riferimento) |

## Operazioni

### 1. `session.open` — Aprire una sessione

**Quando:** Inizio sessione, chiamato da `init` o direttamente.

**Workflow:**

1. **Leggere `.state/state.json`**
   - Se non esiste: crearlo con template default (vedi STATE_SCHEMA.md)
   - Se esiste: caricare in memoria

2. **Generare session_id:**
   ```
   session_YYYYMMDD_HHMM (es. session_20260301_1000)
   ```

3. **Creare file journal:**
   ```
   .state/journal/session_YYYYMMDD_HHMM.jsonl
   ```

4. **Scrivere evento `session.start`** nel journal:
   ```json
   {"ts":"ISO8601","type":"session.start","session_id":"...","data":{"phase":N,"skills_available":N,"config_hash":"..."}}
   ```

5. **Presentare contesto da ultima sessione:**
   - Se `sessions.last_session` esiste: mostrare summary, fase, data
   - Se non esiste: "Prima sessione SkillOS per questo progetto"

### 2. `journal.append` — Registrare evento

**Quando:** Ogni volta che accade qualcosa di significativo nella sessione.

**Workflow:**

1. **Determinare tipo evento** (vedi tabella tipi in STATE_SCHEMA.md)
2. **Costruire riga JSONL:**
   ```json
   {"ts":"ISO8601","type":"[tipo]","session_id":"[current]","data":{...}}
   ```
3. **Appendere** al file journal della sessione corrente
4. **Se tipo e' `skill.complete`:** aggiornare `skills.health` in state.json
5. **Se tipo e' `decision.made`:** aggiungere a `decisions[]` in state.json

**Tipi evento supportati:**

| Tipo | Trigger | Dati minimi |
|------|---------|------------|
| `skill.invoke` | Invocazione skill | skill, trigger |
| `skill.complete` | Skill terminata | skill, outcome |
| `task.start` | Task iniziato | task_id, description |
| `task.complete` | Task completato | task_id, outcome |
| `phase.advance` | Cambio fase | from, to, gate_score |
| `decision.made` | Decisione presa | decision, rationale, skill |
| `error` | Errore significativo | skill, error_type, message |

### 3. `checkpoint.create` — Creare checkpoint

**Quando:** Fine di una fase, prima di operazioni rischiose, o su richiesta utente.

**Workflow:**

1. **Generare checkpoint_id:**
   ```
   cp_YYYYMMDD_HHMM
   ```

2. **Copiare state.json** in `.state/snapshots/cp_YYYYMMDD_HHMM.json`

3. **Registrare in state.json:**
   ```json
   {
     "id": "cp_YYYYMMDD_HHMM",
     "session_id": "session_...",
     "timestamp": "ISO8601",
     "phase": N,
     "description": "Checkpoint pre-[fase/operazione]",
     "state_snapshot": ".state/snapshots/cp_YYYYMMDD_HHMM.json",
     "journal_ref": ".state/journal/session_YYYYMMDD_HHMM.jsonl"
   }
   ```

4. **Garbage collection:** Se `checkpoints.length > 10`:
   - Identificare checkpoint piu' vecchio
   - Eliminare suo snapshot da `.state/snapshots/`
   - Rimuovere da array `checkpoints`

5. **Appendere evento** `checkpoint.created` al journal

### 4. `session.close` — Chiudere sessione

**Quando:** Fine sessione, prima di `session-reporter`.

**Workflow:**

1. **Raccogliere metriche sessione:**
   - Skill usate (da journal, tipo `skill.invoke`)
   - Task completati (da journal, tipo `task.complete`)
   - Durata (da `session.start` a ora)
   - Sommario (generare da contesto o chiedere)

2. **Appendere `session.end`** al journal:
   ```json
   {"ts":"ISO8601","type":"session.end","session_id":"...","data":{"summary":"...","tasks_completed":N,"tasks_total":N,"skills_used":["..."],"duration_minutes":N}}
   ```

3. **Aggiornare state.json:**
   - `sessions.total` += 1
   - Spostare `sessions.last_session` in `sessions.history[]`
   - Impostare nuovo `sessions.last_session` con dati sessione
   - Se `sessions.history.length > 20`: rimuovere piu' vecchio (FIFO)

4. **Aggiornare skills.health:** Per ogni skill invocata nella sessione:
   - Incrementare `invocations`
   - Aggiornare `last_invoked` e `last_session`
   - Se errori: incrementare `issues`, valutare `status`

5. **Creare checkpoint** (automatico se sessione ha completato task)

6. **Scrivere state.json** su disco

### 5. `checkpoint.restore` — Restore da checkpoint

**Quando:** Su richiesta utente, dopo un errore grave, o quando lo stato e' corrotto.

**Workflow:**

1. **Leggere `state.json.checkpoints[]`**
2. **Presentare lista checkpoint** disponibili all'utente
3. **Su selezione:**
   - Leggere snapshot: `.state/snapshots/cp_[id].json`
   - **Creare backup** dello state.json attuale prima di sovrascrivere
   - Copiare snapshot su `.state/state.json`
4. **Presentare sommario:** "Stato ripristinato al checkpoint [id]: [descrizione]"
5. **Appendere evento** al journal corrente: tipo `checkpoint.restored`

### 6. `state.query` — Query stato corrente

**Quando:** Altre skill o l'utente vogliono conoscere lo stato.

**Query disponibili:**

| Query | Output |
|-------|--------|
| `current_phase` | Fase corrente + quando e' iniziata |
| `last_session` | Sommario ultima sessione |
| `skill_health(name)` | Health di una skill specifica |
| `decisions(filter?)` | Decisioni registrate, filtrabile per skill/status |
| `session_history(n?)` | Ultime N sessioni |
| `checkpoints` | Lista checkpoint disponibili |

## Integrazione con altre skill

| Skill | Integrazione |
|-------|-------------|
| **init** | Chiama `session.open` durante il boot |
| **session-reporter** | Legge journal per compilare report, poi chiama `session.close` |
| **phase-gate** | Chiama `journal.append(phase.advance)` quando si cambia fase |
| **skill-router** | Chiama `journal.append(skill.invoke)` ad ogni routing |
| **context-persistence** | Complementare: session-lifecycle = dati strutturati, context-persistence = working memory |
| **skill-postmortem** | Chiama `journal.append(error)` per registrare fallimenti |

## Regole

- **Append-only journal** — MAI modificare righe esistenti nei file .jsonl
- **state.json sempre valido** — Ogni write deve produrre JSON valido
- **Idempotente** — Chiamare `session.open` due volte non deve creare duplicati
- **Graceful degradation** — Se state.json e' corrotto, ricreare da zero con warning
- **No blocking** — Le operazioni di journaling non devono bloccare il flusso di lavoro
- **Timestamp UTC** — Tutti i timestamp in ISO8601 UTC

## Anti-pattern

- Journal con centinaia di eventi banali (loggare solo eventi significativi)
- state.json che cresce senza limiti (rispettare i max: 20 sessioni, 100 invocazioni, 10 checkpoint)
- Restore senza backup dello stato corrente
- Modificare journal retroattivamente
- Checkpoint su ogni singola operazione (solo a fine fase o prima di rischi)

---

**Versione:** 1.0.0
**Tipo:** Driver skill (L2 — Persistence Layer)
**Dipendenze:** Read tool, Write tool, Bash tool (per file operations)
**Si integra con:** init, session-reporter, phase-gate, skill-router, context-persistence
