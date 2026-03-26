---
name: doc-sync
description: Dynamic documentation sync engine — automatically updates all project docs (CLAUDE.md, Design Doc, INSTALL.md, Pitch Deck) when SkillOS state changes. Scans skills/**/SKILL.md to build ground truth, then patches every doc that references outdated counts, paths, structures, or statuses. Runs automatically after skill install/remove, directory changes, or phase milestones. Triggers on "doc aggiornati?", "sync docs", "aggiorna documentazione", skill.installed, directory.restructured.
---

# Doc Sync — Dynamic Documentation Engine

Driver che mantiene **automaticamente** la coerenza tra la documentazione del progetto e lo stato reale di SkillOS. Non si limita a segnalare drift — li corregge.

## Principio

```
Stato reale (filesystem)  →  doc-sync scansiona  →  aggiorna TUTTI i doc
        ↑                                                    ↓
  cambiamento avviene                              doc coerenti, sempre
```

`project-memory` fa questo per il codebase (schema, API, test → PROJECT_STATE.md).
`doc-sync` fa lo stesso per la documentazione di SkillOS (skill count, structure, paths, status → tutti i doc).

## Quando si attiva

| Trigger | Evento | Azione |
|---------|--------|--------|
| **Skill aggiunta/rimossa** | `skill-changelog` rileva cambiamento | Aggiorna conteggi e tabelle in tutti i doc |
| **Directory ristrutturata** | `mv`, `mkdir` su skills/ | Aggiorna alberi directory e path |
| **Fase completata** | `phase-gate` PASS | Aggiorna roadmap status nei doc |
| **Config modificata** | `skill-orch.config.json` cambiato | Aggiorna riferimenti a soglie, fasi, path |
| **Su richiesta** | "doc aggiornati?", "sync docs" | Scan completo + fix |
| **Post-init** | `init` completato | Verifica coerenza come ultimo step |

## Core Workflow

### Fase 1: Build Ground Truth

Scansionare il filesystem e costruire lo stato reale:

```
ground_truth = {
  skill_count: {
    total: N,
    core: N,
    drivers: N,
    packs: N,
    per_pack: { common: N, finance: N, ... }
  },
  structure: {
    core_skills: ["init", "skill-router", ...],
    driver_skills: ["session-reporter", "doc-sync", ...],
    pack_skills: { common: ["api-designer", ...] }
  },
  config: {
    version: "1.0.0",
    phases: [...],
    gate_thresholds: {...},
    discovery_pattern: "skills/**/SKILL.md"
  },
  files: {
    "skill-orch.config.json": exists,
    "CLAUDE.md": exists,
    "INSTALL.md": exists,
    "CLAUDE.md.template": exists,
    ".state/state.json": exists|missing
  },
  roadmap: {
    phase_a: "completed",
    phase_b: "pending",
    ...
  }
}
```

**Come:**
1. `Glob: skills/**/SKILL.md` → conteggi e nomi
2. `ls skills/core/`, `ls skills/drivers/`, `ls skills/packs/*/` → struttura
3. `Read: skill-orch.config.json` → config
4. `Glob: docs/*.md` → lista doc da aggiornare

### Fase 2: Scan & Patch ogni documento

Per ogni documento trovato, **leggere, identificare dati fattuali, e aggiornarli direttamente**.

#### 2.1 Dati fattuali aggiornabili automaticamente

| Dato | Pattern da cercare | Come aggiornare |
|------|-------------------|-----------------|
| **Conteggio skill totale** | `\d+ skill` | Sostituire con `ground_truth.skill_count.total` |
| **Conteggio per layer** | `core.*\d+`, `driver.*\d+`, `pack.*\d+` | Sostituire con conteggi reali |
| **Path di scan** | `skills/*/SKILL.md` (non ricorsivo) | → `skills/**/SKILL.md` |
| **Path deprecati** | `.claude/skills/` | → `skills/` |
| **Albero directory** | Blocchi ``` con tree | Rigenerare da filesystem reale |
| **Status roadmap** | `da avviare`, `COMPLETATA`, checkmark | Aggiornare con stato effettivo |
| **Lista skill in tabelle** | Tabelle markdown con nomi skill | Aggiungere skill mancanti, rimuovere eliminate |
| **Riferimenti a file** | `skill-orch.config.json`, `INSTALL.md`, etc. | Verificare esistenza, aggiornare se rinominati |

#### 2.2 Dati NON toccabili

- Prose strategiche (analisi, raccomandazioni, differenziazione)
- Pricing e modelli di revenue
- Buyer persona e vertical analysis
- Qualsiasi opinione o valutazione qualitativa

### Fase 3: Applicare le fix

**Modalita' default: auto-fix per dati fattuali.**

Per ogni drift rilevato:

1. **Critical (path sbagliati, struttura broken):** Fix immediato con Edit tool
2. **Warning (conteggi, status):** Fix immediato con Edit tool
3. **Info (dettagli estetici):** Segnalare ma non fixare

**Non chiedere conferma per dati fattuali oggettivi** (conteggi, path, struttura). Questi sono fatti, non opinioni — aggiornarli e' sempre corretto.

**Chiedere conferma solo per:**
- Aggiunta/rimozione di righe in tabelle skill
- Modifica di blocchi di testo (non singoli valori)
- Qualsiasi cosa che tocca contenuto narrativo vicino ai dati

### Fase 4: Report sintetico

Dopo aver applicato le fix, presentare un sommario:

```markdown
## Doc Sync completato

| Documento | Fix applicate | Dettaglio |
|-----------|--------------|-----------|
| CLAUDE.md | 3 | Conteggio 73→74, path ricorsivo, aggiunta doc-sync |
| Design Doc | 2 | Albero directory, roadmap status |
| INSTALL.md | 0 | Gia' aggiornato |
| Pitch Deck | 1 | Conteggio skill |

**Totale:** [N] fix su [M] documenti
```

## Integrazione con altre skill

### Trigger chain (quando L3 Event Layer sara' attivo)

```
skill-changelog rileva nuova skill
    → doc-sync.sync()
        → aggiorna CLAUDE.md (tabella skill)
        → aggiorna Design Doc (conteggi, struttura)
        → aggiorna INSTALL.md (se struttura cambiata)
```

```
phase-gate PASS su Fase B
    → doc-sync.sync()
        → aggiorna Design Doc roadmap (Fase B ✅)
        → aggiorna prossimi passi
```

### Oggi (senza L3): invocazione manuale o da init

```
init (boot sequence)
    → Fase 4: Health check
        → include doc-sync come ultimo check
        → se drift rilevati, fixare automaticamente
```

## Esempio concreto

**Scenario:** Aggiungo una nuova skill `portfolio-monitor` in `skills/packs/finance/`.

**Senza doc-sync:** Devo manualmente aggiornare CLAUDE.md (aggiungere riga tabella, cambiare conteggio 74→75), Design Doc (conteggio, struttura directory se nuovo pack), INSTALL.md (se menziona conteggi), Pitch Deck (se menziona conteggi).

**Con doc-sync:**
1. Installo la skill
2. Invoco `doc-sync` (o si triggera automaticamente)
3. doc-sync: rileva 75 skill, nuovo pack `finance/`, aggiorna tutti i doc
4. Ricevo report: "4 fix su 3 documenti"

## Regole

- **Auto-fix dati fattuali** — Conteggi, path, strutture sono fatti: aggiornarli senza chiedere
- **Mai toccare prose** — Analisi, raccomandazioni, pricing: intoccabili
- **Scan completo sempre** — Non fixare un doc senza aver prima scansionato lo stato reale
- **Idempotente** — Invocare doc-sync 2 volte di fila non deve cambiare nulla la seconda volta
- **Log sintetico** — Report breve, non verboso. L'utente vuole sapere "cosa hai fixato", non leggere un trattato
- **Solo skill locali nelle tabelle** — Le tabelle skill in CLAUDE.md devono contenere SOLO skill che hanno un corrispondente SKILL.md nel filesystem locale. Skill esterne (es. plugin Claude Code, MCP skill, skill di altri tool) vanno in una sezione separata "External Skills" o rimosse dalla tabella. Ground truth = filesystem.

## Anti-pattern

- Chiedere conferma per aggiornare "73" a "74" (e' un fatto, non un'opinione)
- Riscrivere sezioni intere per un conteggio sbagliato
- Fixare un doc e dimenticare gli altri (sync = TUTTI i doc)
- Aggiornare doc senza ground truth (prima scansiona, poi fixa)
- Aggiungere dettagli non richiesti ai doc ("gia' che ci sono, miglioro anche...")

---

**Versione:** 2.0 (riscritto: da checker passivo a sync engine dinamico)
**Tipo:** Driver (infrastruttura)
**Dipendenze:** Glob tool, Read tool, Edit tool, Grep tool
**Si integra con:** init (post-boot sync), skill-changelog (trigger su cambiamenti), phase-gate (trigger su milestone), project-memory (complementare — codebase vs docs)
