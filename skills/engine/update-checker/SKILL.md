---
name: update-checker
version: 5.0.0
description: Manifest-aware update system for Leopoldo plugins. Checks GitHub Releases on session start, updates only managed skills (preserving user customizations), runs integrity checks, and handles migration from legacy installs. Use on session start or manually with /update.
skillos:
  layer: core
  category: meta
  pack: null
  requires:
    hard: []
    soft: ["leopoldo-manager"]
  provides: ["auto-update", "plugin-update", "integrity-check"]
  triggers: ["session-start"]
  config: {}
---

# Leopoldo Update Checker v5 — Manifest-Aware

Automatic, silent update system that respects user customizations. Uses the manifest (`.leopoldo-manifest.json`) to know which skills are managed by Leopoldo and which belong to the user. Never overwrites user modifications without explicit consent.

All plugins are free and open source (MIT). No authentication needed.

## Trigger

- **Automatic:** Every session start (pre-tool hook)
- **Manual:** User says "update", "check for updates", or `/update`

## Workflow

### Phase 1: Read state

1. **Detect format:**
   - `.claude/skills/` exists → `claude-code`, manifest at `.claude/skills/.leopoldo-manifest.json`
   - `.claude-plugin/` exists → `cowork`, manifest at `.claude-plugin/skills/.leopoldo-manifest.json`

2. **Read manifest:**
   - **Manifest exists:** extract plugins map, skills map, versions
   - **Manifest missing, but Leopoldo skills detected:** MIGRATION (see Phase 1b)
   - **No manifest, no Leopoldo skills:** exit silently (not a Leopoldo project)

3. **Also read** `VERSION.json` for backward compatibility with legacy installs

### Phase 1b: Migration (legacy installs without manifest)

For users who installed before the manifest system:

1. **Scan** all skills in skills_dir
2. **Match** against known Leopoldo skill catalog (by name)
3. **Generate manifest:**
   - Known Leopoldo skills → `"status": "managed"`, compute hash
   - Unknown skills → `"status": "preserved"`
4. **Extract** plugin info from VERSION.json if available
5. **Write** manifest
6. **Notify:** "Leopoldo manifest created. Your skills are now tracked for safe updates."
7. **Continue** to Phase 2

### Phase 2: Check for updates

For each plugin in `manifest.plugins`:

1. **Call** `GET https://api.github.com/repos/leopoldo-ai/{slug}/releases/latest`
   - No authentication needed (public repo)
   - Set header: `Accept: application/vnd.github.v3+json`
   - Set header: `User-Agent: leopoldo-update-checker`

2. **Extract** `tag_name` from response
3. **Compare** with version in manifest

4. **If all plugins up to date:** proceed to Phase 4 (integrity check only). Zero update output.

### Phase 3: Download and install update (manifest-aware)

1. **Create snapshot** before applying:
   - Copy current managed skill files to `.leopoldo-backup/snapshots/v{current}/`
   - Keep max 3 snapshots (delete oldest if needed)

2. **Download** release assets for plugins that need updating

3. **For each skill in the update, check manifest:**

   **A) Skill is managed, hash matches manifest (user hasn't modified):**
   → Overwrite with new version
   → Update hash in manifest
   → Count as "updated"

   **B) Skill is managed, hash does NOT match (user modified it):**
   → Mark as `"managed-modified"` in manifest
   → Do NOT overwrite
   → Count as "skipped (local changes)"

   **C) Skill is in manifest as "skipped":**
   → Do not touch. User explicitly declined this skill.

   **D) Skill is in manifest as "managed-modified":**
   → Do not touch (already known to be user-modified)
   → Count as "skipped (local changes)"

   **E) New skill (in update but not in manifest):**
   → Check if name exists on disk
   → Name does NOT exist: install, add to manifest as managed
   → Name EXISTS: skip in auto mode (don't conflict-prompt on session start)
     In manual mode (/update): prompt user like install flow

   **F) Skill in manifest but NOT in update (removed upstream):**
   → Keep it. Never auto-delete a skill.

4. **Update manifest:**
   - New plugin versions
   - New skill hashes
   - New skills added
   - Modified skills flagged

5. **Regenerate CLAUDE.md Leopoldo section:**
   - Find `<!-- leopoldo:start -->` and `<!-- leopoldo:end -->`
   - Replace content between markers with updated info
   - If markers don't exist, append section at end of file

6. **Update VERSION.json** for backward compatibility

7. **Notify** (brief):

```
Leopoldo updated to v1.1.0
```

If specific plugins updated:
```
Leopoldo updated: Investment Core v1.0.0 → v1.1.0
  45 updated, 2 skipped (local changes), 1 new
```

If skips exist in auto mode:
```
Leopoldo updated to v1.1.0 (2 skills skipped, local changes preserved)
```

### Phase 4: Integrity check (every session start)

Lightweight check, runs even when no update is available:

1. **For each managed skill in manifest:**
   - Does the file exist on disk?
   - If missing: add to missing list

2. **If missing skills found:**
   - Auto mode: warn once: "2 Leopoldo skills missing. Run /leopoldo repair."
   - Don't block the session, just inform

3. **If all healthy:** zero output

## Error Handling

| Error | Action |
|-------|--------|
| No network / timeout | Exit silently (auto) / "Check your connection" (manual) |
| GitHub API rate limit (403) | Exit silently. Try next session. |
| Release not found (404) | Exit silently. Repo may not have releases yet. |
| Asset download fails | Skip that asset. Try next session. |
| Manifest missing | Attempt migration (Phase 1b). If no Leopoldo skills, exit. |
| Manifest corrupted | Regenerate from disk scan, warn user |
| VERSION.json missing | Create with defaults if manifest exists |
| Snapshot write fails | Continue update without snapshot, warn user |

**Rule: NEVER show errors to the user on automatic checks.** The update system must be invisible when it can't work. Only show errors on manual `/update` invocation.

## Manual mode (/update)

When user explicitly says `/update` or "check for updates":

1. Run same workflow as above
2. Always show output, even if no updates:

```
All plugins up to date.
  Investment Core v1.0.0
  Deal Engine v1.0.0
  124 skills managed, 3 user skills preserved
```

3. On error, show helpful message:

```
Could not check for updates. Check your network connection.
```

4. If modified skills exist, remind:

```
2 skills have local changes (updates skipped):
  dd-screening, risk-framework
Use /leopoldo update --force to override.
```

## Hash Computation

SHA-256 of the SKILL.md file content (the main skill file only, not references/ subdirectory).

```
hash = SHA-256(read("skills/{name}/SKILL.md"))
```

Why only SKILL.md:
- It's the primary file that defines the skill
- References are supplementary and rarely change independently
- Keeps hash computation fast

## VERSION.json (backward compatibility)

Still maintained for legacy compatibility, but manifest is the source of truth:

```json
{
  "github_repo": "leopoldo-ai/investment-core",
  "format": "claude-code",
  "installed_version": "1.0.0",
  "installed_plugins": {
    "investment-core": "1.0.0",
    "deal-engine": "1.0.0"
  }
}
```

When manifest exists, VERSION.json is updated as a mirror but never read as primary source.

## Rules

- **NEVER mention SkillOS** — all user-facing text says "Leopoldo"
- **Silent by default** — zero output when no updates or on error during auto-check
- **Brief notifications** — max 3 lines per update
- **Manifest is source of truth** — VERSION.json is secondary
- **Never overwrite modified skills** — unless user passes --force
- **Never delete skills automatically** — even if removed from upstream
- **Never prompt during auto-check** — save conflict resolution for manual mode
- **Snapshot before update** — always create backup before applying changes
- **Idempotent** — running twice with same state produces same result
- **No authentication** — GitHub API for public repos requires no auth

## Anti-patterns

- Overwriting user-modified skills without --force
- Prompting user during session-start auto-check
- Deleting skills that were removed from an upstream release
- Downgrading a skill to an older version
- Showing verbose progress ("Checking... Downloading... Installing...")
- Ignoring the manifest and falling back to overwrite-all behavior
- Skipping integrity check when no update is available

---

**Version:** 5.0.0 (manifest-aware, integrity checks, migration support)
**Type:** Engine skill (distributed in every plugin)
**Dependencies:** Read/Write tools, WebFetch (for GitHub API), Bash (for hash computation)
