# Dependency Security Checklist

Comprehensive checklist for supply chain security audits, based on OWASP Software Component Verification Standard (SCVS), NIST SSDF, and SLSA framework.

---

## 1. Dependency Inventory & SBOM

- [ ] **SBOM generated** for the current release in CycloneDX or SPDX format
- [ ] **All direct dependencies** listed with exact pinned versions
- [ ] **All transitive dependencies** enumerated (full dependency tree)
- [ ] **Ecosystem identified** for each dependency (npm, PyPI, crates.io, Maven, Go modules)
- [ ] **SBOM stored** as a build artifact alongside release binaries
- [ ] **SBOM includes**: package name, version, supplier, license, hash, purl (package URL)
- [ ] **SBOM freshness**: regenerated on every release, not stale copies

## 2. Vulnerability Scanning

- [ ] **Ecosystem audit** run: `npm audit` / `pip audit` / `cargo audit`
- [ ] **OSV Scanner** run against SBOM or lockfile (`osv-scanner --sbom sbom.json`)
- [ ] **Grype scan** run against SBOM (`grype sbom:sbom.json`)
- [ ] **Zero critical vulnerabilities** in direct dependencies
- [ ] **Zero high vulnerabilities** in direct dependencies without mitigation plan
- [ ] **Transitive vulnerabilities** triaged: upgrade path identified or risk accepted with justification
- [ ] **EPSS score** checked for high/critical CVEs (Exploit Prediction Scoring System)
- [ ] **CISA KEV** checked: no packages on Known Exploited Vulnerabilities catalog
- [ ] **Vulnerability SLA** defined: Critical 24h, High 7d, Medium 30d, Low 90d
- [ ] **Audit results** stored in CI artifacts for traceability

## 3. Dependency Confusion & Namespace Attacks

- [ ] **Internal packages use scoped names**: `@org/package-name` (npm) or organization namespace
- [ ] **Private registry configured** in `.npmrc` / `.pypirc` / pip config
- [ ] **Scoped packages routed** to private registry exclusively
- [ ] **Public registry** used only for public packages
- [ ] **Lockfile committed** to version control (`package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`)
- [ ] **Lockfile integrity verified**: no unexpected registry URLs in resolved fields
- [ ] **Lockfile not manually edited**: changes come only from package manager operations
- [ ] **Package names verified** against typosquatting: checked spelling, publisher, download count
- [ ] **No packages installed** from arbitrary Git URLs or tarballs without review
- [ ] **No wildcard versions** (`*`, `latest`, `>=`) in any dependency specification

## 4. Package Integrity & Provenance

- [ ] **npm audit signatures** pass: all packages have valid registry signatures
- [ ] **Package provenance** verified where available (npm provenance, Sigstore)
- [ ] **Checksums match**: lockfile hashes match downloaded packages
- [ ] **No modified packages**: `npm ci` (not `npm install`) used in CI for reproducible builds
- [ ] **SLSA provenance level** assessed for critical dependencies (Level 1 minimum)
- [ ] **Build reproducibility**: same source produces same artifact (where ecosystem supports it)

## 5. Install Scripts & Runtime Hooks

- [ ] **Pre/post-install scripts** reviewed for all new dependencies
- [ ] **No obfuscated code** in install scripts
- [ ] **No network calls** in install scripts (downloading additional payloads)
- [ ] **No filesystem access** outside package directory in install scripts
- [ ] **`--ignore-scripts`** used during audit installs, scripts enabled only after review
- [ ] **Socket.dev or similar** used to detect suspicious package behavior

## 6. Maintainer & Repository Risk

- [ ] **Maintainer count** assessed: no single-maintainer packages for critical functionality
- [ ] **Repository activity**: no dependencies from repos dormant > 12 months without assessment
- [ ] **Ownership transfers** monitored: recent npm/PyPI transfers flagged for review
- [ ] **Published from CI**: packages published from CI (not developer laptops) preferred
- [ ] **2FA enabled** on maintainer accounts (for own published packages)
- [ ] **No deprecated packages**: `npm outdated` checked, deprecated packages replaced
- [ ] **Fork risk assessed**: if using a fork, diff reviewed against upstream

## 7. License Compliance

- [ ] **All dependencies have SPDX license identifiers**
- [ ] **No copyleft licenses** (GPL, AGPL, SSPL) in proprietary projects — or explicit legal approval obtained
- [ ] **No unlicensed packages** (NOASSERTION) — treated as all-rights-reserved
- [ ] **License compatibility matrix** reviewed against project license
- [ ] **Dual-licensed packages** have appropriate license selected and documented
- [ ] **License text** matches declared SPDX identifier (no bait-and-switch)
- [ ] **Attribution requirements** met: NOTICE file or third-party licenses bundled in distribution
- [ ] **CI check configured**: `license-checker --failOn "GPL-3.0;AGPL-3.0;SSPL-1.0"`

## 8. Version Pinning & Update Policy

- [ ] **Exact versions pinned** in production: `1.2.3` not `^1.2.3` or `~1.2.3`
- [ ] **Lockfile is the source of truth** for installed versions
- [ ] **Dependabot or Renovate** configured for automated update PRs
- [ ] **Major version updates** require changelog review and manual approval
- [ ] **Minor/patch updates** auto-merged only if CI passes (with appropriate test coverage)
- [ ] **Update PRs reviewed** for breaking changes before merge
- [ ] **Dependency update SLA**: security patches within vulnerability SLA, feature updates monthly

## 9. CI/CD Pipeline Integration

- [ ] **`npm audit --audit-level=high`** (or equivalent) runs in CI and fails the build
- [ ] **License check** runs in CI and fails on incompatible licenses
- [ ] **SBOM generation** is part of the release pipeline
- [ ] **`npm ci`** (not `npm install`) used in CI for deterministic builds
- [ ] **OSV Scanner** or **Grype** runs in CI as a secondary vulnerability check
- [ ] **Dependabot security alerts** are triaged within defined SLA
- [ ] **Branch protection** requires security checks to pass before merge
- [ ] **Artifact signing**: release artifacts are signed and verifiable

## 10. Incident Response

- [ ] **Incident playbook** exists for compromised dependency scenarios
- [ ] **Contact list** maintained for security-critical package maintainers
- [ ] **SBOM searchable**: can quickly answer "are we affected by CVE-YYYY-NNNNN?"
- [ ] **Rollback plan**: can revert to previous known-good dependency set via lockfile
- [ ] **Communication template** ready for notifying stakeholders of supply chain incidents
- [ ] **Post-incident review** process includes dependency audit as standard step

---

## Severity Classification

| Check Failure | Severity | Action |
|--------------|----------|--------|
| Critical CVE in direct dependency | Critical | Block release, patch within 24h |
| High CVE in direct dependency | High | Block merge, patch within 7d |
| Critical CVE in transitive dependency | High | Assess exploitability, patch or accept risk within 7d |
| GPL/AGPL in proprietary project | High | Remove dependency or obtain legal clearance |
| No lockfile committed | High | Add lockfile immediately, enforce in CI |
| Unlicensed dependency | Medium | Contact maintainer or replace package within 30d |
| Single-maintainer critical package | Medium | Identify alternative, document risk |
| Dormant dependency (> 12 months) | Medium | Assess alternatives, document risk acceptance |
| Typosquatting risk (similar name) | Medium | Verify publisher and package authenticity |
| Missing SBOM for release | Medium | Generate before next release |
| Outdated dependency (> 2 major versions behind) | Low | Schedule update in next sprint |

---

## References

- [OWASP Software Component Verification Standard (SCVS)](https://owasp.org/www-project-software-component-verification-standard/)
- [NIST Secure Software Development Framework (SSDF) SP 800-218](https://csrc.nist.gov/projects/ssdf)
- [SLSA Supply Chain Levels for Software Artifacts](https://slsa.dev/)
- [OpenSSF Scorecard](https://securityscorecards.dev/)
- [CycloneDX SBOM Specification](https://cyclonedx.org/)
- [SPDX License List](https://spdx.org/licenses/)
- [Google OSV (Open Source Vulnerabilities)](https://osv.dev/)
- [CISA Known Exploited Vulnerabilities Catalog](https://www.cisa.gov/known-exploited-vulnerabilities-catalog)
- [Socket.dev Documentation](https://socket.dev/docs)
- [npm Provenance](https://docs.npmjs.com/generating-provenance-statements)
