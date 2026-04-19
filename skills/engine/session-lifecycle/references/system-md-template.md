# `.leopoldo/system.md` Template

This is the narrative, human-editable state artifact that Leopoldo loads at session start and proposes to update at session end. It complements `.leopoldo-manifest.json` (machine-readable, managed by `leopoldo-manager`) by capturing the *human* side of a project: direction, tone, decisions, patterns.

**File lives at:** `.leopoldo/system.md` (user-generated, never overwritten by updates)

**Who writes:** mostly Leopoldo with user confirmation, but users may edit freely between sessions.

**Token budget:** keep under 2,000 words total. If it grows larger, split decisions into `.leopoldo/decisions/` sub-files and link.

---

## Full Template

```markdown
# Leopoldo System — <project name>

> Narrative state for this project. Loaded at session start, updated at session end with your confirmation. Edit freely.

## Direction

**Domain:** [finance | legal | medical | consulting | marketing | engineering | hybrid]
**Depth:** [shallow-speed | balanced | deep-rigor]
**Tone:** [institutional | consultative | concise | narrative]
**Output bias:** [memo | deck | model | table | prose]

## Active Personas

- Orchestrator (always on)
- <workflow agent name> — <one-line rationale for why this project needs it>
- <second workflow agent> — <rationale>

## Domain Context

<5-10 lines of project-specific context: what this project is, target audience, current phase, constraints that shape all outputs>

## Patterns

### <Pattern name>

- **Trigger:** <when this pattern should activate — user intent or file type or phase>
- **Output shape:** <specific structure the output should take>
- **Anti-pattern:** <what to avoid — prior mistakes or common traps>

### <Second pattern, if applicable>

- **Trigger:** ...
- **Output shape:** ...
- **Anti-pattern:** ...

## Decisions

| Decision | Rationale | Date |
|----------|-----------|------|
| <short decision statement> | <why, in one sentence> | YYYY-MM-DD |

```

---

## Field Conventions

### Direction block

Four dials that bias every output. Each has a closed vocabulary (above) so that downstream skills can read and react programmatically.

- **Domain**: matches `packs/` taxonomy. `hybrid` is allowed when multiple domains apply.
- **Depth**: `shallow-speed` (fast iterations, lower rigor), `balanced` (default), `deep-rigor` (regulated, high-stakes outputs).
- **Tone**: `institutional` (board/LP register), `consultative` (advisor register), `concise` (tight bullets), `narrative` (full prose).
- **Output bias**: which deliverable format wins when the user is ambiguous.

### Active Personas

List of workflow agents that are *meaningfully in use* in this project, each with a one-line rationale. Not the full 27-agent catalog. If an agent has never been dispatched in this project, it does not belong here.

Orchestrator is always on and listed first.

### Domain Context

5-10 lines max. Longer context goes into dedicated memory files, not here.

### Patterns

Reusable output shapes discovered during work on this project. Each pattern has:

- **Trigger**: a concrete signal (e.g., "user asks for IC memo", "file type is .tex", "phase is underwriting")
- **Output shape**: concrete structure (sections, length, required elements)
- **Anti-pattern**: what went wrong before so we don't repeat it

Patterns grow from corrections. When the user corrects the same thing twice, `session-end.sh` proposes a pattern.

### Decisions

Append-only log. Date in ISO 8601 (`YYYY-MM-DD`). One row per decision. Sort newest first.

---

## Lifecycle

| Moment | Action |
|---|---|
| First session in a project | If `.leopoldo/system.md` missing → create empty stub with sections populated from `.leopoldo-manifest.json` (domain from plugins, defaults for depth/tone). Do NOT block. |
| Every session start | If file exists, inject content into `additionalContext`. If missing, skip silently. |
| Session end | Diff-check against working memory. If new pattern/decision emerged, ask user "Save to system.md? [Y/n]". On confirm, append. Never overwrite existing content silently. |
| Manifest change | `scripts/state_sync.py` reports drift (iteration 1, read-only). Bidirectional sync planned for iteration 2. |

## Migration (v2.0.0 → v2.1.0)

v2.0.0 clients have no `.leopoldo/system.md`. On their first post-update session, `session-lifecycle` creates an empty template (populated with domain from manifest) and logs `system_md.created`. This is **non-blocking** — missing file is always a valid state.

## Anti-patterns

- Do NOT duplicate manifest fields (skill versions, plugin list) here. Those live in `.leopoldo-manifest.json`.
- Do NOT grow beyond 2,000 words. Split decisions into dated sub-files if needed.
- Do NOT edit silently during a session. Always ask before writing.
- Do NOT treat system.md as secret. It may be committed to the project repo; ensure no PII.
