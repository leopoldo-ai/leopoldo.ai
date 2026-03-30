<p align="center">
  <img src=".github/banner.png" width="100%" alt="Leopoldo.ai">
</p>

<p align="center">
  <a href="https://leopoldo.ai"><img src="https://img.shields.io/badge/leopoldo.ai-website-1C1917?style=flat&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0iIzNBNkI1NSI+PGNpcmNsZSBjeD0iMTIiIGN5PSIxMiIgcj0iMTAiLz48L3N2Zz4=" alt="Website"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-3A6B55" alt="MIT License"></a>
  <a href="https://github.com/leopoldo-ai/leopoldo.ai/stargazers"><img src="https://img.shields.io/github/stars/leopoldo-ai/leopoldo.ai?style=flat" alt="GitHub Stars"></a>
</p>

---

An **expertise system for Claude** that orchestrates, corrects, and learns. The capabilities are content. The system is the product. Delivered as plugins for Claude Code and Cowork.

**What makes it different:** traditional prompt collections give Claude answers. Leopoldo gives Claude a way to think. An orchestrator understands your intent, workflow agents coordinate multi-step processes, quality gates verify every output, and the system learns from its own mistakes.

---

## How it works

```
You ask something
  -> Orchestrator classifies intent
    -> Routes to the right workflow agent
      -> Agent coordinates domain capabilities
        -> Quality gates verify the output
          -> Correction loop learns from mistakes
```

Every plugin deploys the full system. You choose a domain. You get the complete engine.

## The system

| Layer | What it does |
|-------|-------------|
| **Orchestrator** | Understands intent, routes to the right agent, enforces gates |
| **22 Workflow Agents** | Coordinate multi-step processes: due diligence, deal execution, advisory, clinical trials, consulting, legal |
| **Quality Gates** | Verification, phase coverage, content integrity, documentation coherence |
| **Correction Loop** | Detects when you correct an output, runs postmortem, prevents recurrence |
| **Imprint** | The system learns your style, terminology, and preferences over time |

## Domains

Choose a domain. Get the full system with vertical expertise.

| Domain | What you get | Tier |
|--------|-------------|------|
| **Full Stack** | Architecture, testing, CI/CD, code review, frontend | Free |
| **Investment Core** | Due diligence, valuation, risk frameworks, portfolio analysis | On request |
| **Deal Engine** | IC memos, LBO modeling, term sheets, exit planning | On request |
| **Fund Suite** | NAV, investor reporting, UCITS/ELTIF compliance, fund ops | On request |
| **Advisory Desk** | Pitch books, DCF, sell-side/buy-side, M&A advisory | On request |
| **Markets Pro** | Trading research, portfolio optimization, macro analysis | On request |
| **Senior Consultant** | Market sizing, stakeholder mapping, engagement management | On request |
| **Competitive Intelligence** | Competitor analysis, positioning, market intelligence | On request |
| **Marketing** | Brand strategy, campaign planning, content frameworks | On request |
| **Medical Research** | Clinical trials, biostatistics, grant writing, regulatory, publishing | On request |
| **Legal Suite** | 8 sub-domains: corporate, IP, labour, dispute, real estate, contracts, legal ops | On request |

Each domain includes the orchestrator, workflow agents, quality gates, enforcement hooks, and the correction loop.

## Quick start

```bash
git clone https://github.com/leopoldo-ai/leopoldo.ai .leo && cp -r .leo/.claude . && rm -rf .leo
```

Open your project in Claude Code. The system activates automatically.

**All other domains:** contact [hello@leopoldo.ai](mailto:hello@leopoldo.ai) or visit [leopoldo.ai/services](https://leopoldo.ai/services).

## Quality gates

Every output passes through a gate stack before reaching you:

| Gate | What it checks | Threshold |
|------|---------------|-----------|
| **Verification** | Did the system actually run the verification commands? Evidence, not claims | 100% |
| **Phase** | Were all relevant capabilities for this workflow phase used? | 80% (security: 100%) |
| **Output Integrity** | Placeholder detection, numeric grounding, consistency, AI-slop patterns | Blockers: zero tolerance |
| **Documentation** | Do project docs reflect the work just completed? | Must be current |

Gates are blocking. Only you can override them.

## Mechanical enforcement

Quality processes are enforced by shell hooks, not LLM instructions. This is the difference between "please do X" (ignored under task pressure) and "exit 2" (physically unavoidable).

| Hook | When | What it enforces |
|------|------|-----------------|
| **SessionStart** | Every session | Initialize state, load preferences, detect environment |
| **UserPromptSubmit** | Every message | Detect corrections, set hard gate requiring postmortem before any fix |
| **PreToolUse** | Before Edit/Write | Protect managed files and directories |
| **PostToolUse** | After Edit/Write/Bash | Track progress, activate checkpoint gate at threshold |
| **Stop** | Before response completes | Block if postmortem skipped, checkpoint overdue, or security gate pending |

## Environment awareness

On session start, Leopoldo detects your full environment:

```
CLIs:    vercel (auth), gh (auth), docker, psql, stripe (no auth)
MCP:     postgres (connected), github (connected), sentry (connected)
VS Code: copilot, tailwind, eslint
```

The orchestrator reads this and adapts. If you have Vercel CLI authenticated, it deploys with Vercel. If you have a Postgres MCP server, it queries directly. No configuration needed.

## Self-correction and Imprint

Leopoldo has two mechanisms that make it better the more you use it.

**Correction loop (immediate)**

When you tell Leopoldo an output was wrong, it does not just fix it. It runs a postmortem first: what was the root cause, which capability was responsible, what rule was missing. The fix is applied with the root cause in mind, and the finding is logged. This means corrections make the system permanently better, not just the current output.

**Imprint (cumulative)**

Once installed, Leopoldo observes your corrections and adapts locally: your terminology, your detail level, your formatting preferences. Every correction makes it more precise for you. The more you use it, the more it feels like yours.

Privacy: opt-in, local by default, no data shared or used for training. You can delete your profile at any time.

**The result:** the system gets smarter about your work. You get fewer corrections over time.

## Plugin lifecycle

Managed by the built-in lifecycle manager:

| Command | Purpose |
|---------|---------|
| `/leopoldo install [domain]` | First-time install |
| `/leopoldo add [domain]` | Add another domain (shared capabilities deduplicated) |
| `/leopoldo update` | Check for updates (explicit only, never automatic) |
| `/leopoldo status` | Show installed domains, health, environment |
| `/leopoldo repair` | Reinstall missing capabilities |
| `/leopoldo rollback` | Restore previous version from snapshot |
| `/leopoldo remove [domain]` | Remove one domain |
| `/leopoldo uninstall` | Remove everything, restore originals |

User modifications are preserved. Snapshots are created before every update.

## Architecture

```
skills/
  engine/               System capabilities (orchestrator, lifecycle, enforcement)
  packs/
    common/             Essentials and design foundations (included in every domain)
    dev/                Full Stack development expertise
agents/                 Workflow agents (orchestrator, system, reporting, environment)
.claude/                Configuration (settings, symlinks, commands)
.leopoldo/hooks/        5 enforcement hooks (shell-based, mechanical)
```

## Services

| Tier | For | What you get |
|------|-----|-------------|
| **Personal** | Professionals who want Claude to work harder | Premium domain of your choice. Full system deployment, dedicated support |
| **Team** | Teams who need AI expertise across their workflow | Premium domains, workflow calibration, team training session. Dedicated support |
| **Enterprise** | Organizations that need full deployment with SLA | Premium and custom based domains, team training session. Dedicated support |

[leopoldo.ai/services](https://leopoldo.ai/services) or contact [hello@leopoldo.ai](mailto:hello@leopoldo.ai)

## Community and support

- **Website**: [leopoldo.ai](https://leopoldo.ai)
- **Email**: [hello@leopoldo.ai](mailto:hello@leopoldo.ai)
- **GitHub**: [leopoldo-ai](https://github.com/leopoldo-ai)

## License

MIT. See [LICENSE](LICENSE) for details.

---

<p align="center">
  <sub>Built by Leopoldo. An autonomous system that orchestrates expertise for Claude.<br>The capabilities are content. The system is the product.</sub>
</p>
