---
name: update-checker
version: 7.0.0
description: Use when the user runs /leopoldo update, asks to check for Leopoldo plugin updates, requests a version refresh for skills, agents, hooks, orchestrator, or CLAUDE.md, or when the offline integrity check runs at session start. Backend-aware via client API key, never connects automatically.
type: technique
---

# Leopoldo Update Checker v7 — Backend-Aware

Explicit-only update system. NEVER connects automatically. Uses `leopoldo-client.json` for API key and backend URL. The only thing that runs on session start is an offline integrity check (no network, no API calls).

## Trigger

- **Manual only:** `/leopoldo update` or `/update`
- NOT on session start. NOT automatic. NOT silent.
- Integrity check (offline) runs every session start — no network.

## Phase 1: Read state

1. **Detect format:** `.claude/skills/` → claude-code, `.claude-plugin/` → cowork
2. **Read `leopoldo-client.json`:** extract `api_key`, `api_url`, `client_id`
3. **Legacy check:** `github_token` found instead of `api_key` → show migration message, STOP
4. **Read manifest** for installed plugin versions and skill hashes

## Phase 2: Validate license

1. `GET {api_url}/api/licenses/validate` with `X-Api-Key: {api_key}`
2. Expired → show message, STOP
3. Network error → show message, STOP
4. Valid → proceed

## Phase 3: Check for updates

1. `GET {api_url}/api/updates/check` with `X-Api-Key: {api_key}`
2. No updates → show version list, STOP
3. Updates available → show list with changelogs, ask user to confirm

## Phase 4: Download and install (manifest-aware)

1. **Snapshot** before applying (max 3, delete oldest)
2. **Download** per plugin: `GET {api_url}/api/updates/download/{slug}` with `X-Api-Key`
3. **Apply with manifest rules:**

| Condition | Action |
|---|---|
| Managed + hash matches manifest | Overwrite, update hash. Count: "updated" |
| Managed + hash differs (user modified) | Do NOT overwrite. Mark `managed-modified`. Count: "skipped" |
| New skill (in update, not in manifest) | Install, add as managed |
| Skill in manifest but NOT in update | Keep. Never auto-delete |

4. Update manifest (versions, hashes, new skills, modified flags)
5. Regenerate CLAUDE.md Leopoldo section (between `<!-- leopoldo:start/end -->` markers)
6. Show summary: updated, skipped, new. If modified: list names + suggest `--force`

## Phase 5: Integrity check (offline, every session)

ZERO network calls. Read manifest → verify each managed skill exists on disk → missing: warn once "N skills missing. Run /leopoldo repair." → all healthy: zero output.

## Soft Expiry

Plugin works normally when expired (100% offline). `/leopoldo update` shows expiry + stops. One-time reminder per session. Check: `leopoldo-client.json` → `expires` field.

## Extended Update Categories (v7)

| Category | Location | Update behavior |
|---|---|---|
| `skills` | `.claude/skills/` | Hash-checked, user modifications preserved |
| `agents` | `.claude/agents/` | Always overwrite (no user customization) |
| `hooks` | `.leopoldo/hooks/` | Always overwrite (system scripts) |
| `orchestrator` | `.claude/agents/orchestrator.md` | Always overwrite (client variant) |
| `claude_md` | `CLAUDE.md` | Regenerate leopoldo:start/end section only |

**Update flows:** Agents/hooks/orchestrator: download → overwrite → log event. CLAUDE.md: find markers → replace between → preserve outside. All create snapshots before applying.

## Error Handling

| Error | Action |
|---|---|
| No network / timeout | "Could not reach update server." |
| 401 Unauthorized | "Invalid API key. Contact hello@leopoldo.ai." |
| 403 License revoked | "License revoked. Contact hello@leopoldo.ai." |
| 429 Rate limited | "Too many downloads today. Try again tomorrow." |
| 404 No version | Skip that plugin |
| Old format (github_token) | "Older format. Contact hello@leopoldo.ai for upgrade." |

## Orphan detection on update

After fetching v(new) from backend, before applying the update, compute:

`orphans = managed_in_current_manifest - managed_in_new_manifest`

These are skills that were part of the plugin in the previous version but are no longer shipped (removed from essentials, moved to Studio-only, or deprecated entirely).

**Never delete without prompting.** Present the user an explicit choice:

> Update v(old) → v(new) ready.
> - N new managed skills to install
> - M orphan managed skills detected (were in v(old), not in v(new)):
>   [list the first 5, then "... and K more" if more than 5]
>
> Options:
>   [y] Remove orphan skills (recommended)
>   [k] Keep them (safe default)
>   [l] Show full list
>   [c] Cancel update
>
> Choice [y/k/l/c]:

Default: `k` (keep). If the user picks `y`:
- For each orphan, only remove if the manifest entry status is exactly `managed` (not `modified`, not `preserved`, not `replaced`)
- Remove the file from disk
- Remove the entry from `.leopoldo-manifest.json`
- Log the removal to `.state/journal/` (if journal available) with event `orphan.removed`

If status is `modified`: keep the file, downgrade manifest entry to `preserved` (user edits are now theirs), log `orphan.demoted`.

After removal, rewrite the manifest with the final state. Idempotent: running update again with the same manifest should produce zero further changes.

## Rules

- NEVER check for updates on session start (only integrity check, offline)
- NEVER connect to any server without explicit user command
- Only data sent: `api_key` in header. No file contents, no telemetry
- Manifest is source of truth for all install state
- Never overwrite modified skills unless `--force`
- Never delete managed skills without explicit user confirmation during update or repair --prune
- Always snapshot before updates
- Idempotent: running twice = same result
