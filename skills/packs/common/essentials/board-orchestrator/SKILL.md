---
name: board-orchestrator
description: Use when the user explicitly requests "/board" or "fare un board" for strategic decisions, project reviews, problem solving, planning, or feature evaluation requiring multiple expert perspectives (technical, financial, product, strategic). Orchestrates virtual board meetings with specialized skills as board members (CTO, CFO, CPO, Strategy Director). Do NOT auto-trigger.
type: technique
---

# Virtual Board Meeting Orchestrator

Simulates virtual board meetings where installed project skills collaborate as board members to evaluate complex decisions from multiple perspectives.

## Core Workflow

### Phase 1: Dynamic discovery and board selection

**IMPORTANT: The board self-updates.** Do not use hardcoded lists. Discover available members at runtime.

1. **Analyze the request** — Extract the decision topic
2. **Classify the decision type** — Strategic / Product / Technical / Financial / Change Management / Quality / Mixed
3. **Discover available skills** (dynamic, at every board meeting):
   a. Read `CLAUDE.md` for the updated list of skills and their purpose
   b. Scan `skills/**/SKILL.md` for frontmatter (`name`, `description`)
   c. Build the skill-to-role map based on each skill's `description`
4. **Scan the project context**:
   - Project state (PRD, current work session)
   - Relevant documentation (files in `docs/`)
   - Codebase (if technical decision): `git status`, recent commits
5. **Select board members** (3-7 skills) — Use the [Selection Rules](references/board-composition-guide.md) as a guide, but rely on dynamic discovery
6. **Ask for user confirmation** — Use `AskUserQuestion` to approve the composition

### Phase 2: Parallel board consultation

For each selected member:

1. **Invoke with Task tool** — Use appropriate `subagent_type`
2. **Provide context**:
   - Clear decision question
   - Role-specific perspective (e.g., "As CTO, evaluate the technical implications...")
   - Relevant project files/data
   - Domain-specific questions
3. **Collect responses** from all members

### Phase 3: Synthesis and recommendation

1. **Analyze all contributions** from board members
2. **Identify consensus vs. dissent** — Track voting patterns
3. **Evaluate trade-offs** between perspectives
4. **Formulate recommendation** with:
   - Majority position
   - Key dissenting concerns
   - Risk mitigation strategies
   - Operational next steps

### Phase 4: Structured output

Present results in chat using this format:

```markdown
# Board Decision: [Topic]

## Board Composition
- [Role 1]: [Skill name]
- [Role 2]: [Skill name]

## Recommendations

### [Role/Skill 1]
**Position:** Approve / Conditional / Reject
**Key points:**
- [Point 1]
- [Point 2]

## Consensus Analysis
- **Votes:** [X Approve, Y Conditional, Z Reject]
- **Recommendation:** [Clear recommendation]
- **Critical issues:** [Any dissents or conditions]

## Action Items
1. [Operational next step]
2. [Operational next step]

## Risks to Monitor
- **[Risk]:** [Mitigation strategy]
```

**Optional:** If the user asks "save the board minutes", create a file in `docs/board-meetings/YYYY-MM-DD-topic.md` using the template from the [Board Composition Guide](references/board-composition-guide.md).

## Handling missing skills

If expertise not available among installed skills is needed:

1. **Identify the missing domain** (e.g., "legal", "HR analytics")
2. **Search on GitHub** — See [Skill Domains Map](references/skill-domains.md) for search keywords
3. **Present options to the user** — Top 3-5 results
4. **Mandatory security review** — Run `/review-skill-safety` before installation
5. **Install if approved** and resume the board meeting

## Quick examples

### Strategic decision
```
User: /board Should we prioritize the database migration or the process redesign?

1. Classify: Strategic
2. Board: Strategy Director (strategy-advisor), CEO Advisor (ceo-advisor),
         Product Manager (product-manager-toolkit), Data Lead (data-visualization)
3. User confirmation
4. Parallel consultation
5. Synthesis with RICE score + adoption impact
```

### Technical decision
```
User: Let's run a board on the CRM sync strategy — polling vs webhook

1. Classify: Technical
2. Board: CTO (nextjs-developer), DBA (postgres-pro + neon-postgres-setup),
         API Architect (api-designer), Security Lead (secure-code-guardian)
3. User confirmation
4. Parallel consultation
5. Synthesis with technical trade-offs, costs, risks
```

### Product decision
```
User: /board Add analytics dashboard or prioritize the email campaign?

1. Classify: Product & Strategic
2. Board: Product Manager (product-manager-toolkit), Strategy (strategy-advisor),
         Email Expert (email-marketing-bible), UX Lead (frontend-design),
         Dashboard (dashboard-builder)
3. User confirmation
4. Parallel consultation
5. Synthesis with RICE, email deliverability impact analysis vs dashboard visibility
```

### Change management decision
```
User: /board How should we communicate the new operational process to the team?

1. Classify: Change Management
2. Board: Strategy (strategy-advisor), CEO Advisor (ceo-advisor),
         Comms Lead (document-skills:internal-comms), Presentation (document-skills:pptx)
3. User confirmation
4. Parallel consultation
5. Synthesis with communication plan, adoption messaging
```

## Best Practices

- **Focused boards** — 1 decision per meeting
- **Concise consultations** — Succinct input, not 10-page reports
- **Diverse perspectives** — Balance technical/product/strategic/change
- **User confirmation** — Always confirm composition before invoking
- **Clear synthesis** — Actionable recommendation, not a concatenation of opinions
- **Respect dissent** — Highlight minority opinions
- **Project context** — Every analysis must be grounded in the specific project (goals, constraints, stakeholders)

## Anti-patterns

- Auto-triggering on keywords
- Saving files without explicit request
- Invoking 10+ skills (too slow, diminishing returns)
- Re-inviting the same skill twice
- Deciding for the user (recommend, don't decide)
- Generic advice (anchor to the project context)
- Ignoring change management constraints

## Resources

- **[Board Composition Guide](references/board-composition-guide.md)** — Detailed rules for member selection, decision matrix template, minutes format
- **[Skill Domains Map](references/skill-domains.md)** — Keywords for searching skills on GitHub when expertise is missing

---

**Version:** 1.1 (dynamic discovery)
**Dependencies:** Task tool, AskUserQuestion, Read tool (for discovery), Glob tool (for skill scanning)
