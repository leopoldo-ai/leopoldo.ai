---
name: task-decomposer
description: Use when breaking down a project, planning a sprint, creating a build plan from a PRD, decomposing user stories or feature specs, or preparing tasks for autonomous development loops. Produces ordered task graphs with dependencies. Triggers on task breakdown, decompose, sprint planning, build plan, task graph.
type: technique
---

# Task Decomposer — PRD to Task Graph

Transforms a PRD, feature spec, or requirement into an ordered task graph with dependencies, ready for sequential or parallel execution.


## When to Use

- Given a PRD, generate the complete build plan
- Given a feature request, break it down into atomic tasks
- Before an autonomous development loop
- Sprint planning: define what needs to be done and in what order

## Workflow

### Phase 1: Input Analysis

1. **Read the source document** (PRD, feature spec, issue, user request)
2. **Identify all deliverables** — what must exist at the end?
3. **Extract constraints** — tech stack, external dependencies, time/budget limits
4. **Discover available skills** — read CLAUDE.md + scan `skills/**/SKILL.md` to know which competencies are available

### Phase 2: Decomposition into Atomic Tasks

For each deliverable:

1. **Define atomic tasks** — each task must:
   - Be completable in a single development step
   - Have a verifiable "done" criterion (test that passes, file that exists, endpoint that responds)
   - Be assignable to a specific skill
   - NOT depend on ambiguous decisions (if ambiguous, decompose further)

2. **Categorize each task**:
   - `scaffold` — initial setup, config, boilerplate
   - `schema` — DB definitions, migrations, types
   - `api` — route handlers, endpoints, middleware
   - `ui` — components, pages, layout
   - `integration` — connection to external services (CRM, email service, enrichment API)
   - `test` — unit test, integration test, E2E
   - `config` — env vars, deployment config, CI/CD
   - `doc` — documentation, README, API docs

### Phase 3: Dependency Graph

1. **Identify dependencies** — for each task, which task must be completed first?
2. **Build the DAG** (Directed Acyclic Graph):
   - No cycles (a task cannot depend on itself)
   - Minimize dependencies (only strictly necessary ones)
   - Maximize parallelism (independent tasks can be executed in parallel)

3. **Topological sort** — produce the execution order

### Phase 4: Structured Output

Produce the plan in this format:

```markdown
# Build Plan: [Project/feature name]

**Source:** [PRD/Feature spec/Issue]
**Total tasks:** [N]
**Phase estimate:** [N sequential phases, M parallelizable tasks]

## Phase 1: [Phase name] (parallel: yes/no)

### Task 1.1: [Title]
- **Type:** scaffold | schema | api | ui | integration | test | config
- **Skill:** [skill name to invoke]
- **Input:** [required file/context]
- **Output:** [produced file/artifact]
- **Done when:** [verifiable criterion]
- **Depends on:** none | Task X.Y

### Task 1.2: [Title]
...

## Phase 2: [Phase name]
...

## Dependency Summary
Task 1.1 → Task 2.1
Task 1.2 → Task 2.1
Task 2.1 → Task 3.1, Task 3.2 (parallel)
```

## Rules

- Each task has ONE single responsible (one skill)
- "Done when" criteria must be automatically verifiable (test, build, lint)
- If a task requires human decisions, mark it as `decision-point` and blocking
- Always include a security review task for code that touches personal data (PII, compliance)
- Test tasks should be created BEFORE or IN PARALLEL with implementation tasks (TDD)
- Never create "generic" tasks — each task must specify exactly what to do

## Example: CRM Sync Module

```markdown
## Phase 1: Schema & Config (parallel)
- Task 1.1: Drizzle schema for contacts + sync_state table [schema, drizzle-orm-patterns]
- Task 1.2: Env vars + Neon connection config [config, nextjs-developer]
- Task 1.3: Test schema: migration dry-run [test, test-master]

## Phase 2: API Core (sequential after Phase 1)
- Task 2.1: Route handler GET /api/cron/sync-crm [api, api-designer]
- Task 2.2: CRM API client with rate limiting [integration, typescript-pro]
- Task 2.3: Test: mock CRM response + verify DB write [test, test-master]

## Phase 3: Chunked Sync Logic (after Phase 2)
- Task 3.1: Cursor-based pagination (400 records/chunk) [api, postgres-pro]
- Task 3.2: Security review: input validation API payload [test, secure-code-guardian]
```

## Anti-patterns

- Vague tasks ("implement the feature")
- Circular dependencies
- Overly large tasks (if it takes more than an hour, decompose)
- Forgetting tests
- Not specifying the responsible skill
- Ignoring compliance for tasks touching personal data

---

**Version:** 1.0
**Dependencies:** Read tool (to read PRD/spec), Glob tool (for skill discovery)
