---
description: |
  Run a structured post-mortem on a skill failure before fixing it.
  Trigger with "qualcosa è andato storto", "fai un postmortem",
  "è sbagliato", "correggi questo", "non ha funzionato", or when the
  user corrects a previous output.
argument-hint: "<optional failure description>"
---

# /postmortem

## Required Reading — Do This First

Before any output, read these completely:

1. `skills/engine/skill-postmortem/SKILL.md` — the 5-phase postmortem workflow
2. `.state/journal/` — current session journal (append postmortem.completed event at end)

Do not skip. The discipline is there.

---

**Scope:** skill failure analysis — Detect, Analyze, Document, Patch, Link.
**NOT for:** fixing the original problem (fix comes AFTER the postmortem). Redirect to `/safety` for output validation.

## What I Need From You

- **Failure description**: from `$ARGUMENTS` if provided, otherwise inspect the most recent output in conversation and ask the user for specifics
- **Context hint (optional)**: which skill produced the bad output, which phase you were in

## Output Template

```markdown
POSTMORTEM — [YYYY-MM-DD]

Skill:      [skill-name]
Type:       [test-failure | build-break | wrong-output | user-correction]
Severity:   [Critical | High | Medium]
Root cause: [one-line explanation, no speculation]
Lesson:     [ALWAYS/NEVER rule, actionable]
Patch:      [proposed | applied | not needed]
```

Append entry to `LESSONS_LEARNED.md` in the failed skill's directory. Append JSONL event to current session journal.

## The Tests

Run before showing the user:

- **The grounding test**: Root cause is a fact, not speculation. If unclear, state what is known and what is uncertain.
- **The discipline test**: Did you STOP before fixing? Postmortem precedes the fix, never follows it.
- **The scope test**: Trivial errors (typos, one-off copy mistakes) are skipped. Only significant failures produce a postmortem entry.

## Flow

1. Parse `$ARGUMENTS` or ask the user what failed
2. Read `skills/engine/skill-postmortem/SKILL.md`
3. Phase 1 (Detect): classify failure type, severity, failed skill, workflow phase
4. Phase 2 (Analyze): root cause — what happened vs expected, which step failed
5. Phase 3 (Document): append to `LESSONS_LEARNED.md` in the skill directory
6. Phase 4 (Patch): for Critical/High, propose a concrete diff to SKILL.md. Wait for approval.
7. Phase 5 (Link): log to skill-changelog, flag for next evolution cycle
8. Append JSONL event to `.state/journal/<session>.jsonl`: `{"event":"postmortem.completed", "skill":..., "severity":..., "type":..., "root_cause":..., "patch_status":...}`
9. Present the postmortem card

## Never Say / Instead

| Never say | Instead |
|---|---|
| "Let me fix this quickly" | Run the postmortem FIRST. No exceptions. |
| "Probably a model hallucination" | Cite the specific skill and phase. No hand-wave. |
| "Minor issue, no need to document" | If severity is Critical or High, document. Trivial only skipped if truly one-off. |
