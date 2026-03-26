---
name: skill-sourcer
description: Use when creating new skills for any pack. Executes the 6-step scout-first process (SPEC, SCOUT, DIFF/FORGE, VERIFY, TRACK) to maximize reuse of existing skills and minimize build-from-scratch effort. Mandatory for all financial services ecosystem skills.
---

# Skill Sourcer — Scout-First, Build-Second

Process skill that ensures every new skill is created through a disciplined 6-step pipeline. Maximizes reuse of existing work, enforces security as a hard gate, and produces skills that conform to the SkillOS SKILL.md standard.

**This is a RIGID skill.** Follow every step. Do not skip steps because a skill "seems simple to build from scratch."

## Core Workflow

```
SPEC ──▶ SCOUT ──▶ FORGE ──▶ VERIFY ──▶ TRACK
  │         │        │          │          │
  │     security     │       quality     upstream
  │      gate        │        gate      monitor
  │    PASS/FAIL     │      PASS/FAIL
  │         │        │          │
  ▼         ▼        ▼          ▼
spec    longlist  SKILL.md    registered
card    (safe     + SOURCES   in SOURCES.md
         only)    .md entry
```

**Routing after SCOUT:**

```
SCOUT_HIT (>= 75% match)    → DIFF → FORGE(ADAPT)
SCOUT_PARTIAL (40-74%)       → DIFF → FORGE(MERGE)
SCOUT_MISS (< 40% or empty) → FORGE(BUILD) diretto
```

DIFF replaces the old TEST+RANK steps. Instead of scoring candidates on 7 axes, produce a delta report: what the upstream covers vs what the spec requires. This is faster and more actionable.

### Step 1 — SPEC (Define the target)

Before searching, define exactly what the skill must do. Create `spec-card.md`:

```markdown
# Spec Card: [skill-name]

## Identity
- **Pack:** [pack-name]
- **Cluster:** [cluster within pack]
- **Layer:** userland

## Scope
[1-2 sentences: what this skill does and does NOT do]

## Expected Inputs
- [What the user provides or what triggers this skill]

## Expected Outputs
- [What the skill produces: analysis, document, code, decision, etc.]

## Must-Have Features
1. [Feature]
2. [Feature]

## Nice-to-Have Features
1. [Feature]

## Anti-Patterns
- [What this skill must NOT do]

## Integration Points
- [Which other skills in the pack interact with this one]
- [Handoff points: what comes before, what comes after]

## Success Criteria
- [How do we know the skill works correctly]

## Key Rules
- [Domain-specific rules the skill must enforce]
```

**Output:** `spec-card.md` saved alongside the skill directory

### Step 2 — SCOUT + SECURITY GATE (Search wide, filter hard)

#### 2a. Scout sources

Search across ALL of these source types. Do not stop at the first match:

| Source | How to search | What to look for |
|--------|--------------|-----------------|
| **GitHub skill repos** | `WebSearch` for `claude skill [domain]`, `claude code skill [topic]` | claude-skills, anthropic, vercel-labs, trailofbits, community repos |
| **MCP registries** | `WebSearch` for `MCP server [domain]`, check mcp.so, glama.ai | MCP servers covering the domain |
| **Prompt libraries** | `WebSearch` for `[domain] prompt engineering`, `[domain] system prompt` | Prompt engineering repos with domain templates |
| **Industry frameworks** | `WebSearch` for authoritative standards bodies | ILPA, GIPS, ISDA, OWASP, Basel, IFRS, CFA, FRM, CAIA |
| **Skill marketplaces** | Check Claude skill marketplace, community hubs | Published skills from verified authors |
| **Academic/professional** | `WebSearch` for `[domain] framework checklist methodology` | Professional body curricula, certification frameworks |

**Output:** Longlist table:

```markdown
| # | Candidate | Source | URL | Type | Quick Notes |
|---|-----------|--------|-----|------|-------------|
| 1 | ... | GitHub | ... | Skill | ... |
| 2 | ... | MCP | ... | Server | ... |
```

If longlist is empty (0 candidates found), skip directly to Step 5 with BUILD strategy.

#### 2b. Security gate (PASS/FAIL)

For EACH candidate on the longlist, run a light security check:

```
SCOUT ──▶ SECURITY GATE
                │
                ├── SAFE ──▶ proceed to TEST
                ├── CAUTION ──▶ flag to user, get confirmation ──▶ proceed to TEST
                └── UNSAFE ──▶ DISCARD immediately (does NOT enter ranking)
```

**Light security check (per candidate):**

| Check | How | FAIL if |
|-------|-----|---------|
| **License** | Check repo LICENSE file | No license + commercial intent, or GPL/AGPL incompatibility |
| **Provenance** | Check author, commit history, stars | Anonymous author, <3 commits, suspicious patterns |
| **Code inspection** | Read ALL files, not just SKILL.md | Contains eval, exec, network calls, data exfiltration |
| **Supply chain** | Check dependencies | Unknown packages, suspicious transitive deps |

Use `/review-skill-safety` in light mode for GitHub repos.

**UNSAFE candidates are immediately discarded.** They do NOT waste time in testing or ranking.

**Output:** Updated longlist with security verdicts. Only SAFE and CAUTION (user-approved) proceed.

### Step 3 — DIFF (Delta report, only for SCOUT_HIT/PARTIAL)

**Skip this step entirely for SCOUT_MISS** — go directly to Step 4 FORGE(BUILD).

For each candidate that passed the security gate, produce a delta report instead of a full test+rank cycle:

```markdown
## Delta Report: [candidate-name] vs [spec-card]

| Spec Requirement | Upstream Coverage | Gap | Effort to Close |
|-----------------|-------------------|-----|-----------------|
| [must-have 1] | Full / Partial / None | [what's missing] | Low / Medium / High |
| [must-have 2] | ... | ... | ... |

**Verdict:** SCOUT_HIT (>= 75% coverage) / SCOUT_PARTIAL (40-74%) / DISCARD (< 40%)
**Recommended FORGE strategy:** ADAPT / MERGE / BUILD
```

**Why DIFF replaces TEST+RANK:** The old 7-axis scoring matrix was over-engineered for the actual decision. What matters is: does the upstream cover the spec? The delta report answers this directly and is more actionable for FORGE.

**Output:** Delta report per candidate with verdict and recommended strategy.

### Step 4 — FORGE (Build the skill)

Three strategies based on ranking results:

#### Strategy A — ADAPT (1 candidate >= 75%)

1. Fork the candidate content
2. Restructure to SKILL.md format (frontmatter, workflow, rules, anti-patterns)
3. Fill gaps identified in spec card
4. Add attribution in frontmatter: `metadata.source`, `metadata.author`, `license`
5. Add upstream tracking: `upstream.url`, `upstream.version`, `upstream.last_checked`

#### Strategy B — MERGE (2-3 candidates 40-74%, complementary)

1. Identify which parts of each candidate are strongest
2. Map candidate sections → spec card features
3. Assemble best parts into unified SKILL.md
4. Unify style, format, terminology
5. Add attribution for ALL sources in frontmatter
6. Add upstream tracking for each source

#### Strategy C — BUILD (nothing >= 40%, or no candidates)

1. Use spec card as the blueprint
2. Use industry sources (standards bodies, professional frameworks) as reference material
3. Create from scratch following SKILL.md format
4. Set `metadata.source: custom`, `metadata.author: internal`

**ALL strategies MUST produce:**

```yaml
---
name: [skill-name]
description: [Use when... description]
metadata:
  author: [original author or "internal"]
  source: [repo URL or "custom"]
  created: [YYYY-MM-DD]
  forge_strategy: [adapt/merge/build]
  forge_sources: [list of source URLs if adapt/merge]
license: [MIT/Apache-2.0/proprietary/etc.]
upstream:
  url: [source URL if external]
  version: [version or commit hash]
  last_checked: [YYYY-MM-DD]
---
```

**SKILL.md structure (mandatory sections):**

1. Title + 1-2 line description
2. Core Workflow (numbered steps)
3. Rules (what the skill MUST do)
4. Anti-Patterns (what the skill must NOT do)
5. References table (if > 8KB, split to `references/`)

### Step 5 — VERIFY (Quality gate)

ALL checks must pass. Any failure → fix and re-verify.

| # | Check | How | Pass criteria |
|---|-------|-----|---------------|
| 1 | **Security review** | `/review-skill-safety` (full mode) | SAFE or CAUTION (with user approval) |
| 2 | **Functional test** | Run 2-3 real use cases from spec card | All must-have outputs produced correctly |
| 3 | **Format compliance** | Check SKILL.md structure | Has: frontmatter, workflow, rules, anti-patterns |
| 4 | **Integration test** | Run alongside other pack skills | No conflicts, proper handoffs |
| 5 | **Spec compliance** | Check vs spec card | All must-haves covered |
| 6 | **Size check** | Measure SKILL.md size | If > 15KB, split to references/ per lazy-context-loader |

**If any check fails:**
1. Fix the issue
2. Re-run ALL checks (not just the failed one)
3. Repeat until all pass

### Step 6 — TRACK (Monitor upstream)

For skills with external sources (ADAPT or MERGE strategy):

1. **Register in frontmatter:** `upstream.url`, `upstream.version`, `upstream.last_checked`
2. **Update pack SOURCES.md** (created at SCOUT time, finalized here):

```markdown
| Skill | Upstream URL | Version | Last Checked | Status |
|-------|-------------|---------|--------------|--------|
| [name] | [url] | [ver] | [date] | CURRENT/OUTDATED/DEPRECATED |
```

3. **Quarterly review cycle:**
   - Check upstream for updates (new commits, releases)
   - If updated: evaluate changes, re-run from Step 3 if significant
   - If deprecated/removed: flag for internal review, consider BUILD replacement
   - Update `upstream.last_checked` date

For BUILD skills: no upstream tracking needed, skip this step.

---

## Batch Mode

When creating multiple skills for a pack, batch in groups of 5-10:

1. Run Step 1 (SPEC) for the entire batch
2. Run Step 2 (SCOUT) for the entire batch — many will share sources
3. Run Steps 3-6 per individual skill

This is more efficient because scouting surfaces sources that cover multiple skills.

## FORGE-at-Scale (for bulk upgrades)

When upgrading many existing BUILD skills (e.g., v0.1.0 → v0.2.0), use the 3-phase pipeline:

```
META (metadata injection) → ENRICH (methodology upgrade) → VFY (automated quality gate)
```

- **META:** Mechanical — add frontmatter, normalize sections, add "Perche' esiste" and Anti-pattern tables
- **ENRICH:** Creative — industry standards, web research, enriched workflows proportional to domain complexity
- **VFY:** Automated checks + version bump for passing skills

See `docs/plans/2026-03-09-forge-at-scale-design.md` for full specification.

---

## Rules

1. **Never skip SCOUT.** Even for highly specialized skills, search first. You'd be surprised what exists.
2. **Security is PASS/FAIL.** No negotiation. UNSAFE = discard. Period.
3. **Real testing, not hypothetical.** Step 3 requires actual execution, not "this looks like it would work."
4. **Attribution is mandatory.** Every external source must be credited in frontmatter.
5. **Spec card drives everything.** If it's not in the spec, don't build it. If it IS in the spec, it must be in the skill.
6. **YAGNI applies.** Don't add features not in the spec card, even if a source has them.
7. **Format compliance is non-negotiable.** SKILL.md standard must be followed exactly.

## Anti-Patterns

| Anti-Pattern | Why it's wrong | What to do instead |
|-------------|---------------|-------------------|
| Skip SCOUT, build from scratch | Wastes effort, misses better existing work | Always search first, even for niche topics |
| Security as weighted score | UNSAFE skills sneak through with high scores elsewhere | Security is PASS/FAIL gate, not a ranking axis |
| Full 7-axis scoring matrix | Over-engineered, slow, doesn't inform FORGE | Use DIFF delta report — spec vs upstream coverage |
| Copy-paste without attribution | License violation, ethics issue | Always credit source in frontmatter |
| One search query and done | Misses sources in different ecosystems | Search ALL 6 source types systematically |
| Build monolithic 20KB SKILL.md | Saturates context window | Split to SKILL.md + references/ per lazy-context-loader |
| Skip VERIFY because "I just built it" | Author bias, missed issues | Run all 6 checks, every time |
| Uniform quality regardless of complexity | Simple skills get bloated, complex ones stay shallow | Depth proportional to domain complexity |
