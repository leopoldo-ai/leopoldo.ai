---
name: skill-changelog
description: Use for periodic compliance audits, after bulk skill changes, when tracking new installations/updates/removals of skills, or when an audit trail of skill changes is needed. Scans skills/ and compares with a stored snapshot to detect changes, maintaining the audit trail in docs/.
type: technique
---

# Skill Changelog — Audit Trail & Change Tracking

Traccia modifiche alle skill installate nel tempo, mantenendo un audit trail.

## Core Workflow

### 1. Snapshot corrente

Scansionare `skills/**/SKILL.md`. Per ogni skill raccogliere: name, description (100 char), versione, data modifica, file count, hash contenuto.

### 2. Confronto con snapshot precedente

Cercare `docs/SkillSnapshot_*.md`. Confrontare: nuove (presenti ora, non prima), rimosse (prima ma non ora), modificate (stesso nome, hash/versione diversi), invariate.

### 3. Changelog

Riepilogo (tabella: tipo, count, dettaglio). Skill aggiunte (tabella: skill, versione, categoria, security, data). Rimosse (motivo). Modificate (versione prec → corr, cosa cambiato). Azioni richieste (review-skill-safety per nuove, aggiornare CLAUDE.md, aggiornare MEMORY.md se count cambiato).

### 4. Salvare

- Snapshot: `docs/SkillSnapshot_v[X.Y]_[YYYYMMDD].md`
- Changelog: `docs/SkillChangelog_v[X.Y]_[YYYYMMDD].md`
- Aggiornare MEMORY.md se conteggio cambiato

## Rules

- **Snapshot SEMPRE** — salvare ad ogni esecuzione
- **Naming convention** rispettata
- **Azioni esplicite** — segnalare review e aggiornamenti necessari
- **Non eliminare snapshot** — audit trail

## Anti-pattern

- Changelog senza snapshot
- Non segnalare skill non reviewed
- Eliminare snapshot precedenti
- Non aggiornare MEMORY.md
