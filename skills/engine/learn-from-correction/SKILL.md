---
name: learn-from-correction
description: Use when the user corrects an output, expresses a style preference, or rejects a deliverable. Saves the lesson to user-preferences.md or {domain}-preferences.md for future sessions. Client variant of skill-postmortem (no state/journal dependency).
type: pattern
applies_to: [CONTENT, DEV]
tier: essentials
status: ga
---

# Learn from correction

Client-friendly learning loop. When the user signals a correction, capture
the lesson in project memory so Leo adapts automatically next session.

## When to invoke

The user says:
- "sbagliato", "rifai", "non funziona", "correggi", "wrong", "redo", "fix this", "try again", "not what I asked"
- User provides a corrected version of something just produced
- User rejects the deliverable format

## What to do (lightweight, no blocking)

1. Acknowledge the correction in the user's language
2. Understand what went wrong (ask one clarifying question if needed)
3. Fix the output properly
4. Capture the lesson:
   - **Style / format preferences** (verbosity, sections, tone) → append to `user-preferences.md`
   - **Domain-specific corrections** (finance terminology, legal citation format, currency default) → append to `{domain}-preferences.md` (e.g., `finance-preferences.md`)
   - **One-off context** (this client, this mandate) → note in `MEMORY.md` if it exists

## Structure per preference file

Use the standard three-section structure:

```
## Current
- Active preferences (with confirmation count if recurring)

## Exceptions
- Domain-specific overrides

## Superseded
- Old preferences replaced by newer ones (keep for reference)
```

## Explicit anti-pattern

Do NOT STOP. Do NOT block. Do NOT trigger any HARD GATE workflow.
This is learning by annotation, not by ceremony. Just fix and learn.

The preference files load automatically at session start by Claude's native memory and the Preference Learning layer. No manual processing needed.
