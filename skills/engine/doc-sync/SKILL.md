---
name: doc-sync
description: Use when project docs are outdated, skills have been added/removed, directory structure changed, phase milestones reached, config modified, or when user requests "doc aggiornati?", "sync docs", "aggiorna documentazione". Dynamic documentation sync engine that patches all project docs (CLAUDE.md, Design Doc, INSTALL.md, Pitch Deck) based on filesystem ground truth.
type: technique
---

# Doc Sync — Dynamic Documentation Engine

Mantiene automaticamente la coerenza tra documentazione e stato reale. Non si limita a segnalare drift — li corregge.

`project-memory` fa questo per il codebase → PROJECT_STATE.md.
`doc-sync` fa lo stesso per la documentazione di SkillOS → tutti i doc.

## Quando si attiva

| Trigger | Azione |
|---------|--------|
| Skill aggiunta/rimossa | Aggiorna conteggi e tabelle in tutti i doc |
| Directory ristrutturata | Aggiorna alberi directory e path |
| Fase completata (phase-gate PASS) | Aggiorna roadmap status |
| Config modificata | Aggiorna riferimenti a soglie, fasi, path |
| Su richiesta ("sync docs") | Scan completo + fix |
| Post-init | Verifica coerenza come ultimo step |

## Core Workflow

### 1. Build Ground Truth

Scansionare filesystem per costruire stato reale:
1. `Glob: skills/**/SKILL.md` → conteggi e nomi per layer (core/drivers/packs)
2. `ls skills/core/`, `ls skills/packs/*/` → struttura
3. `Read: skill-orch.config.json` → config, phases, thresholds
4. `Glob: docs/*.md` → lista doc da aggiornare

### 2. Scan & Patch ogni documento

**Dati fattuali aggiornabili automaticamente (senza conferma):**

| Dato | Pattern | Azione |
|------|---------|--------|
| Conteggio skill totale | `\d+ skill` | Sostituire con conteggio reale |
| Conteggio per layer | `core.*\d+`, `pack.*\d+` | Sostituire con conteggi reali |
| Path di scan | `skills/*/SKILL.md` | → `skills/**/SKILL.md` (ricorsivo) |
| Path deprecati | `.claude/skills/` | → `skills/` |
| Alberi directory | Blocchi ``` con tree | Rigenerare da filesystem |
| Status roadmap | `da avviare`, `COMPLETATA` | Aggiornare con stato effettivo |
| Lista skill in tabelle | Tabelle markdown | Aggiungere mancanti, rimuovere eliminate |

**Dati NON toccabili:** prose strategiche, pricing, buyer persona, opinioni qualitative.

**Chiedere conferma solo per:** aggiunta/rimozione righe in tabelle skill, modifica blocchi di testo, contenuto narrativo vicino ai dati.

### 3. Applicare fix

| Severita' | Azione |
|-----------|--------|
| Critical (path sbagliati, struttura broken) | Fix immediato |
| Warning (conteggi, status) | Fix immediato |
| Info (dettagli estetici) | Segnalare, non fixare |

### 4. Report sintetico

Tabella: documento, fix applicate, dettaglio. Totale: N fix su M documenti.

## Integrazione

| Skill | Trigger |
|-------|---------|
| skill-changelog | Rileva nuova skill → doc-sync aggiorna tutti i doc |
| phase-gate | PASS → doc-sync aggiorna roadmap |
| init | Post-boot → doc-sync verifica coerenza |
| project-memory | Complementare: codebase (project-memory) vs docs (doc-sync) |

## Rules

- **Auto-fix dati fattuali** — conteggi, path, strutture sono fatti: aggiornarli senza chiedere
- **Mai toccare prose** — analisi, raccomandazioni, pricing: intoccabili
- **Scan completo sempre** — non fixare un doc senza ground truth
- **Idempotente** — invocare 2 volte = nessun cambiamento la seconda volta
- **Log sintetico** — report breve, non verboso
- **Solo skill locali** — tabelle skill contengono SOLO skill con SKILL.md nel filesystem. Skill esterne in sezione separata

## Anti-pattern

- Chiedere conferma per aggiornare un numero (e' un fatto)
- Riscrivere sezioni intere per un conteggio sbagliato
- Fixare un doc e dimenticare gli altri (sync = TUTTI)
- Aggiornare senza ground truth
- Aggiungere dettagli non richiesti
