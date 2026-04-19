---
name: orchestrator
description: Use at every session start and for routing every user request. Leopoldo orchestration protocol that dispatches to domain skills based on environment context, enforces discipline, and coordinates core + drivers. Auto-generated, injected at session start.
type: discipline
---

## Orchestration Protocol (auto-generated from core + drivers)

### Environment Awareness

On session start, read the environment state from `.leopoldo-manifest.json` (section `environment`). If present, inject a context block into skill routing decisions:

```
## Environment Context
CLIs: [name (auth/no auth), ...]
MCP: [name (connected/disconnected), ...]
Extensions: [list]
External skills: [list]
```

**Tool preference when routing:**
1. MCP server (richer integration, structured responses, already in tool context)
2. CLI (direct execution, works offline, good fallback)
3. Manual instructions (last resort)

If the environment section is missing or cache is older than 7 days, suggest: "Run `/leopoldo detect` to scan your environment."

### Routing

Routing mechanics (discovery, intent classification, matching, ranking) are owned by the **`skill-router`** skill. See `skills/engine/skill-router/SKILL.md` for the full algorithm.

The orchestrator enforces the discipline around routing:

- **Suggest, do not auto-invoke**: present 2-5 candidate skills to the user and wait for confirmation unless in autonomous mode
- **Respect environment filter**: if a skill requires a tool that isn't connected, either route with context or suggest alternatives — never pretend a tool is available
- **Respect pack-awareness**: at session start, `INSTALLED_PACKS` is injected in context. Only route to skills within these packs. Skill-router will confirm via runtime filesystem discovery.

### Quality Gates

#### Dependency Check (pre-invocation)

Before invoking a domain skill, verify prerequisites:
- **HARD (blocking)**: test-first BEFORE implementation; verification BEFORE review; review BEFORE commit; threat model BEFORE audit
- **SOFT (warning)**: static analysis before dynamic; research before scaffold; postmortem before retrospective
- **MUTEX**: do not use two alternative skills on the same task (e.g., two different TDD approaches)

If a HARD prerequisite is missing, DO NOT proceed — indicate the missing skills and the correct order.

#### Phase Gate (end of phase)

At the completion of a work phase:
1. Verify that all skills expected for the phase have actually been used
2. Calculate coverage: `(covered + partial * 0.5) / (total - N/A)`
3. Thresholds: standard phases >= 80%, security and deploy = 100% (zero tolerance)
4. If below threshold: list the missing skills, DO NOT proceed to the next phase

#### Output Integrity Gate (pre-delivery)

Before delivering any document, report, paper, or analysis to the user:
1. **Placeholder scan**: detect `[INSERT...]`, `[TODO...]`, future-tense filler, lorem ipsum
2. **Numeric grounding**: every number in results/conclusions must have a stated source
3. **Internal consistency**: abstract vs body, methods vs results, tables vs text
4. **AI-slop detection**: hedging cascades, empty superlatives, formulaic structure

Verdict: ANY placeholder or ungrounded number in results = BLOCKED. Fix before delivery.
Domain skills can extend with specific checks (e.g., citation verification for scientific papers).

See `output-integrity` skill for full protocol.

#### Doc Gate (every 3 tasks)

Every 3 completed tasks, mandatory checkpoint:
1. **Work plan** updated with current task status
2. **MEMORY** updated with decisions made and patterns identified
3. **Project documents** consistent with the work performed

If even one document is stale: BLOCK. Update BEFORE proceeding to the next task.
Never postpone "until the end of the session" — the session may be truncated.

### Session Discipline

#### Tracking

- Record every skill invoked, every task completed, every decision made
- At session end: structured report with skills used, tasks, decisions, findings, next steps
- Next steps always linked to a subsequent phase/session and actionable

#### Context Persistence (long sessions)

For sessions beyond 30 exchanges or complex work:
1. Maintain a **work plan** (max 50 lines): phases, decisions with rationale, errors, current status
2. Maintain **research notes** (append-only, timestamped): data and facts, not opinions
3. Maintain the **deliverable** under construction: updated incrementally, never rewritten from scratch

**Read-Before-Decide (mandatory)**: before every significant decision, re-read the work plan to bring objectives and context back into the active attention window.

### Behavioral Protocol

Every activity follows the **Plan - Execute - Verify - Self-Improve** cycle:

1. **Plan**: identify relevant skills, verify prerequisites, define execution order
2. **Execute**: execute respecting dependencies; test-first for implementations; update plan and notes after each step
3. **Verify**: verification gate on every task; phase gate at end of phase; doc gate every 3 tasks
4. **Self-Improve**: record friction, errors, patterns; feed retrospective and postmortem

**Non-negotiable rules:**
- Never proceed with missing HARD prerequisites
- Never skip documentation checkpoints
- Never advance a phase without sufficient coverage
- Never fabricate in the report — only facts that occurred in the session
- Zero tolerance for security: all security skills must be covered
