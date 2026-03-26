# Leopoldo

The expertise system for Claude that orchestrates, corrects, and evolves itself.

[![MIT License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![GitHub Stars](https://img.shields.io/github/stars/leopoldo-ai/leopoldo?style=flat)](https://github.com/leopoldo-ai/leopoldo/stargazers)
[![Last Commit](https://img.shields.io/github/last-commit/leopoldo-ai/leopoldo)](https://github.com/leopoldo-ai/leopoldo/commits/master)

---

| Other tools | Leopoldo |
|---|---|
| Static prompt files | Self-evolving system |
| No orchestration | Agents route, verify, correct |
| Set and forget | Weekly auto-improvement |
| Failures break silently | Quality gates block bad output |
| You fix mistakes | Postmortem finds root cause |

---

## Quick start

```bash
git clone https://github.com/leopoldo-ai/leopoldo .leo && cp -r .leo/.claude . && rm -rf .leo
```

Open Claude Code. The system activates automatically.

---

## How it works

```
Request
  → Orchestrator (routes to the right agent)
  → Specialized agent (produces structured output)
  → Quality gate (verifies completeness and correctness)
  → Structured result
```

When something goes wrong:

```
Correction detected
  → Postmortem runs BEFORE fixing
  → Root cause identified and logged
  → Fix applied
  → Finding queued for next evolution cycle
```

No patching over problems. Root cause or nothing.

---

## What's inside

**Engine.** The system core. Orchestrator, quality gates, correction loop, lifecycle manager, and session automation. Runs on every request.

**Studio.** The full toolchain used to build, test, and validate domain expertise. Write a new capability, run it through the studio, ship it. The same toolchain that built Leopoldo is included.

**Evolution.** A weekly cycle that reviews postmortems, scans the ecosystem for updates, and proposes patches. You approve. It ships. The system gets better every week without manual intervention.

**Agents.** 13 workflow agents for multi-step processes: finance, consulting, legal, competitive intelligence, dev, medical research, and reporting. The orchestrator routes requests to the right agent automatically.

**Full Stack Pack.** Included with every install. Architecture design, testing strategy, CI/CD pipelines, security review, frontend patterns, and code review workflows.

---

## See it work

Prompt:

> "Design the architecture for a multi-tenant SaaS with Stripe billing"

What happens:

1. Orchestrator routes to the dev agent
2. Agent produces: system diagram, tech stack recommendation, database schema, API design, Stripe billing integration plan
3. Quality gate verifies completeness against the architecture checklist
4. Structured result delivered in about 45 seconds

No prompt engineering. No retries. The system handles the routing and verification.

---

## Premium domains

| Domain | What you can do |
|---|---|
| Finance | Due diligence, deal execution, fund management, market research, wealth advisory |
| Legal | Compliance, regulatory analysis, risk assessment, contract review |
| Consulting | Strategic analysis, market sizing, stakeholder reporting, engagement management |
| Competitive Intelligence | Market positioning, competitor profiling, ecosystem monitoring |

Available on request. Contact [hello@leopoldo.ai](mailto:hello@leopoldo.ai)

Explore examples in each pack's directory under `skills/packs/`.

---

## The evolution loop

Every correction you make feeds the system.

When you tell Leopoldo an output was wrong, it does not just fix it. It runs a postmortem first: what was the root cause, which capability was responsible, what rule was missing. The fix is applied, the finding is logged.

Once a week, the evolution agent reviews all postmortems, scans the Claude and ecosystem release feeds, and produces a set of proposed patches. You review. You approve. The patches ship.

The system that handles your work today is not the system you will have in 30 days. It compounds.

---

## Build your own

Leopoldo includes the full studio toolchain used to create its domain expertise. Author a new capability, validate it against the quality framework, integrate it with the orchestrator.

See [docs/studio.md](docs/studio.md) to get started.

---

## Architecture

Full system design, infrastructure map, and component breakdown: [ARCHITECTURE.md](ARCHITECTURE.md)

---

## Contributing

[CONTRIBUTING.md](CONTRIBUTING.md)

---

## Premium domains and services

Enterprise setup, team deployment, and custom domain configuration: [leopoldo.ai/services](https://leopoldo.ai/services)

Contact [hello@leopoldo.ai](mailto:hello@leopoldo.ai)

---

## License

MIT. See [LICENSE](LICENSE).
