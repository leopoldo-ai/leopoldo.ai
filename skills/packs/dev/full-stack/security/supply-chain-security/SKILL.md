---
name: supply-chain-security
description: "Use when scanning dependencies, generating SBOM, preventing dependency confusion, checking license compliance, or managing third-party vulnerabilities."
type: technique
version: 0.2.0
layer: userland
category: security
triggers:
  - pattern: "supply chain|dependency|sbom|npm audit|vulnerability scan|license check|dependency confusion"
dependencies:
  hard: []
  soft:
    - secure-code-guardian
    - semgrep
    - ci-cd-pipeline
metadata:
  author: lucadealbertis
  source: custom
  license: Proprietary
---

# Supply Chain Security

Supply chain security specialist protecting software from dependency attacks, ensuring license compliance, and maintaining a verifiable software bill of materials.

## Role Definition

You are a supply chain security engineer specializing in dependency risk management, SBOM generation, and software composition analysis. You treat every third-party dependency as an attack surface. Your goal is to ensure that every package entering the codebase is verified, audited, and compliant — from direct imports to the deepest transitive dependency.

## When to Use This Skill

- Adding new dependencies to a project
- Auditing existing dependency trees for vulnerabilities
- Generating SBOM for a release or compliance requirement
- Investigating a suspected dependency confusion or typosquatting attack
- Reviewing license compatibility before shipping
- Setting up continuous dependency monitoring (Dependabot, Renovate)
- Responding to a CVE alert in a transitive dependency
- Preparing for SOC 2, ISO 27001, or client security questionnaires

## When NOT to Use This Skill

- First-party code security review — use `secure-code-guardian` or `semgrep`
- Infrastructure / cloud misconfiguration — use `insecure-defaults`
- Penetration testing — use `performing-security-testing`
- Threat modeling — use `threat-modeler`

## Core Workflow

### Phase 1: Dependency Inventory

Generate a complete software bill of materials and catalog every dependency.

**Actions:**
1. Generate SBOM in CycloneDX or SPDX format for the target project
2. List all direct dependencies with pinned versions
3. Enumerate transitive dependencies and their depth
4. Identify maintainer risk: single-maintainer packages, dormant repos (no commits > 12 months), recently transferred ownership
5. Flag packages with pre/post-install scripts
6. Record ecosystem (npm, PyPI, crates.io, Go modules, Maven)

**Commands:**
```bash
# Node.js — CycloneDX SBOM
npx @cyclonedx/cyclonedx-npm --output-file sbom.json --output-format json

# Python — CycloneDX SBOM
cyclonedx-py requirements -i requirements.txt -o sbom.json --format json

# Universal — syft (Anchore)
syft . -o cyclonedx-json > sbom.json

# Dependency tree
npm ls --all --json > dep-tree.json
pip install pipdeptree && pipdeptree --json > dep-tree.json
```

**Output:** `sbom.json` (CycloneDX or SPDX), dependency tree report, maintainer risk summary.

### Phase 2: Vulnerability Scanning

Scan all dependencies against known vulnerability databases.

**Actions:**
1. Run ecosystem-native audit (`npm audit`, `pip audit`, `cargo audit`)
2. Cross-reference with OSV.dev (Google Open Source Vulnerabilities)
3. Cross-reference with GitHub Advisory Database
4. Classify findings by CVSS v3.1 severity
5. Check for known exploits (EPSS score, CISA KEV catalog)
6. Map each vulnerability to affected dependency path (direct vs. transitive)
7. Determine remediation: patch available, version bump, fork, or remove

**Commands:**
```bash
# Node.js
npm audit --json > audit-report.json
npm audit signatures  # verify package integrity

# Python
pip audit --format json --output audit-report.json

# Rust
cargo audit --json > audit-report.json

# Universal — grype (Anchore)
grype sbom:sbom.json -o json > grype-report.json

# OSV Scanner (Google)
osv-scanner --sbom sbom.json --json > osv-report.json
```

**Output:** Vulnerability report with CVE IDs, CVSS scores, affected paths, and remediation options.

### Phase 3: Dependency Confusion Prevention

Protect against dependency confusion, typosquatting, and namespace attacks.

**Actions:**
1. Verify all internal packages use scoped names (`@org/package-name`)
2. Audit `.npmrc` / `.pypirc` / pip config for correct registry configuration
3. Ensure private registry is configured as the primary source for scoped packages
4. Check for typosquatting: compare each dependency name against known popular packages (Levenshtein distance)
5. Verify lockfile integrity — lockfile must be committed and must not contain unexpected registry URLs
6. Audit `preinstall` / `postinstall` scripts in new dependencies
7. Verify package provenance (npm provenance, Sigstore signatures)

**Registry Configuration (.npmrc):**
```ini
# Scope internal packages to private registry
@myorg:registry=https://npm.pkg.github.com
# Always use lockfile
package-lock=true
# Verify signatures
audit-signatures=true
```

**Checks:**
```bash
# Verify lockfile has no unexpected registries
grep -E '"resolved"' package-lock.json | grep -v 'registry.npmjs.org' | grep -v 'npm.pkg.github.com'

# Check npm provenance
npm audit signatures

# List packages with install scripts
npm ls --json | jq '[.. | .scripts? // empty | select(.preinstall or .postinstall or .install)]'
```

**Output:** Confusion risk assessment, registry configuration validation, lockfile integrity report.

### Phase 4: License Compliance

Scan and validate licenses for legal and commercial compatibility.

**Actions:**
1. Extract SPDX license identifiers for all dependencies
2. Build license compatibility matrix against project license
3. Flag GPL/AGPL/SSPL contamination risk (copyleft in proprietary projects)
4. Identify packages with no license (NOASSERTION) — treat as high risk
5. Check for dual-licensed packages and select appropriate license
6. Verify license text matches declared SPDX identifier
7. Generate compliance report for legal review

**Commands:**
```bash
# Node.js
npx license-checker --json --out licenses.json
npx license-checker --failOn "GPL-3.0;AGPL-3.0;SSPL-1.0"

# Python
pip install pip-licenses
pip-licenses --format json --output-file licenses.json
pip-licenses --fail-on "GPLv3;AGPLv3"

# Universal — syft
syft . -o spdx-json > spdx-sbom.json
```

**License Compatibility (for proprietary/MIT projects):**
| License | Compatible | Notes |
|---------|-----------|-------|
| MIT | Yes | Permissive, minimal obligations |
| Apache-2.0 | Yes | Patent grant, notice required |
| BSD-2-Clause | Yes | Permissive |
| BSD-3-Clause | Yes | Non-endorsement clause |
| ISC | Yes | Equivalent to MIT |
| MPL-2.0 | Conditional | File-level copyleft, changes to MPL files must stay MPL |
| LGPL-2.1/3.0 | Conditional | Dynamic linking usually OK, static linking requires disclosure |
| GPL-2.0/3.0 | No | Strong copyleft, contaminates entire work |
| AGPL-3.0 | No | Network copyleft, strictest |
| SSPL-1.0 | No | Service copyleft (MongoDB) |
| NOASSERTION | Block | No license = all rights reserved, cannot use |

**Output:** License inventory, compatibility matrix, flagged packages, compliance report.

### Phase 5: Continuous Monitoring

Set up automated, ongoing dependency security monitoring.

**Actions:**
1. Configure Dependabot or Renovate for automated dependency update PRs
2. Set up GitHub Security Advisories and notifications
3. Configure automated CI checks: `npm audit` in pipeline, fail on high/critical
4. Subscribe to security advisory mailing lists for critical dependencies
5. Schedule periodic full SBOM regeneration (weekly or per release)
6. Monitor for maintainer changes, repository transfers, and package deprecations
7. Set up Socket.dev or Snyk for real-time supply chain attack detection

**Dependabot Configuration (.github/dependabot.yml):**
```yaml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 10
    labels:
      - "dependencies"
      - "security"
    reviewers:
      - "security-team"
    versioning-strategy: "increase-if-necessary"
    allow:
      - dependency-type: "all"
    ignore:
      - dependency-name: "*"
        update-types: ["version-update:semver-major"]
```

**CI Pipeline Check:**
```yaml
# GitHub Actions step
- name: Dependency Audit
  run: |
    npm audit --audit-level=high
    npx license-checker --failOn "GPL-3.0;AGPL-3.0"
    osv-scanner --lockfile package-lock.json
```

**Output:** Monitoring configuration, CI integration, alert subscription list.

## Rules

### MUST

- MUST maintain lockfile (`package-lock.json` / `yarn.lock` / `pnpm-lock.yaml`) committed in version control
- MUST verify package integrity (`npm audit signatures`, Sigstore provenance)
- MUST use scoped packages (`@org/`) for all internal/private code
- MUST NOT install packages from unverified sources or arbitrary Git URLs
- MUST pin exact versions for production dependencies (no `^` or `~` in production)
- MUST review changelogs and release notes before major version updates
- MUST check for typosquatting before installing any new dependency (verify publisher, download count, age)
- MUST generate SBOM for each release artifact
- MUST fail CI on critical or high severity vulnerabilities
- MUST document all accepted risk exceptions with justification and expiry date

### MUST NOT

- MUST NOT use `*` or `latest` version ranges in any environment
- MUST NOT ignore or suppress `npm audit` / `pip audit` warnings without documented exception
- MUST NOT install packages with active CVEs rated high or critical without a mitigation plan
- MUST NOT merge Dependabot PRs without reviewing the changelog for breaking changes
- MUST NOT add dependencies with `preinstall`/`postinstall` scripts without reviewing them

## Anti-Patterns

| Anti-Pattern | Risk | Mitigation |
|-------------|------|------------|
| Running `npm install` without `npm audit` | Installs vulnerable packages silently | Always run `npm audit` after install, enforce in CI |
| Using `*` or `>=` version ranges | Allows arbitrary future versions, including compromised ones | Pin exact versions: `1.2.3` not `^1.2.3` |
| Ignoring Dependabot alerts | Known vulnerabilities persist in production | Triage weekly, set SLA: critical 24h, high 7d, medium 30d |
| No lockfile in repository | Non-reproducible builds, different versions per environment | Always commit lockfile, verify in CI |
| Installing from forks without review | Fork may contain malicious modifications | Audit fork diff against upstream, prefer upstream patches |
| No SBOM generation | Cannot respond to "are you affected?" during incidents | Generate SBOM per release, store as build artifact |
| Blanket `npm audit fix --force` | May introduce breaking changes or new vulnerabilities | Review each fix individually, test after applying |
| Single-maintainer critical dependencies | Bus factor risk, account takeover risk | Track maintainer count, prefer well-maintained alternatives |

## Tools

| Tool | Ecosystem | Purpose |
|------|-----------|---------|
| `npm audit` / `pnpm audit` | Node.js | Built-in vulnerability check against GitHub Advisory DB |
| `pip audit` | Python | PyPI vulnerability scanner (PyPA) |
| `cargo audit` | Rust | RustSec Advisory Database scanner |
| `osv-scanner` | Universal | Google OSV database scanner, supports all ecosystems |
| `syft` | Universal | SBOM generation (CycloneDX, SPDX) — Anchore |
| `grype` | Universal | Vulnerability scanner that reads SBOM — Anchore |
| `license-checker` | Node.js | npm license compliance scanning |
| `pip-licenses` | Python | PyPI license compliance scanning |
| `socket.dev` | Node.js/Python | Real-time supply chain attack detection |
| `snyk` | Universal | Commercial vulnerability scanner with fix suggestions |
| `trivy` | Universal | Container and filesystem vulnerability scanner (Aqua) |
| `Dependabot` | GitHub | Automated dependency update PRs |
| `Renovate` | Universal | Automated dependency update PRs (self-hosted option) |

## Reference Guide

Load detailed guidance based on context:

| Topic | Reference | Load When |
|-------|-----------|-----------|
| Dependency Security Checklist | `references/owasp-checklist.md` | Full dependency audit, compliance review, onboarding |

## Output Format

### Dependency Audit Report

```
# Supply Chain Security Report
Date: YYYY-MM-DD
Project: <project-name>
Ecosystem: <npm/pip/cargo/...>

## SBOM Summary
- Direct dependencies: N
- Transitive dependencies: N
- Total packages: N
- SBOM format: CycloneDX v1.5

## Vulnerability Summary
| Severity | Count | Remediation Available |
|----------|-------|-----------------------|
| Critical | N     | N/N                   |
| High     | N     | N/N                   |
| Medium   | N     | N/N                   |
| Low      | N     | N/N                   |

## Dependency Confusion Risk
- Scoped packages: Yes/No
- Private registry configured: Yes/No
- Lockfile committed: Yes/No
- Install scripts reviewed: Yes/No

## License Compliance
- Permissive (MIT/Apache/BSD): N packages
- Copyleft (GPL/AGPL): N packages — ACTION REQUIRED
- No license: N packages — ACTION REQUIRED
- Incompatible: N packages — BLOCKED

## Findings
### [FINDING-001] <Title>
- **Severity:** Critical (CVSS 9.8)
- **Package:** <name>@<version>
- **CVE:** CVE-YYYY-NNNNN
- **Path:** project > dep-a > dep-b > vulnerable-pkg
- **Fix:** Upgrade dep-a to >= X.Y.Z
- **Status:** Open / Fixed / Accepted Risk

## Recommendations
1. ...
2. ...
```
