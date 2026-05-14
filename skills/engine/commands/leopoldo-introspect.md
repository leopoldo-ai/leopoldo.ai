---
description: Show what Leopoldo has done in the current session (skills, agents, gates, audit signings, memory writes)
---

Invoke the `leopoldo-introspection` skill in Form B (full activity). Read the orchestrator ledger of the current session and produce a structured breakdown of:

- Skills invoked with purpose
- Agents dispatched with outcome
- Quality gates run
- Audit signings produced
- Memory writes performed

If the ledger is empty (cold start), invoke Form C instead.

Optional arguments:
- `week` → invoke Form D (cross-session, last N sessions)
- `--brief` → invoke Form A (compact 3-5 lines)
