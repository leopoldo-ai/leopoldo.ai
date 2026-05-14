---
description: Run the 5-minute Leopoldo onboarding sequence (3 context questions + brand-kit setup + skill summary + worked example offer + slash-command primer)
---

Invoke the `leopoldo-onboarding` skill in full mode.

**Without arguments:** full flow Phase 1 → 5.

**Arguments:**
- `--skip-to-brand` → skip Phase 1, start from Phase 2 (brand-kit setup)
- `--skip-to-skills` → skip Phase 1+2, start from Phase 3 (sector skill summary)
- `--demo` → direct Phase 4 option C (differential demo with value-attribution)
- `--reset` → clear `onboarding_completed_at` from user-preferences and full re-trigger

Idempotency: if `onboarding_completed_at` is already set in `user-preferences.md`, ask for confirmation "do you want to redo the full onboarding? (yes/no/refresh-only)"
