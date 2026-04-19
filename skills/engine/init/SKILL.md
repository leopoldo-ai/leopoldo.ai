---
name: init
version: 2.0.0
description: "Use at the start of every session or when setting up SkillOS in a new project. SkillOS boot sequence: reads skill-orch.config.json, discovers installed skills, loads persistent state (state.json + journal), opens a new session, and presents a session summary."
type: technique
---

# SkillOS Init — Boot Sequence v2.0

Inizializza una sessione: legge config, scopre skill, carica stato persistente, apre sessione con journaling, presenta sommario operativo.

## Quando invocare

- **Inizio sessione** — prima di qualsiasi lavoro
- **Primo setup** — installazione SkillOS in nuovo progetto
- **Dopo modifiche strutturali** — aggiunta/rimozione skill o modifica config

## Workflow

### 1. Leggere configurazione

1. Cercare `skill-orch.config.json` nella root
2. **Non esiste:** nuovo progetto → chiedere info base → generare config + creare directory skills/ e .state/
3. **Esiste:** estrarre project.name, paths.skills, paths.state, phases, gate_thresholds, triggers, installed_packs

### 2. Discovery skill

1. Scansionare `skills/**/SKILL.md` (pattern da config)
2. Classificare per layer: core / drivers / packs
3. Contare per categoria e per pack
4. Estrarre frontmatter (name, description)

### 3. Caricare stato persistente

**3.1 State Store:**
- `.state/state.json` esiste → leggere phase.current, sessions, skills.health, checkpoints, decisions
- Non esiste → prima sessione, creare con template default + directory journal/snapshots
- Corrotto → warning, cercare ultimo checkpoint per restore, se nessuno reinizializzare

**3.2 Journal — Ultima sessione:**
- Scansionare `.state/journal/session_*.jsonl` ordinati cronologicamente
- Leggere ultimo, cercare `session.end` → estrarre summary, skills_used, tasks
- Ultimo senza `session.end` → warning "sessione precedente non chiusa"

**3.3 Aprire nuova sessione:**
- session_id: `session_YYYYMMDD_HHMM` (UTC)
- Creare journal file, scrivere evento `session.start` con phase, skills_available, config_hash

### 4. Health check rapido

1. Skill in config phases esistono nel filesystem?
2. CLAUDE.md esiste e conteggio skill corrisponde?
3. Skill orfane (installate ma non mappate)?
4. State store coerente con journal?
5. Skill con status degraded/broken in state.json → warning
6. Anomalie = warning, non bloccante

### 5. Sommario sessione

Presentare: progetto (nome, fase, sessione #), contesto persistente (ultima sessione, decisioni attive, checkpoint), skill disponibili (per layer con conteggi), health warnings, suggerimenti per la sessione.

### 6. Generare/Aggiornare CLAUDE.md (opzionale)

Non esiste o outdated → leggere template → popolare con dati runtime (skill, fasi, convenzioni) → chiedere conferma prima di sovrascrivere.

## Rules

- **Non bloccare** — init deve essere veloce e informativo
- **Warning, non errori** — anomalie sono warning, utente decide
- **Idempotente** — invocare piu' volte non crea duplicati
- **Configurabile** — tutti i path da config, mai hardcoded
- **State-aware** — SEMPRE leggere state.json
- **Journal-safe** — MAI sovrascrivere journal, solo creare nuovi

## Anti-pattern

- Init che richiede 5 minuti (deve essere rapido)
- Sovrascrivere CLAUDE.md senza conferma
- Bloccare per warning non critico
- Creare file di stato senza richiesta utente
- Ignorare state.json corrotto senza warning
- Non aprire sessione nel journal
