# Studio: Creating Capabilities

Studio is the internal toolchain used to produce, test, and validate Leopoldo's capabilities. It is available to contributors and power users who want to extend the system with new expertise.

---

## Studio tools

| Tool | Purpose |
|------|---------|
| `skill-authoring` | Templates and best practices for writing capabilities |
| `skill-testing` | Validation framework: tests triggers, steps, and output format |
| `evolution-tools` | Support tools for the weekly evolution cycle |
| `brand-kit-builder` | Brand identity wizard for consistent output styling |
| `review-skill-safety` | Safety checks before a capability is added to the system |
| `research-before-scaffold` | Research methodology to validate need before building |
| `workflow-discipline` | Quality enforcement for multi-step workflows |

Studio tools are never deployed to clients. They live in `skills/studio/` and are only available in the development environment.

---

## Creating a capability: step by step

### 1. Identify the right pack

| Pack | Use when |
|------|---------|
| `common/essentials` | General-purpose, applicable across all domains |
| `dev/full-stack` | Developer-specific workflows |
| `finance/` | Finance-specific workflows (investment-core, deal-engine, etc.) |
| `legal/legal-suite` | Legal-specific workflows |
| `consulting/` | Consulting, marketing, medical research |

When in doubt, start in `common/essentials` and move to a vertical pack if the capability is clearly domain-specific.

### 2. Run research-before-scaffold

Before writing anything, use the `research-before-scaffold` tool to validate the need. Answer:

- Is this capability already covered by an existing one?
- What is the trigger condition? (When does the user need this?)
- What is the expected output format?

### 3. Create the SKILL.md file

Place the file at `skills/packs/[pack]/[capability-name]/SKILL.md`.

Use the template below.

### 4. Test locally

```bash
# Open Claude Code in the leopoldo directory
# The capability is auto-loaded via the .claude/skills/ symlink
# Trigger it with a real prompt and verify the output
```

Use `skill-testing` to run the validation framework against your new capability.

### 5. Safety review

Run `review-skill-safety` before submitting. This checks for:

- Scope creep (capability doing more than one thing)
- Missing output format definition
- Missing trigger conditions
- Security concerns in any API or data-handling steps

### 6. Submit a PR

Open a pull request against `leopoldo-ai/leopoldo`. Include:

- The new SKILL.md file
- Test prompts and expected outputs
- Which pack it belongs to and why

---

## Capability template

Copy this into your `SKILL.md` file and fill in each section.

```markdown
# [Capability Name]

## Description
One sentence. What does this capability do?

## Trigger conditions
When should the orchestrator invoke this capability? Be specific.

Examples:
- User asks to [specific task]
- User provides [specific input type]
- Previous step produces [specific output]

## Workflow steps

1. [Step 1: what happens, what is produced]
2. [Step 2: what happens, what is produced]
3. [Step 3: what happens, what is produced]

## Output format

Describe the exact structure of the output:
- Format: table / report / JSON / prose
- Required sections: [list them]
- Length: [approximate]

## Quality gates

- Gate 1: [what must be true before this step is complete]
- Gate 2: [what must be true before output is delivered]

## Notes
Any edge cases, dependencies on other capabilities, or known limitations.
```

---

## Best practices

| Principle | What it means in practice |
|-----------|--------------------------|
| Single responsibility | One capability, one job. If you need two steps, write two capabilities. |
| Clear trigger conditions | The orchestrator needs to know exactly when to invoke this. Vague triggers cause missed invocations. |
| Structured output | Define the output format explicitly. Prose is not an output format. |
| Test with real prompts | Use prompts from actual use cases, not idealized inputs. |
| Gate everything | Every meaningful step should have a gate. No gates means no quality assurance. |
