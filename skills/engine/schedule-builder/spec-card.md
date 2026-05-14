# Spec Card: schedule-builder

## Identity

- **Pack:** engine
- **Cluster:** cowork-integration / system-helpers
- **Layer:** userland (user-facing, conversational)
- **Tier:** essentials
- **Profile:** CONTENT, DEV (Studio excluded)
- **Positioning:** complementary to Anthropic's built-in `/schedule` skill (we sit upstream of it)

## Scope

Conducts a Leopoldo brief interview, applies autonomous-prompt discipline, and produces a self-contained prompt + recommended `taskName` + `timing` decision. The user then invokes Anthropic's built-in `/schedule` skill (bundled in Cowork and Claude Code Desktop) which calls the runtime `create_scheduled_task` tool to actually register the task.

**Does NOT** call `create_scheduled_task` (we have no access to that runtime tool). **Does NOT** produce a 6-field form payload (the previous design, abandoned). **Does NOT** duplicate the work of `/schedule`.

## Expected Inputs

- Trigger phrases: "schedulami", "every morning", "set up a recurring task", "automate this", "remind me daily"
- User answers to brief interview: outcome, inputs, destination, timing
- Optional: preselected template name (morning-brief, weekly-pipeline-review, etc.)

## Expected Outputs

A "Leopoldo Schedule Package" block in plain text, with:

- `taskName`: kebab-case identifier
- `timing`: one of `cron <expression>`, `fireAt <ISO 8601>`, or `preset <Hourly|Daily|Weekdays|Weekly|Manual>`
- `prompt`: self-contained prompt body (autonomous-discipline)

Plus a constraints reminder block (desktop awake, sandbox connectors, local timezone) and explicit handoff instructions: "invoke `/schedule` and paste these three values."

## Must-Have Features

1. **Recognize trigger phrases** in EN and IT
2. **Brief interview** (max 4 questions): outcome, inputs, destination, timing
3. **Apply autonomous-prompt rules**: explicit inputs, explicit destination, fail-safe lines, no clarifying questions, no self-rescheduling
4. **Embed delivery instructions in the Prompt body** (no separate output destination field)
5. **Decide timing format**: cron expression / fireAt ISO 8601 / preset name
6. **Output the handoff package** + invocation instructions for `/schedule`
7. **Surface platform constraints** every time: desktop awake, sandbox MCP availability, local timezone for cron
8. **5 ready templates** as companion file: morning-brief, weekly-pipeline-review, monthly-portfolio-snapshot, daily-deal-radar, quarterly-client-report
9. **Cron quick reference** (in templates.md companion) for common business cadences

## Nice-to-Have Features

1. Detect language and respond in user's language (EN/IT)
2. Suggest matching template when user describes intent
3. Warn when prompt complexity may exceed sensible runtime
4. Provide manual-form fallback when `/schedule` is unavailable on older platform versions

## Anti-Patterns

- Calling `create_scheduled_task` directly (we have no runtime access)
- Duplicating the work of Anthropic's `/schedule` (we are upstream, not parallel)
- Producing a 6-field form payload (wrong handoff target since `/schedule` exists)
- Falsely claiming Cowork doesn't support cron or specific times (it does, via `/schedule`)
- Calling Leopoldo backend or our Resend (client uses HIS connectors)
- Producing prompts with clarifying questions (no human in loop at runtime)
- Inventing data or fabricating outputs in templates
- Coupling to specific MCPs that may not be installed in user's Cowork workspace
- Copying `/schedule`'s SKILL.md text (license unclear, proprietary bundle)

## Integration Points

- **Trigger context:** orchestrator routes to this skill on trigger phrase match
- **Companion:** templates.md (5 ready templates + cron quick reference, on-demand load)
- **Reference:** `.claude/rules/cowork-compatibility-rules.md` (sandbox limits)
- **Handoff before:** none (entry point)
- **Handoff after:** Anthropic's built-in `/schedule` skill (the user invokes it manually after our output)

## Success Criteria

1. User invokes with intent → produces valid handoff package in under 4 conversational turns
2. Generated prompt runs autonomously in headless session without prompting user
3. Recommended `timing` is correctly formatted (valid cron, valid ISO 8601, or valid preset name)
4. Handoff to `/schedule` requires zero further interpretation by the user
5. All 5 templates produce coherent output when adapted with placeholder substitution
6. Constraints reminder visible on every output

## Key Rules

- We never claim to bypass `/schedule`; we feed it.
- Output destination always inside Prompt body, never as a separate field.
- Fail-safe lines are mandatory in every generated prompt.
- Cron expressions evaluate in user's local timezone (per `/schedule` spec).
- Disclaim platform constraints on every output (desktop awake, sandbox MCP, local TZ).
