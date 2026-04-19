---
description: |
  Inventory all Leopoldo skills and produce a categorized count.
  Trigger with "scan skills", "quante skill abbiamo", "inventory skills",
  "catalog skills", "skill count", or "quante skill ha Leopoldo".
argument-hint: ""
---

# /scan-skills

## Required Reading — Do This First

Before any output, read these completely:

1. `.state/state.json` — authoritative skill count by pack
2. `skills/engine/skill-inventory/SKILL.md` — inventory discipline

---

**Scope:** systematic skill count across all packs, with drift detection vs state.json.
**NOT for:** status snapshot (use `/status`). Not for detailed skill-by-skill audit.

## What I Need From You

No arguments required.

## Output Template

```markdown
LEOPOLDO SKILL INVENTORY — [YYYY-MM-DD]

| Pack | Skills | Notes |
| --- | --- | --- |
| finance/ | [N] | investment-core, deal-engine, fund-suite, advisory-desk, markets-pro |
| consulting/ | [N] | senior-consultant, marketing, med-research |
| dev/ | [N] | full-stack |
| intelligence/ | [N] | competitive-intelligence |
| legal/ | [N] | 8 sub-packs (corporate, contract, IP, dispute, etc.) |
| common/ | [N] | essentials + design-foundations (shipped in every plugin) |
| engine/ | [N] | system skills |
| studio/ | [N] | authoring tools (never shipped to clients) |
| **TOTAL** | **[N]** | |

State.json claims: [N] → [🟢 match | 🟡 drift: filesystem +X / -Y]
```

## The Tests

Run before showing the user:

- **The drift test**: Compare filesystem count with `.state/state.json.skills.total`. If mismatch, flag 🟡 and list the delta.
- **The grounding test**: Every count is the result of `find skills/** -name SKILL.md | wc -l` per directory, never estimated.
- **The scope test**: Do not count `_backup-pre-slim` or `_archive-pre-split` directories (they are snapshots, not live skills).

## Flow

1. Read `.state/state.json` for baseline
2. Run filesystem scan: `find skills -name SKILL.md -not -path '*/_backup*' -not -path '*/_archive*'`
3. Group by pack directory
4. Render the inventory table
5. Compute drift vs state.json; mark 🟢 or 🟡
6. If drift detected, list the specific skills added/removed (first 5, then ellipsis)

## Tips

1. If the drift is >10 skills in either direction, suggest running `/evolve` or updating `.state/state.json` manually
2. The `common/` pack counts apply to every distributed plugin — note it in output so the numbers are not double-counted externally
3. Backup directories (`_backup-pre-slim/`, `_archive-pre-split/`) are not skills. Always exclude them.
