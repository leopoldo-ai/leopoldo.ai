---
layer: engine
version: 1.0.0
description: SkillOS runtime — kernel (routing, gating, orchestration) and infrastructure (sessions, reporting, self-improvement).
deploy_cc: true
deploy_desktop: false
deploy_cowork: false
skills:
  - init
  - event-dispatcher
  - skill-router
  - dependency-checker
  - sprint-planner
  - phase-gate
  - doc-gate
  - project-memory
  - skill-inventory
  - pack-manager
  - session-lifecycle
  - session-reporter
  - skill-changelog
  - coverage-analyzer
  - skill-retrospective
  - skill-postmortem
  - context-persistence
  - doc-sync
---

# Engine Layer

Runtime del sistema SkillOS. Merge di core (kernel) e drivers (infra).

- **Claude Code clients**: deploy completo — queste skill funzionano con filesystem e Bash
- **Desktop / Cowork clients**: non deployate raw — la logica comportamentale è distillata in `platforms/orchestrator-rules.md`

## Skill incluse

### Kernel (ex-core, 10 skill)
Orchestration, routing, gating — non modificare.

| Skill | Purpose |
|-------|---------|
| `init` | Boot sequence: leggi config, discovery skill, apri sessione |
| `event-dispatcher` | Pipeline eventi (pre/post/blocking/auto hooks) |
| `skill-router` | Discovery e routing dinamico delle skill |
| `dependency-checker` | Verifica prerequisiti prima di ogni invocazione |
| `sprint-planner` | Assegna skill ai task per ogni sprint |
| `phase-gate` | Verifica copertura skill per fase — blocking hook |
| `doc-gate` | Freshness enforcement della documentazione |
| `project-memory` | Mantiene PROJECT_STATE.md aggiornato |
| `skill-inventory` | Inventario completo skill con metadata e health |
| `pack-manager` | Package manager — installa/rimuovi/aggiorna pack |

### Infrastructure (ex-drivers, 8 skill)
Sessioni, report, self-improvement.

| Skill | Purpose |
|-------|---------|
| `session-lifecycle` | Open/close sessioni, journaling, checkpoint, restore |
| `session-reporter` | Report fine sessione (skill usate, task, findings) |
| `skill-changelog` | Audit trail modifiche skill nel tempo |
| `coverage-analyzer` | Mappa skill → codebase, identifica zone scoperte |
| `skill-retrospective` | Identifica friction, genera patch per skill |
| `skill-postmortem` | Post-mortem strutturato dopo failure |
| `context-persistence` | Memoria esterna per sessioni lunghe (30+ exchange) |
| `doc-sync` | Verifica coerenza documentazione con stato SkillOS |
