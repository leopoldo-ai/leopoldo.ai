---
name: skill-changelog
description: Tracks changes to installed skills over time — new installations, updates, removals. Scans skills/ and compares with a stored snapshot to detect changes (path configurable via skill-orch.config.json). Maintains an audit trail in docs/. Use periodically for compliance, or after bulk skill changes.
---

# Skill Changelog — Audit Trail & Change Tracking

Meta-skill che traccia le modifiche alle skill installate nel tempo, mantenendo un audit trail per compliance e manutenzione.

**Contesto:** Skill set in crescita (da 42 a 63+), serve tracciabilita' delle modifiche.

## Core Workflow

### Fase 1: Snapshot corrente

1. **Scansionare `skills/**/SKILL.md`** con Glob
2. **Per ogni skill, raccogliere:**
   - `name`
   - `description` (primi 100 caratteri)
   - Versione (se presente)
   - Data ultima modifica del file (da filesystem)
   - Numero file nella directory
   - Hash del contenuto SKILL.md (per detect modifiche)
3. **Costruire snapshot:**
   ```json
   {
     "date": "2026-02-27",
     "skills": [
       {
         "name": "skill-router",
         "version": "1.0",
         "files": 1,
         "modified": "2026-02-27",
         "hash": "abc123..."
       }
     ]
   }
   ```

### Fase 2: Confronto con snapshot precedente

1. **Cercare snapshot precedente:** `docs/SkillSnapshot_*.md`
2. **Se esiste, confrontare:**
   - **Nuove skill** — Presenti nello snapshot corrente ma non nel precedente
   - **Rimosse** — Presenti nel precedente ma non nel corrente
   - **Modificate** — Stesso name ma hash diverso o versione diversa
   - **Invariate** — Stesso name, stesso hash
3. **Se non esiste snapshot precedente**, tutto e' "nuovo" (prima esecuzione)

### Fase 3: Generare changelog

```markdown
# Skill Changelog — [Data corrente]
**Confronto con:** [Data snapshot precedente] (o "Prima esecuzione")
**Skill totali:** [N] (precedente: [M])

## Riepilogo cambiamenti

| Tipo | Count | Dettaglio |
|------|-------|-----------|
| Nuove | [N] | [Lista nomi] |
| Rimosse | [N] | [Lista nomi] |
| Modificate | [N] | [Lista nomi] |
| Invariate | [N] | — |

## Dettaglio cambiamenti

### Skill aggiunte
| Skill | Versione | Categoria | Security | Data |
|-------|----------|-----------|----------|------|
| `skill-router` | 1.0 | Meta-skill | Da revieware | 2026-02-27 |
| `audit-coordinator` | 1.0 | Meta-skill | Da revieware | 2026-02-27 |

### Skill rimosse
| Skill | Motivo (se noto) |
|-------|-----------------|
| [skill] | [Motivo] |

### Skill modificate
| Skill | Versione prec. | Versione corr. | Cosa e' cambiato |
|-------|---------------|----------------|------------------|
| [skill] | 1.0 | 1.1 | [Descrizione modifica] |

### Azioni richieste

| Azione | Skill | Motivo |
|--------|-------|--------|
| `/review-skill-safety` | [nuove skill] | Regola 2: tutte le skill devono essere reviewed |
| Aggiornare CLAUDE.md | [nuove/rimosse] | Mantenere la tabella skill aggiornata |
| Aggiornare MEMORY.md | [se conteggio cambiato] | Mantenere il conteggio skill aggiornato |

## Cronologia completa

| Data | Evento | Skill | Dettaglio |
|------|--------|-------|-----------|
| 2026-02-27 | Aggiunta | skill-router | Meta-skill routing v1.0 |
| 2026-02-27 | Aggiunta | phase-gate | Meta-skill gating v1.0 |
| 2026-02-27 | Aggiunta | audit-coordinator | Meta-skill security v1.0 |
| ... |
```

### Fase 4: Salvare snapshot aggiornato

1. **Salvare snapshot:** `docs/SkillSnapshot_v1.0_[YYYYMMDD].md`
2. **Salvare changelog:** `docs/SkillChangelog_v1.0_[YYYYMMDD].md`
3. **Aggiornare MEMORY.md** con il nuovo conteggio skill (se cambiato)

## Regole

- **Snapshot SEMPRE** — Salvare uno snapshot ad ogni esecuzione per confronti futuri
- **Naming convention** — `SkillSnapshot_v[X.Y]_[YYYYMMDD].md` e `SkillChangelog_v[X.Y]_[YYYYMMDD].md`
- **Azioni esplicite** — Segnalare sempre se servono review-skill-safety o aggiornamenti CLAUDE.md
- **Non eliminare snapshot** — Tenere la cronologia per audit trail

## Anti-pattern

- Changelog senza snapshot (impossibile confrontare al prossimo run)
- Non segnalare skill non reviewed
- Eliminare snapshot precedenti
- Non aggiornare MEMORY.md quando cambia il conteggio

---

**Versione:** 1.0
**Tipo:** Meta-skill con dynamic discovery
**Dipendenze:** Glob tool, Read tool, Write tool (per salvare snapshot)
