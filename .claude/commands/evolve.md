# Evolution Cycle

Trigger the Leopoldo evolution cycle manually. This runs the weekly evolution process regardless of schedule.

## What it does

Dispatches the evolution-agent which runs 3 parallel analyses:

1. **Internal Retrospective**: Friction detection, patch proposals, state checks across all skills and agents
2. **GitHub Radar**: New repos, MCP servers, Claude plugins, competitor activity
3. **Anthropic Watch**: SDK/API changes, new features, deprecations, documentation updates

## Process

1. Read `.state/state.json` for current evolution state
2. Dispatch `evolution-agent` from `agents/studio/evolution-agent.md`
3. Run all 3 subagents in parallel
4. Synthesize findings into an evolution report
5. Present report for approval
6. Save approved items to `.state/state.json` as pending tasks
7. Save report to `.state/evolution/report_[date].md`

## Rules

- Nothing is applied without explicit user approval
- Cap: 5 patches + 5 sprint tasks per cycle
- Pending tasks carry over between cycles
