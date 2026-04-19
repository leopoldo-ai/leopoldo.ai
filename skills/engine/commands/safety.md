---
name: safety
description: Run Safety Agent on the last output. Usage: /safety [code|full|numbers|disclaimer]
---

# Safety Check

Run the Safety Agent on the last output in this conversation.

## Profiles

- `/safety` — Auto-detect profile from current domain
- `/safety code` — DEV profile: code security checks
- `/safety full` — Full BUSINESS profile: all checks
- `/safety numbers` — Numeric consistency only
- `/safety disclaimer` — Disclaimer check only

## How to run

Dispatch a Safety Agent (sonnet, foreground) with the appropriate profile and the last output as context. The agent produces an explicit report (does NOT auto-fix).

### DEV profile checks

1. SQL injection: string concatenation vs parameterized queries
2. XSS: innerHTML with user input
3. Unsafe packages: typosquatting, deprecated with CVE
4. Supply chain: unverified CDNs, unpinned deps, HTTP URLs
5. Weak crypto: MD5/SHA1 for passwords, ECB mode, short keys
6. Auth patterns: endpoints without authentication, permissive CORS

### BUSINESS profile checks

1. **Fact consistency**: numbers match across table, text, and summary
2. **Source flagging**: factual claims marked "verified" or "to be verified"
3. **Disclaimer enforcement**: domain-appropriate disclaimer present
   - Finance: "This analysis is for informational purposes only and does not constitute investment advice."
   - Legal: "This does not constitute legal advice. Consult qualified counsel for specific situations."
   - Medical: "This is not medical advice. Consult a qualified healthcare professional."
   - Consulting: caveat on assumptions and data limitations
4. **Cross-contamination guard**: no entities not introduced in this conversation
5. **Numeric consistency**: derived numbers mathematically correct vs base numbers
6. **Regulatory freshness**: citations flagged with "verify currency at date of consultation"
7. **Hallucination markers**: unsourced citations flagged as "to be verified"

## Report format

```text
Safety check: N issues found

1. CATEGORY [domain]
   Description of the issue.
   Suggestion: how to fix.

Overall: PASS | WARN (N issues, M blockers)
```

## Audit trail

After every safety check, log to the session journal:
```json
{"event":"safety.check","profile":"<profile>","result":"PASS|WARN|FAIL","issues":<count>,"checks_run":<count>,"timestamp":"<ISO-8601>"}
```
