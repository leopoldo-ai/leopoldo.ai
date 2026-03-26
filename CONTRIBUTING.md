# Contributing | Leopoldo

Leopoldo is open source and welcomes contributions. The system includes Studio, a complete toolchain for creating, testing, and validating capabilities before they enter the system.

Whether you want to add a new capability, improve an existing one, fix a bug, or improve the engine itself, this guide covers how to do it well.

---

## Ways to Contribute

- **Create new capabilities.** Add domain expertise to an existing pack using the Studio authoring tools.
- **Improve existing capabilities.** Refine trigger conditions, improve output structure, fix gaps, or update outdated references.
- **Improve documentation.** Clearer explanations, better examples, corrected errors.
- **Report bugs.** Found something that behaves incorrectly? Open an issue.
- **Suggest features.** Have an idea for a new agent, engine improvement, or capability? Start a Discussion or open a feature request.
- **Improve the engine or agents.** Contribute to the orchestrator, quality gates, correction loop, lifecycle manager, or any of the 13 workflow agents.

---

## Creating a New Capability

Capabilities are the domain expertise delivered through the system. Each capability is a `SKILL.md` file in the appropriate pack directory under `skills/packs/`.

### Step 1. Identify the right pack

Find the pack that best matches your capability's domain:

```
skills/packs/
  finance/          Investment, deals, funds, markets
  consulting/       Strategy, marketing, research
  dev/              Full-stack development
  intelligence/     Competitive analysis
  legal/            Compliance, contracts, regulatory
  common/           Essentials and design foundations (included everywhere)
```

If no pack fits, propose a new one in a Discussion before creating it.

### Step 2. Use the Studio authoring tools

Studio provides structured authoring guidance. Open Claude Code in this repo and use the Studio tools to scaffold a new capability. They will walk you through trigger conditions, workflow steps, output format, and example prompts.

If you prefer to author manually, use the template below.

### Step 3. Write the capability file

Minimum required structure:

```
---
name: capability-name
description: What this capability does in one sentence
domain: finance | consulting | dev | intelligence | legal | common
author: your-github-handle
---

# Capability Name

## When to use this
[Trigger conditions: what user requests or context patterns activate this capability]

## Workflow
[Step-by-step process this capability follows]

## Output format
[What the output looks like: sections, tables, summaries, recommendations]

## Example prompts
- [Example 1]
- [Example 2]
- [Example 3]
```

A few rules for good capabilities:

- Be specific about trigger conditions. Vague triggers cause the orchestrator to misroute.
- Output format matters. Every capability should produce a structured, actionable output. Include an executive summary for any output longer than a page.
- Use tables over prose for structured data.
- No filler. Every section should add information the user can act on.

### Step 4. Test locally

Before submitting, test your capability in Claude Code:

1. Place the `SKILL.md` file in the correct pack directory.
2. Open a new Claude Code session in the repo.
3. Test with the example prompts you wrote in the file.
4. Verify the output structure matches what you documented.
5. Check that the trigger conditions are accurate (test edge cases too).

---

## Submitting a Pull Request

1. **Fork the repository.** Create your fork on GitHub.

2. **Create a feature branch.** Use a descriptive name:
   ```
   git checkout -b capability/finance-dcf-analysis
   git checkout -b fix/orchestrator-routing-edge-case
   git checkout -b docs/improve-architecture-guide
   ```

3. **Make your changes.** Keep commits focused. One logical change per commit.

4. **Test locally.** Run the capability or change in Claude Code before submitting.

5. **Submit the PR.** Include:
   - What you changed and why
   - How you tested it
   - Any related issues (link with `Closes #123` if applicable)

We review PRs as quickly as we can. For significant changes (new packs, engine modifications, agent changes), expect a discussion before merge.

---

## Issue Types

### Bug Report

Use the bug report template. Include:
- What you expected to happen
- What actually happened
- Steps to reproduce
- Claude Code version and plugin version if relevant

### Feature Request

Use the feature request template. Include:
- The problem you are trying to solve
- Your proposed solution
- Why this belongs in the system rather than as a local customization

### New Capability Proposal

Before writing a full capability, open a proposal issue. Include:

- **Name:** What you would call this capability
- **Domain:** Which pack it belongs to
- **What it does:** One paragraph describing the workflow it handles
- **Example prompts:** 3 to 5 prompts that would trigger it
- **Output:** What a good output looks like

Proposals let us give feedback on scope and fit before you invest time authoring the full file.

---

## Code of Conduct

Be respectful. Focus on the work, not the person. Constructive feedback is welcome and expected. Personal attacks, dismissive responses, or bad-faith engagement will result in removal from the project.

We are building a system used by professionals in high-stakes domains (finance, legal, medical). The standard for quality and accuracy is high. Feedback on contributions reflects that standard, not personal judgment.

---

## Author Credit

Contributors are credited in two places:

1. **CHANGELOG.** Every merged contribution is listed with the contributor's GitHub handle.
2. **Capability file header.** The `author` field in the capability frontmatter is preserved in the distributed system.

---

## Questions

Open a [Discussion](https://github.com/leopoldo-ai/leopoldo/discussions) for anything that is not a bug or a clear feature request. Discussions are the right place for questions about architecture, capability design, pack organization, and contribution ideas.

For everything else: hello@leopoldo.ai
