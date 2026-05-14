---
description: Setup, view, or reset the project brand-kit.yaml (interactive 4-question flow, neutral default, or PDF import)
---

Invoke the `brand-kit-setup` skill.

**Without arguments:** full flow (Step 0 detection + Step 1 4-mode menu + execution of chosen mode).

**Arguments:**
- `show` → print the current contents of `brand-kit.yaml` (sections: brand, colors, typography, document)
- `reset` → backup existing to `.brand-kit-backup-{date}.yaml`, regenerate from the neutral template (mode B)
- `pdf {path}` → direct mode C with the specified PDF
- `default` → silent mode B, overwrites only if not existing

Examples:
- `/leopoldo brand` — interactive
- `/leopoldo brand show` — print current
- `/leopoldo brand reset` — reset to neutral
- `/leopoldo brand pdf /path/to/guidelines.pdf` — PDF import
