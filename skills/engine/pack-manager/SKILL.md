---
name: pack-manager
version: 1.0.0
description: Use when the user runs "skillos install <pack>", "skillos remove <pack>", "skillos list", or "skillos update <pack>", or requests package management for SkillOS packs from local directories or Git repositories. Reads PACK.md manifests, verifies integrity, runs review-skill-safety, updates skill-orch.config.json.
type: technique
---

# Pack Manager — SkillOS Package Manager

Gestisce installazione, rimozione, listing e aggiornamento dei pack di skill. Opera su `skills/packs/` e aggiorna `skill-orch.config.json`.

## Concetti

**Pack:** raccolta di skill correlate con directory sotto `skills/packs/`, file `PACK.md` (manifest), e sub-directory con SKILL.md.

**PACK.md:** frontmatter YAML con name, version, description, author, license, skillos_min_version, skills list, dependencies (packs + skills), tags.

## Operazioni

### install

**Source:** path locale, URL Git, o nome dal registry locale.

1. Risolvere source → verificare PACK.md
2. Validare: name/version presenti, skillos_min_version compatibile, dependencies soddisfatte
3. **Security review:** invocare `review-skill-safety` su ogni SKILL.md. UNSAFE → BLOCCO. CAUTION → warning + conferma
4. Copiare skill in `skills/packs/[name]/`
5. Aggiornare `installed_packs[]` in config
6. Report: tabella skill installate con stato security

### remove

1. Verificare pack esiste
2. Controllare dipendenze inverse → warning se altri pack dipendono
3. Rimuovere directory
4. Aggiornare config
5. **MAI rimuovere `common`** senza conferma esplicita
6. **MAI rimuovere skill core o driver** (non sono pack)

### list

Scansionare `skills/packs/*/PACK.md` → tabella: pack, versione, skill count, descrizione. Totale pack + skill.

### update

1. Leggere PACK.md attuale → versione
2. Se Git: pull
3. Nuova versione > corrente → procedere
4. Security review su skill nuove/modificate
5. **Backup** in `.state/snapshots/pack_[name]_[version]/`
6. Sovrascrivere
7. Verificare compatibilita'
8. Report con changelog

### create

Scaffoldare nuovo pack: creare directory + PACK.md template + aggiungere a config.

## Pack Registry

Sezione opzionale in config: `pack_registry` con source (local/URL), version, installed_at per ogni pack.

## Rules

- **PACK.md obbligatorio** — nessun pack senza manifest
- **Security review obbligatoria** — ogni skill verificata prima dell'installazione
- **Core e drivers intoccabili** — pack-manager gestisce SOLO `skills/packs/`
- **Backup prima di update** — sempre snapshot prima di sovrascrivere
- **Config aggiornato** — ogni operazione aggiorna `installed_packs[]`
- **Non auto-rigenerare CLAUDE.md** — suggerire `/init`

## Anti-pattern

- Installare pack senza security review
- Rimuovere `common` senza verificare dipendenze
- Aggiornare senza backup
- Pack senza PACK.md
- Modificare skill core/driver tramite pack-manager
- Usare `cp -r` per copiare struttura (puo' unire contenuto). Usare `mkdir -p` + `cp -R` per layer separatamente
