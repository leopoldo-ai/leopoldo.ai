# Scan Skills

Inventory all skills in the Leopoldo system. Silent scan, single structured output.

## Steps

1. Find all `SKILL.md` files under `skills/`
2. Categorize by location:
   - `skills/packs/finance/` — Finance plugins
   - `skills/packs/consulting/` — Consulting plugins
   - `skills/packs/dev/` — Dev plugin
   - `skills/packs/intelligence/` — Intelligence plugin
   - `skills/packs/legal/` — Legal plugin
   - `skills/packs/common/` — Common (included in all plugins)
   - `skills/engine/` — Engine skills
   - `skills/studio/` — Studio skills (not distributed)
3. For each category: count skills, list skill names
4. Compare with `.state/state.json` skill count if available

## Output

```
LEOPOLDO SKILL INVENTORY — [date]

Pack                Skills    Status
─────────────────────────────────────
finance/            [N]       [plugins list]
consulting/         [N]       [plugins list]
dev/                [N]
intelligence/       [N]
legal/              [N]       [sub-packs]
common/             [N]       essentials + design
engine/             [N]       system skills
studio/             [N]       dev tools (not shipped)
─────────────────────────────────────
TOTAL               [N]

State.json says: [N] — [✅ match / ⚠️ drift]
```
