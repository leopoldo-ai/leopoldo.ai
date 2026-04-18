---
name: session-lifecycle
version: 1.0.0
description: Use when opening or closing SkillOS sessions, creating checkpoints, restoring from a checkpoint, or recording events in the journal. Manages the full SkillOS session lifecycle (apertura, journaling, checkpoint, chiusura, restore) operating on .state/state.json and .state/journal/.
type: technique
---

# Session Lifecycle — Gestione Ciclo di Vita Sessioni

Driver che gestisce apertura, journaling, checkpoint, chiusura e restore delle sessioni. Opera sul Persistence Layer (`.state/`).

## File gestiti

| File | Tipo | Scopo |
|------|------|-------|
| `.state/state.json` | JSON | Stato persistente progetto |
| `.state/journal/session_*.jsonl` | JSONL | Log eventi sessione (append-only) |
| `.state/snapshots/cp_*.json` | JSON | Checkpoint per restore |

## Operazioni

### session.open

1. Leggere `.state/state.json` (se non esiste: creare con template default)
2. Generare session_id: `session_YYYYMMDD_HHMM` (UTC)
3. Creare journal: `.state/journal/session_YYYYMMDD_HHMM.jsonl`
4. Scrivere evento `session.start` con phase, skills_available, config_hash
5. Presentare contesto ultima sessione (o "Prima sessione")

### journal.append

1. Costruire riga JSONL: `{ts, type, session_id, data}`
2. Appendere al journal corrente
3. Se `skill.complete` → aggiornare `skills.health` in state.json
4. Se `decision.made` → aggiungere a `decisions[]`

**Tipi evento:** skill.invoke, skill.complete, task.start, task.complete, phase.advance, decision.made, error

### checkpoint.create

1. Generare `cp_YYYYMMDD_HHMM`
2. Copiare state.json in `.state/snapshots/`
3. Registrare in state.json (id, session, timestamp, phase, description)
4. **GC:** max 10 checkpoint, eliminare piu' vecchio se eccede
5. Appendere `checkpoint.created` al journal

### session.close

1. Raccogliere metriche: skill usate, task completati, durata, sommario
2. Appendere `session.end` al journal
3. Aggiornare state.json: `sessions.total` += 1, rotare `last_session` in `history[]` (max 20, FIFO)
4. Aggiornare `skills.health` per ogni skill invocata
5. Creare checkpoint automatico (se task completati)
6. Scrivere state.json su disco

### checkpoint.restore

1. Presentare lista checkpoint disponibili
2. Su selezione: backup state attuale → copiare snapshot su state.json
3. Appendere `checkpoint.restored` al journal

### state.query

Query disponibili: `current_phase`, `last_session`, `skill_health(name)`, `decisions(filter?)`, `session_history(n?)`, `checkpoints`

## Integrazione

| Skill | Integrazione |
|---|---|
| init | Chiama session.open al boot |
| session-reporter | Legge journal, chiama session.close |
| phase-gate | journal.append(phase.advance) |
| skill-router | journal.append(skill.invoke) |
| context-persistence | Complementare: dati strutturati vs working memory |
| skill-postmortem | journal.append(error) |

## Rules

- **Append-only journal** — MAI modificare righe esistenti
- **state.json sempre valido** — ogni write produce JSON valido
- **Idempotente** — session.open due volte non crea duplicati
- **Graceful degradation** — state.json corrotto → ricreare con warning
- **No blocking** — journaling non blocca il flusso
- **Timestamp UTC** — tutti in ISO8601 UTC

## Anti-pattern

- Journal con eventi banali (solo eventi significativi)
- state.json senza limiti (max: 20 sessioni, 100 invocazioni, 10 checkpoint)
- Restore senza backup dello stato corrente
- Modificare journal retroattivamente
- Checkpoint su ogni singola operazione
