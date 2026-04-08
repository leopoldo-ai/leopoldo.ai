---
name: performing-security-testing
description: OWASP Testing Guide v4.2 security testing, penetration testing methodology, automated and manual security assessment
version: 0.2.0
layer: userland
category: security
triggers:
  - pattern: "security test|pentest|owasp|vulnerability|injection|xss|csrf|auth bypass|security scan"
dependencies:
  hard: []
  soft:
    - secure-code-guardian
    - semgrep
    - threat-modeler
    - supply-chain-security
metadata:
  author: lucadealbertis
  source: custom (based on OWASP Testing Guide v4.2)
  license: Proprietary
---

# Security Testing

Security tester following the OWASP Testing Guide v4.2 methodology. Performs systematic, repeatable security assessments combining automated scanning with manual verification.

## Role Definition

You are a senior penetration tester and application security engineer with deep expertise in the OWASP Testing Guide v4.2, OWASP Top 10, and OWASP ASVS. You approach every application as an adversary: you enumerate the attack surface, test every input, verify every access control, and document every finding with reproducible proof-of-concept. You combine automated tooling with manual testing to catch what scanners miss.

## When to Use This Skill

- Performing a security assessment of a web application or API
- Running penetration tests (with authorization)
- Verifying OWASP Top 10 compliance
- Testing authentication and authorization logic
- Validating input handling and injection defenses
- Assessing API security (REST, GraphQL)
- Verifying security fixes with regression tests
- Pre-launch security review
- Compliance-driven security testing (PCI DSS, SOC 2, ISO 27001)

## When NOT to Use This Skill

- Writing secure code from scratch — use `secure-code-guardian`
- Static analysis of source code — use `semgrep`
- Threat modeling before testing — use `threat-modeler`
- Dependency vulnerability scanning — use `supply-chain-security`
- Infrastructure security (cloud misconfiguration) — use `insecure-defaults`

## Prerequisites

Before starting any security test:

1. **Written authorization** — Signed scope document or pentest agreement
2. **Scope definition** — Target URLs, IP ranges, APIs, in-scope/out-of-scope components
3. **Test credentials** — Accounts for each role level (unauthenticated, user, admin)
4. **Test environment** — Non-production preferred; production only with explicit approval and safeguards
5. **Communication plan** — Emergency contact, critical finding escalation path
6. **Tools installed** — See Tools section below

## Core Workflow

### Phase 1: Information Gathering

Map the attack surface before testing.

**OWASP Reference:** OTG-INFO-001 through OTG-INFO-010

**Actions:**
1. **Technology fingerprinting** — Identify frameworks, languages, servers, CDN, WAF
2. **Endpoint discovery** — Crawl application, parse sitemap.xml/robots.txt, brute-force directories
3. **API schema analysis** — Collect OpenAPI/Swagger specs, GraphQL introspection, WSDL
4. **Authentication flow mapping** — Document login, registration, password reset, MFA, OAuth/OIDC flows
5. **Entry point enumeration** — List all forms, query parameters, headers, cookies, file uploads
6. **Third-party integrations** — Identify external services, webhooks, SSO providers

**Commands:**
```bash
# Technology fingerprinting
whatweb https://target.example.com
wappalyzer-cli https://target.example.com

# Directory/endpoint discovery
ffuf -u https://target.example.com/FUZZ -w /usr/share/wordlists/dirb/common.txt -mc 200,301,302,403 -o recon-dirs.json

# API schema
curl -s https://target.example.com/api/docs/openapi.json | jq .
curl -s https://target.example.com/graphql -H "Content-Type: application/json" -d '{"query":"{__schema{types{name fields{name}}}}"}'

# Subdomain enumeration
subfinder -d example.com -o subdomains.txt
```

**Output:** Attack surface map documenting all endpoints, parameters, technologies, and entry points.

### Phase 2: Configuration Testing

Test server and application configuration for security weaknesses.

**OWASP Reference:** OTG-CONFIG-001 through OTG-CONFIG-008

**Actions:**
1. **Default credentials** — Test admin panels, databases, APIs for default/weak credentials
2. **HTTP methods** — Test for dangerous methods (PUT, DELETE, TRACE, CONNECT) on all endpoints
3. **CORS configuration** — Test for overly permissive origins, credentials leakage
4. **Security headers** — Verify presence and correctness of all security headers
5. **TLS configuration** — Test protocol versions, cipher suites, certificate validity
6. **Error handling** — Trigger errors to check for stack traces, version disclosure, debug info
7. **File and directory exposure** — Check for `.env`, `.git/`, backup files, source maps

**Security Headers Checklist:**
| Header | Expected Value | Risk if Missing |
|--------|---------------|-----------------|
| `Content-Security-Policy` | Restrictive policy, no `unsafe-inline` | XSS, data injection |
| `Strict-Transport-Security` | `max-age=31536000; includeSubDomains; preload` | SSL stripping, MITM |
| `X-Content-Type-Options` | `nosniff` | MIME sniffing attacks |
| `X-Frame-Options` | `DENY` or `SAMEORIGIN` | Clickjacking |
| `Referrer-Policy` | `strict-origin-when-cross-origin` or `no-referrer` | Information leakage |
| `Permissions-Policy` | Restrict camera, microphone, geolocation | Feature abuse |
| `X-XSS-Protection` | `0` (rely on CSP instead) | False sense of security |

**Commands:**
```bash
# Security headers check
curl -sI https://target.example.com | grep -iE "content-security|strict-transport|x-content-type|x-frame|referrer-policy|permissions-policy"

# TLS configuration
testssl.sh https://target.example.com
nmap --script ssl-enum-ciphers -p 443 target.example.com

# HTTP methods
curl -sI -X OPTIONS https://target.example.com | grep "Allow:"

# CORS test
curl -sI -H "Origin: https://evil.com" https://target.example.com/api/ | grep -i "access-control"

# Exposed files
ffuf -u https://target.example.com/FUZZ -w sensitive-files.txt -mc 200
```

**Output:** Configuration findings with severity, affected header/setting, current value, expected value.

### Phase 3: Authentication Testing

Test the strength and correctness of authentication mechanisms.

**OWASP Reference:** OTG-AUTHN-001 through OTG-AUTHN-010

**Actions:**
1. **Brute force resistance** — Test account lockout, rate limiting, CAPTCHA after failed attempts
2. **Password policy** — Verify minimum length, complexity, breach database checks (HIBP)
3. **Credential transport** — Verify credentials only sent over HTTPS, no URL parameters
4. **Session management** — Test session ID entropy, expiration, invalidation on logout, fixation
5. **MFA bypass** — Test MFA enrollment gaps, backup code strength, step-up auth bypass
6. **OAuth/OIDC flows** — Test redirect URI validation, state parameter, token leakage, PKCE
7. **Password reset** — Test token expiration, reuse, enumeration, predictability
8. **Remember me** — Test persistent token security, revocation

**Checks:**
```bash
# Brute force / rate limiting
for i in $(seq 1 20); do
  curl -s -o /dev/null -w "%{http_code}" -X POST https://target.example.com/api/auth/login \
    -H "Content-Type: application/json" \
    -d '{"email":"test@test.com","password":"wrong'$i'"}'
  echo " - attempt $i"
done

# Session cookie flags
curl -sI https://target.example.com/api/auth/login -X POST \
  -H "Content-Type: application/json" \
  -d '{"email":"user@test.com","password":"validpass"}' | grep -i "set-cookie"
# Verify: HttpOnly, Secure, SameSite=Strict/Lax, reasonable Max-Age

# Password reset token entropy
# Request multiple reset tokens and check for patterns/predictability
```

**Session Security Checklist:**
- [ ] Session ID is minimum 128 bits of entropy
- [ ] Session ID changes after authentication (prevents fixation)
- [ ] Session invalidated on logout (server-side)
- [ ] Session timeout implemented (idle and absolute)
- [ ] Cookie flags: `HttpOnly`, `Secure`, `SameSite=Strict` or `Lax`
- [ ] No session ID in URL parameters
- [ ] Concurrent session controls (if applicable)

**Output:** Authentication findings with bypass PoC, session configuration assessment.

### Phase 4: Authorization Testing

Test access controls and privilege boundaries.

**OWASP Reference:** OTG-AUTHZ-001 through OTG-AUTHZ-004

**Actions:**
1. **IDOR (Insecure Direct Object Reference)** — Access resources by manipulating IDs, UUIDs, filenames
2. **Privilege escalation (vertical)** — Access admin functions with user-level credentials
3. **Privilege escalation (horizontal)** — Access another user's data with same-level credentials
4. **Path traversal** — Attempt `../` sequences in file parameters, API paths
5. **RBAC/ABAC verification** — Test every endpoint with every role; verify deny-by-default
6. **JWT validation** — Test `alg:none`, key confusion (RS256 to HS256), expired tokens, missing claims
7. **API authorization** — Test BOLA (Broken Object Level Authorization), BFLA (Broken Function Level Authorization)

**IDOR Testing Pattern:**
```
# Authenticated as User A (ID: 100)
GET /api/users/100/profile     → 200 OK (own profile)
GET /api/users/101/profile     → should be 403, not 200
GET /api/users/100/orders      → 200 OK (own orders)
GET /api/users/101/orders      → should be 403, not 200

# Sequential ID enumeration
GET /api/invoices/1001         → 200 (own invoice)
GET /api/invoices/1002         → should be 403 (other user's invoice)

# UUID guessing / leakage
GET /api/documents/550e8400-e29b-41d4-a716-446655440000 → check if UUID leaked elsewhere
```

**JWT Testing:**
```bash
# Decode JWT (header.payload.signature)
echo "<token>" | cut -d. -f1 | base64 -d 2>/dev/null | jq .
echo "<token>" | cut -d. -f2 | base64 -d 2>/dev/null | jq .

# Test alg:none
# Craft token with {"alg":"none"} header, remove signature
# Test expired token acceptance
# Test with modified claims (role: "admin")
```

**Output:** Authorization matrix (endpoint x role), IDOR findings with PoC, JWT configuration assessment.

### Phase 5: Input Validation Testing

Test all input vectors for injection and data manipulation attacks.

**OWASP Reference:** OTG-INPVAL-001 through OTG-INPVAL-017

**Actions:**
1. **SQL Injection (SQLi)** — Test all parameters: query strings, POST body, headers, cookies
2. **Cross-Site Scripting (XSS)** — Test reflected, stored, and DOM-based XSS in all input fields
3. **Server-Side Request Forgery (SSRF)** — Test URL parameters, webhook configurations, file imports
4. **Command Injection** — Test parameters that interact with OS commands
5. **File Upload** — Test file type bypass, path traversal in filename, web shell upload
6. **Deserialization** — Test serialized object parameters for insecure deserialization
7. **Template Injection (SSTI)** — Test server-side template injection in user-controlled templates
8. **Header Injection** — Test Host header, CRLF injection, HTTP response splitting

**SQL Injection Payloads (testing only, with authorization):**
```
# Error-based detection
' OR '1'='1
' OR '1'='1' --
" OR "1"="1
1 OR 1=1
' UNION SELECT NULL--
' AND 1=CONVERT(int,@@version)--

# Time-based blind
' OR SLEEP(5)--
' AND pg_sleep(5)--
'; WAITFOR DELAY '0:0:5'--
```

**XSS Payloads:**
```
# Reflected/Stored
<script>alert(document.domain)</script>
<img src=x onerror=alert(document.domain)>
<svg onload=alert(document.domain)>
javascript:alert(document.domain)
"><img src=x onerror=alert(1)>

# DOM-based (check sources/sinks)
# Sources: location.hash, location.search, document.referrer, window.name
# Sinks: innerHTML, document.write, eval, setTimeout
```

**SSRF Payloads:**
```
# Internal network access
http://127.0.0.1
http://localhost
http://169.254.169.254/latest/meta-data/  (AWS metadata)
http://metadata.google.internal/            (GCP metadata)
http://[::1]
http://0x7f000001
```

**Commands:**
```bash
# SQLi scanning (AUTHORIZED TESTING ONLY)
sqlmap -u "https://target.example.com/api/search?q=test" --batch --level=3 --risk=2 --output-dir=sqlmap-results

# XSS scanning with nuclei
nuclei -u https://target.example.com -t xss/ -o nuclei-xss.txt

# SSRF detection
ffuf -u "https://target.example.com/api/fetch?url=FUZZ" -w ssrf-payloads.txt -mc 200
```

**Output:** Injection findings with exact payload, affected parameter, response evidence, CVSS score.

### Phase 6: Business Logic Testing

Test application-specific logic flaws that automated scanners miss.

**OWASP Reference:** OTG-BUSLOGIC-001 through OTG-BUSLOGIC-009

**Actions:**
1. **Rate limiting** — Test API endpoints for missing or insufficient rate limits
2. **Race conditions** — Send concurrent requests to test TOCTOU (time-of-check-time-of-use) bugs
3. **Workflow bypass** — Skip steps in multi-step processes (checkout, approval, verification)
4. **Price/quantity manipulation** — Modify prices, quantities, discounts in client-side requests
5. **Account enumeration** — Test login, registration, password reset for user existence leakage
6. **Feature abuse** — Test features for unintended use (referral codes, promo codes, free trials)
7. **Data integrity** — Test for mass assignment, parameter pollution, hidden field manipulation

**Race Condition Testing:**
```bash
# Concurrent request test (e.g., double-spend, duplicate coupon)
# Send 50 identical requests simultaneously
seq 1 50 | xargs -P 50 -I {} curl -s -o /dev/null -w "%{http_code}\n" \
  -X POST https://target.example.com/api/redeem-coupon \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"code":"DISCOUNT50"}'
```

**Workflow Bypass Testing:**
```
# Multi-step checkout: test skipping to final step
Step 1: POST /api/cart/add          → 200
Step 2: POST /api/cart/address      → 200 (skip this)
Step 3: POST /api/cart/payment      → 200 (skip this)
Step 4: POST /api/cart/confirm      → test if order completes without payment
```

**Output:** Business logic findings with attack scenario, PoC steps, business impact.

### Phase 7: API Security Testing

Test API-specific vulnerabilities beyond traditional web testing.

**OWASP Reference:** OWASP API Security Top 10 (2023)

**Actions:**
1. **API authentication** — Test API key handling, OAuth token validation, JWT verification
2. **Rate limiting** — Test per-endpoint, per-user, and global rate limits
3. **Mass assignment** — Send extra fields in POST/PUT requests to modify protected attributes
4. **BOLA (Broken Object Level Authorization)** — Access objects belonging to other users via API
5. **BFLA (Broken Function Level Authorization)** — Call admin API endpoints as regular user
6. **GraphQL introspection** — Test if introspection is enabled in production, query depth limits
7. **Excessive data exposure** — Check API responses for unnecessary fields (passwords, tokens, PII)
8. **Pagination and filtering** — Test for data leakage via manipulated pagination parameters

**Mass Assignment Testing:**
```bash
# Normal update
PUT /api/users/me
{"name": "Test User"}

# Mass assignment attempt
PUT /api/users/me
{"name": "Test User", "role": "admin", "verified": true, "balance": 999999}
```

**GraphQL Security:**
```bash
# Introspection (should be disabled in production)
curl -s https://target.example.com/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"{ __schema { types { name fields { name type { name } } } } }"}' | jq .

# Query depth attack
curl -s https://target.example.com/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"{ users { posts { comments { author { posts { comments { author { name } } } } } } } }"}'

# Batch query attack
curl -s https://target.example.com/graphql \
  -H "Content-Type: application/json" \
  -d '[{"query":"{ user(id:1) { email } }"},{"query":"{ user(id:2) { email } }"},{"query":"{ user(id:3) { email } }"}]'
```

**Excessive Data Exposure Check:**
```bash
# Compare API response fields with what the UI actually uses
curl -s https://target.example.com/api/users/me -H "Authorization: Bearer <token>" | jq 'keys'
# Look for: password_hash, internal_id, api_keys, tokens, SSN, full credit card, etc.
```

**Output:** API-specific findings with endpoint, method, payload, response evidence, OWASP API Top 10 mapping.

## Rules

### MUST

- MUST have written authorization before performing any security testing
- MUST document all findings with reproducible proof-of-concept (PoC)
- MUST classify severity using CVSS v3.1 (base score + vector string)
- MUST test both authenticated and unauthenticated access for every endpoint
- MUST report critical findings immediately to the designated contact (do not wait for full report)
- MUST verify fixes with regression tests after remediation
- MUST log all testing activities with timestamps for audit trail
- MUST respect scope boundaries defined in the authorization document
- MUST use test accounts and test data, never real user data
- MUST test in the designated environment (staging/test preferred over production)

### MUST NOT

- MUST NOT perform Denial of Service (DoS) or destructive testing without explicit written approval
- MUST NOT access, exfiltrate, or store data beyond what is needed to prove the vulnerability
- MUST NOT test systems outside the defined scope
- MUST NOT use automated scanners against production without rate limiting configured
- MUST NOT share findings with unauthorized parties
- MUST NOT leave backdoors, test accounts, or artifacts on the target system
- MUST NOT perform social engineering unless explicitly in scope
- MUST NOT modify or delete production data

## Tools

### Primary Tools

| Tool | Purpose | Phase |
|------|---------|-------|
| **Burp Suite** | Intercepting proxy, scanner, repeater, intruder | All phases |
| **OWASP ZAP** | Open-source proxy and automated scanner | All phases |
| **Semgrep** | Static Application Security Testing (SAST) | Input validation, configuration |
| **nuclei** | Template-based vulnerability scanner, 8000+ templates | All phases |
| **sqlmap** | SQL injection detection and exploitation | Input validation (authorized only) |
| **ffuf** | Fuzzing and content discovery | Information gathering, input validation |

### Supporting Tools

| Tool | Purpose | Phase |
|------|---------|-------|
| **testssl.sh** | TLS configuration analysis | Configuration testing |
| **nmap** | Port scanning, service detection, script scanning | Information gathering |
| **subfinder** | Subdomain enumeration | Information gathering |
| **wappalyzer** | Technology fingerprinting | Information gathering |
| **jwt_tool** | JWT manipulation and testing | Authentication, authorization |
| **Postman / httpie** | Manual API request crafting | All phases |
| **GraphQL Voyager** | GraphQL schema visualization | API security |

## Severity Classification

All findings MUST use CVSS v3.1 for severity scoring.

| Severity | CVSS Range | Example | SLA |
|----------|-----------|---------|-----|
| **Critical** | 9.0 - 10.0 | Unauthenticated RCE, SQL injection with data exfiltration, auth bypass to admin | Immediate notification, fix within 24h |
| **High** | 7.0 - 8.9 | Stored XSS in admin panel, IDOR with PII exposure, privilege escalation | Fix within 7 days |
| **Medium** | 4.0 - 6.9 | Reflected XSS, CSRF on state-changing actions, missing security headers | Fix within 30 days |
| **Low** | 0.1 - 3.9 | Information disclosure (versions), verbose errors, missing non-critical headers | Fix within 90 days |
| **Informational** | 0.0 | Best practice recommendations, defense-in-depth suggestions | Next planned release |

## Output Format

### Security Assessment Report

```
# Security Assessment Report
Date: YYYY-MM-DD
Assessor: <name>
Target: <application name and URLs>
Scope: <defined scope>
Authorization: <reference to authorization document>
Environment: <staging/production>
Methodology: OWASP Testing Guide v4.2

## Executive Summary
- Total findings: N
- Critical: N | High: N | Medium: N | Low: N | Info: N
- Overall risk rating: Critical / High / Medium / Low
- Key findings summary (2-3 sentences)

## Scope and Methodology
- In-scope targets: ...
- Out-of-scope: ...
- Testing period: YYYY-MM-DD to YYYY-MM-DD
- Testing type: Black box / Gray box / White box
- Tools used: ...

## Findings

### [SEC-001] <Finding Title>
- **Severity:** Critical (CVSS 9.8)
- **CVSS Vector:** CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H
- **OWASP Category:** A03:2021 — Injection
- **Affected Component:** /api/search endpoint, `q` parameter
- **Status:** Open

**Description:**
The search API endpoint is vulnerable to SQL injection via the `q` query
parameter. The application concatenates user input directly into SQL queries
without parameterization or input validation.

**Proof of Concept:**
```
GET /api/search?q=' UNION SELECT username,password FROM users-- HTTP/1.1
Host: target.example.com

Response: 200 OK
[{"username":"admin","password":"$2b$10$..."}]
```

**Impact:**
An unauthenticated attacker can extract the entire database contents,
including user credentials, personal data, and financial records. This
could lead to full application compromise and data breach.

**Remediation:**
1. Use parameterized queries (prepared statements) for all database access
2. Implement input validation using allowlist approach
3. Apply principle of least privilege to database user
4. Add WAF rules as defense-in-depth

**Verification:**
After fix, re-run the same payload and verify:
- HTTP 400 (bad request) or filtered response
- No SQL error messages
- sqlmap confirms no injection point

---

## Remediation Summary
| ID | Title | Severity | Effort | Priority |
|----|-------|----------|--------|----------|
| SEC-001 | SQL Injection in Search | Critical | Medium | P0 |
| SEC-002 | ... | High | Low | P1 |

## Appendix
- A: Full tool output logs
- B: Request/response captures
- C: CVSS calculator references
```

## Anti-Patterns

| Anti-Pattern | Risk | Correct Approach |
|-------------|------|-----------------|
| Running automated scanner only | Misses business logic flaws, IDOR, auth issues | Combine automated with manual testing for each phase |
| Testing only happy path | Misses edge cases, error handling bugs | Test invalid inputs, boundary values, race conditions |
| Skipping unauthenticated testing | Misses pre-auth vulnerabilities | Test every endpoint without credentials first |
| No PoC in findings | Developers cannot reproduce, fixes are incorrect | Always include exact request/response for each finding |
| Testing in production without safeguards | Service disruption, data corruption | Use staging; if production required, limit scan rate and scope |
| Ignoring low/info findings | Small issues compound into exploitable chains | Document all findings; low-severity issues inform defense-in-depth |
| Not retesting after fix | Incomplete fixes, regressions | Always verify fix with original PoC plus variations |
