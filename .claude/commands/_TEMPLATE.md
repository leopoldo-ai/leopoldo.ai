---
description: <one sentence imperative, under 80 chars>
argument-hint: "<what the user should pass, or blank>"
---

<!--
  Leopoldo prompt card template.
  Convention: docs/guides/prompt-card-standard.md
  Style: imperative-to-LLM, not documentation-to-user.
  Every section below is MANDATORY unless marked optional.
-->

# /<verb>

<!--
  OPTIONAL — only for user-facing commands (e.g., /postmortem, /evolve, /status, /clients, /scan-skills):
  Add a "Trigger with" block inside the description frontmatter above.
  Example:
    description: |
      Run a postmortem analysis on a skill failure.
      Trigger with "qualcosa è andato storto", "fai un postmortem",
      "non ha funzionato", or when the user corrects a previous output.
-->

## Required Reading — Do This First

Before any output, read these completely:

1. `<path/to/SKILL.md or reference>` — <why you need it>
2. `<another path>` — <why you need it>

Do not skip. The craft is there.

---

**Scope:** <explicit domain this command covers>
**NOT for:** <explicit anti-scope>. Redirect to `/<sibling-command>`.

## What I Need From You

- **<Input 1>**: <what and format>
- **<Input 2>**: <what and format, if any>
- **<Optional input>**: <what and format>

## Output Template

```markdown
## <Output Section 1>
<template with [placeholders] the LLM must fill>

## <Output Section 2>
| Column 1 | Column 2 | Column 3 |
| --- | --- | --- |
| [fill] | [fill] | [fill] |
```

## The Tests

Run before showing the user:

- **The swap test**: <specific criterion — e.g., would another Leopoldo command produce the same output? If yes, narrow scope.>
- **The grounding test**: <specific criterion — e.g., every number in the output has a stated source>
- **The anti-default test**: If a generic AI given the same prompt would produce substantially the same output — you have failed. Add Leopoldo-specific structure, terminology, rigor.

## Flow

1. Parse the argument (or lack thereof)
2. Read required files
3. Check for state artifact (`.leopoldo/system.md`, relevant playbook)
4. If state exists: apply. If not: propose minimum viable output, confirm, build, save.
5. Run the tests above
6. Emit output

## If Connectors Available

<!-- OPTIONAL — only if the command benefits from external data sources. -->

If **~~<category>** is connected:
- <behavior 1>
- <behavior 2>

Fallback: request data from user manually.

## Available Capabilities

<!-- OPTIONAL — preserve Leopoldo's existing pattern of capability tables
     when relevant to the command. -->

| Area | What it does | Example prompt |
|------|-------------|----------------|
| ... | ... | ... |

## Tips

1. <concrete tip, not generic>
2. <concrete tip>
3. <concrete tip>

## Never Say / Instead

| Never say | Instead |
|---|---|
| "I'm now in X mode" | Jump into the work |
| "Let me check..." | Just do it; narrate results, not steps |
| "Based on best practices" | Cite the specific principle or source |
