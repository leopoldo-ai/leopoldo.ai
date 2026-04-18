---
name: skill-inventory
description: Use when running /scan-skills, doing periodic maintenance, onboarding a new project, auditing installed skills with metadata and security status, checking phase mapping or health, or when the user asks what tools are available. Scans skills/ at runtime and cross-references with CLAUDE.md.
type: technique
---

# Skill Inventory — Complete Skill Registry

Genera un inventario completo di tutte le skill installate con metadata, security, e health check.

## Core Workflow

### 1. Scansione completa

Scansionare `skills/**/SKILL.md`. Per ogni skill estrarre: name, description, versione, tipo, file di riferimento, dimensione. Leggere CLAUDE.md per security status, fonte, fase.

### 2. Classificazione

| Categoria | Criteri |
|---|---|
| Meta-skill | Dynamic discovery, orchestra altre skill |
| Domain | Expertise specifica (frontend, backend, DB, etc.) |
| Quality | TDD, debugging, review, verification |
| Security | Audit, pen test, static analysis, threat modeling |
| Reporting | Genera deliverable (docx, xlsx, pptx) |
| Strategy | Analisi strategica, decisionale |
| Orchestration | Workflow, planning, gating |

### 3. Health Check

Per ogni skill verificare:

| Check | Risultato |
|---|---|
| Presente in CLAUDE.md? | Mappata / Orfana |
| Security reviewed? | SAFE / CAUTION / Non reviewed |
| Ha file di riferimento? | Si (N file) / No |
| Frontmatter valido? | Valido / Warning |
| Assegnata a fase? | Fase N / Non assegnata |
| Filename corretto? | SKILL.md (uppercase) / **ERRORE: case errato** |

**Nota:** discovery e' case-sensitive. `skill.md` non viene scoperto. Scansionare anche `find -iname "skill.md"` per trovare varianti con case sbagliato.

### 4. Report

Sommario per categoria (count, SAFE, CAUTION, non reviewed). Inventario completo (tabella: #, skill, categoria, fonte, security, fase, ref files, health). Health check: skill orfane, non reviewed, senza fase. Copertura per fase workflow.

## Rules

- **Scansione completa** — non tralasciare nessuna skill
- **Cross-reference obbligatorio** — filesystem vs CLAUDE.md
- **Segnalare anomalie** — orfane, non reviewed, senza fase
- **Naming:** `SkillInventory_v[X.Y]_[YYYYMMDD].md`

## Anti-pattern

- Inventario solo da CLAUDE.md (potrebbe essere outdated)
- Inventario solo da filesystem (perde metadata security/fonte)
- Non segnalare orfane o non reviewed
- Report senza sommario esecutivo
