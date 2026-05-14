---
description: Show Leopoldo Contribution Score for the most recent deliverable (Form B weighted breakdown showing what Leopoldo added vs vanilla Claude)
---

Invoke the `value-attribution` skill in Form B (full breakdown).

Read the orchestrator ledger of the current session, map the events to `skills/engine/value-attribution/inventory.yaml`, compute the weighted score and produce the breakdown table.

**Without arguments:** Form B for the latest deliverable of the session.

**Arguments:**
- `--last-N <n>` → aggregated score for the last N deliverables
- `--brief` → just the score number without breakdown table
- `--why` → Form B with explicit differential framing ("vs vanilla Claude") in the lead

Examples:
- `/leopoldo score` → full table latest deliverable
- `/leopoldo score --brief` → "87%"
- `/leopoldo score --why` → table + paragraph "without Leopoldo this would have been..."
