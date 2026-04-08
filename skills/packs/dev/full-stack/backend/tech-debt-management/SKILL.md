---
name: tech-debt-management
description: "Use when assessing, prioritizing, or addressing technical debt. Covers debt categorization, prioritization frameworks, refactoring strategies, and team communication. Triggers on: tech debt, technical debt, refactor, code quality, legacy code, migration, upgrade, deprecation."
metadata:
  author: leopoldo
  source: custom
  created: 2026-03-24
  forge_strategy: build
license: MIT
upstream:
  url: null
  version: null
  last_checked: 2026-03-24
---

# Tech Debt Management -- Prioritize and Pay Down Debt

## Why This Exists

| Problem | Solution |
|---------|----------|
| Tech debt accumulates silently until it blocks features | Structured assessment and prioritization |
| "We should refactor" never gets prioritized | Framework to quantify debt impact |

Inspired by [anthropics/knowledge-work-plugins/engineering/tech-debt](https://github.com/anthropics/knowledge-work-plugins).

## Core Workflow

### 1. Categorize

| Type | Description | Example |
|------|------------|---------|
| **Deliberate** | Conscious shortcuts for speed | "Ship without tests, add later" |
| **Accidental** | Discovered after the fact | Wrong architecture choice |
| **Environmental** | External changes make code outdated | Deprecated dependency |
| **Bit rot** | Code degrades over time | Inconsistent patterns across codebase |

### 2. Assess Impact

For each debt item, score on two axes:

**Pain (1-5):** How much does this slow us down?
- 1: Minor annoyance
- 3: Slows feature development by 20-50%
- 5: Blocks critical features or causes incidents

**Effort (1-5):** How much work to fix?
- 1: Hours (quick fix)
- 3: Days (focused refactor)
- 5: Weeks (major rewrite)

**Priority = Pain / Effort** (highest ratio first)

### 3. Debt Register

```markdown
| # | Debt Item | Type | Pain | Effort | Priority | Owner | Status |
|---|-----------|------|------|--------|----------|-------|--------|
| 1 | No TypeScript strict mode | Environmental | 4 | 3 | 1.3 | Alice | In progress |
| 2 | Monolithic API handler | Deliberate | 3 | 2 | 1.5 | Bob | Planned |
| 3 | jQuery in checkout flow | Bit rot | 2 | 4 | 0.5 | -- | Backlog |
```

### 4. Strategies

```
HIGH PAIN + LOW EFFORT (Priority > 1.0)
  -> Fix immediately, include in current sprint

HIGH PAIN + HIGH EFFORT (Priority 0.5-1.0)
  -> Plan as dedicated project, allocate 20% time

LOW PAIN + LOW EFFORT (Quick wins)
  -> Fix opportunistically when touching related code

LOW PAIN + HIGH EFFORT (Priority < 0.5)
  -> Document and defer, revisit quarterly
```

### 5. The 20% Rule

Allocate 20% of sprint capacity to tech debt:
- 1 day per week per team
- Or 1 sprint per 5 sprints
- Non-negotiable, protect this time

### 6. Refactoring Patterns

```
STRANGLER FIG: Build new alongside old, gradually migrate
  Use when: Replacing a large legacy system

BRANCH BY ABSTRACTION: Add abstraction layer, swap implementation
  Use when: Replacing a library or service

BOY SCOUT RULE: Leave code better than you found it
  Use when: Working in a specific area anyway

PARALLEL CHANGE: Add new, migrate consumers, remove old
  Use when: Changing interfaces with many consumers
```

## Rules

1. Maintain a debt register (visible to entire team)
2. Prioritize by Pain/Effort ratio (not gut feeling)
3. 20% of sprint capacity for debt paydown (non-negotiable)
4. Never refactor without tests (add tests first, then refactor)
5. Strangler fig over big bang rewrite (incremental, lower risk)
6. Review debt register quarterly (items may no longer be relevant)

## Anti-Patterns

| Anti-Pattern | Why Wrong | Do Instead |
|-------------|-----------|------------|
| "We'll fix it later" (never) | Debt compounds, blocks features | Schedule in sprint, 20% rule |
| Big bang rewrite | High risk, long freeze, often fails | Strangler fig (incremental) |
| Refactoring without tests | New bugs from refactoring | Add tests first, then refactor |
| Only tracking in someone's head | Not visible, not prioritized | Shared debt register |
| All debt is equal | Wasted effort on low-impact items | Score Pain/Effort, fix highest ratio first |
