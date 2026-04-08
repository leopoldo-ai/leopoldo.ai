# Skill Post-Mortem

Run a structured post-mortem analysis on a skill failure. Use this when something went wrong and you want to document it properly before fixing.

**Argument:** $ARGUMENTS (optional description of what went wrong)

## Process

1. **Identify the failure**: If `$ARGUMENTS` is provided, use it as the failure description. Otherwise, look at the most recent output in the conversation and ask the user what went wrong.

2. **Run skill-postmortem workflow** from `skills/engine/skill-postmortem/SKILL.md`:
   - **Phase 1 (Detect)**: Classify the failure type (test-failure, build-break, wrong-output, user-correction) and severity (Critical, High, Medium). Identify the skill that produced the error and the workflow phase.
   - **Phase 2 (Analyze)**: Root cause analysis. What happened, what was expected, why it happened, which step failed.
   - **Phase 3 (Document)**: Create or append to `LESSONS_LEARNED.md` in the failed skill's directory.
   - **Phase 4 (Patch)**: For Critical/High severity, propose a concrete diff to the skill's SKILL.md. Present for approval before applying.
   - **Phase 5 (Link)**: Log to skill-changelog and flag for the next evolution cycle.

3. **Log to session journal**: Append a JSONL event to the current session journal file in `.state/journal/`:
   ```
   {"event":"postmortem.completed","timestamp":"<ISO-8601>","skill":"<skill-name>","severity":"<level>","type":"<failure-type>","root_cause":"<one-line cause>","patch_status":"proposed|applied|not_needed"}
   ```

4. **Present summary**: Show a concise postmortem card:
   ```
   POSTMORTEM — [date]

   Skill:      [skill name]
   Type:       [failure type]
   Severity:   [Critical/High/Medium]
   Root cause: [one-line explanation]
   Lesson:     [ALWAYS/NEVER rule]
   Patch:      [proposed/applied/not needed]
   ```

## Rules

- Do NOT fix the original problem during the postmortem. Fix comes AFTER.
- No speculation in root cause. If unclear, state what is known and what is uncertain.
- Append-only to LESSONS_LEARNED.md. Never overwrite previous entries.
- Patches to SKILL.md require explicit user approval.
- Skip trivial errors (typos, one-off copy mistakes). Only document significant failures.
