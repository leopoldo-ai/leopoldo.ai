---
name: context-persistence
description: Use for long sessions (30+ exchanges), closure loops, long build loops, or any task where context risks being compacted. Trigger on "sessione lunga", "non perdere contesto", "mantieni memoria", "persistenza contesto". Maintains 3 persistent files (task_plan.md, notes.md, deliverable) with Read-Before-Decide mechanism, complementing project-memory with session working memory.
type: technique
---

# Context Persistence — Memoria Esterna per Sessioni Lunghe

Mantiene 3 file persistenti come memoria esterna, prevenendo perdita di contesto durante sessioni lunghe.

`project-memory` = stato codebase (schema, API, test). `context-persistence` = stato sessione corrente (piano, note, deliverable).

## Quando attivare

- Sessioni che si prevede superino **30 scambi**
- `product-closure-loop`, `board-orchestrator`, build loop lunghi
- L'utente dice "sessione lunga", "non perdere il contesto"
- Il context inizia a compattarsi (risposte meno dettagliate)

**NON attivare per:** sessioni brevi (< 15 scambi), task singoli, pura analisi senza deliverable.

## I 3 File

| File | Contenuto | Regole |
|---|---|---|
| `task_plan.md` | Fasi, decisioni (con motivazione), errori, stato corrente | Max 50 righe. Aggiornare DOPO ogni step significativo |
| `notes.md` | Risultati ricerca, dati intermedi, appunti | Append-only, timestamped, fatti non opinioni |
| `[deliverable].md` | Output finale in costruzione (PRD, board decision, sprint plan) | Aggiornato incrementalmente, mai riscritto da zero |

**Directory:** `docs/wip/session_[YYYYMMDD_HHMM]/`

## Read-Before-Decide (OBBLIGATORIO)

```
PRIMA di qualsiasi decisione significativa:
1. Read task_plan.md → riporta obiettivi in attenzione
2. Decisione coerente col piano? → SI: procedi + aggiorna. NO: aggiorna piano prima
3. Se context compattato → leggere TUTTI e 3 i file per ricostruire contesto
```

**Perche' funziona:** "Lost in the middle" fa perdere dettagli nei contesti lunghi. Re-leggere riporta obiettivi nella finestra di attenzione attiva.

## Lifecycle

1. **Inizio:** creare directory + 3 file
2. **Durante:** aggiornare task_plan e notes ad ogni step
3. **Read-Before-Decide:** prima di ogni decisione importante
4. **Se compaction:** rileggere tutti e 3 per ricostruire
5. **Fine:** spostare deliverable in `docs/` con naming del progetto

## Integrazione

| Skill | Come |
|---|---|
| product-closure-loop | task_plan = iterazioni/gap, notes = gap analysis, deliverable = PRD |
| board-orchestrator | task_plan = agenda, notes = contributi, deliverable = decision |
| session-reporter | notes come input per report |
| project-memory | Complementare: codebase vs sessione |

## Rules

- **Read-Before-Decide OBBLIGATORIO** — non opzionale
- **task_plan aggiornato DOPO ogni step** — non solo a fine giornata
- **notes append-only** — mai editare/rimuovere
- **Deliverable incrementale** — mai riscritto da zero
- **Max 50 righe** per task_plan — conciso e scannable

## Anti-pattern

- Attivare per sessioni brevi (overhead non giustificato)
- Non aggiornare task_plan (diventa stale)
- task_plan troppo dettagliato (summary, non romanzo)
- Non leggere prima di decidere (vanifica lo scopo)
- Riscrivere deliverable da zero ad ogni iterazione
- Dimenticare di spostare deliverable a fine sessione
