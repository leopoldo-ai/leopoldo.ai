# Common Security Fix Failures

A catalog of ways security fixes commonly fail, organized by failure mode. Use this to guide review of patches and anticipate problems before they reach production.

## Category 1: Incomplete Fixes

### 1.1 Single-Location Fix for Multi-Location Bug

**Pattern:** Developer fixes the reported location but misses identical patterns elsewhere.

**Example:**
```python
# Fixed in api/v1/users.py
query = db.session.execute(text(stmt), {"id": user_id})  # Parameterized

# Still vulnerable in api/v1/admin.py (same pattern, not fixed)
query = db.session.execute(f"SELECT * FROM users WHERE id={user_id}")
```

**Detection:** Run variant analysis across the entire codebase after any security fix.

### 1.2 Single Entry Point Fix

**Pattern:** Fix covers one API endpoint but misses others that reach the same vulnerable code.

**Example:**
```
POST /api/v1/upload     -> upload_handler() -> process_file()  # Fixed
POST /api/v2/upload     -> upload_handler_v2() -> process_file()  # NOT fixed
PUT  /api/v1/update     -> update_handler() -> process_file()  # NOT fixed
```

**Detection:** Trace all callers of the fixed function, not just the reported entry point.

### 1.3 Partial Input Handling

**Pattern:** Fix validates one input type but misses others.

**Example:**
```javascript
// Fix: validate string input
if (typeof input === 'string') {
  input = sanitize(input);
}
// Missing: array input bypasses validation
// POST body: {"input": ["<script>alert(1)</script>"]}
```

**Detection:** Test with all possible input types: string, array, object, null, number, boolean.

---

## Category 2: Bypassable Fixes

### 2.1 Blocklist-Based Fix

**Pattern:** Fix blocks known malicious values instead of allowing known good values.

**Example:**
```python
# Fix: block known bad characters
BLOCKED = ['<', '>', '"', "'", '&']
if any(c in input for c in BLOCKED):
    raise ValueError("Invalid input")
# Bypass: Unicode characters, HTML entities, double encoding
```

**Why it fails:** Blocklists are always incomplete. New bypass techniques are discovered constantly.

### 2.2 Case-Sensitive Validation

**Pattern:** Fix checks for exact case match of dangerous patterns.

**Example:**
```python
# Fix: check for script tags
if '<script' in user_input:
    reject()
# Bypass: <SCRIPT>, <ScRiPt>, <script/>, <img onerror=...>
```

**Detection:** Test with case variations, mixed case, and alternative attack vectors.

### 2.3 Single-Encoding Fix

**Pattern:** Fix handles one encoding but misses double encoding or alternative encodings.

**Example:**
```python
# Fix: URL-decode and check
decoded = urllib.parse.unquote(input)
if '../' in decoded:
    reject()
# Bypass: %252e%252e%252f (double-encoded ../)
```

**Detection:** Test with single encoding, double encoding, UTF-8 encoding, and mixed encoding.

### 2.4 Client-Side Only Fix

**Pattern:** Validation added in frontend JavaScript but not on the server.

**Example:**
```javascript
// Frontend fix
function validateInput(value) {
  if (value.length > 100) return false;
  if (/<script/i.test(value)) return false;
  return true;
}
// Server has no validation - curl bypasses the fix entirely
```

**Detection:** Always verify that validation exists server-side. Client-side is UX, not security.

---

## Category 3: Introducing New Vulnerabilities

### 3.1 Information Leakage in Error Handling

**Pattern:** Fix adds error handling that reveals internal state.

**Example:**
```python
# Before: crash (vulnerability via stack trace)
result = dangerous_op(user_input)

# "Fix": catch and log
try:
    result = dangerous_op(user_input)
except Exception as e:
    # New vulnerability: leaks internal path and query
    return {"error": str(e), "query": f"SELECT * FROM users WHERE input='{user_input}'"}
```

**Detection:** Review all new error messages and logging for sensitive data exposure.

### 3.2 TOCTOU (Time-of-Check-Time-of-Use)

**Pattern:** Fix adds validation but a race condition exists between check and use.

**Example:**
```python
# Fix: validate file path
if not is_valid_path(filepath):  # Check
    raise ValueError("Invalid path")

time.sleep(0.001)  # Window for race condition

data = open(filepath).read()  # Use - filepath may have changed
```

**Detection:** Look for any gap between validation and use, especially with filesystem or database operations.

### 3.3 Denial of Service via Fix

**Pattern:** Fix adds processing (regex, crypto, parsing) that can be exploited for DoS.

**Example:**
```python
# Fix: validate email with regex
import re
EMAIL_REGEX = r'^([a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+)$'
if not re.match(EMAIL_REGEX, user_input):  # ReDoS vulnerable
    raise ValueError("Invalid email")
# Attack: "a" * 10000 + "@" causes catastrophic backtracking
```

**Detection:** Check for regex complexity, unbounded loops, and resource-intensive operations in validation code.

### 3.4 Weakened Access Control

**Pattern:** Fix changes authorization logic and accidentally broadens access.

**Example:**
```python
# Before: strict check (but buggy for edge case)
def can_access(user, resource):
    return user.id == resource.owner_id

# "Fix": handle null case but introduces bypass
def can_access(user, resource):
    if resource.owner_id is None:
        return True  # BUG: anyone can access unowned resources
    return user.id == resource.owner_id
```

**Detection:** Review all branches in authorization logic for unintended access grants.

---

## Category 4: Cosmetic Fixes

### 4.1 Suppressing Error Output

**Pattern:** Fix hides the error instead of fixing the cause.

**Example:**
```python
# Before: SQL error displayed to user
cursor.execute(f"SELECT * FROM users WHERE id={user_input}")

# "Fix": catch the error
try:
    cursor.execute(f"SELECT * FROM users WHERE id={user_input}")
except:
    return {"error": "Something went wrong"}
# SQL injection still works, just no visible error
# Attacker uses time-based blind injection instead
```

### 4.2 Adding Logging Without Fixing

**Pattern:** Fix adds audit logging but does not prevent the attack.

**Example:**
```python
# "Fix": log the attack attempt
def process_input(user_input):
    if looks_suspicious(user_input):
        logger.warning(f"Suspicious input detected: {user_input}")
    # Still processes the malicious input
    return dangerous_operation(user_input)
```

### 4.3 Rate Limiting as Primary Fix

**Pattern:** Fix adds rate limiting to make exploitation harder, not impossible.

**Example:**
```python
# "Fix": rate limit the vulnerable endpoint
@rate_limit(max=10, per=60)
def vulnerable_endpoint(request):
    # Still vulnerable, just slower to exploit
    return dangerous_operation(request.data)
```

Rate limiting is defense-in-depth, not a fix. The vulnerability still exists.

---

## Category 5: Dependency-Related Failures

### 5.1 Pinning Without Patching

**Pattern:** Fix pins the dependency version but does not update to the patched version.

**Example:**
```
# Before: vulnerable-lib>=1.0
# "Fix": pin to specific vulnerable version
vulnerable-lib==1.2.3  # Still vulnerable
# Correct: vulnerable-lib>=1.2.4  # Version with security fix
```

### 5.2 Workaround Instead of Update

**Pattern:** Fix works around a dependency vulnerability instead of updating.

**Example:**
```python
# Vulnerable: yaml.load(data)  # Arbitrary code execution
# "Fix": wrap in try/except
try:
    result = yaml.load(data)  # Still vulnerable
except:
    result = {}
# Correct: yaml.safe_load(data)  # Or update PyYAML
```

### 5.3 Transitive Dependency Ignored

**Pattern:** Fix updates the direct dependency but a transitive dependency remains vulnerable.

**Detection:** Run `npm audit`, `pip-audit`, or equivalent to check the full dependency tree.

---

## Quick Reference: Fix Review Red Flags

| Red Flag | What It Suggests |
|----------|------------------|
| Only one file changed | Variant locations likely missed |
| No tests added | Fix not verified |
| `try/except` or `try/catch` added | May be suppressing, not fixing |
| Blocklist of bad values | Will be bypassed |
| Only client-side changes | Server still vulnerable |
| Rate limiting as primary defense | Vulnerability still exists |
| Error message changes only | Information leak fix, not root cause |
| Regex added for validation | Potential ReDoS |
| `if err != nil { return nil }` | Error suppression |
| Dependency version pinned, not bumped | Still on vulnerable version |
