# Skill Sourcer — Templates

Ready-to-use templates for each step of the 7-step process.

## Spec Card Template

```markdown
# Spec Card: [skill-name]

## Identity
- **Pack:** [pack-name]
- **Cluster:** [cluster within pack, e.g. "Risk & Compliance"]
- **Layer:** userland

## Scope
[1-2 sentences: what this skill does. Be precise about boundaries.]
[1 sentence: what this skill does NOT do — adjacent skills handle those.]

## Expected Inputs
- [Trigger: "Use when..." — what user action or context activates this]
- [Data: what information the user provides]
- [Context: what other skills may have run before this]

## Expected Outputs
- [Primary output: analysis, document, code, decision matrix, etc.]
- [Secondary output: recommendations, next steps, handoff to another skill]
- [Format: markdown table, structured report, SKILL.md, etc.]

## Must-Have Features
1. [Core capability that defines the skill]
2. [Second essential capability]
3. [Third essential capability]
4. [Continue as needed — these are NON-NEGOTIABLE]

## Nice-to-Have Features
1. [Enhancement that improves but isn't essential]
2. [Another optional improvement]

## Anti-Patterns
- DO NOT [common mistake that would make this skill worse]
- DO NOT [another anti-pattern]
- NEVER [hard constraint]

## Integration Points
- **Depends on:** [skills that must run before this one]
- **Feeds into:** [skills that typically run after]
- **Shares data with:** [skills that exchange information bidirectionally]

## Success Criteria
1. [Measurable criterion: "produces X with Y quality"]
2. [Measurable criterion]
3. [Edge case: "handles Z correctly"]

## Key Rules (Domain-Specific)
- [Industry standard or regulation this skill must follow]
- [Professional framework or methodology it implements]
- [Calculation formula or decision threshold it must use]
```

## Scout Longlist Template

```markdown
# Scout Longlist: [skill-name]

Date: [YYYY-MM-DD]
Spec card: [link to spec-card.md]

## Search Queries Executed

| Source Type | Query | Results |
|------------|-------|---------|
| GitHub skill repos | `claude skill [domain]` | X results |
| MCP registries | `MCP server [domain]` | X results |
| Prompt libraries | `[domain] prompt engineering` | X results |
| Industry frameworks | `[standard body] [topic]` | X results |
| Skill marketplaces | `[topic] skill` | X results |
| Academic/professional | `[domain] framework checklist` | X results |

## Longlist

| # | Candidate | Source | URL | Type | Quick Notes | Security |
|---|-----------|--------|-----|------|-------------|----------|
| 1 | [name] | GitHub | [url] | Skill | [brief assessment] | SAFE/CAUTION/UNSAFE |
| 2 | ... | ... | ... | ... | ... | ... |

## Security Gate Results

| Candidate | License | Provenance | Code Inspection | Supply Chain | **Verdict** |
|-----------|---------|------------|-----------------|--------------|-------------|
| [name] | PASS/FAIL | PASS/FAIL | PASS/FAIL | PASS/FAIL | SAFE/CAUTION/UNSAFE |

## Candidates Proceeding to TEST
[List only SAFE and CAUTION (user-approved) candidates]
```

## Test Report Template

```markdown
# Test Report: [skill-name]

## Test Case
- **Scenario:** [concrete use case from spec card]
- **Input:** [what was provided]
- **Expected output:** [what spec says it should produce]

## Results

| Candidate | Verdict | Output Quality | Must-Haves Covered | Gaps |
|-----------|---------|----------------|-------------------|------|
| [name] | PASS/PARTIAL/FAIL | [assessment] | X/Y | [missing features] |

## Detailed Notes

### [Candidate 1]
- **Strengths:** ...
- **Weaknesses:** ...
- **Execution time:** ...
- **Gaps vs spec:** ...
```

## Ranking Matrix Template

```markdown
# Ranking Matrix: [skill-name]

## Scores (0-100 per axis, weighted)

| Candidate | Coverage (25%) | Depth (15%) | Quality (15%) | Test (20%) | Fresh (5%) | Adapt (10%) | Compose (10%) | **Total** | **Verdict** |
|-----------|---------------|-------------|---------------|------------|------------|-------------|---------------|-----------|-------------|
| [name] | XX | XX | XX | XX | XX | XX | XX | **XX%** | ADAPT/MERGE/DISCARD |

## Recommended Strategy

**Strategy:** [ADAPT / MERGE / BUILD]

**Reasoning:** [Why this strategy, which sources to use, what to build/fill]

**Forge Plan:**
1. [First action]
2. [Second action]
3. [Continue as needed]
```

## SOURCES.md Template (per pack)

```markdown
# [pack-name] — Upstream Sources Registry

Last full review: [YYYY-MM-DD]
Next scheduled review: [YYYY-MM-DD]

| Skill | Upstream URL | Version/Commit | Last Checked | Status | Notes |
|-------|-------------|----------------|--------------|--------|-------|
| [name] | [url] | [version] | [YYYY-MM-DD] | CURRENT | [any notes] |
| [name] | custom | N/A | N/A | N/A | Built from scratch |
```
