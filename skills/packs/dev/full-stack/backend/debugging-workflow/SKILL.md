---
name: debugging-workflow
description: "Use when debugging application issues: structured root cause analysis, reproduction, isolation, and fix verification. Covers systematic debugging methodology for frontend and backend. Triggers on: debug, bug, error, crash, not working, broken, investigate, root cause, reproduce, stack trace."
type: technique
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

# Debugging Workflow -- Systematic Root Cause Analysis

## Why This Exists

| Problem | Solution |
|---------|----------|
| Developers debug by random trial and error | Structured 6-step debugging methodology |
| Bugs get "fixed" without understanding root cause | Root cause analysis prevents recurrence |

Inspired by [anthropics/knowledge-work-plugins/engineering/debug](https://github.com/anthropics/knowledge-work-plugins).

## Core Workflow

### The 6-Step Process

```
1. REPRODUCE  -> Confirm the bug exists and is reproducible
2. ISOLATE    -> Narrow down to the smallest failing unit
3. DIAGNOSE   -> Understand WHY it fails (root cause)
4. FIX        -> Apply the minimal correct fix
5. VERIFY     -> Confirm the fix works and nothing regressed
6. PREVENT    -> Add tests/guards to prevent recurrence
```

### Step 1: REPRODUCE

```
Before anything else, reproduce the bug reliably.

Questions:
- Can I reproduce locally?
- What are the exact steps?
- Does it happen every time or intermittently?
- Which environment? (dev, staging, prod)
- Which browser/OS/device?

If not reproducible:
- Check logs for the exact error
- Check environment differences (env vars, data, versions)
- Check if it's timing/race-condition dependent
```

### Step 2: ISOLATE

```
Narrow the scope. Where is the bug?

Techniques:
- Binary search: comment out half the code, does it still fail?
- Git bisect: find the commit that introduced the bug
  $ git bisect start
  $ git bisect bad          # Current commit is broken
  $ git bisect good abc123  # Last known good commit
  # Git will binary search through commits

- Component isolation: render the component alone
- Network isolation: mock the API, does the bug persist?
- Data isolation: use minimal data, does the bug persist?
```

### Step 3: DIAGNOSE

```
Understand the root cause, not just the symptom.

Tools:
- Browser DevTools: Console, Network, Sources (breakpoints)
- React DevTools: Component tree, state, props, re-renders
- Node.js: --inspect flag + Chrome DevTools
- Logging: add strategic console.log or logger statements
- Stack traces: read from bottom to top (origin to error)

Ask:
- What SHOULD happen? (expected behavior)
- What DOES happen? (actual behavior)
- What CHANGED? (git diff, recent deploys, config changes)
- Is this a symptom of a deeper issue?
```

### Step 4: FIX

```
Apply the MINIMAL correct fix.

Rules:
- Fix the root cause, not the symptom
- Smallest possible change
- Don't refactor while fixing (separate commits)
- If the fix is complex, explain WHY in a comment
```

### Step 5: VERIFY

```
Confirm the fix works:

1. Original reproduction steps pass
2. Edge cases work (empty data, null values, large data)
3. Related features still work (regression check)
4. Run existing test suite
5. Test in the same environment where the bug was found
```

### Step 6: PREVENT

```
Ensure this bug class can't happen again:

- Write a test that FAILS without the fix, PASSES with it
- Add TypeScript types to prevent invalid states
- Add validation/assertions at boundaries
- Add monitoring/alerting for this error class
- Document in team knowledge base if significant
```

### Common Bug Patterns

| Pattern | Symptoms | Common Cause | Fix |
|---------|----------|-------------|-----|
| Hydration mismatch | Console warning, UI flicker | Date/random in SSR | Use suppressHydrationWarning or client-only |
| Stale closure | Old state values in callbacks | Missing dependency in useEffect | Add to dependency array or use useRef |
| Race condition | Intermittent wrong data | Async without cancellation | AbortController, cleanup in useEffect |
| N+1 query | Slow API response | Nested database queries | DataLoader or eager loading |
| Memory leak | Growing memory, slow app | Uncleared intervals/subscriptions | Cleanup in useEffect return |
| Type coercion | Unexpected behavior | String vs number comparison | Strict equality (===), TypeScript strict |

## Rules

1. ALWAYS reproduce before attempting to fix
2. Git bisect for regression bugs (fastest way to find the culprit commit)
3. Fix root cause, not symptoms
4. One fix per commit (don't mix refactoring with bug fixes)
5. Write a test that fails without the fix, passes with it
6. If a bug took > 30 minutes to find, add monitoring for it

## Anti-Patterns

| Anti-Pattern | Why Wrong | Do Instead |
|-------------|-----------|------------|
| Random code changes until it works | No understanding, may introduce new bugs | Systematic reproduce -> isolate -> diagnose |
| Fixing symptoms, not root cause | Bug will recur in different form | Understand WHY before fixing |
| No test for the fix | Bug can regress silently | Write failing test first, then fix |
| Mixing refactoring with bug fix | Hard to review, hard to revert | Separate commits |
| "It works on my machine" | Environment difference is the bug | Reproduce in same environment as report |
