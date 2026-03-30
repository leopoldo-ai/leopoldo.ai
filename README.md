# Leopoldo

The first autonomous expertise system for Claude.

Leopoldo is a complete system that orchestrates domain expertise, self-corrects through postmortems, and evolves automatically. The skills are content. The system is the product.

## What You Get

This repository contains **148 capabilities** across three areas:

| Area | Capabilities | Description |
|------|:------------:|-------------|
| Full Stack | 84 | Architecture, testing, CI/CD, code review, frontend, backend |
| Essentials | 38 | Strategy, reports, presentations, brand, design foundations |
| Engine | 26 | Orchestration, lifecycle management, Imprint, system hooks |

Plus the full system: orchestrator, workflow agents, quality gates, and lifecycle hooks.

## Quick Start

1. Clone this repository into your project:

```bash
git clone https://github.com/leopoldo-ai/leopoldo.ai.git .leopoldo-system
```

2. Copy the contents into your project root (or use as a submodule)

3. Start Claude Code. Leopoldo activates automatically.

## Architecture

```
skills/
  engine/             System skills (orchestration, lifecycle, Imprint)
  packs/
    common/           Essentials and design foundations (included in every domain)
    dev/              Full Stack development expertise
agents/               Workflow agents (orchestrator, system, reporting, environment)
.claude/              Configuration (settings, symlinks, commands)
.leopoldo/hooks/      Lifecycle hooks (session, logging, validation, gates)
```

## The System

Leopoldo is not a collection of prompts. It is a system with five pillars:

1. **Orchestrator**: routes every request to the right expertise
2. **Workflow Agents**: handle complex multi-step tasks autonomously
3. **Quality Gates**: block incomplete or undocumented work
4. **Correction Loop**: postmortems before fixes, learning from every mistake
5. **Auto-Evolution**: weekly self-improvement cycle

## More Domains

Premium domains are available for finance, consulting, legal, intelligence, and medical research. Each domain packages the full system with vertical expertise.

Visit [leopoldo.ai](https://leopoldo.ai) to explore all domains.

## Imprint

Every Leopoldo installation includes Imprint: a local learning engine that adapts to your style, preferences, and terminology as you work. Your data stays on your machine.

## License

[MIT](./LICENSE)

## Author

Luca De Albertis. [leopoldo.ai](https://leopoldo.ai)
