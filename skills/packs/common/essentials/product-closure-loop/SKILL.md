---
name: product-closure-loop
description: Use when finalizing a PRD, closing a product spec, optimizing a feature set, or running autonomous improvement cycles. Iteratively evaluates and improves a PRD until production-ready, using board-orchestrator for multi-perspective evaluation, task-decomposer for gap identification, and domain skills for execution.
type: technique
---

# Product Closure Loop — Autonomous PRD & Product Refinement

An autonomous loop that evaluates, improves, and "closes" a PRD or product specification through iterative cycles of board review + execution until production-ready quality is achieved.

## Concept

```
          +---------------------------------------------+
          |                                             |
          v                                             |
   [Board Review]                                       |
   Each skill evaluates the PRD/product                 |
   from its perspective                                 |
          |                                             |
          v                                             |
   [Gap Analysis]                                       |
   Collect ALL gaps/improvements                        |
   identified by the board                              |
          |                                             |
          v                                             |
   [Prioritization]                                     |
   RICE score each gap                                  |
   Filter: only Critical + High                         |
          |                                             |
          v                                             |
   [Task Decomposition]                                 |
   Break gaps into atomic tasks                         |
          |                                             |
          v                                             |
   [Execution]                                          |
   Execute tasks (write PRD sections,                   |
   schemas, specs, code)                                |
          |                                             |
          v                                             |
   [Verification]                                       |
   Verify each completed task                           |
          |                                             |
          v                                             |
   [Quality Gate]                                       |
   Board re-evaluates:                                  |
   All APPROVE? --YES--> CLOSED                         |
          |                                             |
          NO                                            |
          |                                             |
          +---------------------------------------------+
```

## Detailed Workflow

### Phase 0: Loop Setup

1. **Read `PROJECT_STATE.md`** (if it exists) -- Use PRD compliance % as baseline for the initial quality score
2. **Identify the target** -- What are we closing?
   - PRD (product requirements document)
   - Feature spec (specification for a single feature)
   - Technical architecture (design decisions)
   - Project plan (roadmap, milestones)

3. **Define closure criteria** -- When is it "closed"?
   - **PRD:** All board members vote APPROVE, no open Critical/High gaps
   - **Feature:** Spec complete, test plan defined, effort estimated, dependencies mapped
   - **Architecture:** Decision record written, trade-offs documented, risks mitigated
   - **Plan:** Milestones defined, ownership assigned, measurable KPIs

4. **Select the review board** -- Using board-orchestrator with dynamic discovery
5. **Set max iterations** -- Default: 5. Beyond 5, escalate to the user.

### Phase 1: Board Review (per iteration)

Convene the board with a prompt specific to the review type:

#### For PRD Review
Each board member receives:
```
Context: You are participating in a refinement loop for the PRD [name].
Iteration: [N] of max [M].

Evaluate the PRD from your perspective as [role]:
1. COMPLETENESS: Are there missing sections, details, or specifications?
2. COHERENCE: Are there internal contradictions?
3. FEASIBILITY: Is it achievable with the defined stack/budget/team?
4. RISKS: Which risks are not covered?
5. SPECIFICITY: Are the requirements detailed enough for development?

For each point, respond:
- OK: No issues
- GAP [severity: Critical/High/Medium/Low]: [description of the gap]
- SUGGESTION: [proposed improvement]

At the end, vote: APPROVE / CONDITIONAL / REJECT
```

#### Recommended Board Members by Review Type

**PRD Review (5-7 members):**
- **Product Manager** (`product-manager-toolkit`) -- Functional completeness, user stories, RICE
- **CTO / Lead Engineer** (relevant tech skill) -- Technical feasibility, effort estimation
- **API Architect** (`api-designer`) -- API design, integrations, data flow
- **DBA** (database skill) -- Schema design, performance, scalability
- **Security Lead** (`threat-modeler` + `audit-coordinator`) -- Threat model, security pipeline
- **UX Lead** (`frontend-design`) -- User experience, information architecture
- **Domain Expert** (relevant domain skill) -- Domain-specific requirements

**Feature Review (3-4 members):**
- Product Manager + Lead Engineer + UX + relevant domain expert

**Architecture Review (4-5 members):**
- CTO + DBA + Security Lead + API Architect + DevOps

### Phase 2: Gap Analysis

1. **Collect all gaps** from all board members
2. **Deduplicate** -- Same gap reported by multiple members = 1 gap with highest severity
3. **Classify by severity:**
   - **Critical:** Blocks development. Must be resolved.
   - **High:** Significant risk. Must be resolved.
   - **Medium:** Important improvement. Resolve if possible.
   - **Low:** Nice to have. Resolve in future iterations.

4. **Calculate quality score:**
   ```
   Quality Score = (Approve * 3 + Conditional * 1 + Reject * 0) / (Total members * 3) * 100

   Thresholds:
   >= 90%: CLOSED (all or nearly all approve)
   70-89%: Gaps remain to resolve (1-2 iterations)
   50-69%: Significant gaps (2-3 iterations)
   < 50%: Structural problems (escalate to user)
   ```

### Phase 3: Gap Prioritization

Use `product-manager-toolkit` for RICE scoring:

| Gap | Reach | Impact | Confidence | Effort | RICE Score |
|-----|-------|--------|------------|--------|------------|
| [gap 1] | 1-10 | 1-10 | 0.5-1.0 | 1-10 | auto |

Filter: execute only gaps with severity Critical or High.

### Phase 4: Task Decomposition

Use `task-decomposer` to transform gaps into tasks:

For each Critical/High gap:
1. Define the task (what to write/modify in the PRD)
2. Specify the PRD section to update
3. Define the "done" criterion

### Phase 5: Execution

For PRD refinement, tasks typically involve:
- Adding a missing section to the PRD
- Detailing a vague specification
- Adding a diagram, schema, or table
- Resolving a contradiction
- Adding risk analysis
- Detailing an API spec
- Adding a test plan
- Specifying edge cases

Execute each task using the appropriate skill.

### Phase 6: Verification

After every modification to the PRD:
1. Re-read the modified section
2. Verify that the gap is effectively resolved
3. Verify that no new contradictions have been introduced
4. Use `phase-gate` to verify that all relevant skills for this iteration have been invoked
5. Use `dependency-checker` to validate that skill execution order has been respected

### Phase 7: Quality Gate

Re-convene the board. If:
- **Quality Score >= 90%:** CLOSED. Output the final PRD.
- **Quality Score < 90% and iteration < max:** Return to Phase 2.
- **Iteration = max and score < 90%:** Escalate to user with summary of remaining gaps.

## Final Output

When the loop terminates (CLOSED or escalation):

```markdown
# Product Closure Report: [PRD/Product Name]

## Status: CLOSED / ESCALATED

## Metrics
- **Iterations:** [N] of max [M]
- **Final Quality Score:** [X]%
- **Gaps resolved:** [Y] of [Z] total
- **Critical gaps resolved:** [all / N remaining]

## Board Members
| Role | Skill | Final Vote |
|------|-------|------------|
| [Role] | [skill] | APPROVE/CONDITIONAL/REJECT |

## Gaps Resolved (by iteration)
### Iteration 1
- [Gap 1]: [how resolved]
- [Gap 2]: [how resolved]

### Iteration 2
- [Gap 3]: [how resolved]

## Remaining Gaps (if escalated)
- [Gap N]: [severity] -- [why not resolved]

## Final PRD
[Link to updated file]
```

## Configuration by Target Type

### PRD Closure (default)
- Board: 5-7 members (Product + Tech + Security + UX + Domain)
- Max iterations: 5
- Closure threshold: 90%
- Focus: completeness, feasibility, risks

### Feature Closure
- Board: 3-4 members (Product + Tech + UX)
- Max iterations: 3
- Closure threshold: 85%
- Focus: spec detail, test plan, effort

### Architecture Closure
- Board: 4-5 members (Tech-heavy + Security)
- Max iterations: 4
- Closure threshold: 90%
- Focus: trade-offs, scalability, costs

## Rules

- **Never close with open Critical gaps** -- even if the quality score is high
- **Never exceed max iterations without escalating** -- the user must decide
- **Every iteration must resolve at least 1 gap** -- if 0 gaps resolved, the loop is stuck
- **SAVE INTERMEDIATES ALWAYS** -- every iteration output (PRD sections, gap analysis, board votes, reports) must be saved IMMEDIATELY as markdown in a working directory. Pattern: `wip/closure_{target}_iter{N}_{type}.md`. This prevents data loss during context compaction. Delete wip files only after saving the final consolidated document.

## Anti-patterns

- Infinite loop (forgetting max iterations)
- Resolving Low gaps before Critical ones
- Using the same board when gaps shift to a different domain
- Modifying the PRD without board approval
- Ignoring dissent ("the majority approves anyway")
- Adding scope during the loop (scope creep)

---

**Version:** 1.3
**Dependencies:** board-orchestrator, task-decomposer, product-manager-toolkit, phase-gate, dependency-checker, threat-modeler, audit-coordinator, project-memory (PROJECT_STATE.md), domain-specific skills
