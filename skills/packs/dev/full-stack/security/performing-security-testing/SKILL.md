---
name: performing-security-testing
description: "Use when running security testing per OWASP Testing Guide v4.2, performing penetration testing, or conducting automated and manual security assessments."
type: technique
---

# Security Testing

Security tester following OWASP Testing Guide v4.2 methodology. Systematic, repeatable assessments combining automated scanning with manual verification.

## Prerequisites

1. **Written authorization** -- signed scope document or pentest agreement
2. **Scope definition** -- target URLs, IPs, APIs, in-scope/out-of-scope
3. **Test credentials** -- accounts for each role level
4. **Test environment** -- non-production preferred; production only with explicit approval
5. **Communication plan** -- emergency contact, critical finding escalation path

## Core Workflow

| Phase | OWASP Ref | Key Actions |
|-------|-----------|-------------|
| 1. Information Gathering | OTG-INFO-001-010 | Technology fingerprinting, endpoint/API discovery, auth flow mapping, entry point enumeration |
| 2. Configuration Testing | OTG-CONFIG-001-008 | Default credentials, HTTP methods, CORS, security headers, TLS, error handling, exposed files (.env, .git/) |
| 3. Authentication Testing | OTG-AUTHN-001-010 | Brute force resistance, password policy, session management (128-bit entropy, HttpOnly/Secure/SameSite), MFA bypass, OAuth/OIDC, password reset |
| 4. Authorization Testing | OTG-AUTHZ-001-004 | IDOR, vertical/horizontal privilege escalation, path traversal, RBAC/ABAC verification, JWT validation (alg:none, key confusion), BOLA/BFLA |
| 5. Input Validation | OTG-INPVAL-001-017 | SQLi, XSS (reflected/stored/DOM), SSRF, command injection, file upload, deserialization, SSTI, header injection |
| 6. Business Logic | OTG-BUSLOGIC-001-009 | Rate limiting, race conditions (TOCTOU), workflow bypass, price/quantity manipulation, account enumeration, mass assignment |
| 7. API Security | OWASP API Top 10 | API auth, rate limits, mass assignment, BOLA/BFLA, GraphQL introspection/depth, excessive data exposure, pagination leakage |

## Security Headers Checklist

| Header | Expected Value |
|--------|---------------|
| Content-Security-Policy | Restrictive, no unsafe-inline |
| Strict-Transport-Security | max-age=31536000; includeSubDomains; preload |
| X-Content-Type-Options | nosniff |
| X-Frame-Options | DENY or SAMEORIGIN |
| Referrer-Policy | strict-origin-when-cross-origin or no-referrer |
| Permissions-Policy | Restrict camera, microphone, geolocation |

## Rules

### MUST
- Written authorization before any testing
- Document all findings with reproducible PoC
- Classify severity using CVSS v3.1 (base score + vector string)
- Test both authenticated and unauthenticated for every endpoint
- Report critical findings immediately (do not wait for full report)
- Verify fixes with regression tests after remediation
- Log all testing activities with timestamps
- Respect scope boundaries
- Use test accounts and test data only

### MUST NOT
- DoS or destructive testing without explicit written approval
- Access/exfiltrate/store data beyond what proves the vulnerability
- Test systems outside defined scope
- Automated scanners against production without rate limiting
- Share findings with unauthorized parties
- Leave backdoors, test accounts, or artifacts on target
- Social engineering unless explicitly in scope
- Modify or delete production data

## Severity Classification (CVSS v3.1)

| Severity | CVSS | Example | SLA |
|----------|------|---------|-----|
| Critical | 9.0-10.0 | Unauth RCE, SQLi with data exfil, auth bypass to admin | Fix within 24h |
| High | 7.0-8.9 | Stored XSS in admin, IDOR with PII, privilege escalation | Fix within 7d |
| Medium | 4.0-6.9 | Reflected XSS, CSRF on state-changing, missing headers | Fix within 30d |
| Low | 0.1-3.9 | Info disclosure (versions), verbose errors | Fix within 90d |
| Info | 0.0 | Best practice recommendations | Next release |

## Tools

| Tool | Purpose |
|------|---------|
| Burp Suite / OWASP ZAP | Intercepting proxy, scanner |
| nuclei | Template-based vuln scanner (8000+ templates) |
| sqlmap | SQL injection (authorized only) |
| ffuf | Fuzzing and content discovery |
| testssl.sh | TLS configuration analysis |
| nmap | Port scanning, service detection |
| jwt_tool | JWT manipulation and testing |

## Anti-Patterns

| Anti-Pattern | Risk | Instead |
|-------------|------|---------|
| Automated scanner only | Misses business logic, IDOR, auth issues | Combine automated + manual per phase |
| Testing only happy path | Misses edge cases, error handling | Test invalid inputs, boundaries, race conditions |
| Skipping unauthenticated testing | Misses pre-auth vulnerabilities | Test every endpoint without credentials first |
| No PoC in findings | Devs cannot reproduce; fixes incorrect | Exact request/response for each finding |
| Production testing without safeguards | Service disruption, data corruption | Use staging; limit scan rate if production required |
| Not retesting after fix | Incomplete fixes, regressions | Verify with original PoC plus variations |
