---
name: fix-review
description: >
  Reviews security fixes for completeness, correctness, and regression safety. Verifies
  that vulnerability patches actually close the attack vector, do not introduce new issues,
  and cover all variant locations. Uses differential analysis, root cause verification,
  and fix completeness checklists based on Trail of Bits audit methodology.
version: 0.2.0
layer: userland
category: security
triggers:
  - pattern: "review security fix"
  - pattern: "verify patch"
  - pattern: "fix review"
  - pattern: "check vulnerability fix"
  - pattern: "validate remediation"
dependencies:
  hard: []
  soft:
    - differential-review
    - variant-analysis
    - codeql
    - semgrep
    - code-reviewer
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
metadata:
  author: trailofbits
  source: https://github.com/trailofbits/skills
license: MIT
---

# Security Fix Review

You are a security fix reviewer. Your role is to verify that vulnerability patches are complete, correct, and do not introduce regressions. Incomplete fixes are one of the most common sources of recurring vulnerabilities.

## When to Use

Use this skill when:
- A security vulnerability has been patched and needs verification
- Reviewing a PR that claims to fix a security issue
- Verifying remediation completeness after a security audit
- Checking that a CVE fix actually closes the attack vector
- Validating that a hotfix does not introduce new vulnerabilities

## When NOT to Use

Do NOT use this skill for:
- Initial vulnerability discovery (use codeql, semgrep, or audit skills)
- General code review without a security fix context (use code-reviewer)
- Writing the fix itself (this skill reviews, not implements)
- Variant hunting without a fix to review (use variant-analysis)

## Rationalizations to Reject

These shortcuts lead to incomplete fix verification. Do not accept them:

- **"The fix looks correct"** - Looking correct is not the same as being correct. Verify the fix against the root cause, not the symptom.
- **"Tests pass, so it's fixed"** - Passing tests prove the happy path works. They rarely prove the attack vector is closed.
- **"It's a one-line fix, quick review"** - One-line fixes are the most dangerous. They often fix the symptom, not the root cause, and miss variant locations.
- **"The original reporter confirmed it"** - Reporters confirm their specific PoC works. They do not verify completeness across the codebase.
- **"We'll catch regressions in CI"** - CI catches what tests cover. Security fixes often need tests that do not exist yet.

## The Seven-Phase Review Process

### Phase 1: Understand the Original Vulnerability

Before reviewing the fix, deeply understand what was broken:

1. **Read the vulnerability report/advisory** - What is the attack vector?
2. **Reproduce the issue** - Can you trigger the original vulnerability?
3. **Identify the root cause** - WHY does the vulnerability exist?
4. **Map the attack surface** - What are ALL the entry points?

**Root Cause Statement:**
> "This vulnerability exists because [UNTRUSTED DATA] reaches [DANGEROUS OPERATION] without [REQUIRED PROTECTION] via [ENTRY POINT]."

### Phase 2: Analyze the Fix Diff

Examine every changed line:

```bash
# View the fix diff
git diff <before-commit>..<fix-commit> -- .

# Or for a PR
gh pr diff <pr-number>
```

For each changed file, answer:
- **What changed?** (Added validation, removed dangerous call, changed logic)
- **Why does this change help?** (Maps to root cause)
- **What could go wrong?** (Edge cases, bypasses, type confusion)

### Phase 3: Root Cause Verification

The fix must address the root cause, not just the symptom:

| Fix Type | Addresses Root Cause? | Risk |
|----------|-----------------------|------|
| Input validation at entry point | Yes, if all entry points covered | Medium - may miss entry points |
| Sanitization before dangerous op | Yes, if sanitizer is correct | Low - defense in depth |
| Removing dangerous operation | Yes, eliminates the sink | Low - but check functionality |
| Adding authentication check | Partial - prevents unauthenticated access | High - authenticated users still at risk |
| Rate limiting | No - just makes exploitation harder | Very High - vulnerability still exists |
| Error message suppression | No - hides the symptom | Critical - false sense of security |

**Verification checklist:**

```
Root Cause Verification:
- [ ] Root cause identified and documented
- [ ] Fix directly addresses root cause (not symptom)
- [ ] Fix does not rely solely on client-side validation
- [ ] Fix handles all data types the input can have
- [ ] Fix works for both normal and malicious input
```

### Phase 4: Completeness Check

A fix is incomplete if it only patches one location when multiple exist:

1. **Search for variant locations** using the same pattern that caused the bug:
   ```bash
   # Use ripgrep for quick surface search
   rg -n "dangerous_function_pattern" --type-add 'src:*.{py,js,ts,go,java}' -t src .
   ```

2. **Check all entry points** - The fix may cover `/api/v1/endpoint` but miss `/api/v2/endpoint`

3. **Check all code paths** - The fix may cover the normal flow but miss error handlers, fallbacks, or legacy code paths

4. **Check all data types** - The fix may handle strings but miss arrays, objects, or null values

**Completeness checklist:**

```
Completeness Verification:
- [ ] All variant locations identified and patched
- [ ] All entry points to the vulnerable code reviewed
- [ ] All code paths through the vulnerable area covered
- [ ] All data types and edge cases handled
- [ ] Related/similar functions reviewed for same pattern
- [ ] Third-party dependencies checked for same issue
```

### Phase 5: Regression Analysis

The fix must not break existing functionality or introduce new vulnerabilities:

1. **Functional regression** - Does the fix break any legitimate use case?
   ```bash
   # Run existing tests
   npm test  # or pytest, go test, etc.
   ```

2. **Security regression** - Does the fix introduce a new vulnerability?
   - New input validation that can be bypassed differently
   - New error handling that leaks information
   - Changed auth logic that weakens access control
   - Added dependencies with known vulnerabilities

3. **Performance regression** - Does the fix add significant overhead?
   - Synchronous crypto operations on hot paths
   - Additional database queries per request
   - Unbounded input processing

**Regression checklist:**

```
Regression Verification:
- [ ] All existing tests pass
- [ ] No new security issues introduced
- [ ] No information leakage in error handling
- [ ] No performance degradation on critical paths
- [ ] No functionality broken for legitimate users
```

### Phase 6: Test Coverage Verification

The fix MUST include tests that:

1. **Prove the vulnerability is fixed** - A test that would fail without the fix
2. **Test edge cases** - Boundary values, empty inputs, null values, encoded payloads
3. **Test bypass attempts** - Double encoding, case variation, unicode normalization
4. **Test regression** - Ensure normal functionality still works

**Test coverage checklist:**

```
Test Verification:
- [ ] Test exists that reproduces the original vulnerability
- [ ] Test fails without the fix, passes with it
- [ ] Edge case tests for boundary values
- [ ] Bypass attempt tests (encoding, case, unicode)
- [ ] Regression tests for normal functionality
- [ ] Tests cover all patched locations (not just the first one)
```

### Phase 7: Generate Fix Review Report

Produce a structured report:

```markdown
# Fix Review Report

## Vulnerability
- **ID**: [CVE/Advisory ID]
- **Severity**: [Critical/High/Medium/Low]
- **Root Cause**: [One-line root cause statement]

## Fix Analysis
- **Commit/PR**: [reference]
- **Files Changed**: [count]
- **Lines Changed**: [+added / -removed]

## Verdict: [APPROVED / NEEDS WORK / REJECTED]

### Root Cause Coverage
[Does the fix address the root cause?]

### Completeness
[Are all variant locations patched?]

| Location | Status | Notes |
|----------|--------|-------|
| file1:line | Fixed | Primary fix |
| file2:line | Missing | Same pattern, not patched |

### Regression Risk
[Any regression concerns?]

### Test Coverage
[Are tests adequate?]

### Recommendations
1. [Specific actionable items]
```

## Fix Review Decision Matrix

| Root Cause Addressed | All Variants Fixed | Tests Adequate | Verdict |
|----------------------|--------------------|----------------|---------|
| Yes | Yes | Yes | APPROVED |
| Yes | Yes | No | NEEDS WORK - add tests |
| Yes | No | - | NEEDS WORK - fix variants |
| No | - | - | REJECTED - fix root cause |

## Anti-Patterns in Security Fixes

### 1. Blocklist Approach

**Bad:** Blocking known malicious inputs
```python
# BAD: Blocklist - will be bypassed
BLOCKED = ["<script>", "javascript:", "onerror="]
if any(b in user_input for b in BLOCKED):
    reject()
```

**Good:** Allowlist or structural sanitization
```python
# GOOD: Structural sanitization
import bleach
clean_input = bleach.clean(user_input, tags=[], strip=True)
```

### 2. Client-Side Only Fix

**Bad:** Adding validation only in frontend
```javascript
// BAD: Client-side validation only
if (input.length > 100) { showError("Too long"); return; }
```

**Good:** Server-side validation (client-side is UX, not security)
```python
# GOOD: Server-side validation
def validate_input(data):
    if len(data) > 100:
        raise ValidationError("Input too long")
```

### 3. Catch-All Exception Handler

**Bad:** Swallowing errors to "fix" crashes
```python
# BAD: Hides the vulnerability
try:
    dangerous_operation(user_input)
except:
    pass  # "Fixed" - no more errors
```

**Good:** Validate before the operation
```python
# GOOD: Prevent the dangerous condition
validated = validate_and_sanitize(user_input)
dangerous_operation(validated)
```

### 4. Incomplete Input Validation

**Bad:** Checking only one encoding/representation
```python
# BAD: Only checks lowercase
if "script" in user_input:
    reject()
# Bypassed by: SCRIPT, ScRiPt, &#115;cript
```

**Good:** Normalize before checking
```python
# GOOD: Normalize then validate
normalized = user_input.lower()
# Better: use a proper HTML sanitizer
```

## Key Principles

1. **Root cause over symptom**: A fix that does not address the root cause is not a fix
2. **Completeness over speed**: Check all variant locations, not just the reported one
3. **Tests prove fixes**: No test = no proof the fix works
4. **Regression awareness**: Every fix can break something else
5. **Allowlist over blocklist**: Blocklists are always incomplete
6. **Server-side is mandatory**: Client-side validation is UX, not security
7. **Defense in depth**: The best fixes add multiple layers of protection

## Skill Resources

For structured checklists and report templates, see `references/`:
- [references/fix-completeness-checklist.md](references/fix-completeness-checklist.md) - Comprehensive fix verification checklist
- [references/common-fix-failures.md](references/common-fix-failures.md) - Catalog of common ways security fixes fail
