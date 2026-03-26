---
name: skill-inventory
description: Generates a complete inventory of all installed skills with metadata, security status, phase mapping, and health checks. Scans skills/ at runtime (path configurable via skill-orch.config.json) and cross-references with CLAUDE.md. Use for periodic maintenance, onboarding, or when you need to understand what tools are available.
---

# Skill Inventory — Complete Skill Registry

Meta-skill che genera un inventario completo e aggiornato di tutte le skill installate nel progetto.

**Contesto:** 63+ skill (e in crescita). Serve una vista d'insieme aggiornata.

## Core Workflow

### Fase 1: Scansione completa

1. **Scansionare `skills/**/SKILL.md`** con Glob
2. **Per ogni skill, estrarre:**
   - `name` (frontmatter)
   - `description` (frontmatter)
   - Versione (se presente nel body)
   - Tipo (meta-skill / domain skill / quality / security / reporting)
   - File di riferimento (contare file in `references/` se esistono)
   - Dimensione totale (bytes della directory)
3. **Leggere CLAUDE.md** per:
   - Security status (SAFE / CAUTION)
   - Fonte (GitHub repo / catalogo / custom)
   - Fase di appartenenza nel workflow

### Fase 2: Classificazione

Categorizzare ogni skill:

| Categoria | Criteri |
|-----------|---------|
| **Meta-skill** | Ha dynamic discovery, orchestra altre skill |
| **Domain** | Expertise specifica (frontend, backend, DB, email, ecc.) |
| **Quality** | TDD, debugging, review, verification |
| **Security** | Audit, pen test, static analysis, threat modeling |
| **Reporting** | Genera deliverable (docx, xlsx, pptx) |
| **Strategy** | Analisi strategica, decisionale |
| **Orchestration** | Workflow, planning, gating |

### Fase 3: Health Check

Per ogni skill, verificare:

| Check | Come | Risultato |
|-------|------|-----------|
| **Presente in CLAUDE.md?** | Grep nel CLAUDE.md | Mappata / Orfana |
| **Security reviewed?** | Colonna Security in CLAUDE.md | SAFE / CAUTION / Non reviewed |
| **Ha file di riferimento?** | Check `references/` directory | Si ([N] file) / No |
| **Frontmatter valido?** | Parse YAML | Valido / Warning |
| **Assegnata a una fase?** | Cross-ref con workflow CLAUDE.md | Fase [N] / Non assegnata |
| **Filename corretto?** | Verificare che il file sia `SKILL.md` (uppercase), non `skill.md` o varianti | Corretto / **ERRORE: filename case errato** |

**Nota:** Il discovery (`find -name "SKILL.md"`) e' case-sensitive. Un file `skill.md`
non verra' scoperto e la skill sara' invisibile al sistema. Questo check deve
anche scansionare `find skills -iname "skill.md"` e confrontare con
`find skills -name "SKILL.md"` per trovare varianti con case sbagliato.

### Fase 4: Report inventario

```markdown
# Skill Inventory
**Data:** [YYYY-MM-DD]
**Totale skill installate:** [N]

## Sommario per categoria

| Categoria | Count | SAFE | CAUTION | Non reviewed |
|-----------|-------|------|---------|-------------|
| Meta-skill | [N] | [N] | [N] | [N] |
| Domain | [N] | [N] | [N] | [N] |
| Quality | [N] | [N] | [N] | [N] |
| Security | [N] | [N] | [N] | [N] |
| Reporting | [N] | [N] | [N] | [N] |
| Strategy | [N] | [N] | [N] | [N] |
| Orchestration | [N] | [N] | [N] | [N] |
| **TOTALE** | **[N]** | **[N]** | **[N]** | **[N]** |

## Inventario completo

| # | Skill | Categoria | Fonte | Security | Fase | Ref files | Health |
|---|-------|-----------|-------|----------|------|-----------|--------|
| 1 | skill-router | Meta-skill | Custom | SAFE | All | 0 | OK |
| 2 | semgrep | Security | trailofbits | SAFE | 4 | 0 | OK |
| ... |

## Health Check

### Skill orfane (non in CLAUDE.md)
| Skill | Azione suggerita |
|-------|-----------------|
| [skill] | Aggiungere a CLAUDE.md o rimuovere |

### Skill non reviewed
| Skill | Azione suggerita |
|-------|-----------------|
| [skill] | Eseguire /review-skill-safety |

### Skill senza fase assegnata
| Skill | Azione suggerita |
|-------|-----------------|
| [skill] | Assegnare a Fase [N] nel workflow |

## Copertura per fase workflow

| Fase | Skill assegnate | Coverage |
|------|----------------|----------|
| 0 — PRD Closure | [N] | [Lista] |
| 1 — Pianificazione | [N] | [Lista] |
| 2 — Scaffold | [N] | [Lista] |
| 3 — Build Loop | [N] | [Lista] |
| 4 — Sicurezza & AI | [N] | [Lista] |
| 5 — Deploy | [N] | [Lista] |
```

## Regole

- **Scansione completa** — Non tralasciare nessuna skill
- **Cross-reference obbligatorio** — Sempre confrontare filesystem vs CLAUDE.md
- **Segnalare anomalie** — Skill orfane, non reviewed, senza fase
- **Naming convention** — Se il report viene salvato: `SkillInventory_v[X.Y]_[YYYYMMDD].md`

## Anti-pattern

- Inventario basato solo su CLAUDE.md (potrebbe essere outdated)
- Inventario basato solo su filesystem (perde metadata security/fonte)
- Non segnalare skill orfane o non reviewed
- Report troppo lungo senza sommario esecutivo

---

**Versione:** 1.0
**Tipo:** Meta-skill con dynamic discovery
**Dipendenze:** Glob tool, Read tool, Grep tool
