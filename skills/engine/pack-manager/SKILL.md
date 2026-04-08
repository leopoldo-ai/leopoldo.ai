---
name: pack-manager
version: 1.0.0
description: Package manager for SkillOS packs — install, remove, list, update packs from local directories or Git repositories. Reads PACK.md manifests, verifies integrity, runs review-skill-safety, and updates skill-orch.config.json. Use with "skillos install <pack>", "skillos remove <pack>", "skillos list", "skillos update <pack>".
skillos:
  layer: core
  category: meta
  pack: null
  requires:
    hard: []
    soft: ["review-skill-safety"]
  provides: ["pack-install", "pack-remove", "pack-list", "pack-update"]
  triggers: []
  config: {}
---

# Pack Manager — SkillOS Package Manager

Core skill che gestisce l'installazione, rimozione, listing e aggiornamento dei pack di skill. Opera su `skills/packs/` e aggiorna `skill-orch.config.json`.

## Concetti

### Pack

Un **pack** e' una raccolta di skill correlate, distribuite insieme. Ogni pack ha:

- Una directory sotto `skills/packs/`
- Un file `PACK.md` (manifest) nella root della directory
- Una o piu' skill, ciascuna nella propria sub-directory con `SKILL.md`

### PACK.md — Manifest

Ogni pack deve avere un file `PACK.md` nella sua root:

```yaml
---
name: fo-essential
version: 1.0.0
description: Family Office Essential — skill pack per family office operations
author: lucadealbertis
license: proprietary
skillos_min_version: "0.3.0"
skills:
  - due-diligence-framework
  - client-reporter
  - portfolio-monitor
  - deal-screener
  - compliance-checker
  - board-pack-generator
dependencies:
  packs: ["common"]
  skills: ["data-visualization", "xlsx-reports", "docx-reports"]
tags: ["finance", "family-office", "compliance", "reporting"]
---

# FO Essential — Family Office Skill Pack

Pack di skill specializzate per family office: due diligence, reporting clienti, monitoraggio portafoglio, compliance.

## Skill incluse

| Skill | Scopo | Priorita' |
|-------|-------|-----------|
| `due-diligence-framework` | Analisi investimento multi-dimensionale | P0 |
| `client-reporter` | Report personalizzato per HNWI | P0 |
| `portfolio-monitor` | Monitoraggio portafoglio real-time | P1 |
| `deal-screener` | Screening rapido opportunita' | P1 |
| `compliance-checker` | Verifica compliance MiFID II, GDPR | P1 |
| `board-pack-generator` | Board meeting pack automatico | P2 |

## Requisiti

- SkillOS >= 0.3.0
- Pack `common` installato (per data-visualization, xlsx-reports, docx-reports)

## Setup

Dopo l'installazione, configurare le variabili specifiche in skill-orch.config.json.
```

## Operazioni

### 1. `install` — Installare un pack

**Comando:** `skillos install <source>`

**Source supportate:**

| Source | Formato | Esempio |
|--------|---------|---------|
| Locale | Path a directory con PACK.md | `skillos install ./my-packs/fo-essential` |
| Git | URL repository Git | `skillos install https://github.com/org/skillos-pack-finance` |
| Nome pack (registry) | Nome registrato nel registry locale | `skillos install fo-essential` |

**Workflow install:**

1. **Risolvere source:**
   - Se path locale: verificare che esista PACK.md
   - Se URL Git: `git clone` in directory temporanea, verificare PACK.md
   - Se nome: cercare nel registry locale (`skill-orch.config.json.pack_registry`)

2. **Leggere PACK.md** e validare:
   - `name` e `version` presenti
   - `skillos_min_version` compatibile con versione corrente
   - `dependencies.packs` — pack richiesti sono installati?
   - `dependencies.skills` — skill richieste sono disponibili?

3. **Security review:**
   - Invocare `review-skill-safety` su ogni SKILL.md nel pack
   - Se UNSAFE: **BLOCCARE** installazione, informare utente
   - Se CAUTION: WARNING, chiedere conferma all'utente
   - Se SAFE: proseguire

4. **Copiare skill:**
   - Creare directory `skills/packs/[pack-name]/`
   - Copiare PACK.md e tutte le sub-directory skill
   - Verificare che ogni skill abbia SKILL.md valido

5. **Aggiornare skill-orch.config.json:**
   - Aggiungere `[pack-name]` a `installed_packs[]`

6. **Presentare risultato:**
   ```markdown
   ## Pack installato: [name] v[version]

   | Skill | Security | Stato |
   |-------|----------|-------|
   | `skill-a` | SAFE | Installata |
   | `skill-b` | CAUTION (no-license) | Installata con warning |

   **Azione richiesta:** Rigenerare CLAUDE.md con `/init`
   ```

### 2. `remove` — Rimuovere un pack

**Comando:** `skillos remove <pack-name>`

**Workflow remove:**

1. **Verificare che il pack esista** in `skills/packs/[pack-name]/`
2. **Controllare dipendenze inverse:**
   - Ci sono altri pack che dipendono da questo?
   - Se si: WARNING, chiedere conferma
3. **Rimuovere directory** `skills/packs/[pack-name]/`
4. **Aggiornare skill-orch.config.json:**
   - Rimuovere da `installed_packs[]`
5. **Informare:** "Pack rimosso. Rigenerare CLAUDE.md con `/init`"

**Protezioni:**
- **MAI rimuovere `common`** senza conferma esplicita (e' il pack base)
- **MAI rimuovere skill core o driver** (non sono pack)

### 3. `list` — Elencare pack installati

**Comando:** `skillos list`

**Workflow list:**

1. **Scansionare `skills/packs/*/PACK.md`** con Glob
2. **Per ogni PACK.md:** estrarre name, version, description, skill count
3. **Presentare:**

```markdown
## Pack installati

| Pack | Versione | Skill | Descrizione |
|------|----------|-------|-------------|
| `common` | 1.0.0 | 60 | Skill condivise (TDD, review, debug, ...) |
| `fo-essential` | 1.0.0 | 6 | Family Office Essential |

**Totale:** 2 pack, 66 skill di dominio
**Core:** 8 skill kernel | **Drivers:** 9 skill infrastruttura
**Grand total:** 83 skill
```

### 4. `update` — Aggiornare un pack

**Comando:** `skillos update <pack-name>`

**Workflow update:**

1. **Leggere PACK.md attuale** — versione corrente
2. **Se source e' Git:** `git pull` nella directory temporanea
3. **Confrontare versioni:** se la nuova e' > della corrente, procedere
4. **Security review** sulle skill nuove/modificate
5. **Backup** del pack corrente in `.state/snapshots/pack_[name]_[version]/`
6. **Sovrascrivere** con la nuova versione
7. **Verificare compatibilita'** skillos_min_version
8. **Informare** risultato con changelog se disponibile

### 5. `create` — Scaffoldare un nuovo pack

**Comando:** `skillos create <pack-name>`

**Workflow create:**

1. **Creare directory** `skills/packs/[pack-name]/`
2. **Generare PACK.md** template:
   ```yaml
   ---
   name: [pack-name]
   version: 0.1.0
   description: [chiedere all'utente]
   author: [da skill-orch.config.json o chiedere]
   license: proprietary
   skillos_min_version: "0.3.0"
   skills: []
   dependencies:
     packs: ["common"]
     skills: []
   tags: []
   ---
   ```
3. **Aggiungere a skill-orch.config.json** `installed_packs[]`
4. **Informare:** "Pack [name] creato. Aggiungere skill con directory + SKILL.md"

## Pack Registry (locale)

Il registry e' una sezione opzionale in `skill-orch.config.json`:

```json
{
  "pack_registry": {
    "fo-essential": {
      "source": "https://github.com/org/skillos-pack-fo-essential",
      "version": "1.0.0",
      "installed_at": "2026-03-01T00:00:00Z"
    },
    "common": {
      "source": "local",
      "version": "1.0.0",
      "installed_at": "2026-03-01T00:00:00Z"
    }
  }
}
```

## Regole

- **PACK.md obbligatorio** — Nessun pack senza manifest
- **Security review obbligatoria** — Ogni skill viene verificata prima dell'installazione
- **Core e drivers intoccabili** — Il pack-manager gestisce SOLO `skills/packs/`
- **Backup prima di update** — Sempre creare snapshot del pack prima di sovrascrivere
- **Config aggiornato** — Ogni operazione aggiorna `installed_packs[]`
- **Non auto-rigenerare CLAUDE.md** — Suggerire all'utente di invocare `/init`

## Anti-pattern

- Installare pack senza security review
- Rimuovere `common` senza verificare dipendenze
- Aggiornare senza backup
- Pack senza PACK.md (non e' un pack, e' una directory random)
- Modificare skill core/driver tramite pack-manager
- Usare `cp -r source/skills/ dest/skills/` per copiare la struttura — puo' unire il contenuto invece di preservare la gerarchia. Usare invece: `mkdir -p dest/skills/{core,drivers,packs}` e poi `cp -R source/skills/core/* dest/skills/core/` per ogni layer separatamente.

---

**Versione:** 1.0.0 (Fase D — Packaging & Distribution)
**Tipo:** Core skill (pack management)
**Dipendenze:** Glob tool, Read tool, Write tool, Bash tool (per git clone/cp), review-skill-safety, AskUserQuestion
