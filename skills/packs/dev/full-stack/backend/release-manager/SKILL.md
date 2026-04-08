---
name: release-manager
description: Semantic versioning, changelog generation, release workflows, hotfix procedures, release notes
version: 0.2.0
layer: userland
category: development
triggers:
  - pattern: "release|version|changelog|semver|hotfix|tag|release notes"
dependencies:
  hard: []
  soft:
    - git-workflow
    - ci-cd-pipeline
metadata:
  author: lucadealbertis
  source: custom
  license: Proprietary
---

# Release Manager

Ensures consistent, documented, and reliable releases. Covers semantic versioning, changelog generation from conventional commits, release branch workflows, hotfix procedures, and user-facing release notes.

---

## Table of Contents

- [Role](#role)
- [5-Phase Workflow](#5-phase-workflow)
  - [Phase 1: Version Planning](#phase-1-version-planning)
  - [Phase 2: Changelog](#phase-2-changelog)
  - [Phase 3: Release Branch](#phase-3-release-branch)
  - [Phase 4: Tag and Publish](#phase-4-tag--publish)
  - [Phase 5: Post-Release](#phase-5-post-release)
- [Semantic Versioning](#semantic-versioning)
- [Changelog](#changelog)
- [Release Types](#release-types)
- [Release Notes](#release-notes)
- [Tooling](#tooling)
- [Rules](#rules)
- [Anti-Patterns](#anti-patterns)
- [Quick Reference](#quick-reference)

---

## Role

You are a release manager ensuring:
- Every release follows semantic versioning strictly
- Every release has a complete, accurate changelog
- Release processes are repeatable and automatable
- Hotfixes reach production within 4 hours of critical issue detection
- Breaking changes are communicated with migration guides
- Deprecations follow a predictable lifecycle

You coordinate between development, QA, and operations to deliver reliable software releases that users and downstream consumers can depend on.

---

## 5-Phase Workflow

### Phase 1: Version Planning

**Goal:** Determine the correct version number for the upcoming release.

**Decision tree:**

```
What changed since the last release?

├── Public API removed or changed incompatibly?
│   └── YES → MAJOR version bump (X.0.0)
│
├── New functionality added (backward-compatible)?
│   └── YES → MINOR version bump (0.X.0)
│
├── Bug fixes only (backward-compatible)?
│   └── YES → PATCH version bump (0.0.X)
│
└── No functional changes (docs, CI, refactoring)?
    └── Usually no release needed. If releasing: PATCH.
```

**Version planning checklist:**

- [ ] Review all commits since last release tag
- [ ] Identify any breaking changes (API changes, removed features, schema migrations)
- [ ] Check for new features vs bug fixes
- [ ] Verify all breaking changes have migration documentation
- [ ] Confirm all deprecation notices are updated
- [ ] Determine version number using semver rules
- [ ] Set target release date

---

### Phase 2: Changelog

**Goal:** Generate a complete, accurate changelog entry for the release.

See the [Changelog](#changelog) section for format and automation details.

**Process:**

1. Collect all commits since the last release tag:
   ```bash
   git log v1.2.0..HEAD --oneline --no-merges
   ```

2. Categorize by type (from conventional commit prefix):
   - `feat:` → Added
   - `fix:` → Fixed
   - `perf:` → Performance
   - `refactor:` → Changed (if user-visible) or omit
   - `docs:` → Documentation (optional in changelog)
   - `BREAKING CHANGE:` → Breaking Changes (always first)
   - `deprecate:` or deprecated in body → Deprecated

3. Write human-readable descriptions (not raw commit messages)

4. Include issue/PR references where applicable

---

### Phase 3: Release Branch

**Goal:** Stabilize the release candidate while unblocking development on main.

**Workflow:**

```
main ─────────────────────────────────────────────────
       │                                    ↑
       ├─ release/1.3.0 ──(fixes)──(RC)────┤
       │                                    │
       │                                    └─ merge back to main
       │
       └─ (development continues on main)
```

**Steps:**

```bash
# 1. Create release branch from main
git checkout main
git pull origin main
git checkout -b release/1.3.0

# 2. Bump version in package.json (or equivalent)
npm version 1.3.0 --no-git-tag-version
# OR manually update version files

# 3. Update CHANGELOG.md with the new entry
# (see Changelog section)

# 4. Commit version bump + changelog
git add package.json CHANGELOG.md
git commit -m "chore(release): prepare v1.3.0"

# 5. Only bug fixes allowed on release branch from this point
# No new features. Fix-forward only.

# 6. If fixes are needed:
git commit -m "fix(auth): resolve token refresh race condition"

# 7. When stable, proceed to Phase 4
```

**Rules for release branches:**
- Only bug fixes and documentation updates allowed after creation
- No new features, no refactoring
- Every fix on the release branch must be cherry-picked or merged back to main
- Release branch lifetime: maximum 2 weeks (if it takes longer, your scope is too large)

---

### Phase 4: Tag & Publish

**Goal:** Create the immutable release artifact.

**Steps:**

```bash
# 1. Final checks
npm run test
npm run build
npm run lint

# 2. Create annotated tag
git tag -a v1.3.0 -m "Release v1.3.0

See CHANGELOG.md for details."

# 3. Push release branch and tag
git push origin release/1.3.0
git push origin v1.3.0

# 4. Merge release branch to main
git checkout main
git merge release/1.3.0 --no-ff -m "chore: merge release/1.3.0 into main"
git push origin main

# 5. Create GitHub Release
gh release create v1.3.0 \
  --title "v1.3.0" \
  --notes-file RELEASE_NOTES.md \
  --latest

# 6. Delete release branch (optional, after merge)
git branch -d release/1.3.0
git push origin --delete release/1.3.0
```

**Tag rules:**
- Always use annotated tags (`-a`), never lightweight tags
- Tag format: `v` prefix + semver (e.g., `v1.3.0`, `v2.0.0-beta.1`)
- Tag message should reference the changelog
- Tags are immutable: never delete and recreate a tag that has been pushed
- Sign tags with GPG when available (`git tag -s`)

---

### Phase 5: Post-Release

**Goal:** Verify the release and prepare for the next cycle.

**Checklist:**

- [ ] GitHub Release published with release notes
- [ ] Deployment to production successful (or staged rollout initiated)
- [ ] Monitoring dashboards checked (error rates, latency, key metrics)
- [ ] Smoke tests passed on production
- [ ] Release announcement sent (if applicable)
- [ ] Version bumped on main to next development version (e.g., `1.4.0-dev`)
- [ ] Release branch deleted (after merge to main)
- [ ] Retrospective scheduled (for major releases)

**Post-release monitoring window:**

| Release Type | Monitoring Period | Rollback Threshold |
|-------------|:-----------------:|-------------------|
| PATCH | 1 hour | Error rate > 1% above baseline |
| MINOR | 4 hours | Error rate > 0.5% above baseline, or key metric regression |
| MAJOR | 24 hours | Any regression in key metrics |

---

## Semantic Versioning

### MAJOR.MINOR.PATCH

Format: `MAJOR.MINOR.PATCH` (e.g., `1.3.7`)

| Component | When to Increment | Example |
|-----------|------------------|---------|
| **MAJOR** | Incompatible API changes, removed features, breaking schema changes | `1.3.7` -> `2.0.0` |
| **MINOR** | New functionality added in a backward-compatible manner | `1.3.7` -> `1.4.0` |
| **PATCH** | Backward-compatible bug fixes | `1.3.7` -> `1.3.8` |

**Reset rules:**
- When MAJOR increments: MINOR and PATCH reset to 0
- When MINOR increments: PATCH resets to 0
- PATCH never resets MINOR or MAJOR

### Pre-Release Versions

Format: `MAJOR.MINOR.PATCH-<pre-release>` (e.g., `2.0.0-alpha.1`)

| Stage | Format | Purpose | Stability |
|-------|--------|---------|-----------|
| Alpha | `2.0.0-alpha.1` | Internal testing, feature-incomplete | Unstable, breaking changes expected |
| Beta | `2.0.0-beta.1` | External testing, feature-complete | Mostly stable, minor changes possible |
| Release Candidate | `2.0.0-rc.1` | Final testing, production-ready candidate | Stable, only critical fixes |

**Pre-release precedence (lowest to highest):**
```
2.0.0-alpha.1 < 2.0.0-alpha.2 < 2.0.0-beta.1 < 2.0.0-beta.2 < 2.0.0-rc.1 < 2.0.0-rc.2 < 2.0.0
```

**Rules:**
- Pre-release versions have lower precedence than the release version
- Increment the numeric identifier for successive pre-releases: `alpha.1`, `alpha.2`, etc.
- Moving from alpha to beta to rc resets the numeric identifier

### Build Metadata

Format: `MAJOR.MINOR.PATCH+<build>` (e.g., `1.3.7+build.42`)

- Build metadata is appended with `+` sign
- Ignored for version precedence (1.0.0+build.1 = 1.0.0+build.2)
- Used for CI build numbers, git SHA references, timestamps
- Examples: `1.3.7+20260303`, `1.3.7+build.42`, `1.3.7+sha.a1b2c3d`

### Combined Format

```
2.0.0-rc.1+build.42

  2         = MAJOR
  .0        = MINOR
  .0        = PATCH
  -rc.1     = pre-release (release candidate 1)
  +build.42 = build metadata (CI build number 42)
```

---

## Changelog

### Keep a Changelog Format

Follow the [Keep a Changelog](https://keepachangelog.com/) specification.

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- New feature description (#PR)

## [1.3.0] - 2026-03-03

### Breaking Changes
- `getUserById()` now returns `null` instead of throwing when user not found (#142)
  - **Migration:** Replace `try/catch` blocks with null checks. See [migration guide](docs/migrations/v1.3.0.md).

### Added
- User profile avatars with automatic resizing (#138)
- Bulk export of contacts to CSV (#140)
- Rate limiting on public API endpoints (#141)

### Fixed
- Token refresh race condition causing intermittent 401 errors (#135)
- CSV import failing silently on malformed UTF-8 (#136)
- Dashboard chart tooltip positioning on mobile (#137)

### Changed
- Upgraded Next.js from 14.1 to 14.2 (#139)
- Improved error messages for validation failures (#143)

### Deprecated
- `GET /api/users?search=` parameter — use `GET /api/users?q=` instead. Will be removed in v2.0.0.

### Security
- Patched XSS vulnerability in markdown renderer (#144)

## [1.2.0] - 2026-02-15

### Added
- ...

## [1.1.0] - 2026-01-28

### Added
- ...

[Unreleased]: https://github.com/org/repo/compare/v1.3.0...HEAD
[1.3.0]: https://github.com/org/repo/compare/v1.2.0...v1.3.0
[1.2.0]: https://github.com/org/repo/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/org/repo/releases/tag/v1.1.0
```

### Changelog Categories

| Category | When to Use | Conventional Commit Mapping |
|----------|------------|----------------------------|
| **Breaking Changes** | Always first if present; incompatible changes | `BREAKING CHANGE:` in commit footer |
| **Added** | New features or capabilities | `feat:` |
| **Fixed** | Bug fixes | `fix:` |
| **Changed** | Changes to existing functionality | `refactor:` (if user-visible), `perf:` |
| **Deprecated** | Features that will be removed in future | `deprecate:` or noted in commit body |
| **Removed** | Features removed in this release | Removed features |
| **Security** | Vulnerability fixes | `fix:` with security context |

### Auto-Generation from Conventional Commits

When using conventional commits consistently, the changelog can be auto-generated:

```bash
# Using standard-version
npx standard-version

# Using conventional-changelog CLI
npx conventional-changelog -p angular -i CHANGELOG.md -s

# Using release-please (GitHub Action)
# Automatically creates and maintains a Release PR with changelog
```

**Rules for auto-generated changelogs:**
- Always review auto-generated entries before publishing
- Rewrite commit messages that are too terse or developer-focused into user-friendly descriptions
- Group related commits into single changelog entries when appropriate
- Add context that the commit message alone does not convey

---

## Release Types

### Scheduled Releases

**Cadence options:**

| Cadence | Best For | Example |
|---------|----------|---------|
| Weekly | Fast-moving SaaS products | Every Tuesday |
| Biweekly | Teams balancing speed and stability | Every other Thursday |
| Monthly | Enterprise products, APIs with external consumers | First Monday of month |
| Quarterly | Products with compliance/audit requirements | Q1/Q2/Q3/Q4 |

**Scheduled release process:**
1. Feature freeze: 2-3 days before release date
2. Release branch creation: day of feature freeze
3. QA and bug fixes on release branch
4. Release on scheduled date
5. Post-release verification

### Feature Releases

For significant new features that warrant their own release outside the regular schedule.

**Process:**
1. Feature development on feature branch (merged to main)
2. When feature is complete and tested, create release
3. Version bump: MINOR (new feature) or MAJOR (breaking feature)
4. Full release workflow (branch, changelog, tag, publish)

### Hotfix Releases

**Definition:** An emergency fix for a critical issue in production.

**Criticality criteria:**

| Severity | Response Time | Examples |
|----------|:------------:|---------|
| P0 — Critical | < 1 hour to start, < 4 hours to deploy | Data loss, security breach, complete outage |
| P1 — High | < 4 hours to start, < 24 hours to deploy | Major feature broken, significant data integrity issue |
| P2 — Medium | Next business day | Degraded performance, workaround available |

**Hotfix workflow:**

```
main ──────────────────────────────────────────
  │                                    ↑
  │                                    │ merge hotfix
  │                                    │
  v1.3.0 ─── hotfix/1.3.1 ───(fix)───(tag v1.3.1)
```

```bash
# 1. Create hotfix branch FROM the release tag (not from main)
git checkout v1.3.0
git checkout -b hotfix/1.3.1

# 2. Apply the fix
# ... make changes ...
git add [specific files]
git commit -m "fix(auth): patch token validation bypass (CVE-2026-XXXX)"

# 3. Run tests
npm run test
npm run build

# 4. Update version and changelog
npm version 1.3.1 --no-git-tag-version
# Update CHANGELOG.md with hotfix entry
git add package.json CHANGELOG.md
git commit -m "chore(release): prepare v1.3.1 hotfix"

# 5. Tag and push
git tag -a v1.3.1 -m "Hotfix v1.3.1 — fix token validation bypass"
git push origin hotfix/1.3.1
git push origin v1.3.1

# 6. Create GitHub Release
gh release create v1.3.1 \
  --title "v1.3.1 (Hotfix)" \
  --notes "## Security Fix
- Patched token validation bypass (CVE-2026-XXXX)

**Severity:** Critical
**Impact:** All users on v1.3.0
**Action required:** Update immediately" \
  --latest

# 7. Merge hotfix back to main
git checkout main
git merge hotfix/1.3.1 --no-ff -m "chore: merge hotfix/1.3.1 into main"
git push origin main

# 8. If a release branch exists, merge there too
git checkout release/1.4.0
git merge hotfix/1.3.1 --no-ff -m "chore: merge hotfix/1.3.1 into release/1.4.0"

# 9. Clean up
git branch -d hotfix/1.3.1
git push origin --delete hotfix/1.3.1
```

**Hotfix rules:**
- Always branch from the tag, never from main
- Minimum viable fix only (no refactoring, no feature additions)
- Must be merged back to both main AND any active release branch
- P0 hotfixes deploy within 4 hours, no exceptions
- Post-mortem required for all P0 hotfixes within 48 hours

---

## Release Notes

### User-Facing Release Notes

Release notes differ from changelogs: they are written for end users, not developers.

**Template:**

```markdown
# Release Notes — v1.3.0

**Release date:** March 3, 2026

## Highlights

Brief paragraph (2-3 sentences) summarizing the most important changes in
this release and why they matter to users.

## New Features

### User Profile Avatars
You can now upload a profile photo that appears across the platform. Avatars
are automatically resized and optimized for fast loading.

### Bulk Contact Export
Export your entire contact list to CSV with a single click. Includes all
custom fields and tags.

## Improvements

- **Faster API responses** — Public API endpoints are now rate-limited for
  consistent performance under load.
- **Better error messages** — Validation errors now include specific field
  names and suggestions.

## Bug Fixes

- Fixed an issue where sessions could expire prematurely during long operations.
- Fixed CSV imports failing silently when files contained special characters.
- Fixed dashboard chart tooltips overlapping on small screens.

## Breaking Changes

### `getUserById()` Return Value Changed
**Previously:** Threw an error when user was not found.
**Now:** Returns `null` when user was not found.

**Why:** This change makes the API consistent with other lookup methods and
eliminates unnecessary try/catch blocks.

**Migration steps:**
1. Search your codebase for `getUserById` calls wrapped in try/catch
2. Replace the catch block with a null check
3. See the [full migration guide](docs/migrations/v1.3.0.md) for examples

## Deprecations

- **`GET /api/users?search=` parameter** — Use `?q=` instead. The `search`
  parameter will be removed in v2.0.0 (estimated Q3 2026).

## Security

- Patched a cross-site scripting (XSS) vulnerability in the markdown
  renderer. All users are advised to update.
```

### Breaking Changes Migration Guide

For every breaking change, provide a dedicated migration guide:

```markdown
# Migration Guide: v1.2.x to v1.3.0

## Breaking Change: `getUserById()` return value

### What Changed
In v1.2.x, `getUserById(id)` threw a `UserNotFoundError` when no user
matched the provided ID. In v1.3.0, it returns `null` instead.

### Why
This aligns `getUserById` with the behavior of `getOrganizationById`,
`getContactById`, and other lookup methods, which already return `null`
for missing entities. The previous throwing behavior was inconsistent and
required unnecessary try/catch boilerplate.

### Before (v1.2.x)
```typescript
try {
  const user = await getUserById(userId);
  // use user
} catch (error) {
  if (error instanceof UserNotFoundError) {
    // handle missing user
  }
}
```

### After (v1.3.0)
```typescript
const user = await getUserById(userId);
if (!user) {
  // handle missing user
}
```

### Migration Steps
1. Search for all `getUserById` calls: `grep -r "getUserById" src/`
2. For each call site, check if it is wrapped in try/catch for
   `UserNotFoundError`
3. Replace the try/catch with a null check
4. Remove imports of `UserNotFoundError` if no longer used
5. Run tests to verify: `npm run test`

### Estimated Effort
- Small codebase (< 10 call sites): 15-30 minutes
- Medium codebase (10-50 call sites): 1-2 hours
- Large codebase (50+ call sites): use a codemod (see below)

### Automated Codemod
```bash
npx jscodeshift -t codemods/getUserById-null-check.ts src/
```
```

### Deprecation Notices

**Deprecation lifecycle:**

```
v1.3.0 — Feature deprecated (announced in changelog + release notes)
         Runtime warning emitted when deprecated feature is used
         Migration guide published
         ↓
v1.4.0 — Reminder in release notes
         Warning upgraded to console.warn on every call
         ↓
v2.0.0 — Feature removed (MAJOR version bump)
         Breaking change documented in migration guide
```

**Rules:**
- Minimum 1 MINOR version between deprecation and removal
- For widely-used features: minimum 2 MINOR versions or 3 months, whichever is longer
- Always provide an alternative before deprecating
- Emit runtime warnings for deprecated features

---

## Tooling

### standard-version

**What it does:** Bumps version, generates changelog, creates git tag — all from conventional commits.

```bash
# Install
npm install --save-dev standard-version

# Standard release
npx standard-version

# Pre-release
npx standard-version --prerelease alpha   # 1.3.0 → 1.4.0-alpha.0
npx standard-version --prerelease beta    # 1.4.0-alpha.0 → 1.4.0-beta.0
npx standard-version --prerelease rc      # 1.4.0-beta.0 → 1.4.0-rc.0

# Force specific version type
npx standard-version --release-as major   # → 2.0.0
npx standard-version --release-as minor   # → 1.4.0
npx standard-version --release-as patch   # → 1.3.1

# Dry run (preview without changes)
npx standard-version --dry-run
```

**Configuration (.versionrc.json):**

```json
{
  "types": [
    { "type": "feat", "section": "Added" },
    { "type": "fix", "section": "Fixed" },
    { "type": "perf", "section": "Performance" },
    { "type": "refactor", "section": "Changed", "hidden": false },
    { "type": "docs", "hidden": true },
    { "type": "style", "hidden": true },
    { "type": "chore", "hidden": true },
    { "type": "test", "hidden": true },
    { "type": "ci", "hidden": true }
  ],
  "commitUrlFormat": "https://github.com/{{owner}}/{{repository}}/commit/{{hash}}",
  "compareUrlFormat": "https://github.com/{{owner}}/{{repository}}/compare/{{previousTag}}...{{currentTag}}"
}
```

**Note:** standard-version is in maintenance mode. For new projects, consider release-please or semantic-release.

### release-please (Google)

**What it does:** GitHub Action that creates and maintains a Release PR automatically. When merged, it creates the tag and GitHub Release.

```yaml
# .github/workflows/release-please.yml
name: Release Please

on:
  push:
    branches:
      - main

permissions:
  contents: write
  pull-requests: write

jobs:
  release-please:
    runs-on: ubuntu-latest
    steps:
      - uses: googleapis/release-please-action@v4
        with:
          release-type: node
          token: ${{ secrets.GITHUB_TOKEN }}
```

**Key benefits:**
- Automatically creates and updates a "Release PR" with changelog
- Only creates a release when the PR is merged (human approval)
- Supports monorepos
- No local tooling required

### semantic-release

**What it does:** Fully automated versioning and package publishing based on conventional commits.

```yaml
# .github/workflows/release.yml
name: Release

on:
  push:
    branches:
      - main

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: actions/setup-node@v4
        with:
          node-version: 20
      - run: npm ci
      - run: npx semantic-release
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          NPM_TOKEN: ${{ secrets.NPM_TOKEN }}
```

**Configuration (.releaserc.json):**

```json
{
  "branches": ["main"],
  "plugins": [
    "@semantic-release/commit-analyzer",
    "@semantic-release/release-notes-generator",
    "@semantic-release/changelog",
    "@semantic-release/npm",
    "@semantic-release/github",
    [
      "@semantic-release/git",
      {
        "assets": ["package.json", "CHANGELOG.md"],
        "message": "chore(release): ${nextRelease.version} [skip ci]"
      }
    ]
  ]
}
```

**Key benefits:**
- Fully automated (no human intervention needed)
- Determines version bump automatically from commits
- Publishes to npm and GitHub Releases
- Extensible with plugins

**Trade-off:** No human review before release. Use release-please if you want a manual approval step.

### GitHub Releases API

```bash
# Create a release
gh release create v1.3.0 \
  --title "v1.3.0" \
  --notes-file RELEASE_NOTES.md \
  --latest

# Create a pre-release
gh release create v2.0.0-beta.1 \
  --title "v2.0.0 Beta 1" \
  --notes "Beta release for testing. Not recommended for production." \
  --prerelease

# Upload release assets
gh release upload v1.3.0 dist/app-1.3.0.tar.gz dist/app-1.3.0.zip

# List releases
gh release list --limit 10

# View a specific release
gh release view v1.3.0

# Edit release notes
gh release edit v1.3.0 --notes-file UPDATED_RELEASE_NOTES.md

# Delete a release (use with caution)
gh release delete v1.3.0 --yes
```

### Tool Comparison

| Feature | standard-version | release-please | semantic-release |
|---------|:----------------:|:--------------:|:----------------:|
| Automation level | Semi-auto (local CLI) | Auto (GitHub PR) | Fully auto (CI) |
| Human approval | Yes (manual run) | Yes (merge PR) | No |
| Changelog generation | Yes | Yes | Yes (plugin) |
| npm publish | No | Plugin | Yes |
| GitHub Release | No | Yes | Yes |
| Monorepo support | Limited | Yes | Plugin |
| Maintenance status | Maintenance mode | Active | Active |
| Best for | Simple projects, local workflow | Teams wanting approval | Fully automated pipelines |

---

## Rules

1. **Never skip the changelog.** Every release, no matter how small, must have a changelog entry. If a release is not worth documenting, it is not worth releasing.

2. **Always tag releases.** Every release gets an annotated git tag. Tags are the source of truth for what code is in production.

3. **Hotfix within 4 hours for critical issues.** P0 issues (data loss, security breach, complete outage) must have a fix deployed within 4 hours. No exceptions for process or meetings.

4. **Breaking changes require a migration guide.** You cannot bump MAJOR without providing a documented path for consumers to update their code.

5. **Deprecate before removing.** Features must be deprecated for at least 1 MINOR version before removal. Widely-used features get at least 2 MINOR versions or 3 months.

6. **Release branches are short-lived.** Maximum 2 weeks. If stabilization takes longer, the scope is too large — split the release.

7. **Conventional commits are mandatory.** The release toolchain depends on structured commit messages. Enforce with commitlint and husky.

8. **Never tag uncommitted or unpushed code.** Tags must be created on committed, tested, and pushed code only.

9. **One version source of truth.** Version number lives in exactly one place (e.g., `package.json`). All other references derive from it.

10. **Post-release verification is not optional.** Every release must be verified in production with smoke tests and monitoring checks within the monitoring window.

---

## Anti-Patterns

| Anti-Pattern | Why It Fails | What to Do Instead |
|-------------|-------------|-------------------|
| Manual version bumps | Human error, inconsistency, forgotten updates | Use automated tooling (standard-version, release-please, semantic-release) |
| Changelog as afterthought | Incomplete, inaccurate, or missing entries; users lose trust | Generate changelog during release process, review before publishing |
| No migration guides for breaking changes | Users cannot upgrade; they stay on old versions or leave | Write migration guide as part of the breaking change PR, not after |
| Hotfix on main instead of from tag | Main may contain unreleased features; hotfix ships unintended changes | Always branch hotfixes from the release tag |
| Long-lived release branches | Merge conflicts accumulate; divergence from main increases risk | Maximum 2 weeks; reduce release scope if stabilization takes longer |
| Skipping pre-releases for major versions | Users discover breaking changes in production | Use alpha/beta/RC cycle for all MAJOR releases |
| Tagging before tests pass | Broken release published; tag must be deleted or superseded | Run full test suite and build before creating the tag |
| No post-release monitoring | Regressions go undetected for hours or days | Define monitoring window and rollback thresholds per release type |
| Version 0.x.y forever | Users perceive the product as unstable; semver rules do not apply below 1.0 | Move to 1.0.0 when you have a stable public API |
| Force-deleting and recreating tags | Breaks downstream caches, package managers, and consumer references | If a tag is wrong, create a new PATCH release with the fix |

---

## Quick Reference

### Version Bump Decision

```
Breaking change?  → MAJOR (X.0.0)
New feature?      → MINOR (0.X.0)
Bug fix?          → PATCH (0.0.X)
```

### Release Checklist (copy-paste)

```markdown
## Release Checklist — v[X.X.X]

### Preparation
- [ ] All target PRs merged to main
- [ ] Version number determined (semver rules)
- [ ] Breaking changes identified and migration guides written
- [ ] Deprecation notices updated

### Changelog & Branch
- [ ] Release branch created: `release/X.X.X`
- [ ] Version bumped in package.json
- [ ] CHANGELOG.md updated with all changes
- [ ] Release notes drafted (user-facing)
- [ ] Version bump + changelog committed

### Validation
- [ ] All tests passing
- [ ] Build succeeds
- [ ] Lint clean
- [ ] Smoke tests on staging/preview

### Publish
- [ ] Annotated tag created: `vX.X.X`
- [ ] Tag pushed to origin
- [ ] Release branch merged to main
- [ ] GitHub Release created with release notes
- [ ] Release branch deleted

### Post-Release
- [ ] Production deployment verified
- [ ] Monitoring checked (error rates, latency)
- [ ] Smoke tests passed on production
- [ ] Announcement sent (if applicable)
- [ ] Main bumped to next development version
```

### Conventional Commit to Changelog Mapping

```
feat:     → Added      → MINOR bump
fix:      → Fixed      → PATCH bump
perf:     → Performance → PATCH bump
refactor: → Changed    → (usually no bump unless user-visible)
docs:     → (hidden)   → (no bump)
chore:    → (hidden)   → (no bump)
test:     → (hidden)   → (no bump)
ci:       → (hidden)   → (no bump)

BREAKING CHANGE: → Breaking Changes → MAJOR bump (overrides all above)
```

### Hotfix Decision Tree

```
Is production broken?
├── Data loss or security breach (P0)?
│   └── START HOTFIX NOW. Deploy within 4 hours.
├── Major feature broken, no workaround (P1)?
│   └── Start hotfix within 4 hours. Deploy within 24 hours.
├── Degraded but functional, workaround exists (P2)?
│   └── Fix in next scheduled release. Document workaround.
└── Cosmetic or minor (P3)?
    └── Add to backlog. Fix when convenient.
```

---

## Validation Checklist

### Versioning
- [ ] Version follows semver strictly (MAJOR.MINOR.PATCH)
- [ ] MAJOR bumped for any breaking change
- [ ] MINOR bumped for new features (backward-compatible)
- [ ] PATCH bumped for bug fixes only
- [ ] Pre-release labels used for unstable versions

### Changelog
- [ ] CHANGELOG.md follows Keep a Changelog format
- [ ] All changes categorized correctly (Added, Fixed, Changed, etc.)
- [ ] Breaking changes listed first with migration references
- [ ] PR/issue references included
- [ ] Comparison links at bottom of file

### Release Process
- [ ] Release branch created (not releasing directly from main)
- [ ] Only bug fixes on release branch after creation
- [ ] Annotated tag created with meaningful message
- [ ] Tag matches version in package.json
- [ ] GitHub Release published with release notes
- [ ] Hotfix merged back to main AND active release branches

### Communication
- [ ] Release notes written for end users (not just developers)
- [ ] Breaking changes have dedicated migration guides
- [ ] Deprecation notices include removal timeline and alternative
- [ ] Security fixes reference CVE if applicable
