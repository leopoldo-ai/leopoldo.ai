# engine — Upstream Sources Registry

Last full review: 2026-05-05
Next scheduled review: 2026-08-05

Engine skills are mostly internal. Only skills with external research or upstream tracking are listed here.

## Cowork integration (1 skill)

| Skill | Version | Forge Strategy | Upstream URL | Last Checked | Status | Notes |
|-------|---------|---------------|-------------|--------------|--------|-------|
| `schedule-builder` | 0.2.0 | BUILD | https://support.claude.com/en/articles/13854387-schedule-recurring-tasks-in-claude-cowork | 2026-05-05 | CURRENT | v0.1.0 was a form-payload generator; v0.2.0 repositioned as prompt-enricher upstream of Anthropic's built-in `/schedule`. |

### schedule-builder forge sources (BUILD reference, not adapted)

| Source | URL | License | Used as |
|---|---|---|---|
| Anthropic Cowork Help — Schedule recurring tasks | https://support.claude.com/en/articles/13854387-schedule-recurring-tasks-in-claude-cowork | proprietary | Authoritative form schema (6 fields, frequency enum) |
| Claude Code Desktop Scheduled Tasks docs | https://code.claude.com/docs/en/desktop-scheduled-tasks | proprietary | Cron support, time/day pickers, worktree, permission mode confirmation |
| Anthropic bundled `/schedule` skill (local-only) | `~/Library/Application Support/Claude/local-agent-mode-sessions/skills-plugin/.../skills/schedule/SKILL.md` | unclear (bundled, no LICENSE in plugin dir) | Behavioral reference only. 41-line skill, captures (taskName, prompt, cronExpression\|fireAt) and calls runtime tool `create_scheduled_task`. We do NOT copy text. |
| anthropics/claude-code Issue #29022 | https://github.com/anthropics/claude-code/issues/29022 | n/a | Confirms `/schedule` exists as Cowork-bundled skill, `create_scheduled_task` is harness-injected at runtime |
| anthropics/claude-code Issue #33281 | https://github.com/anthropics/claude-code/issues/33281 | n/a | Autonomous-prompt constraints (no self-rescheduling, no human-in-loop) |
| anthropics/skills (GitHub) | https://github.com/anthropics/skills | MIT | Confirmed: NO `schedule` skill on GitHub. Bundled-only. 17 other skills present (none scheduling-related). |
| EAIconsulting/cowork-skills-library | https://github.com/EAIconsulting/cowork-skills-library | MIT | UX onboarding pattern reference (~30% spec coverage, low-coverage match) |
| TheCraigHewitt/cowork-starter-pack | https://github.com/TheCraigHewitt/cowork-starter-pack | MIT | Recipe library reference (~30% spec coverage, low-coverage match) |

### Key positioning decision (2026-05-05)

Initial v0.1.0 design (form-payload generator for the 6-field UI form) was abandoned after discovering Anthropic ships a bundled `/schedule` skill that:
- Already handles form-fill (taskName, prompt, timing)
- Calls a runtime tool `create_scheduled_task` we have no access to
- Supports cron expressions and fireAt ISO 8601 (which v0.1.0 incorrectly claimed were unsupported)

v0.2.0 repositions Leopoldo's `schedule-builder` **upstream** of `/schedule`: we add interview discipline, autonomous-prompt rules, fail-safe lines, and finance/legal/consulting templates. The user then invokes `/schedule` and pastes the output. Same trigger surface, deeper domain content. No shadow, no duplicate.

### UNSAFE candidates (discarded at security gate)

PhialsBasement/scheduler-mcp, phildougherty/claudecron, jolks/mcp-cron, tonybentley/claude-mcp-scheduler — all bundled MCP schedulers, incompatible with Cowork sandbox per `docs/decisions/cowork-compatibility-rules.md`.

### CAUTION-flagged (referenced for inspiration only, no content copied)

claudefa.st guide, aiblewmymind Substack, Petr Vojáček blog, Robert Mill on Medium, grandamenium/reminder-processor-skill.

### Lessons learned from this skill's forge cycle

1. **Always check for first-party Anthropic skills before designing competing UX.** A bundled `/schedule` exists; only 1 hour of additional research surfaced it. Forge-process SCOUT must include `~/Library/Application Support/Claude/local-agent-mode-sessions/skills-plugin/` for bundled skills, not just GitHub.
2. **"Not documented" ≠ "not possible".** Cowork help docs don't mention cron/fireAt because they describe the UI form. The bundled `/schedule` skill supports both. Inferring limits from one source is risky.
3. **Position complementary, not parallel.** Where Anthropic ships a thin skill, our value is upstream discipline + domain templates, not duplicate UX.
