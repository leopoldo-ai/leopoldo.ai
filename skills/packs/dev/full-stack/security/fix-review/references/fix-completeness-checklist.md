# Fix Completeness Checklist

Comprehensive verification checklist for security fix reviews. Use this for every fix review to ensure nothing is missed.

## 1. Root Cause Analysis

- [ ] Root cause identified and documented in a single sentence
- [ ] Root cause is a code defect (not a configuration or deployment issue)
- [ ] Fix addresses the root cause directly (not a symptom or side effect)
- [ ] If root cause is in a dependency, the dependency is updated (not just worked around)

## 2. Fix Correctness

### Input Validation Fixes
- [ ] Validation uses allowlist, not blocklist
- [ ] Validation handles all input encodings (UTF-8, URL-encoded, double-encoded)
- [ ] Validation handles null, empty, and boundary values
- [ ] Validation is applied server-side (not just client-side)
- [ ] Validation error messages do not leak sensitive information
- [ ] Validation cannot be bypassed via type confusion (string vs array vs object)

### Authentication / Authorization Fixes
- [ ] Fix applies to all relevant endpoints (not just the reported one)
- [ ] Fix checks both authentication AND authorization
- [ ] Fix handles session edge cases (expired, revoked, concurrent)
- [ ] Fix does not introduce timing side channels
- [ ] Default deny is enforced (fail closed, not fail open)

### Injection Fixes (SQL, XSS, Command, etc.)
- [ ] Fix uses parameterized queries / prepared statements (not string escaping)
- [ ] Fix applies output encoding appropriate to context (HTML, URL, JS, CSS)
- [ ] Fix covers all injection points (not just the reported one)
- [ ] Fix handles nested/recursive injection attempts
- [ ] Content-Security-Policy headers updated if applicable

### Cryptographic Fixes
- [ ] Algorithm is current and appropriate (not MD5, SHA1, DES, RC4)
- [ ] Key size is adequate (RSA >= 2048, AES >= 128, ECDSA >= 256)
- [ ] Random number generation uses CSPRNG
- [ ] Timing-safe comparison used for secrets
- [ ] Key material is properly zeroized after use

### Memory Safety Fixes (C/C++)
- [ ] Bounds checking added for all buffer operations
- [ ] Integer overflow checks before allocation/indexing
- [ ] Use-after-free prevented (ownership clear, or smart pointers)
- [ ] Double-free prevented (nullify after free, or unique_ptr)
- [ ] Format string uses literal format (not user-controlled)

## 3. Variant Coverage

- [ ] Searched entire codebase for same vulnerable pattern
- [ ] All variant locations identified and listed
- [ ] All variants either fixed or documented as out-of-scope with justification
- [ ] Related but different vulnerability patterns checked (same root cause, different manifestation)
- [ ] Third-party code / vendored dependencies checked

## 4. Entry Point Coverage

- [ ] All API endpoints that reach the vulnerable code identified
- [ ] All entry points verified as patched (not just the one in the report)
- [ ] Internal callers (cron jobs, message queues, admin endpoints) checked
- [ ] API versioning checked (v1, v2, legacy endpoints)
- [ ] WebSocket / GraphQL / gRPC endpoints checked if applicable

## 5. Edge Cases

- [ ] Empty input handled
- [ ] Null / undefined / None handled
- [ ] Maximum-length input handled
- [ ] Unicode and special characters handled
- [ ] Concurrent request race conditions considered
- [ ] Error/exception paths reviewed (catch blocks, fallbacks)

## 6. Test Adequacy

- [ ] Regression test exists that reproduces the original vulnerability
- [ ] Test FAILS without the fix and PASSES with the fix
- [ ] Edge case tests included (empty, null, boundary, encoded)
- [ ] Bypass attempt tests included (double encoding, case variation, unicode normalization)
- [ ] Normal functionality regression tests included
- [ ] Tests cover ALL patched locations (not just the primary one)
- [ ] Tests are deterministic (no flaky tests)

## 7. Regression Safety

- [ ] All existing tests pass after the fix
- [ ] No new warnings or deprecation notices
- [ ] No new dependencies introduced (or dependencies vetted if added)
- [ ] Performance impact assessed on critical paths
- [ ] Error handling does not leak sensitive information
- [ ] Logging changes do not log sensitive data (passwords, tokens, PII)

## 8. Documentation

- [ ] Vulnerability description documented (for audit trail)
- [ ] Fix description documented (what changed and why)
- [ ] Root cause documented (for future prevention)
- [ ] Affected versions documented
- [ ] If public: CVE / advisory updated with fix details

## Verdict Criteria

| Criteria Met | Verdict |
|-------------|---------|
| All sections pass | **APPROVED** |
| Minor test gaps only | **APPROVED WITH CONDITIONS** - list required tests |
| Variant locations missing | **NEEDS WORK** - fix all variants |
| Root cause not addressed | **REJECTED** - rework the fix |
| Regression introduced | **REJECTED** - fix the regression first |

## Report Template

```markdown
## Fix Review: [Vulnerability ID]

**Reviewer:** [name]
**Date:** [date]
**Verdict:** [APPROVED / NEEDS WORK / REJECTED]

### Root Cause
[One sentence description]

### Fix Summary
[What the fix does]

### Sections
| Section | Status | Notes |
|---------|--------|-------|
| Root Cause Analysis | Pass/Fail | |
| Fix Correctness | Pass/Fail | |
| Variant Coverage | Pass/Fail | |
| Entry Point Coverage | Pass/Fail | |
| Edge Cases | Pass/Fail | |
| Test Adequacy | Pass/Fail | |
| Regression Safety | Pass/Fail | |
| Documentation | Pass/Fail | |

### Issues Found
1. [Description of issue]
2. [Description of issue]

### Recommendations
1. [Specific actionable recommendation]
```
