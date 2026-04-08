---
name: init
version: 2.0.0
description: SkillOS boot sequence — initializes a new session by reading skill-orch.config.json, discovering installed skills, loading persistent state (state.json + journal), opening a new session, and presenting a session summary. Use at the start of every session or when setting up SkillOS in a new project.
skillos:
  layer: core
  category: meta
  pack: null
  requires:
    hard: []
    soft: []
  provides: ["boot", "session-init"]
  triggers:
    - on: "session.start"
      mode: auto
  config: {}
---

# SkillOS Init — Boot Sequence v2.0

Meta-skill che inizializza una sessione SkillOS: legge la configurazione, scopre le skill disponibili, carica lo stato persistente, apre una nuova sessione con journaling, e presenta un sommario operativo.

## Quando invocare

- **Inizio sessione** — Prima di qualsiasi altro lavoro
- **Primo setup** — Quando si installa SkillOS in un nuovo progetto
- **Dopo modifiche strutturali** — Dopo aver aggiunto/rimosso skill o modificato skill-orch.config.json

## Workflow

### Fase 1: Leggere configurazione

1. **Cercare `skill-orch.config.json`** nella root del progetto
2. **Se non esiste:**
   - Questo e' un nuovo progetto
   - Chiedere all'utente le info base (nome progetto, lingua, descrizione)
   - Generare `skill-orch.config.json` con template default
   - Creare directory `skills/core/`, `skills/drivers/`, `skills/packs/`
   - Creare directory `.state/journal/`, `.state/snapshots/`
3. **Se esiste, estrarre:**
   - `project.name` e `project.description`
   - `paths.skills` — dove cercare le skill
   - `paths.state` — dove risiede lo state store (default: `skillos`)
   - `phases` — fasi del workflow
   - `gate_thresholds` — soglie per i gate
   - `triggers` — regole evento
   - `installed_packs` — pack installati

### Fase 2: Discovery skill

1. **Scansionare `skills/**/SKILL.md`** con Glob (usando `skill_discovery.pattern` da config)
2. **Escludere** pattern in `skill_discovery.exclude`
3. **Classificare per layer:**
   - `skills/core/*` -> Kernel
   - `skills/drivers/*` -> Drivers
   - `skills/packs/*` -> Domain skill
4. **Contare per categoria:**
   - Totale skill
   - Per layer (core / drivers / packs)
   - Per pack (se organizzate in sub-directory di packs/)
5. **Estrarre frontmatter** (name, description) da ogni SKILL.md

### Fase 3: Caricare stato persistente (L2)

**Questa fase e' il cuore dell'integrazione con il Persistence Layer.**

#### 3.1 State Store

1. **Cercare `.state/state.json`:**
   - **Se esiste:** leggere e validare struttura
     - Estrarre: `phase.current`, `phase.name`, `sessions.last_session`, `sessions.total`
     - Estrarre: `skills.health` per eventuali warning su skill degradate
     - Estrarre: `checkpoints` per mostrare punti di restore disponibili
     - Estrarre: `decisions` attive per contesto
   - **Se non esiste:** prima sessione per questo progetto
     - Creare `.state/state.json` con template default (vedi STATE_SCHEMA.md)
     - Creare directory `.state/journal/` e `.state/snapshots/` se non esistono
   - **Se corrotto (JSON non valido):**
     - Warning all'utente: "state.json corrotto, verificare manualmente"
     - Cercare ultimo checkpoint in `.state/snapshots/` per restore
     - Se nessun checkpoint: reinizializzare con template default

#### 3.2 Journal — Ultima sessione

1. **Scansionare `.state/journal/session_*.jsonl`** ordinati per nome (cronologico)
2. **Se esistono journal:**
   - Leggere l'ultimo file journal
   - Cercare evento `session.end` — estrarre summary, skills_used, tasks
   - Se l'ultimo journal NON ha `session.end`: sessione precedente non chiusa correttamente
     - Warning: "Sessione precedente non chiusa. Dati potrebbero essere incompleti."
3. **Se non esistono journal:** prima sessione, nessun storico

#### 3.3 Aprire nuova sessione

1. **Generare session_id:** `session_YYYYMMDD_HHMM` (UTC)
2. **Creare file journal:** `.state/journal/session_YYYYMMDD_HHMM.jsonl`
3. **Scrivere primo evento:**
   ```json
   {"ts":"ISO8601","type":"session.start","session_id":"...","data":{"phase":N,"skills_available":N,"config_hash":"..."}}
   ```
4. **Calcolare `config_hash`:** hash semplice di skill-orch.config.json per detectare cambiamenti config tra sessioni

### Fase 4: Health check rapido

1. **Verificare coerenza:**
   - Skill in skill-orch.config.json `phases` esistono effettivamente?
   - CLAUDE.md esiste ed e' aggiornato?
   - Il conteggio skill in CLAUDE.md corrisponde al filesystem?
     (Leggere la riga "**N skills**" dal header e confrontare con il
     risultato della discovery Fase 2. Se diverso: WARNING con count corretto.)
   - Ci sono skill orfane (installate ma non mappate)?
   - State store e' coerente con journal? (session count match)
2. **Verificare skill health:**
   - Skill con `status: degraded` o `status: broken` in state.json?
   - Se si: warning con raccomandazione
3. **Segnalare anomalie** (warning, non bloccante)

### Fase 5: Presentare sommario sessione

```markdown
# SkillOS v0.2 — Sessione inizializzata

## Progetto
- **Nome:** [da skill-orch.config.json]
- **Fase corrente:** [N] — [nome fase]
- **Sessione #:** [sessions.total + 1]

## Contesto persistente
- **Ultima sessione:** [data] — [sommario da state.json]
  - Skill usate: [lista]
  - Task completati: [N/M]
- **Decisioni attive:** [N] decisioni registrate
- **Checkpoint disponibili:** [N] (ultimo: [data e descrizione])

## Skill disponibili
| Layer | Count | Dettaglio |
|-------|-------|-----------|
| Core (Kernel) | [N] | init, skill-router, dependency-checker, ... |
| Drivers | [N] | session-reporter, session-lifecycle, ... |
| Packs | [N] | [lista pack installati] |
| **Totale** | **[N]** | |

## Skill health (se warning)
| Skill | Status | Issues | Ultima invocazione |
|-------|--------|--------|-------------------|
| [skill] | degraded | [N] | [data] |

## Stato progetto
- **PROJECT_STATE.md:** [Aggiornato / Da aggiornare / Non esiste]
- **State store:** Attivo — [sessions.total] sessioni registrate
- **Journal:** [N] file, ultimo: [nome file]

## Warning (se presenti)
- [Eventuali anomalie dal health check]

## Suggerimenti per questa sessione
Basandosi sulla fase corrente, sull'ultima sessione e sullo stato del progetto:
1. [Skill suggerita 1] — [motivo]
2. [Skill suggerita 2] — [motivo]
3. [Skill suggerita 3] — [motivo]
```

### Fase 6: Generare/Aggiornare CLAUDE.md (opzionale)

Se CLAUDE.md non esiste o e' outdated:

1. **Leggere template** da `skills/core/CLAUDE.md.template`
2. **Popolare con dati runtime:**
   - Lista skill effettivamente installate (dal discovery Fase 2)
   - Fasi e soglie da skill-orch.config.json
   - Convenzioni naming da skill-orch.config.json
   - Sezione session-lifecycle nel workflow
3. **Scrivere CLAUDE.md** nella root del progetto
4. **Chiedere conferma utente** prima di sovrascrivere se esiste gia'

## Regole

- **Non bloccare** — Init deve essere veloce e informativo, non bloccante
- **Warning, non errori** — Anomalie sono warning, l'utente decide se agire
- **Idempotente** — Invocare init piu' volte non deve creare duplicati o sovrascrivere dati
- **Configurabile** — Tutti i path da skill-orch.config.json, mai hardcoded
- **State-aware** — SEMPRE leggere state.json prima di presentare il sommario
- **Journal-safe** — MAI sovrascrivere journal esistenti, solo creare nuovi

## Anti-pattern

- Init che richiede 5 minuti (deve essere rapido: scan + report)
- Sovrascrivere CLAUDE.md senza conferma
- Bloccare la sessione per un warning non critico
- Creare file di stato senza che l'utente lo richieda
- Ignorare state.json corrotto senza warning
- Non aprire la sessione nel journal (ogni sessione deve essere tracciata)

---

**Versione:** 2.0.0 (Fase B — Persistence Layer integration)
**Tipo:** Core meta-skill (boot sequence)
**Dipendenze:** Glob tool, Read tool, Write tool, session-lifecycle (per journal), STATE_SCHEMA.md (riferimento)
**Changelog:**
- v1.0: Boot base con discovery e sommario
- v2.0: Integrazione L2 Persistence Layer (state.json, journal, checkpoint awareness, session opening)
