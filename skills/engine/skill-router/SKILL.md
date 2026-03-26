---
name: skill-router
version: 2.1.0
description: Routes user requests to the most relevant skills via dynamic discovery. Scans skills/**/SKILL.md at runtime (path configurable via skill-orch.config.json), extracts name+description, and matches semantically to the user's intent. Dispatches skill.invoke events through event-dispatcher for pre/post hook execution. Use when unsure which skill to invoke, or at session start to identify the right tools for the task.
skillos:
  layer: core
  category: meta
  pack: null
  requires:
    hard: []
    soft: ["event-dispatcher"]
  provides: ["routing", "skill-matching"]
  triggers: []
  config: {}
---

# Skill Router — Dynamic Discovery, Matching & Event Dispatch

Meta-skill che scansiona tutte le skill installate, suggerisce le 2-5 piu' rilevanti per la richiesta corrente, e dispatcha eventi `skill.invoke` attraverso l'event-dispatcher per attivare la middleware chain.

**Contesto:** Progetto con molte skill installate, routing manuale da CLAUDE.md non scala.

## Core Workflow

### Fase 1: Discovery — Scansione skill disponibili

**Ad ogni invocazione, scoprire le skill disponibili a runtime. Mai usare liste hardcoded.**

1. **Scansionare il filesystem:**
   ```
   Glob: skills/**/SKILL.md (pattern da skill-orch.config.json.skill_discovery.pattern)
   Exclude: skill-orch.config.json.skill_discovery.exclude
   ```
2. **Per ogni SKILL.md trovato, estrarre:**
   - `name` dal frontmatter
   - `description` dal frontmatter
   - `skillos.layer` dal frontmatter (se presente)
   - `skillos.requires` dal frontmatter (se presente)
   - Prima riga del body (solitamente il titolo/scopo)
3. **Costruire indice runtime:**
   ```
   skill_index = [
     { name: "strategy-advisor", description: "Framework strategico...", layer: "userland", domain: "strategy" },
     { name: "semgrep", description: "Static analysis...", layer: "userland", domain: "security" },
     ...
   ]
   ```

### Fase 2: Classificazione richiesta utente

Analizzare la richiesta e classificarla in uno o piu' domini:

| Dominio | Keywords indicative |
|---------|---------------------|
| **strategy** | strategia, roadmap, decisione, SWOT, priorita', opzioni |
| **development** | codice, implementare, build, feature, bug, fix, Next.js, API |
| **database** | query, schema, migrazione, PostgreSQL, Drizzle, Neon, dati |
| **frontend** | UI, dashboard, componente, design, layout, shadcn, Tremor |
| **security** | sicurezza, audit, vulnerabilita', OWASP, pen test, review |
| **testing** | test, TDD, coverage, E2E, Playwright, unit test |
| **email** | email, campagna, deliverability, ESP, newsletter, automation |
| **ai** | AI, RAG, embedding, prompt, scoring, search semantica |
| **deploy** | deploy, Vercel, preview, produzione, CI/CD |
| **planning** | sprint, task, backlog, PRD, decomposizione, dipendenze |
| **reporting** | report, deliverable, Excel, Word, presentazione |
| **change-mgmt** | comunicazione, adoption, change, onboarding, formazione |
| **orchestration** | board, meta-skill, fase, gate, workflow |
| **quality** | review, code quality, refactoring, debugging |

### Fase 2.5: Intent Preset Boost

Prima del matching, verificare se l'intent matcha un preset configurato:

1. **Leggere `intent_presets`** da `skill-orch.config.json`
2. **Per ogni preset**, verificare se l'intent utente contiene uno dei `patterns`:
   - Match case-insensitive
   - Match word boundary (non substring: "fund" NON matcha "refunding")
   - Pattern con caratteri speciali (es. "M&A") trattati come literal
3. **Se match trovato:** le skill appartenenti ai `packs` indicati ricevono un priority boost in Fase 3
4. **Se piu' preset matchano:** i pack si sommano (union), tutti con stesso boost weight
5. **Validazione:** i pack nei preset devono essere presenti in `installed_packs` — pack non installati vengono ignorati con warning

**Esempio:** Utente chiede "devo fare una due diligence su un target"
- Match preset: `["due diligence", "deal", "target"]` → packs: `["deal-engine", "investment-core"]`
- Fase 3 prioritizza skill da deal-engine e investment-core, ma skill da altri pack restano candidate

**Principio:** I preset **arricchiscono**, non sostituiscono la discovery dinamica. Se nessun preset matcha, Fase 3 lavora esattamente come prima.

### Fase 3: Matching — Selezionare skill rilevanti

1. **Match primario:** Skill il cui `description` contiene keyword del dominio identificato
2. **Match secondario:** Skill il cui `name` corrisponde parzialmente al dominio
3. **Ranking:** Ordinare per rilevanza (match description > match name > match domain generico)
4. **Priority boost:** Skill da pack matchati in Fase 2.5 ricevono bonus ranking (salgono nella lista)
5. **Filtrare:** Massimo 5 skill, minimo 2
6. **Cross-reference:** Verificare da `.state/state.json` la fase corrente — priorita' a skill della fase attiva
7. **Skill health:** Consultare `.state/state.json.skills.health` — de-prioritizzare skill con status `degraded` o `broken`

### Fase 4: Output — Raccomandazione

Presentare all'utente in questo formato:

```markdown
## Skill suggerite per: "[richiesta sintetizzata]"

| # | Skill | Perche' | Priorita' |
|---|-------|---------|-----------|
| 1 | `skill-name` | Motivo specifico del match | Primaria |
| 2 | `skill-name` | Motivo specifico del match | Primaria |
| 3 | `skill-name` | Motivo specifico del match | Secondaria |

**Workflow suggerito:** Invocare in ordine: 1 → 2 → 3
**Fase corrente:** [N] — [nome fase] (da state.json)
```

### Fase 5: Dispatch evento — Invocazione con middleware chain

Quando l'utente conferma la skill da invocare:

1. **Costruire payload evento:**
   ```json
   {
     "skill": "nome-skill",
     "layer": "userland|core|driver",
     "trigger": "user|auto|suggest",
     "context": "descrizione breve del contesto"
   }
   ```

2. **Dispatchare evento `skill.invoke`** attraverso l'event-dispatcher:
   ```
   dispatch("skill.invoke", payload)
   ```

3. **La middleware chain esegue:**
   - **PRE:** `dependency-checker.verify` (se `layer == 'userland'`)
     - Se BLOCK: skill NON viene invocata, mostrare motivazione e prerequisiti mancanti
     - Se PASS: proseguire
   - **AZIONE:** Invocazione effettiva della skill
   - **POST:** `session-lifecycle.journal-append` (registra invocazione nel journal)

4. **Al completamento della skill**, dispatchare `skill.complete`:
   ```json
   {
     "skill": "nome-skill",
     "outcome": "success|warning|error",
     "duration_seconds": N
   }
   ```

### Fase 6: Gestione blocco PRE-hook

Se `dependency-checker.verify` blocca l'invocazione:

```markdown
## Invocazione bloccata: `skill-name`

**Motivo:** Prerequisiti non soddisfatti

| Prerequisito | Tipo | Stato |
|-------------|------|-------|
| `tdd-red-green-refactor` | HARD | Mancante |
| `verification-gate` | HARD | Mancante |

**Azioni suggerite:**
1. Invocare prima `tdd-red-green-refactor`
2. Procedere con l'implementazione
3. Invocare `verification-gate`
4. Riprovare l'invocazione di `skill-name`
```

## Regole

- **Discovery SEMPRE a runtime** — Mai hardcodare la lista skill
- **Dispatch SEMPRE via event-dispatcher** — Per garantire middleware chain
- **Non auto-invocare** — Suggerire e attendere conferma utente (tranne mode=auto)
- **Contesto progetto** — Usare state.json per fase corrente e skill health
- **Skill mancanti** — Se nessuna skill matcha, segnalarlo esplicitamente
- **Meta-skill incluse** — Il router puo' suggerire anche altre meta-skill
- **No dispatch ricorsivo** — Il router NON dispatcha eventi per la propria invocazione

## Anti-pattern

- Suggerire piu' di 5 skill (information overload)
- Suggerire skill non installate localmente (violare Regola 1 CLAUDE.md)
- Invocare skill senza conferma utente
- Ignorare la fase corrente del workflow
- Bypassare l'event-dispatcher invocando skill direttamente
- Ignorare il blocco del dependency-checker

---

**Versione:** 2.0.0 (Fase C — Event Layer integration)
**Tipo:** Core meta-skill con dynamic discovery + event dispatch
**Dipendenze:** Glob tool, Read tool, event-dispatcher, .state/state.json
**Changelog:**
- v1.0: Discovery + matching + raccomandazione
- v2.0: Integrazione event-dispatcher, dispatch skill.invoke/skill.complete, skill health awareness, state.json integration
- v2.1: Fase 2.5 — Intent preset boost da skill-orch.config.json.intent_presets
