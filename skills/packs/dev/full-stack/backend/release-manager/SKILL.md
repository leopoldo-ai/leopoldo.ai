---
name: release-manager
description: "Use when managing semantic versioning, changelogs, release workflows, hotfix procedures, or release notes."
type: technique
---

# Release Manager

Ensures consistent, documented, and reliable releases. Covers semantic versioning, changelog generation from conventional commits, release branch workflows, hotfix procedures, and user-facing release notes.

## Role

Release manager ensuring every release follows semver strictly, has a complete changelog, is repeatable and automatable, and hotfixes reach production within 4 hours.

## 5-Phase Workflow

| Phase | Goal | Key Actions | Fallback |
|-------|------|-------------|----------|
| 1. Version Planning | Determine correct version | Review commits since last tag, identify breaking changes, verify migration docs | If uncertain, default to PATCH |
| 2. Changelog | Complete changelog entry | Categorize commits by type, write human-readable descriptions, include PR/issue refs | Review auto-generated entries before publishing |
| 3. Release Branch | Stabilize while unblocking main | Create `release/X.X.X` from main, only bug fixes allowed, max 2 weeks lifetime | If stabilization > 2 weeks, scope is too large |
| 4. Tag & Publish | Create immutable release artifact | Run tests+build+lint, annotated tag, push, merge to main, create GitHub Release | Never tag uncommitted/unpushed code |
| 5. Post-Release | Verify and prepare next cycle | Check monitoring dashboards, smoke tests, bump to next dev version, delete release branch | Rollback thresholds: PATCH 1h, MINOR 4h, MAJOR 24h |

## Semantic Versioning

**MAJOR.MINOR.PATCH** (e.g., `1.3.7`)

| Component | When to Increment |
|-----------|------------------|
| MAJOR | Incompatible API changes, removed features, breaking schema changes |
| MINOR | New backward-compatible functionality |
| PATCH | Backward-compatible bug fixes |

**Reset rules:** MAJOR resets MINOR+PATCH to 0. MINOR resets PATCH to 0.

**Pre-release stages:** `alpha` (internal, unstable) > `beta` (external, mostly stable) > `rc` (production-ready candidate) > release. Format: `2.0.0-alpha.1`.

**Build metadata:** `+build.42` or `+sha.a1b2c3d`. Ignored for precedence.

## Changelog

Follow [Keep a Changelog](https://keepachangelog.com/) format.

| Category | Commit Mapping | Version Bump |
|----------|---------------|:------------:|
| Breaking Changes | `BREAKING CHANGE:` footer | MAJOR |
| Added | `feat:` | MINOR |
| Fixed | `fix:` | PATCH |
| Performance | `perf:` | PATCH |
| Changed | `refactor:` (if user-visible) | - |
| Deprecated | `deprecate:` | - |
| Security | `fix:` with security context | PATCH |

**Auto-generation tools:** `standard-version` (maintenance mode), `release-please` (auto PR, human approval), `semantic-release` (fully automated, no approval).

| Feature | standard-version | release-please | semantic-release |
|---------|:---:|:---:|:---:|
| Human approval | Manual run | Merge PR | No |
| GitHub Release | No | Yes | Yes |
| npm publish | No | Plugin | Yes |
| Best for | Simple projects | Teams wanting approval | Fully automated pipelines |

## Hotfix Workflow

| Severity | Response Time | Deploy Deadline |
|----------|:---:|:---:|
| P0 (data loss, security, outage) | < 1 hour | < 4 hours |
| P1 (major feature broken) | < 4 hours | < 24 hours |
| P2 (degraded, workaround exists) | Next business day | Next release |

**Hotfix rules:**
- Always branch from the release tag, never from main
- Minimum viable fix only (no refactoring, no features)
- Must merge back to main AND any active release branch
- Post-mortem required for all P0 within 48 hours

## Deprecation Lifecycle

1. Feature deprecated (changelog + release notes + runtime warning)
2. Reminder in next release, warning on every call
3. Feature removed (MAJOR version bump)

**Minimum:** 1 MINOR version between deprecation and removal. Widely-used features: 2 MINOR versions or 3 months.

## Rules

1. Never skip the changelog. If not worth documenting, not worth releasing.
2. Always tag releases with annotated tags. Tags are immutable.
3. Hotfix within 4 hours for P0. No exceptions.
4. Breaking changes require a migration guide.
5. Deprecate before removing.
6. Release branches max 2 weeks.
7. Conventional commits mandatory. Enforce with commitlint + husky.
8. Never tag uncommitted or unpushed code.
9. One version source of truth (e.g., `package.json`).
10. Post-release verification is not optional.

## Anti-Patterns

| Anti-Pattern | Why It Fails | Do Instead |
|-------------|-------------|------------|
| Manual version bumps | Human error, inconsistency | Use automated tooling |
| Changelog as afterthought | Incomplete, users lose trust | Generate during release process |
| No migration guides | Users cannot upgrade | Write guide as part of breaking change PR |
| Hotfix on main instead of tag | Ships unreleased features | Branch from release tag |
| Long-lived release branches | Merge conflicts accumulate | Max 2 weeks, reduce scope |
| Skipping pre-releases for majors | Breaking changes hit production | Use alpha/beta/RC cycle |
| Tagging before tests pass | Broken release published | Full test suite before tag |
| Version 0.x.y forever | Users perceive instability | Move to 1.0.0 with stable API |
| Force-deleting tags | Breaks downstream caches | Create new PATCH release |
