---
name: leopoldo-onboarding
description: "Use at first session after license activation, or when user runs /leopoldo onboard, to guide a 5-minute conversational onboarding: 3 context questions, brand-kit setup, sector-relevant skills overview, worked example offer, and slash-command primer."
type: technique
version: 1.0.0
tier: essentials
status: ga
applies_to: [CONTENT, DEV, STUDIO]
---

# Leopoldo Onboarding

Client onboarding skill. Transforms the post-License Gate moment from "empty prompt" to "first 5 minutes guided" — capturing context, configuring brand, showing relevant capabilities, and offering a worked example.

Distinct from `leopoldo-setup` (which handles plugin installation and manifest creation). This is the UX flow **after** the system is installed and activated.

## Out of scope

- Does not install plugins (see `leopoldo-setup` / `leopoldo-manager`).
- Does not validate the license (License Gate is a prerequisite).
- Not a sales pitch: it is functional, not promotional.
- Does not redo onboarding every session: it is once-per-installation with a flag.

## Stop and surface

- Every phase is skippable. Never block the user.
- Phase 4 worked example option C produces real sample output: request confirmation before generating substantial content.
- If the user says "skip" at any point: close with abbreviated Phase 5 and set the flag.

## Two artifacts

1. **user-preferences.md** populated with sector, language, onboarding_completed_at, brand_kit_status
2. **Hand-off message** final, with slash-command primer

## Citation discipline

No external output cited. Skill is pure interaction + persistence.

## Quality bar

- Happy path completed in 4-5 minutes
- Every Phase has a visible skip option
- Phase 1 completable in <90 seconds if the user answers fluently
- user-preferences.md updated correctly at the end
- Idempotent: re-trigger via `/leopoldo onboard` redoes the flow without duplicating

## Trigger

- **Auto:** orchestrator session-start detect: client's first session AND `user-preferences.md` does not have `onboarding_completed_at`. Invoke in full mode.
- **Manual:** `/leopoldo onboard` (refresh / first-time miss recovery)
- **Implicit:** user explicitly changes sector ("from now on I work on M&A") → re-trigger Phase 3 only

## Workflow

### Phase 1 — Welcome + 3 context questions (1 min)

```markdown
Welcome, {name}. I am Leopoldo. Before we start, 3 quick questions to
configure me to your work. Everything is optional, you can always say "skip".

1. What do you primarily work on?
   PE / VC / M&A advisory / Family office / Asset management /
   Consulting / Legal / Medical research / Recruiting / Other

2. Working language?
   IT / EN / Both

3. Do you have a brand kit for your fund or company?
   - Yes, I have it (file path)
   - I can give you a PDF of guidelines
   - No, generate me a neutral one
   - Later
```

Capture and persist in `user-preferences.md`:

```markdown
## Current
- sector: {Q1}
- language: {Q2}
- brand_kit_status: {Q3 mapped to: provided | pdf_pending | neutral_requested | deferred}
- onboarding_completed_at: (will be filled at end of Phase 5)
```

If the user answers "skip" here: jump to abbreviated Phase 5.

### Phase 2 — Brand-kit setup (1 min)

Branch on Q3:

| Q3 answer | Action |
|---|---|
| "Yes, I have it" + path | Verify file, validate YAML, set `brand_kit_status: provided` |
| "Yes, I have it" without path | Ask for path. Fallback: silent Mode B |
| "PDF guidelines" | Invoke `brand-kit-setup` Mode C with requested path |
| "Generate me a neutral one" | Invoke `brand-kit-setup` Mode B (copy neutral.yaml) |
| "Later" | Invoke `brand-kit-setup` Mode D (silent Mode B + comment), set `brand_kit_status: deferred` |

At the end of Phase 2, `brand-kit.yaml` always exists in the root.

### Phase 3 — Skill activation summary (30 sec)

Read `skills/engine/leopoldo-onboarding/sector-skills.yaml` and produce:

```markdown
Configured. For your profile ({sector}), I have activated {N} specific capabilities.
The 5 most relevant for you:

- `{skill-1}` → {short purpose}
- `{skill-2}` → {short purpose}
- `{skill-3}` → {short purpose}
- `{skill-4}` → {short purpose}
- `{skill-5}` → {short purpose}

Plus {M-5} more capabilities in the packs you have installed.
For the full list: /leopoldo introspect
```

If sector = "Other": fallback to top-5 generic from `sector-skills.yaml` `default` key.

**Runtime filtering of non-installed skills**: skills listed in `sector-skills.yaml` for each sector may not be present in the client's build (e.g., `lbo-modeler` exists only if the `deal-engine` pack is installed). The orchestrator filters at runtime: for each skill in the top-5 list, verify existence in `skills/packs/**/SKILL.md` (Glob). Skills not found are skipped. If filtering brings the count below 5, replace with skills from `default` to reach 5. Concrete logic:

```
filtered = [s for s in sector_skills if exists(skill_path(s))]
while len(filtered) < 5 and default_skills_remaining:
    filtered.append(next_default_skill)
```

### Phase 4 — Worked example offer (1-2 min)

```markdown
Want to see me at work? 4 options:

A) Generate a {sector}-relevant template for a fictional case
B) Have a real case you want me to process now? Give it to me
C) Differential demo: I produce the same output with and without Leopoldo,
   I'll show you what changes (Form B value attribution)
D) Skip, let's start with what you need
```

Mapping A by sector:
- PE / VC / M&A → "ic-memo template"
- Family office → "wealth structuring brief"
- Asset management → "fund factsheet template"
- Consulting → "engagement proposal one-pager"
- Legal → "NDA template"
- Medical research → "grant proposal outline"
- Recruiting → "job mandate brief"
- Other → "executive briefing one-pager"

**Confirmation gate before execution** (B-NEW-9, 2026-05-09):

For options A, B, C that produce substantial content, NEVER execute silently. Always request explicit confirmation:

```markdown
OK, option {A|B|C}. I am about to:
- Generate {brief description: "a sample IC memo for a fictional deal"}
- Estimated time: {1-2 minutes}
- Capabilities I will activate: {list}

Proceed? (yes/no/modify)
```

On "yes" → execute. On "no" → return to Phase 4 menu. On "modify" → ask what to change.

For option C specifically: before producing the output, EXPLICITLY declare the 2 versions you will generate (with/without Leopoldo) to avoid the delta seeming invented. Show both in the same message.

Execute the chosen skill only after confirmation. For option C, invoke `value-attribution` Form B immediately after the Leopoldo output (not on the vanilla output).

### Phase 5 — Hand-off + slash-command primer (30 sec)

```markdown
At your service. Useful things to know:

  /leopoldo status          — what is active
  /leopoldo introspect      — what I did in this session + active capabilities
  /leopoldo score           — how much Leopoldo value I added to a deliverable
  /leopoldo brand show      — how your brand is configured
  /leopoldo onboard         — redo this flow

When you correct an output, I learn. I will explicitly confirm
every time I save a preference.

Tell me what you need.
```

Update `user-preferences.md` setting `onboarding_completed_at: <ISO8601>`.

Update orchestrator ledger: `Memory writes: + user-preferences.md (onboarding completed)`.

On Cowork: also write to native memory key `leopoldo.onboarding-completed = true` for cross-session persistence.

### Abbreviated Phase 5 (skip path)

If the user skips after Phase 1:

```markdown
OK, I'll skip the initial configuration. I am still active and available.
If you want to configure me better later, run /leopoldo onboard.

Tell me what you need.
```

Set `onboarding_skipped_at: <ISO8601>` in user-preferences (to prevent re-triggering).

## Idempotency

| Scenario | Behavior |
|---|---|
| `onboarding_completed_at` present | Skip auto-trigger; manual via `/leopoldo onboard` redoes |
| `onboarding_skipped_at` present, no completed | Skip auto-trigger; on 3rd session start show 1-line reminder "Want to complete setup? /leopoldo onboard" |
| Major version update | No forced re-trigger; show changelog + optional "redo onboarding?" |
| User changes sector | Re-trigger Phase 3 only (skill summary refresh) |

## Adaptation

| User phrasing (intent) | Behavior |
|---|---|
| "skip" / "not now" | Jump to abbreviated Phase 5 |
| "redo onboarding" | Force full re-trigger |
| "I'm switching to M&A" | Re-trigger Phase 3 only with new sector |
| "don't speak Italian" mid-flow | Switch language and continue from current Phase |

## Disclaimer

Onboarding captures indicative preferences. It is not an assessment, not a contract, not a commercial segmentation. It is pure setup UX. The answers serve to personalize skill suggestions and brand configuration, nothing more.

## Language note

This SKILL.md is documented entirely in English (project convention). At runtime, the orchestrator delivers all phases in the user's language. Phase 1 Q2 captures the language preference and propagates it to subsequent phases and to `brand-kit.yaml.brand.language_primary`.
