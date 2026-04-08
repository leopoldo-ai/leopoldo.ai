# Project Status

Run a comprehensive status check of the Leopoldo system. Report silently, then present a single structured output.

## Steps

1. **Skills inventory**: Count SKILL.md files in `skills/` grouped by pack
2. **Agents**: List agents in `agents/` with names
3. **Git health**: Last 5 commits, uncommitted changes, current branch
4. **Infrastructure**: Check if leopoldo.ai and the API are reachable (curl status codes)
5. **State**: Read `.state/state.json` for evolution status and pending tasks
6. **Build readiness**: Check if `bin/build-public-repos.sh` exists and is executable

## Output format

Present a single status card:

```
LEOPOLDO STATUS — [date]

Skills:     [count] across [N] packs
Agents:     [count] ([list])
Branch:     [branch] — [clean/dirty]
Last commit: [hash] [message] ([time ago])

Services:
  leopoldo.ai        [✅/❌] [status code]
  API (Railway)       [✅/❌] [status code]

Evolution:
  Last run:    [date or "never"]
  Pending:     [N] tasks

Build:       [ready/not ready]
```
