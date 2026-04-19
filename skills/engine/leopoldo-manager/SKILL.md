---
name: leopoldo-manager
description: "Use when the user runs any /leopoldo command (install, add, update, remove, repair, rollback, status, uninstall), or requests plugin lifecycle operations: manifest tracking, safe updates, deduplication across plugins, conflict resolution, preservation of user customizations."
type: technique
---

# Leopoldo Manager — Plugin Lifecycle Management

Manages the full lifecycle of Leopoldo plugins in any project. Uses a manifest to track what is managed vs user-owned, enabling safe updates that never destroy user customizations.

## Commands

| Command | Purpose |
|---------|---------|
| `/leopoldo install [slug]` | First-time install of a plugin in the current project |
| `/leopoldo add [slug]` | Add another plugin (dedup shared skills) |
| `/leopoldo update` | Force update check now |
| `/leopoldo update --force` | Update including locally modified skills |
| `/leopoldo status` | Show installed plugins, skill counts, health |
| `/leopoldo repair` | Reinstall missing or corrupted managed skills |
| `/leopoldo rollback` | Restore previous version from snapshot |
| `/leopoldo restore [skill]` | Restore a single replaced skill from backup |
| `/leopoldo remove [slug]` | Remove one plugin, keep shared skills if other plugins need them |
| `/leopoldo uninstall` | Remove all Leopoldo skills, restore originals |

## Manifest

Source of truth: `.claude/skills/.leopoldo-manifest.json` (Claude Code) or `.claude-plugin/skills/.leopoldo-manifest.json` (Cowork).

**Key fields:** `manifest_version`, `format`, `installed_at`, `updated_at`, `plugins` (map of slug → version + date), `skills` (map of name → source, shared_with, version, hash, status).

### Skill statuses

| Status | Meaning | Update behavior |
|--------|---------|-----------------|
| `managed` | Installed by Leopoldo | Auto-update if hash unchanged |
| `managed-modified` | Installed by Leopoldo, user edited | Skip update (notify user) |
| `preserved` | User's own skill | Never touch |
| `replaced` | User's skill we replaced (backup exists) | N/A |
| `skipped` | User declined installing | Don't ask again |

## Format Detection

1. `.claude/skills/` exists → `claude-code`
2. `.claude-plugin/` exists → `cowork`
3. Neither → ask user, then create

## Workflow Rules

### Install (`/leopoldo install [slug]`)

Precondition: no manifest, or manifest without this plugin (→ redirect to add).

1. Detect format → download plugin from GitHub releases → scan existing skills
2. **Conflict resolution** per skill: name exists on disk → prompt user: replace (backup original) / skip / all
3. Compute SHA-256 hashes → generate/merge CLAUDE.md → write manifest → create snapshot
4. Report: skills added, replaced (backed up), skipped

### Add (`/leopoldo add [slug]`)

Precondition: manifest exists.

1. Check not already installed → download plugin
2. **Dedup:** skill already managed → compare versions → highest wins, add to `shared_with`
3. Skill not in manifest but on disk → conflict flow (replace/skip/all)
4. New skill → copy, mark managed
5. Update manifest → regenerate CLAUDE.md

### Update (`/leopoldo update`)

1. No manifest → **migration**: scan disk, generate manifest, notify user
2. Check GitHub releases per plugin → skip if all current
3. **Snapshot before applying** (max 3, auto-rotate oldest)
4. Per skill: hash matches manifest → overwrite. Hash differs → `managed-modified`, skip (unless `--force`)
5. New skills in release: check disk conflict → add or prompt
6. Regenerate CLAUDE.md → report (updated, skipped, new)

### Status, Repair, Rollback, Restore, Remove, Uninstall

| Command | Core logic |
|---------|-----------|
| **status** | Read manifest → display plugins, skill counts by status, modified/skipped lists, backup info, health |
| **repair** | Integrity check (exists + hash) → download + reinstall only damaged managed skills |
| **rollback** | List snapshots → user picks version → confirm → restore skills + manifest → regenerate CLAUDE.md |
| **restore [skill]** | Find `replaced` skill in manifest → copy from `.leopoldo-backup/skills/` → remove Leopoldo version |
| **remove [slug]** | Identify unique vs shared skills → remove unique only → restore backups if applicable → regenerate CLAUDE.md |
| **uninstall** | Confirm → restore all `replaced` skills → remove all managed → remove CLAUDE.md markers → delete manifest + backups. `.leopoldo/` user data: ask separately (default: keep) |

## CLAUDE.md Management

Markers: `<!-- leopoldo:start -->` / `<!-- leopoldo:end -->`

| Situation | Action |
|-----------|--------|
| No CLAUDE.md | Generate from template |
| Exists, no markers | Append markers + section at end |
| Exists, markers present | Replace between markers only |
| Content outside markers | NEVER touch |

Section contains: plugin table, agent table, workflow summary, conventions, commands.

## Hook Management

Hooks ship with every install. System-managed, not user-customizable.

| Script | Hook Event | Purpose |
|--------|-----------|---------|
| `core.sh` | (shared lib) | Root discovery, gate state, journal helpers |
| `session-start.sh` | SessionStart | Init session, check evolution |
| `compact-reinject.sh` | SessionStart (compact) | Re-inject gate state |
| `correction-detector.sh` | UserPromptSubmit | Detect corrections, set postmortem gate |
| `gate-enforcer.sh` | Stop | Enforce pending gates |
| `human-in-the-loop.sh` | PreToolUse | Block irreversible actions (deploy, email, db destructive, git push, pr merge) |
| `pre-edit-validator.sh` | PreToolUse | Protect .state/ and .leopoldo/ |
| `code-safety.sh` | PreToolUse | Scan for unsafe code patterns |
| `tool-logger.sh` | PostToolUse | Log tool usage, checkpoint counter |
| `pii-scanner.sh` | PostToolUse | Scan for PII and secrets |
| `rate-limiter.sh` | PostToolUse | Check rate limits |
| `subagent-tracker.sh` | SubagentStart/Stop | Track subagent lifecycle |
| `activate-license.sh` | (called by session-start) | Activate license on first run |
| `verify-license.py` | (called by session-start) | Verify Ed25519 license signature |

**Install:** copy scripts → chmod +x → merge into settings.json (detect Leopoldo hooks by `.leopoldo/hooks/` in command, preserve user hooks).
**Update:** snapshot → overwrite scripts → verify executability → update manifest hash.
**Uninstall:** remove Leopoldo hooks from settings.json → clean empty event keys → delete directories.

## Version Conflict Resolution

When two plugins bring the same skill: **highest version wins**. Never downgrade. Add to `shared_with`.

## Integrity Check (Session Start)

Runs every session, lightweight: manifest exists → count managed skills → check file existence (not hash) → warn if missing → delegate version check to update-checker.

## Error Handling

| Error | Action |
|-------|--------|
| No network | "Cannot reach GitHub." (manual) / silent (auto) |
| Plugin not found | "Plugin '{slug}' not found." |
| Manifest corrupted | Regenerate from disk scan, warn user |
| Disk full / permission denied | Inform user with path |
| Hash computation fails | Treat as unmodified (safe default) |

## Anti-patterns

- Touching files outside skills_dir without explicit user request
- Modifying content above `<!-- leopoldo:start -->` in CLAUDE.md
- Auto-updating user-modified skills (without --force)
- Asking questions during automatic session-start operations
- Deleting user skills without explicit confirmation
- Overwriting higher version with lower version

## Integration

| Skill | Integration |
|-------|-------------|
| `update-checker` | Delegates to manager for manifest-aware updates |
| `leopoldo-setup` | First-time setup delegates to manager install flow |
| `session-lifecycle` | Triggers integrity check on session start |
