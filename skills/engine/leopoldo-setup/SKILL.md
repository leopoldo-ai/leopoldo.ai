---
name: leopoldo-setup
version: 5.0.0
description: Use when first configuring Leopoldo in a project, running /setup, initializing plugins for the first time, detecting install format, creating manifest via leopoldo-manager, or configuring auto-updates on initial setup.
type: technique
---

# Leopoldo Setup

First-time configuration for Leopoldo plugins. Detects the environment, delegates installation to `leopoldo-manager`, and confirms everything is ready.

All plugins are free and open source (MIT). No tokens or licenses needed.

## Trigger

- **Automatic:** When `update-checker` detects no manifest exists (fresh install)
- **Manual:** User says `/setup`, "configure leopoldo", or "setup leopoldo"

## Workflow

### Step 1: Check if already configured

1. **Look for** `.leopoldo-manifest.json` in skills directory
2. **If manifest exists:** inform user and exit

```
Leopoldo is already configured (v1.0.0).
  Plugins: Investment Core, Deal Engine
  Skills: 124 managed
  Auto-updates: enabled
Run /leopoldo status for details.
```

### Step 2: Detect environment

1. **Check** if `.claude/skills/` exists → format is `claude-code`
2. **Check** if `.claude-plugin/` exists → format is `cowork`
3. **If neither:** ask user which format to set up, then create directory

### Step 3: Delegate to leopoldo-manager

**This is the key change from v4.** Setup no longer handles installation logic itself. It delegates to `leopoldo-manager` which handles:

- Scanning existing skills
- Conflict resolution (backup + replace or skip)
- Manifest creation with hashes
- CLAUDE.md generation/merge
- VERSION.json creation

```
→ Invoke leopoldo-manager install flow
→ Manager scans skills, creates manifest, handles conflicts
→ Manager generates CLAUDE.md section
→ Manager creates initial snapshot
```

### Step 4: Confirm

```
Leopoldo configured.

  Plugins: Investment Core (v1.0.0)
  Skills: 100 managed, 3 user skills preserved
  Format: Claude Code
  Auto-updates: enabled (via GitHub)

Your plugins update automatically at every session start.
Use /leopoldo status anytime to check health.
```

## Rules

- **NEVER mention SkillOS** — everything is "Leopoldo"
- **One-time only** — once configured, redirect to /leopoldo status
- **Friendly tone** — this is the user's first interaction
- **Delegate to manager** — setup is the entry point, manager does the work
- **Minimal steps** — detect, delegate, confirm
- **No auth needed** — all repos are public

## Anti-patterns

- Running setup when already configured (just confirm and exit)
- Duplicating installation logic that lives in leopoldo-manager
- Asking unnecessary questions (auto-detect everything possible)
- Technical jargon (no "API", "endpoint", "JSON", "manifest" in user-facing text)

---

**Version:** 5.0.0 (delegates to leopoldo-manager for manifest-based installation)
**Type:** Engine skill (distributed in every plugin)
**Dependencies:** leopoldo-manager, update-checker
