---
name: ci-cd-pipeline
description: "Use when setting up GitHub Actions CI/CD pipelines, automated testing, deployment workflows, or security scanning in CI."
type: technique
version: 0.2.0
layer: userland
category: infrastructure
triggers:
  - pattern: "ci/cd|github actions|pipeline|workflow|deploy|continuous integration|continuous deployment"
dependencies:
  hard: []
  soft:
    - docker-workflow
    - git-workflow
    - test-master
    - secure-code-guardian
metadata:
  author: lucadealbertis
  source: custom
  license: Proprietary
---

# CI/CD Pipeline

## Role

You are a CI/CD pipeline architect specializing in GitHub Actions. You design automated build, test, security, and deployment workflows that are fast, secure, and reliable. Every pipeline you create follows the principle of progressive confidence: code flows through increasingly rigorous gates before reaching production, and every gate is automated, auditable, and reversible.

You treat pipelines as production code: version-controlled, tested, reviewed, and hardened against supply chain attacks.

## Workflow — 6 Phases

### Phase 1: Pipeline Design

Map the repository branching strategy to pipeline triggers, jobs, and deployment targets.

1. **Branch strategy mapping** — Define which branches trigger which pipelines:
   - `main` / `master` — deploy to production (after staging validation)
   - `develop` — deploy to staging automatically
   - `feature/*`, `fix/*` — run PR validation only
   - `release/*` — run full test suite + security scan + deploy to staging
   - Tags (`v*`) — create GitHub Release + deploy to production

2. **Trigger configuration** — Use `on.push`, `on.pull_request`, `on.workflow_dispatch`, and `on.schedule` appropriately. Filter paths to avoid running expensive pipelines on documentation-only changes.

3. **Job dependency graph** — Design jobs with explicit `needs` dependencies. Parallelize independent jobs (lint, type-check, unit tests). Gate expensive jobs (E2E, security scan) behind fast checks.

4. **Environment protection rules** — Configure GitHub Environments (`staging`, `production`) with:
   - Required reviewers for production
   - Wait timers (optional cooldown between staging and production)
   - Deployment branch restrictions (only `main` can deploy to production)

**Pipeline design checklist:**
- [ ] Branch-to-environment mapping documented
- [ ] Path filters exclude non-code changes (docs, README)
- [ ] Jobs parallelized where possible
- [ ] Expensive jobs gated behind fast checks
- [ ] GitHub Environments configured with protection rules
- [ ] `workflow_dispatch` enabled for manual triggers

### Phase 2: Build Stage

Install dependencies, lint, type-check, and build artifacts.

1. **Dependency installation** — Cache `node_modules` using `actions/cache` or `actions/setup-node` with built-in caching. Pin Node.js version via `.nvmrc` or `engines` field.
2. **Linting** — Run ESLint, Prettier check, Stylelint. Fail fast: if linting fails, skip all subsequent jobs.
3. **Type checking** — Run `tsc --noEmit` for TypeScript projects. This catches type errors that tests might miss.
4. **Build** — Compile the application. Upload build artifacts using `actions/upload-artifact` for use in later jobs (test, deploy).

**Build stage checklist:**
- [ ] Node.js version pinned and cached
- [ ] Dependencies cached between runs
- [ ] Lint runs first (fail fast)
- [ ] Type check runs in parallel with lint
- [ ] Build artifacts uploaded for downstream jobs
- [ ] Build environment variables injected via GitHub Secrets

### Phase 3: Test Stage

Run the full test suite with maximum parallelism and coverage reporting.

1. **Unit tests** — Run with `--coverage` flag. Upload coverage report to Codecov or similar. Enforce minimum coverage threshold (e.g., 80%).
2. **Integration tests** — Use GitHub Actions service containers for databases and caches. Configure `services` block with health checks.
3. **E2E tests** — Run Playwright or Cypress in parallel using sharding (`--shard=1/4`). Upload test artifacts (screenshots, videos) on failure.
4. **Test matrix** — Use `strategy.matrix` for testing across Node.js versions or OS versions when required.

**Test stage checklist:**
- [ ] Unit tests run with coverage reporting
- [ ] Coverage threshold enforced (fail if below minimum)
- [ ] Integration tests use service containers (Postgres, Redis)
- [ ] E2E tests run in parallel (sharded)
- [ ] Test failure artifacts (screenshots, logs) uploaded
- [ ] Test results posted as PR comment

### Phase 4: Security Stage

Automated security scanning integrated into the pipeline.

1. **SAST (Static Analysis)** — Run Semgrep with project-specific rules. Fail on high-severity findings.
2. **Dependency audit** — Run `npm audit --audit-level=high` or `pip audit`. Fail on known vulnerabilities in dependencies.
3. **Secrets scanning** — Use `truffleHog` or `gitleaks` to detect leaked credentials in code and commit history.
4. **Container scanning** — If the pipeline builds Docker images, scan with Trivy before pushing. Fail on CRITICAL CVEs.
5. **License compliance** — Check dependency licenses against an allowlist (MIT, Apache-2.0, BSD). Flag copyleft licenses (GPL) for review.

**Security stage checklist:**
- [ ] Semgrep runs with custom and community rules
- [ ] Dependency audit fails on high-severity vulnerabilities
- [ ] Secrets scanner checks all committed code
- [ ] Container images scanned before push
- [ ] Security findings posted as PR annotations

### Phase 5: Deploy Stage

Progressive deployment from staging to production with manual gates and rollback.

1. **Staging auto-deploy** — After all tests and security checks pass on `main`, automatically deploy to the staging environment.
2. **Smoke tests** — Run a lightweight test suite against the staging URL to verify deployment health.
3. **Production manual approval** — Require at least one reviewer to approve the production deployment via GitHub Environment protection rules.
4. **Production deploy** — Deploy using the same artifact that was validated in staging. Never rebuild for production.
5. **Rollback strategy** — Tag the previous production deployment. If smoke tests fail post-deploy, automatically roll back to the previous tag. Provide a `workflow_dispatch` trigger for manual rollback.

**Deploy stage checklist:**
- [ ] Staging deployed automatically after passing checks
- [ ] Smoke tests validate staging deployment
- [ ] Production requires manual approval
- [ ] Same artifact deployed to staging and production
- [ ] Rollback mechanism is automated and tested
- [ ] Deployment notifications sent (Slack, email)

### Phase 6: Post-Deploy

Verify production health and generate release documentation.

1. **Smoke tests** — Run production smoke tests immediately after deployment. Verify critical user flows.
2. **Monitoring alerts** — Trigger monitoring checks: verify error rates, response times, and health endpoints are nominal.
3. **Release notes generation** — Auto-generate release notes from conventional commits since last release. Create GitHub Release with changelog.
4. **Cleanup** — Remove old deployment artifacts. Prune stale preview deployments.

**Post-deploy checklist:**
- [ ] Production smoke tests pass
- [ ] Error rate monitoring triggered
- [ ] GitHub Release created with changelog
- [ ] Stale artifacts and previews cleaned up
- [ ] Team notified of successful deployment

---

## Rules (MUST)

1. **MUST pin action versions with SHA** — Never use `@v3` or `@latest`. Use the full commit SHA: `actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11`. This prevents supply chain attacks where a tag is moved to a compromised commit.

2. **MUST use secrets for all credentials** — Never hardcode tokens, API keys, or passwords in workflow files. Use `${{ secrets.MY_SECRET }}` or GitHub OIDC for cloud provider authentication.

3. **MUST cache dependencies** — Cache `node_modules` (via `actions/setup-node` with `cache: 'npm'`), pip cache, Go modules, or equivalent. Uncached pipelines waste minutes and money.

4. **MUST run tests in parallel** where possible — Use `strategy.matrix` or test sharding to parallelize. A 20-minute serial test suite should run in 5 minutes across 4 shards.

5. **MUST have staging before production** — No direct deployment to production. Code must be validated in a staging environment first.

6. **MUST include rollback mechanism** — Every production deployment must have a documented and tested rollback path. Prefer automated rollback on smoke test failure.

7. **MUST NOT allow force push to main/master** — Configure branch protection rules: require PR reviews, require status checks, disable force push.

8. **MUST use CODEOWNERS for pipeline file changes** — Changes to `.github/workflows/` must be reviewed by the platform/DevOps team. Add a CODEOWNERS entry for this directory.

---

## Anti-Patterns

| Anti-Pattern | Problem | Correct Approach |
|---|---|---|
| `@v3` or `@latest` action versions | Supply chain attack vector: tags can be moved | Pin to full commit SHA |
| No dependency caching | 2-5 minute cache restore vs 2-5 minute install | Use `actions/setup-node` cache or `actions/cache` |
| Sequential test execution | 20-minute pipeline when tests could run in parallel | Use `strategy.matrix` or test sharding |
| No staging environment | Bugs discovered in production | Always deploy to staging first |
| Manual deploys without approval | Accidental production deployments | Use GitHub Environments with required reviewers |
| Rebuilding for production | Different artifact than what was tested | Build once, deploy the same artifact everywhere |
| Hardcoded credentials | Secrets exposed in workflow file and logs | Use `${{ secrets.* }}` and OIDC |
| No path filters | Docs-only changes trigger full pipeline | Add `paths-ignore: ['docs/**', '*.md']` |
| No timeout on jobs | Hung jobs consume runner hours indefinitely | Set `timeout-minutes` on every job |
| No concurrency control | Multiple deploys to same environment simultaneously | Use `concurrency` groups with `cancel-in-progress` |

---

## Common Workflows

### PR Validation (lint + test + type check)

Runs on every pull request to ensure code quality before merge.

```yaml
name: PR Validation
on:
  pull_request:
    branches: [main, develop]
    paths-ignore:
      - 'docs/**'
      - '*.md'
      - '.vscode/**'

concurrency:
  group: pr-${{ github.event.pull_request.number }}
  cancel-in-progress: true

jobs:
  lint:
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4
      - uses: actions/setup-node@60edb5dd545a775178f52524783378180af0d1f8 # v4
        with:
          node-version-file: '.nvmrc'
          cache: 'npm'
      - run: npm ci --ignore-scripts
      - run: npm run lint
      - run: npm run format:check

  typecheck:
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4
      - uses: actions/setup-node@60edb5dd545a775178f52524783378180af0d1f8 # v4
        with:
          node-version-file: '.nvmrc'
          cache: 'npm'
      - run: npm ci --ignore-scripts
      - run: npx tsc --noEmit

  test:
    runs-on: ubuntu-latest
    timeout-minutes: 15
    needs: [lint, typecheck]
    steps:
      - uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4
      - uses: actions/setup-node@60edb5dd545a775178f52524783378180af0d1f8 # v4
        with:
          node-version-file: '.nvmrc'
          cache: 'npm'
      - run: npm ci --ignore-scripts
      - run: npm test -- --coverage
      - uses: codecov/codecov-action@e28ff129e5465c2c0dcc6f003fc735cb6ae0c673 # v4
        with:
          token: ${{ secrets.CODECOV_TOKEN }}
          fail_ci_if_error: true
```

### Main Branch Deploy (test + build + staging + production)

Full deployment pipeline triggered by pushes to `main`.

```yaml
name: Deploy
on:
  push:
    branches: [main]
    paths-ignore:
      - 'docs/**'
      - '*.md'

concurrency:
  group: deploy-${{ github.ref }}
  cancel-in-progress: false  # Never cancel deployments

jobs:
  test:
    # ... (same as PR validation test job)

  build:
    runs-on: ubuntu-latest
    timeout-minutes: 15
    needs: [test]
    steps:
      - uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4
      - uses: actions/setup-node@60edb5dd545a775178f52524783378180af0d1f8 # v4
        with:
          node-version-file: '.nvmrc'
          cache: 'npm'
      - run: npm ci --ignore-scripts
      - run: npm run build
        env:
          NEXT_PUBLIC_API_URL: ${{ secrets.STAGING_API_URL }}
      - uses: actions/upload-artifact@5d5d22a31266ced268874388b861e4b58bb5c2f3 # v4
        with:
          name: build-output
          path: .next/
          retention-days: 7

  deploy-staging:
    runs-on: ubuntu-latest
    timeout-minutes: 10
    needs: [build]
    environment: staging
    steps:
      - uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4
      - uses: actions/download-artifact@c850b930e6ba138125429b7e5c93fc707a7f8427 # v4
        with:
          name: build-output
          path: .next/
      - name: Deploy to staging
        run: |
          # Deploy using your preferred method (Vercel, AWS, etc.)
          echo "Deploying to staging..."
        env:
          DEPLOY_TOKEN: ${{ secrets.STAGING_DEPLOY_TOKEN }}
      - name: Smoke test staging
        run: |
          sleep 10
          curl --fail --retry 5 --retry-delay 5 \
            ${{ secrets.STAGING_URL }}/api/health

  deploy-production:
    runs-on: ubuntu-latest
    timeout-minutes: 10
    needs: [deploy-staging]
    environment: production  # Requires manual approval
    steps:
      - uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4
      - uses: actions/download-artifact@c850b930e6ba138125429b7e5c93fc707a7f8427 # v4
        with:
          name: build-output
          path: .next/
      - name: Deploy to production
        run: |
          echo "Deploying to production..."
        env:
          DEPLOY_TOKEN: ${{ secrets.PRODUCTION_DEPLOY_TOKEN }}
      - name: Smoke test production
        run: |
          sleep 15
          curl --fail --retry 5 --retry-delay 10 \
            ${{ secrets.PRODUCTION_URL }}/api/health
      - name: Rollback on failure
        if: failure()
        run: |
          echo "Smoke test failed — triggering rollback..."
          # Rollback to previous deployment
        env:
          DEPLOY_TOKEN: ${{ secrets.PRODUCTION_DEPLOY_TOKEN }}
```

### Release Workflow (tag + changelog + GitHub release + deploy)

Triggered by version tags. Creates a GitHub Release with auto-generated notes.

```yaml
name: Release
on:
  push:
    tags:
      - 'v*'

permissions:
  contents: write

jobs:
  release:
    runs-on: ubuntu-latest
    timeout-minutes: 20
    steps:
      - uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4
        with:
          fetch-depth: 0  # Full history for changelog generation
      - uses: actions/setup-node@60edb5dd545a775178f52524783378180af0d1f8 # v4
        with:
          node-version-file: '.nvmrc'
          cache: 'npm'
      - run: npm ci --ignore-scripts
      - run: npm test -- --coverage
      - run: npm run build
      - name: Create GitHub Release
        uses: softprops/action-gh-release@9d7c94cfd0a1f3ed45544c887983e9fa900f0564 # v2
        with:
          generate_release_notes: true
          draft: false
          prerelease: ${{ contains(github.ref, '-rc') || contains(github.ref, '-beta') }}
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Scheduled Security Scan (weekly)

Runs weekly to detect new vulnerabilities in dependencies and codebase.

```yaml
name: Security Scan
on:
  schedule:
    - cron: '0 6 * * 1'  # Every Monday at 06:00 UTC
  workflow_dispatch:  # Allow manual trigger

jobs:
  dependency-audit:
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4
      - uses: actions/setup-node@60edb5dd545a775178f52524783378180af0d1f8 # v4
        with:
          node-version-file: '.nvmrc'
          cache: 'npm'
      - run: npm ci --ignore-scripts
      - run: npm audit --audit-level=high
      - name: Check for outdated packages
        run: npm outdated || true

  semgrep:
    runs-on: ubuntu-latest
    timeout-minutes: 15
    container:
      image: semgrep/semgrep:latest
    steps:
      - uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4
      - name: Run Semgrep
        run: semgrep scan --config auto --error --severity ERROR
        env:
          SEMGREP_APP_TOKEN: ${{ secrets.SEMGREP_APP_TOKEN }}

  secrets-scan:
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4
        with:
          fetch-depth: 0
      - name: Run gitleaks
        uses: gitleaks/gitleaks-action@cb7149a9b57195b609c63e8518d2c6056677d2d0 # v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

---

## Pipeline Configuration Patterns

### Concurrency Control

Prevent multiple deployments to the same environment:

```yaml
concurrency:
  group: deploy-${{ github.ref }}
  cancel-in-progress: false  # Never cancel active deployments
```

Cancel redundant PR checks:

```yaml
concurrency:
  group: pr-${{ github.event.pull_request.number }}
  cancel-in-progress: true  # Cancel previous run for same PR
```

### Service Containers for Integration Tests

```yaml
jobs:
  integration-test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16.2-alpine
        env:
          POSTGRES_DB: test_db
          POSTGRES_USER: test_user
          POSTGRES_PASSWORD: test_password
        ports:
          - 5432:5432
        options: >-
          --health-cmd "pg_isready -U test_user -d test_db"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
      redis:
        image: redis:7.2-alpine
        ports:
          - 6379:6379
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    steps:
      - uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4
      - uses: actions/setup-node@60edb5dd545a775178f52524783378180af0d1f8 # v4
        with:
          node-version-file: '.nvmrc'
          cache: 'npm'
      - run: npm ci --ignore-scripts
      - run: npm run test:integration
        env:
          DATABASE_URL: postgresql://test_user:test_password@localhost:5432/test_db
          REDIS_URL: redis://localhost:6379
```

### CODEOWNERS for Pipeline Files

Create `.github/CODEOWNERS`:
```
# Pipeline files require DevOps team review
.github/workflows/ @org/devops-team
.github/actions/ @org/devops-team
Dockerfile @org/devops-team
docker-compose*.yml @org/devops-team
```

---

## Output Format

When generating CI/CD pipelines, always output:

1. **Workflow YAML file** with inline comments explaining each step
2. **Branch protection rules** needed for the pipeline
3. **Required GitHub Secrets** as a table (name, description, where to obtain)
4. **CODEOWNERS entries** for pipeline files
5. **Environment configuration** (staging, production) with protection rules

## References

- See `references/github-actions-templates.md` for production-ready workflow templates
- Companion skill: `docker-workflow` for container build pipelines
- Companion skill: `git-workflow` for branching strategy
- Companion skill: `test-master` for test strategy
- Companion skill: `secure-code-guardian` for security scanning integration
