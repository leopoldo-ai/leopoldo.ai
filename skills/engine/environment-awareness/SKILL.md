---
name: environment-awareness
version: 1.0.0
description: Unified environment detection for CLIs, MCP servers, and plugins/extensions. Scans all three layers, stores results in the manifest, and provides context to the orchestrator for capability-aware routing. Absorbs and replaces mcp-discovery. Use on install, session start (quick check), or on demand via /leopoldo detect.
skillos:
  layer: core
  category: meta
  pack: null
  requires:
    hard: []
    soft: [leopoldo-manager]
  provides: [environment-detection, cli-detection, mcp-detection, plugin-detection, capability-map]
  triggers:
    - on: "leopoldo.install"
      mode: auto
    - on: "session.start"
      mode: auto
    - on: "command == '/leopoldo detect'"
      mode: auto
    - on: "command == '/leopoldo status'"
      mode: auto
  config: {}
metadata:
  author: lucadealbertis
  source: local
  license: proprietary
  replaces: mcp-discovery
  created: 2026-03-25
---

# Environment Awareness — Unified Tool Detection

Detects the full environment Leopoldo operates in: CLI tools, MCP servers, and installed plugins/extensions. One scan, one manifest section, one context block for the orchestrator.

**Replaces:** `mcp-discovery` (senior-consultant pack). All MCP detection is now handled here, unified with CLI and plugin detection.

## Why It Exists

| Problem | Solution |
|---------|----------|
| Leopoldo ignores installed CLIs (vercel, stripe, gh) | Layer 1 scans 20+ CLIs with version and auth status |
| `mcp-discovery` exists but is isolated in one pack | Unified system in engine, available to all plugins |
| VS Code extensions and external skills are invisible | Layer 3 detects extensions and non-Leopoldo skills |
| Every skill must guess what tools are available | Orchestrator injects environment context into every skill invocation |
| Full scan on every session start is too slow | Tiered scanning: full on install, quick on session start |

## Scan Types

| Moment | Scan type | What it does | Cost |
|--------|-----------|--------------|------|
| `leopoldo install` | **Full scan** | All 3 layers: CLIs, MCP, plugins | ~30 commands, 10-15s |
| **Session start** | **Quick check** | Validate cache, detect MCP changes | ~5 commands, <3s |
| MCP config change | **Layer 2 re-scan** | Re-scan MCP servers only | ~2s |
| `/leopoldo detect` | **Full re-scan** | On-demand full environment scan | ~10-15s |

## Core Workflow

### Layer 1 — CLI Detection

Detect installed CLI tools, their versions, and authentication status.

**Source:** `registry.yaml` in this skill's directory.

**Procedure:**

```
For each tool in registry.yaml cli_tools:
  1. Run check command (timeout 2s, stderr suppressed)
     - Exit 0 + output → installed, parse version from output
     - Non-zero or timeout → not installed, skip
  2. If installed AND auth_check defined:
     - Run auth_check (timeout 3s)
     - Exit 0 → authenticated
     - Non-zero → installed but not authenticated
  3. Record: name, version, authenticated (bool), capabilities, detected_at
```

**Version parsing:** Extract the first semver-like pattern (`X.Y.Z` or `X.Y`) from the check command output. If no version found, record `"unknown"`.

**Quick check mode (session start):** Only re-check CLIs already in cache. Do not search for new ones. If a cached CLI fails its check, mark as `"removed"`.

### Layer 2 — MCP Server Detection

Detect connected MCP servers and their capabilities.

**Procedure:**

```
1. List all tools in the current context that match the pattern mcp__*
2. Group by server name (second segment: mcp__{server}__{tool})
3. For each server:
   a. Extract tool list
   b. Match against known_servers in registry.yaml
      - Known → assign predefined capabilities
      - Unknown → capabilities = ["unknown"], known = false
   c. Record: name, status (connected), tools, capabilities, known (bool), detected_at
```

**Quick check mode (session start):** Compare currently visible `mcp__*` tools against cached list. If diff detected, update Layer 2 entries. This catches new MCP servers added between sessions.

**Replaces mcp-discovery Phase 2A/2B/3.** The categorization from mcp-discovery (notion, google_drive, slack, etc.) is replaced by the registry-based capability mapping, which is more extensible and not hardcoded to specific categories.

### Layer 3 — Plugins & Extensions

Detect VS Code extensions and external (non-Leopoldo) skills.

**Procedure:**

```
1. VS Code extensions:
   - Check if running in VS Code context (env var VSCODE_PID or similar)
   - If yes: run `code --list-extensions` (timeout 5s)
   - Parse output into list of extension IDs
   - Match against known extensions in registry for relevance notes

2. External skills:
   - Scan .claude/skills/ for any skill not tracked in .leopoldo-manifest.json
   - These are user-created or third-party skills
   - Record name and path (do not read content, just catalog)
```

**Quick check mode:** Skip entirely. Plugin/extension changes are rare. Only on full scan.

## Manifest Integration

All results stored in the `environment` section of `.leopoldo-manifest.json`:

```json
{
  "environment": {
    "last_scan": "2026-03-25T10:30:00Z",
    "scan_type": "full",

    "cli_tools": {
      "vercel": {
        "version": "37.2.1",
        "authenticated": true,
        "capabilities": ["deploy", "domains", "env-vars", "logs"],
        "detected_at": "2026-03-25T10:30:00Z"
      },
      "gh": {
        "version": "2.65.0",
        "authenticated": true,
        "capabilities": ["repos", "issues", "prs", "releases", "actions"],
        "detected_at": "2026-03-25T10:30:00Z"
      }
    },

    "mcp_servers": {
      "postgres": {
        "status": "connected",
        "tools": ["query"],
        "capabilities": ["query", "schema"],
        "known": true,
        "detected_at": "2026-03-25T10:30:00Z"
      },
      "custom-internal-api": {
        "status": "connected",
        "tools": ["fetch_data", "submit_report"],
        "capabilities": ["unknown"],
        "known": false,
        "detected_at": "2026-03-25T10:30:00Z"
      }
    },

    "plugins": {
      "vscode_extensions": ["github.copilot", "bradlc.vscode-tailwindcss"],
      "external_skills": ["my-custom-skill"],
      "detected_at": "2026-03-25T10:30:00Z"
    }
  }
}
```

## Orchestrator Integration

The orchestrator reads `environment` from the manifest and injects a context block into every skill invocation:

```
## Environment Context
CLIs: vercel (auth), gh (auth), stripe (no auth), docker, psql
MCP: postgres (connected), github (connected), sentry (connected), custom-api (2 tools)
Extensions: copilot, tailwind, eslint
External skills: my-custom-skill
```

Skills see this context and adapt. They do not read the manifest themselves. The orchestrator is the single reader.

### Tool Preference Logic

When both a CLI and an MCP server provide the same capability:

```
Priority:
  1. MCP server (richer integration, structured responses, already in tool context)
  2. CLI (direct execution, works offline, good fallback)
  3. Manual instructions (last resort: provide commands for the user to run)
```

Example: GitHub operations.
- `github` MCP connected → use `mcp__github__*` tools
- MCP not available but `gh` CLI authenticated → use `gh` via Bash
- Neither → provide manual instructions

### Routing Examples

| User request | Orchestrator sees | Routes with context |
|---|---|---|
| "deploy this" | vercel CLI (auth) | Deploy skill + "use `vercel deploy`" |
| "check errors in prod" | sentry MCP (connected) | Monitoring skill + "use sentry MCP tools" |
| "query the database" | postgres MCP + psql CLI | Prefers MCP, falls back to psql |
| "send update to client" | resend MCP (connected) | Comms skill + "use resend MCP tools" |
| "create a PR" | gh CLI (auth) + github MCP | Prefers MCP (richer API), gh CLI as backup |
| "generate a research paper" | researchclaw CLI detected | medical-research agent + note ARC availability |

### Auth Awareness

| State | Behavior |
|---|---|
| CLI installed + authenticated | Use directly |
| CLI installed + not authenticated | Note in context: "available but needs auth" |
| CLI not installed | Omit from context, use alternatives |
| MCP connected | Use directly |
| MCP in config but not connected | Note: "configured but disconnected" |

## User-Facing Output

On `/leopoldo status` or `/leopoldo detect`:

```
Environment

  CLIs
    vercel     v37.2.1   authenticated
    gh         v2.65.0   authenticated
    stripe     v1.21.0   not authenticated (run: stripe login)
    docker     v27.1.0   running
    psql       v16.2     available

  MCP Servers
    postgres   connected   query, schema
    github     connected   repos, issues, prs, releases, search
    sentry     connected   issues, errors, performance
    custom-api connected   2 tools (unknown server)

  Plugins
    VS Code: copilot, tailwind, eslint
    External skills: my-custom-skill

  5 CLIs detected (4 ready) | 4 MCP servers | 3 VS Code extensions
```

## Cache Invalidation

```
Cached CLI not responding       → mark "removed", remove from context injection
Cached MCP not connected        → mark "disconnected", note in status
New MCP server appears          → auto-detected at session start (quick check)
User runs /leopoldo detect      → full cache rebuild
Cache older than 7 days         → orchestrator suggests re-scan (non-blocking)
```

## Custom Entries

Users can add custom tools to their manifest that get scanned alongside the registry:

```json
{
  "environment": {
    "custom_cli_tools": {
      "mycorp-cli": {
        "check": "mycorp --version",
        "capabilities": ["deploy", "config"]
      }
    },
    "custom_mcp_notes": {
      "custom-internal-api": {
        "description": "Internal reporting API",
        "capabilities": ["reports", "dashboards"]
      }
    }
  }
}
```

Custom CLI entries are checked during full scans using the provided `check` command. Custom MCP notes enrich unknown servers with human-readable descriptions.

## Migration from mcp-discovery

For projects that used `mcp-discovery`:

1. On first run of `environment-awareness`, detect if `mcp_capabilities` exists in `.state/state.json`
2. If found: migrate data to the new `environment.mcp_servers` format in the manifest
3. Remove `mcp_capabilities` from state.json
4. The old `mcp-discovery` skill in the senior-consultant pack becomes a thin redirect:
   "This skill has been replaced by `environment-awareness` (engine). Run `/leopoldo detect` instead."

## Rules

1. **Never install tools.** Detection only. Installing is the user's choice (or `dev-setup` agent's job)
2. **Never store credentials.** Only store whether auth succeeded (bool), not tokens or keys
3. **Never fail the session.** If a check command hangs or errors, skip that tool and continue
4. **Timeout everything.** 2s for CLI checks, 3s for auth checks, 5s for extension listing
5. **Quick check must be fast.** Under 3 seconds total. No full rescans on session start
6. **Unknown is valid.** An MCP server not in the registry gets `known: false` and its tools listed. Never discard

## Anti-patterns

| Anti-pattern | Why it is wrong | What to do instead |
|---|---|---|
| Running full scan on every session start | Adds 10-15s to every session | Quick check only, full scan on demand |
| Hardcoding server names for MCP detection | Servers change names across versions | Use `mcp__*` tool prefix pattern matching |
| Storing auth tokens in the manifest | Security risk | Store only `authenticated: true/false` |
| Skipping unknown MCP servers | User might have valuable custom integrations | Catalog as unknown with tool list |
| Each skill reading the manifest directly | Duplicated logic, inconsistent reads | Orchestrator reads once, injects context |
