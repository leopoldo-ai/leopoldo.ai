---
name: dependency-checker
description: Use for build loop sequencing, on skill.invoke events, or when verifying that prerequisite skills executed before dependent ones. Maintains a skill dependency graph and checks execution order at runtime. Can be invoked directly or auto-triggered via event-dispatcher.
type: discipline
---

# Dependency Checker — Skill Execution Order Validator

Meta-skill che verifica che le skill siano state eseguite nell'ordine corretto, rispettando le dipendenze.

## Modalita' di invocazione

**Auto-trigger (via event-dispatcher):** registrato come hook `pre` su `skill.invoke` quando `skill.layer == 'userland'`. Il dispatcher lo invoca prima di ogni skill di dominio. Se BLOCK → skill non viene invocata.

**Invocazione diretta:** verificare un piano di esecuzione, report completo dipendenze, debugging ordine.

## Core Workflow

### 1. Discovery — Costruire grafo dipendenze

1. Scansionare `skills/**/SKILL.md` con Glob
2. Estrarre frontmatter (name, skillos.requires.hard[], skillos.requires.soft[])
3. Arricchire con grafo predefinito dal workflow CLAUDE.md:

```
research-before-scaffold → project-scaffolder → [build loop]
Build loop: tdd → [implementazione] → verification-gate → code-reviewer → git-workflow
  Se fallisce: systematic-debugging → skill-postmortem (opzionale) → retry
Security: threat-modeler → audit-coordinator → [skill security in sequenza]
Meta: skill-router → [qualsiasi], sprint-planner → [build loop], phase-gate → [fine fase]
Memory: skill-postmortem → skill-retrospective, context-persistence → session-reporter
```

### 2. Regole di dipendenza

| Tipo | Comportamento |
|------|--------------|
| **HARD** | Bloccante — skill B NON PUO' eseguire prima di A |
| **SOFT** | Warning — B DOVREBBE eseguire dopo A |
| **MUTEX** | Warning — A e B non dovrebbero essere usate insieme |

#### Regole HARD

| Prerequisito | Dipendente | Motivo |
|-------------|-----------|--------|
| tdd-red-green-refactor o tdd-vertical-slicing | Implementazione | Test-first obbligatorio |
| Implementazione | verification-gate | Non verificare prima di implementare |
| verification-gate | code-reviewer | Verificare prima di review |
| code-reviewer | git-workflow (commit) | Review prima di committare |
| task-decomposer | sprint-planner | Decomporre prima di pianificare |
| threat-modeler | audit-coordinator | Threat model prima di audit |
| secure-code-guardian | audit-prep-assistant | Fix OWASP prima di audit formale |

#### Regole SOFT

| Prerequisito | Dipendente | Motivo |
|-------------|-----------|--------|
| skill-router | Qualsiasi skill | Router aiuta a scegliere |
| semgrep | performing-security-testing | Static prima di dynamic |
| insecure-defaults | sharp-edges | Config prima di API |
| sprint-planner | Build loop | Pianificare prima di costruire |
| research-before-scaffold | project-scaffolder | Ricerca prima di scaffoldare |
| skill-postmortem | skill-retrospective | Postmortem prima di retrospective |

#### MUTEX

tdd-red-green-refactor ↔ tdd-vertical-slicing (scegliere uno, non entrambi per task).

### 3. Verify (usato da event-dispatcher)

1. Leggere storico invocazioni da `.state/state.json` e journal corrente
2. Prerequisiti HARD non soddisfatti → `{ outcome: "block", missing: [...], remediation: "..." }`
3. Prerequisiti SOFT non soddisfatti → warning (non blocca)
4. MUTEX violato → warning
5. Tutto ok → `{ outcome: "pass", warnings: [] }`

### 4. Report completo (invocazione diretta)

Tabella con ordine esecuzione, stato per skill, violazioni BLOCK/WARN/MUTEX, verdetto finale PASS/BLOCK.

## Regole

- **HARD = bloccante**, SOFT = warning
- Discovery sempre — nuove skill con `skillos.requires` integrate nel grafo
- Check deve essere veloce (solo lettura)
- **Fail-safe** — se non riesce a leggere journal, PASS con warning
- **Sessione-scoped** — verifica solo invocazioni sessione corrente

## Anti-pattern

- Ignorare violazioni BLOCK "per fretta"
- Troppe regole HARD (rallenta workflow)
- Non aggiornare grafo con nuove skill
- Usare come sostituto di phase-gate (sono complementari)
- Bloccare su regole SOFT

## Rationalizations — STOP

| Excuse | Reality |
|---|---|
| "È solo una dipendenza SOFT" | Warning comunque, non silenziare |
| "Il journal non mostra A ma è stata eseguita" | No evidenza journal = skill NON eseguita. Nessuna deroga |
| "Aggiungo regola hard al volo" | Regole hard richiedono review. Proponi, non imporre |
| "MUTEX è troppo rigido per questo task" | Scegli una delle due. Non usarle entrambe |
| "Skippo il check per velocità" | Check è solo lettura. Zero costo reale |
| "L'ordine non conta davvero" | HARD dependency esiste per un motivo documentato |
