---
name: context-persistence
description: Pattern di memoria esterna strutturata per sessioni lunghe. Mantiene 3 file persistenti (task_plan.md, notes.md, deliverable) con meccanismo "Read-Before-Decide" per prevenire perdita di contesto. Complementa project-memory (stato codebase) con working memory di sessione. Usare per sessioni 30+ scambi, closure loop, build loop lunghi, o attivita' dove il context rischia di compattarsi. Trigger su sessione lunga, non perdere contesto, mantieni memoria, persistenza contesto.
---

# Context Persistence — Memoria Esterna Strutturata per Sessioni Lunghe

Pattern che mantiene 3 file persistenti come memoria esterna di lavoro, prevenendo la perdita di contesto durante sessioni lunghe.

## Perche' esiste

| Problema | Soluzione |
|----------|-----------|
| Context compaction perde dettagli mid-session | 3 file persistenti come backup |
| "Lost in the middle" — decisioni dimenticate | Read-Before-Decide riporta obiettivi in attenzione |
| Rework per contesto perso | task_plan.md mantiene stato e decisioni |

## Differenza con project-memory

| Aspetto | project-memory | context-persistence |
|---------|---------------|---------------------|
| **Scope** | Codebase (schema, routes, test, PRD) | Sessione corrente |
| **Persistenza** | Tra sessioni | Solo sessione corrente |
| **Contenuto** | Stato oggettivo del codice | Piano, note di lavoro, decisioni |
| **Trigger** | Inizio sessione, post-commit | Sessioni lunghe (30+ scambi) |
| **Output** | `PROJECT_STATE.md` | `docs/wip/session_[data]/` |

**Sono complementari:** project-memory per lo stato del progetto, context-persistence per lo stato della sessione di lavoro.

## Quando attivare

- **Sessioni che si prevede superino 30 scambi**
- **`product-closure-loop`** — iterazioni multiple con gap analysis
- **`board-orchestrator`** per sessioni complesse con molti contributi
- **Build loop lunghi** — Fase 3 del workflow di sviluppo
- **L'utente dice:** "sessione lunga", "lavoriamo a lungo", "non perdere il contesto"
- **Il context inizia a compattarsi** — segni: risposte meno dettagliate, dettagli dimenticati

**NON attivare per:**
- Sessioni brevi (< 15 scambi) — overhead non giustificato
- Task singoli e circoscritti
- Sessioni di pura analisi/ricerca senza deliverable

## I 3 File

### 1. `task_plan.md` — Piano e stato

Traccia fasi del lavoro, decisioni prese, errori incontrati, stato corrente.

```markdown
# Task Plan — [Obiettivo della sessione]
**Data:** [YYYY-MM-DD]
**Obiettivo:** [Una riga chiara]

## Fasi
- [x] Fase 1: [Descrizione] — completata
- [ ] Fase 2: [Descrizione] — IN CORSO
- [ ] Fase 3: [Descrizione] — da fare

## Decisioni prese
- [DD/1] [Decisione]: [motivazione breve]
- [DD/2] [Decisione]: [motivazione breve]

## Errori incontrati
- [ERR/1] [Cosa]: [come risolto]

## Stato corrente
Fase 2 in corso. Prossimo step: [descrizione].
```

**Regole task_plan.md:**
- **Max 50 righe** — deve essere conciso e scannable
- **Aggiornare DOPO ogni step significativo** — non solo quando ci si ricorda
- **Decisioni con motivazione** — non solo "scelto X" ma "scelto X perche' Y"

### 2. `notes.md` — Ricerca e dati intermedi

Raccoglie risultati di ricerca, dati intermedi, appunti di lavoro.

```markdown
# Notes — [Sessione]

## [HH:MM] — [Topic]
[Contenuto: risultato ricerca, dato trovato, osservazione]

## [HH:MM] — [Topic]
[Contenuto]
```

**Regole notes.md:**
- **Append-only** — non editare o rimuovere note precedenti
- **Timestamped** — ogni entry con ora approssimativa
- **Dati, non opinioni** — fatti trovati, codice analizzato, risultati di query

### 3. `[deliverable].md` — Output finale in costruzione

Il documento o artefatto finale che si sta costruendo. Il nome varia in base al tipo di lavoro.

**Esempi:**
- `prd_v2.md` per un PRD in fase di closure
- `board_decision.md` per un board meeting
- `sprint_plan.md` per un piano sprint
- `architecture_design.md` per un design architetturale

**Regole deliverable:**
- **Aggiornato incrementalmente** — non riscritto da zero ad ogni iterazione
- **Il deliverable finale** viene spostato in `docs/` con naming convention del progetto a fine sessione

## Directory output

```
docs/wip/session_[YYYYMMDD_HHMM]/
├── task_plan.md
├── notes.md
└── [deliverable].md
```

## Meccanismo "Read-Before-Decide"

**La regola fondamentale di questo pattern:**

```
PRIMA di qualsiasi decisione significativa:

1. Read task_plan.md
   → Riporta obiettivi e stato nella finestra di attenzione

2. Valutare: la decisione e' coerente con il piano?
   → Se NO: aggiornare il piano prima di procedere
   → Se SI: procedere e aggiornare task_plan.md dopo

3. Se il context e' stato compattato:
   → Leggere TUTTI e 3 i file per ricostruire il contesto completo
```

**Perche' funziona:** Il problema "lost in the middle" fa perdere dettagli nel mezzo di contesti lunghi. Re-leggere task_plan.md riporta obiettivi e decisioni nella finestra di attenzione attiva, dove il modello li usa con massima efficacia.

## Integrazione con skill esistenti

| Skill | Come si integra |
|-------|----------------|
| **product-closure-loop** | task_plan.md = iterazioni e gap; notes.md = gap analysis; deliverable = PRD |
| **board-orchestrator** | task_plan.md = agenda; notes.md = contributi membri; deliverable = board decision |
| **session-reporter** | notes.md come input per arricchire il report di fine sessione |
| **project-memory** | Complementare: project-memory = codebase, context-persistence = sessione |

## Lifecycle

1. **Inizio sessione lunga:** Creare directory `docs/wip/session_[YYYYMMDD_HHMM]/` + 3 file
2. **Durante la sessione:** Aggiornare task_plan.md e notes.md ad ogni step significativo
3. **Read-Before-Decide:** Prima di ogni decisione importante, rileggere task_plan.md
4. **Se context si compatta:** Rileggere tutti e 3 i file per ricostruire contesto
5. **Fine sessione:** Spostare deliverable finale in `docs/` con naming convention del progetto. I file wip/ possono essere conservati o eliminati.

## Regole

- **Read-Before-Decide e' OBBLIGATORIO** — non opzionale, non "quando mi ricordo"
- **task_plan.md aggiornato DOPO ogni step** — non solo a fine giornata
- **notes.md e' append-only** — mai editare o rimuovere note precedenti
- **Deliverable aggiornato incrementalmente** — non riscritto da zero
- **Se il context si compatta** — i 3 file sono il backup. Rileggere tutti per riprendere
- **Max 50 righe per task_plan.md** — deve restare conciso e leggibile in un read

## Anti-pattern

- **Attivare per sessioni brevi** (< 15 scambi) — overhead non giustificato
- **Non aggiornare task_plan.md** — diventa stale, peggio che non averlo
- **task_plan.md troppo dettagliato** — deve essere un summary, non un romanzo
- **Non leggere prima di decidere** — vanifica lo scopo del pattern
- **Usare come sostituto di project-memory** — scopi diversi, usarli entrambi
- **Riscrivere il deliverable da zero** ad ogni iterazione — aggiornare incrementalmente
- **Dimenticare di spostare il deliverable** in docs/ a fine sessione

---

**Versione:** 1.0 (2026-03-01)
**Tipo:** Pattern skill invocabile
**Dipendenze:** Write tool, Read tool
**Si integra con:** project-memory, session-reporter, product-closure-loop, board-orchestrator
