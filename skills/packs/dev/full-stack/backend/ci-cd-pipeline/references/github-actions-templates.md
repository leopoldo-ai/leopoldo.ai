# GitHub Actions Templates — Production Ready

Four production-grade GitHub Actions workflow templates. Each template follows the rules defined in the `ci-cd-pipeline` skill: SHA-pinned actions, secrets management, dependency caching, parallel execution, staging gates, and rollback mechanisms.

---

## Template 1: Full-Stack Next.js Pipeline

Complete CI/CD pipeline for a Next.js application with TypeScript, Postgres, and Docker deployment.

```yaml
# =============================================================================
# Full-Stack Next.js CI/CD Pipeline
# Triggers: PR validation, main branch deploy, release tags
# Stack: Next.js 14+, TypeScript, PostgreSQL, Docker
# =============================================================================

name: CI/CD Pipeline

on:
  pull_request:
    branches: [main, develop]
    paths-ignore:
      - 'docs/**'
      - '*.md'
      - '.vscode/**'
      - 'LICENSE'
  push:
    branches: [main]
    paths-ignore:
      - 'docs/**'
      - '*.md'
  push:
    tags:
      - 'v*'

# Cancel redundant runs for PRs; never cancel deployments
concurrency:
  group: ${{ github.workflow }}-${{ github.event.pull_request.number || github.ref }}
  cancel-in-progress: ${{ github.event_name == 'pull_request' }}

env:
  NODE_VERSION: '20'
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

permissions:
  contents: read
  packages: write
  pull-requests: write
  security-events: write

jobs:
  # ---------------------------------------------------------------------------
  # Stage 1: Fast checks (parallel)
  # ---------------------------------------------------------------------------
  lint:
    name: Lint & Format
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - name: Checkout code
        uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4.1.1

      - name: Setup Node.js with cache
        uses: actions/setup-node@60edb5dd545a775178f52524783378180af0d1f8 # v4.0.2
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'

      - name: Install dependencies
        run: npm ci --ignore-scripts

      - name: Run ESLint
        run: npx eslint . --format=json --output-file=eslint-report.json || true

      - name: Run ESLint (fail on errors)
        run: npx eslint .

      - name: Check formatting
        run: npx prettier --check "**/*.{ts,tsx,js,jsx,json,css,md}"

  typecheck:
    name: Type Check
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - name: Checkout code
        uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4.1.1

      - name: Setup Node.js with cache
        uses: actions/setup-node@60edb5dd545a775178f52524783378180af0d1f8 # v4.0.2
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'

      - name: Install dependencies
        run: npm ci --ignore-scripts

      - name: Run TypeScript compiler
        run: npx tsc --noEmit --pretty

  # ---------------------------------------------------------------------------
  # Stage 2: Unit tests (after fast checks pass)
  # ---------------------------------------------------------------------------
  unit-test:
    name: Unit Tests
    runs-on: ubuntu-latest
    timeout-minutes: 15
    needs: [lint, typecheck]
    steps:
      - name: Checkout code
        uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4.1.1

      - name: Setup Node.js with cache
        uses: actions/setup-node@60edb5dd545a775178f52524783378180af0d1f8 # v4.0.2
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'

      - name: Install dependencies
        run: npm ci --ignore-scripts

      - name: Run unit tests with coverage
        run: npm test -- --coverage --coverageReporters=lcov --coverageReporters=text-summary

      - name: Upload coverage to Codecov
        if: always()
        uses: codecov/codecov-action@e28ff129e5465c2c0dcc6f003fc735cb6ae0c673 # v4.5.0
        with:
          token: ${{ secrets.CODECOV_TOKEN }}
          file: ./coverage/lcov.info
          fail_ci_if_error: false

      - name: Enforce coverage threshold
        run: |
          COVERAGE=$(npx istanbul-cobertura-coverage-threshold --threshold 80 || echo "FAIL")
          if [ "$COVERAGE" = "FAIL" ]; then
            echo "::error::Coverage below 80% threshold"
            exit 1
          fi

  # ---------------------------------------------------------------------------
  # Stage 3: Integration tests (with service containers)
  # ---------------------------------------------------------------------------
  integration-test:
    name: Integration Tests
    runs-on: ubuntu-latest
    timeout-minutes: 20
    needs: [lint, typecheck]
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
      - name: Checkout code
        uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4.1.1

      - name: Setup Node.js with cache
        uses: actions/setup-node@60edb5dd545a775178f52524783378180af0d1f8 # v4.0.2
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'

      - name: Install dependencies
        run: npm ci --ignore-scripts

      - name: Run database migrations
        run: npx drizzle-kit push
        env:
          DATABASE_URL: postgresql://test_user:test_password@localhost:5432/test_db

      - name: Run integration tests
        run: npm run test:integration
        env:
          DATABASE_URL: postgresql://test_user:test_password@localhost:5432/test_db
          REDIS_URL: redis://localhost:6379
          NODE_ENV: test

  # ---------------------------------------------------------------------------
  # Stage 4: E2E tests (sharded for speed)
  # ---------------------------------------------------------------------------
  e2e-test:
    name: E2E Tests (Shard ${{ matrix.shard }})
    runs-on: ubuntu-latest
    timeout-minutes: 30
    needs: [unit-test, integration-test]
    if: github.event_name == 'push' || github.event.pull_request.draft == false
    strategy:
      fail-fast: false
      matrix:
        shard: [1, 2, 3, 4]
    steps:
      - name: Checkout code
        uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4.1.1

      - name: Setup Node.js with cache
        uses: actions/setup-node@60edb5dd545a775178f52524783378180af0d1f8 # v4.0.2
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'

      - name: Install dependencies
        run: npm ci --ignore-scripts

      - name: Install Playwright browsers
        run: npx playwright install --with-deps chromium

      - name: Build application
        run: npm run build
        env:
          NEXT_PUBLIC_API_URL: http://localhost:3000

      - name: Run E2E tests (shard ${{ matrix.shard }}/4)
        run: npx playwright test --shard=${{ matrix.shard }}/4
        env:
          CI: true

      - name: Upload test artifacts on failure
        if: failure()
        uses: actions/upload-artifact@5d5d22a31266ced268874388b861e4b58bb5c2f3 # v4.3.1
        with:
          name: playwright-report-shard-${{ matrix.shard }}
          path: |
            playwright-report/
            test-results/
          retention-days: 7

  # ---------------------------------------------------------------------------
  # Stage 5: Security scanning
  # ---------------------------------------------------------------------------
  security:
    name: Security Scan
    runs-on: ubuntu-latest
    timeout-minutes: 15
    needs: [lint]
    steps:
      - name: Checkout code
        uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4.1.1
        with:
          fetch-depth: 0  # Full history for secrets scanning

      - name: Setup Node.js with cache
        uses: actions/setup-node@60edb5dd545a775178f52524783378180af0d1f8 # v4.0.2
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'

      - name: Install dependencies
        run: npm ci --ignore-scripts

      - name: Dependency audit
        run: npm audit --audit-level=high

      - name: Run Semgrep
        uses: semgrep/semgrep-action@713efdd6e81b5950027b01e1d1ef5765d39c7688 # v1
        with:
          config: >-
            p/javascript
            p/typescript
            p/nextjs
            p/react
            p/owasp-top-ten
          generateSarif: true
        env:
          SEMGREP_APP_TOKEN: ${{ secrets.SEMGREP_APP_TOKEN }}

      - name: Upload SARIF results
        if: always()
        uses: github/codeql-action/upload-sarif@1b1aada464948af03b950897e5eb522f92603cc2 # v3
        with:
          sarif_file: semgrep.sarif

      - name: Run gitleaks (secrets detection)
        uses: gitleaks/gitleaks-action@cb7149a9b57195b609c63e8518d2c6056677d2d0 # v2.3.4
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

  # ---------------------------------------------------------------------------
  # Stage 6: Build Docker image
  # ---------------------------------------------------------------------------
  build-image:
    name: Build & Push Docker Image
    runs-on: ubuntu-latest
    timeout-minutes: 20
    needs: [unit-test, integration-test, security]
    if: github.event_name == 'push' && (github.ref == 'refs/heads/main' || startsWith(github.ref, 'refs/tags/v'))
    outputs:
      image-tag: ${{ steps.meta.outputs.tags }}
      image-digest: ${{ steps.build.outputs.digest }}
    steps:
      - name: Checkout code
        uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4.1.1

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@f95db51fddba0c2d1ec667646a06c2ce06100226 # v3.0.0

      - name: Login to GitHub Container Registry
        uses: docker/login-action@343f7c4344506bcbf9b4de18042ae17996df046d # v3.0.0
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extract Docker metadata
        id: meta
        uses: docker/metadata-action@8e5442c4ef9f78752691e2d8f8d19755c6f78e81 # v5.5.1
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}
            type=sha,prefix=sha-
            type=raw,value=latest,enable={{is_default_branch}}

      - name: Build and push Docker image
        id: build
        uses: docker/build-push-action@4a13e500e55cf31b7a5d59a38ab2040ab0f42f56 # v5.1.0
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
          platforms: linux/amd64,linux/arm64

      - name: Scan image with Trivy
        uses: aquasecurity/trivy-action@d710d95c29280dd0bb5a5fb58a8e9b6d0d88d0de # v0.18.0
        with:
          image-ref: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:sha-${{ github.sha }}
          format: 'sarif'
          output: 'trivy-results.sarif'
          severity: 'CRITICAL,HIGH'
          exit-code: '1'

      - name: Upload Trivy SARIF
        if: always()
        uses: github/codeql-action/upload-sarif@1b1aada464948af03b950897e5eb522f92603cc2 # v3
        with:
          sarif_file: trivy-results.sarif

  # ---------------------------------------------------------------------------
  # Stage 7: Deploy to staging
  # ---------------------------------------------------------------------------
  deploy-staging:
    name: Deploy to Staging
    runs-on: ubuntu-latest
    timeout-minutes: 15
    needs: [build-image, e2e-test]
    if: github.ref == 'refs/heads/main'
    environment: staging
    steps:
      - name: Checkout code
        uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4.1.1

      - name: Deploy to staging
        run: |
          echo "Deploying image ${{ needs.build-image.outputs.image-tag }} to staging..."
          # Replace with your deployment method:
          # - kubectl set image deployment/app app=$IMAGE
          # - aws ecs update-service --cluster staging --service app --force-new-deployment
          # - vercel deploy --prod --token=$VERCEL_TOKEN
        env:
          DEPLOY_TOKEN: ${{ secrets.STAGING_DEPLOY_TOKEN }}

      - name: Wait for deployment to stabilize
        run: sleep 30

      - name: Run smoke tests against staging
        run: |
          echo "Running smoke tests against staging..."
          curl --fail --retry 5 --retry-delay 10 --retry-all-errors \
            "${{ secrets.STAGING_URL }}/api/health"
          curl --fail --retry 3 --retry-delay 5 \
            "${{ secrets.STAGING_URL }}/" -o /dev/null -w "%{http_code}"

  # ---------------------------------------------------------------------------
  # Stage 8: Deploy to production (manual approval required)
  # ---------------------------------------------------------------------------
  deploy-production:
    name: Deploy to Production
    runs-on: ubuntu-latest
    timeout-minutes: 15
    needs: [deploy-staging]
    if: github.ref == 'refs/heads/main'
    environment: production  # Requires manual approval via GitHub UI
    steps:
      - name: Checkout code
        uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4.1.1

      - name: Record pre-deploy state for rollback
        id: pre-deploy
        run: |
          echo "previous-tag=$(git describe --tags --abbrev=0 2>/dev/null || echo 'none')" >> $GITHUB_OUTPUT

      - name: Deploy to production
        run: |
          echo "Deploying to production..."
        env:
          DEPLOY_TOKEN: ${{ secrets.PRODUCTION_DEPLOY_TOKEN }}

      - name: Wait for deployment to stabilize
        run: sleep 30

      - name: Run production smoke tests
        id: smoke
        run: |
          curl --fail --retry 5 --retry-delay 10 --retry-all-errors \
            "${{ secrets.PRODUCTION_URL }}/api/health"

      - name: Rollback on smoke test failure
        if: failure() && steps.smoke.outcome == 'failure'
        run: |
          echo "::error::Production smoke tests failed! Rolling back to ${{ steps.pre-deploy.outputs.previous-tag }}"
          # Replace with your rollback method
        env:
          DEPLOY_TOKEN: ${{ secrets.PRODUCTION_DEPLOY_TOKEN }}

      - name: Notify team
        if: always()
        run: |
          STATUS="${{ job.status }}"
          if [ "$STATUS" = "success" ]; then
            echo "Production deployment successful"
          else
            echo "::error::Production deployment failed — check logs"
          fi
```

**Required GitHub Secrets:**

| Secret | Description | Where to obtain |
|--------|-------------|-----------------|
| `CODECOV_TOKEN` | Codecov upload token | codecov.io dashboard |
| `SEMGREP_APP_TOKEN` | Semgrep CI token | semgrep.dev/manage/settings |
| `STAGING_DEPLOY_TOKEN` | Deployment token for staging | Your hosting provider |
| `STAGING_URL` | Staging environment URL | e.g., `https://staging.example.com` |
| `PRODUCTION_DEPLOY_TOKEN` | Deployment token for production | Your hosting provider |
| `PRODUCTION_URL` | Production environment URL | e.g., `https://example.com` |

---

## Template 2: Python FastAPI Pipeline

CI/CD pipeline for Python FastAPI applications with Poetry, pytest, and Docker.

```yaml
# =============================================================================
# Python FastAPI CI/CD Pipeline
# Stack: Python 3.12, FastAPI, Poetry, PostgreSQL, Docker
# =============================================================================

name: Python CI/CD

on:
  pull_request:
    branches: [main]
    paths-ignore:
      - 'docs/**'
      - '*.md'
  push:
    branches: [main]
    tags:
      - 'v*'

concurrency:
  group: ${{ github.workflow }}-${{ github.event.pull_request.number || github.ref }}
  cancel-in-progress: ${{ github.event_name == 'pull_request' }}

env:
  PYTHON_VERSION: '3.12'
  POETRY_VERSION: '1.8.2'
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

permissions:
  contents: read
  packages: write
  security-events: write

jobs:
  # ---------------------------------------------------------------------------
  # Quality checks (parallel)
  # ---------------------------------------------------------------------------
  lint:
    name: Lint & Format
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4.1.1

      - name: Setup Python
        uses: actions/setup-python@0a5c61591373683505ea898e09a3ea4f39ef2b9c # v5.0.0
        with:
          python-version: ${{ env.PYTHON_VERSION }}

      - name: Install Poetry
        run: pip install poetry==${{ env.POETRY_VERSION }}

      - name: Cache Poetry virtualenv
        uses: actions/cache@0c45773b623bea8c8e75f6c82b208c3cf94ea4f9 # v4.0.2
        with:
          path: ~/.cache/pypoetry/virtualenvs
          key: poetry-${{ runner.os }}-${{ env.PYTHON_VERSION }}-${{ hashFiles('poetry.lock') }}
          restore-keys: |
            poetry-${{ runner.os }}-${{ env.PYTHON_VERSION }}-

      - name: Install dependencies
        run: poetry install --no-interaction

      - name: Run ruff (linter)
        run: poetry run ruff check .

      - name: Run ruff (formatter check)
        run: poetry run ruff format --check .

      - name: Run mypy (type checking)
        run: poetry run mypy app/ --ignore-missing-imports

  test:
    name: Tests
    runs-on: ubuntu-latest
    timeout-minutes: 20
    needs: [lint]
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
      - uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4.1.1

      - name: Setup Python
        uses: actions/setup-python@0a5c61591373683505ea898e09a3ea4f39ef2b9c # v5.0.0
        with:
          python-version: ${{ env.PYTHON_VERSION }}

      - name: Install Poetry
        run: pip install poetry==${{ env.POETRY_VERSION }}

      - name: Cache Poetry virtualenv
        uses: actions/cache@0c45773b623bea8c8e75f6c82b208c3cf94ea4f9 # v4.0.2
        with:
          path: ~/.cache/pypoetry/virtualenvs
          key: poetry-${{ runner.os }}-${{ env.PYTHON_VERSION }}-${{ hashFiles('poetry.lock') }}

      - name: Install dependencies
        run: poetry install --no-interaction

      - name: Run database migrations
        run: poetry run alembic upgrade head
        env:
          DATABASE_URL: postgresql://test_user:test_password@localhost:5432/test_db

      - name: Run tests with coverage
        run: |
          poetry run pytest \
            --cov=app \
            --cov-report=xml:coverage.xml \
            --cov-report=term-summary \
            --cov-fail-under=80 \
            -v --tb=short
        env:
          DATABASE_URL: postgresql://test_user:test_password@localhost:5432/test_db
          REDIS_URL: redis://localhost:6379
          ENVIRONMENT: test

      - name: Upload coverage
        if: always()
        uses: codecov/codecov-action@e28ff129e5465c2c0dcc6f003fc735cb6ae0c673 # v4.5.0
        with:
          token: ${{ secrets.CODECOV_TOKEN }}
          file: coverage.xml

  security:
    name: Security Scan
    runs-on: ubuntu-latest
    timeout-minutes: 15
    needs: [lint]
    steps:
      - uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4.1.1
        with:
          fetch-depth: 0

      - name: Setup Python
        uses: actions/setup-python@0a5c61591373683505ea898e09a3ea4f39ef2b9c # v5.0.0
        with:
          python-version: ${{ env.PYTHON_VERSION }}

      - name: Install Poetry
        run: pip install poetry==${{ env.POETRY_VERSION }}

      - name: Install dependencies
        run: poetry install --no-interaction

      - name: Run pip-audit (dependency vulnerabilities)
        run: poetry run pip-audit --strict --desc

      - name: Run bandit (Python security linter)
        run: poetry run bandit -r app/ -c pyproject.toml -f json -o bandit-report.json || true

      - name: Run Semgrep
        uses: semgrep/semgrep-action@713efdd6e81b5950027b01e1d1ef5765d39c7688 # v1
        with:
          config: >-
            p/python
            p/flask
            p/django
            p/owasp-top-ten
        env:
          SEMGREP_APP_TOKEN: ${{ secrets.SEMGREP_APP_TOKEN }}

      - name: Run gitleaks
        uses: gitleaks/gitleaks-action@cb7149a9b57195b609c63e8518d2c6056677d2d0 # v2.3.4
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

  # ---------------------------------------------------------------------------
  # Build & deploy (main branch only)
  # ---------------------------------------------------------------------------
  build-and-deploy:
    name: Build & Deploy
    runs-on: ubuntu-latest
    timeout-minutes: 20
    needs: [test, security]
    if: github.event_name == 'push' && (github.ref == 'refs/heads/main' || startsWith(github.ref, 'refs/tags/v'))
    steps:
      - uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4.1.1

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@f95db51fddba0c2d1ec667646a06c2ce06100226 # v3.0.0

      - name: Login to GHCR
        uses: docker/login-action@343f7c4344506bcbf9b4de18042ae17996df046d # v3.0.0
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@8e5442c4ef9f78752691e2d8f8d19755c6f78e81 # v5.5.1
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=semver,pattern={{version}}
            type=sha,prefix=sha-
            type=raw,value=latest,enable={{is_default_branch}}

      - name: Build and push
        uses: docker/build-push-action@4a13e500e55cf31b7a5d59a38ab2040ab0f42f56 # v5.1.0
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

      - name: Scan with Trivy
        uses: aquasecurity/trivy-action@d710d95c29280dd0bb5a5fb58a8e9b6d0d88d0de # v0.18.0
        with:
          image-ref: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:sha-${{ github.sha }}
          severity: 'CRITICAL,HIGH'
          exit-code: '1'
```

---

## Template 3: Monorepo Pipeline (Turborepo / Nx)

Pipeline for monorepo projects with selective job execution based on changed packages.

```yaml
# =============================================================================
# Monorepo CI/CD Pipeline (Turborepo)
# Runs only affected packages based on file changes
# =============================================================================

name: Monorepo CI

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

concurrency:
  group: ${{ github.workflow }}-${{ github.event.pull_request.number || github.ref }}
  cancel-in-progress: ${{ github.event_name == 'pull_request' }}

env:
  NODE_VERSION: '20'
  TURBO_TOKEN: ${{ secrets.TURBO_TOKEN }}
  TURBO_TEAM: ${{ secrets.TURBO_TEAM }}

permissions:
  contents: read
  pull-requests: write

jobs:
  # ---------------------------------------------------------------------------
  # Determine affected packages
  # ---------------------------------------------------------------------------
  detect-changes:
    name: Detect Changes
    runs-on: ubuntu-latest
    timeout-minutes: 5
    outputs:
      packages: ${{ steps.filter.outputs.changes }}
      web-changed: ${{ steps.filter.outputs.web }}
      api-changed: ${{ steps.filter.outputs.api }}
      shared-changed: ${{ steps.filter.outputs.shared }}
    steps:
      - uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4.1.1

      - name: Detect changed paths
        uses: dorny/paths-filter@de90cc6fb38fc0963ad72b210f1f284cd68cea36 # v3.0.2
        id: filter
        with:
          filters: |
            web:
              - 'apps/web/**'
              - 'packages/ui/**'
              - 'packages/shared/**'
            api:
              - 'apps/api/**'
              - 'packages/shared/**'
              - 'packages/database/**'
            shared:
              - 'packages/**'

  # ---------------------------------------------------------------------------
  # Quality checks (always run)
  # ---------------------------------------------------------------------------
  quality:
    name: Quality Checks
    runs-on: ubuntu-latest
    timeout-minutes: 15
    steps:
      - uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4.1.1

      - uses: actions/setup-node@60edb5dd545a775178f52524783378180af0d1f8 # v4.0.2
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'

      - run: npm ci --ignore-scripts

      # Turborepo runs lint, typecheck, and test only for affected packages
      - name: Lint affected packages
        run: npx turbo lint --filter='...[origin/main]'

      - name: Type check affected packages
        run: npx turbo typecheck --filter='...[origin/main]'

  # ---------------------------------------------------------------------------
  # Test web app (only if web changed)
  # ---------------------------------------------------------------------------
  test-web:
    name: Test Web App
    runs-on: ubuntu-latest
    timeout-minutes: 20
    needs: [detect-changes, quality]
    if: needs.detect-changes.outputs.web-changed == 'true'
    steps:
      - uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4.1.1

      - uses: actions/setup-node@60edb5dd545a775178f52524783378180af0d1f8 # v4.0.2
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'

      - run: npm ci --ignore-scripts

      - name: Run web tests
        run: npx turbo test --filter=web -- --coverage

      - name: Build web app
        run: npx turbo build --filter=web
        env:
          NEXT_PUBLIC_API_URL: ${{ secrets.STAGING_API_URL }}

  # ---------------------------------------------------------------------------
  # Test API (only if API changed)
  # ---------------------------------------------------------------------------
  test-api:
    name: Test API
    runs-on: ubuntu-latest
    timeout-minutes: 20
    needs: [detect-changes, quality]
    if: needs.detect-changes.outputs.api-changed == 'true'
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
    steps:
      - uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4.1.1

      - uses: actions/setup-node@60edb5dd545a775178f52524783378180af0d1f8 # v4.0.2
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'

      - run: npm ci --ignore-scripts

      - name: Run API tests
        run: npx turbo test --filter=api -- --coverage
        env:
          DATABASE_URL: postgresql://test_user:test_password@localhost:5432/test_db

  # ---------------------------------------------------------------------------
  # Deploy (main branch, after all tests pass)
  # ---------------------------------------------------------------------------
  deploy:
    name: Deploy
    runs-on: ubuntu-latest
    timeout-minutes: 15
    needs: [test-web, test-api]
    if: |
      always() &&
      github.event_name == 'push' &&
      github.ref == 'refs/heads/main' &&
      !contains(needs.*.result, 'failure')
    strategy:
      matrix:
        include:
          - app: web
            changed: ${{ needs.detect-changes.outputs.web-changed }}
          - app: api
            changed: ${{ needs.detect-changes.outputs.api-changed }}
    steps:
      - name: Skip if not changed
        if: matrix.changed != 'true'
        run: echo "Skipping deploy for ${{ matrix.app }} — no changes detected"

      - uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4.1.1
        if: matrix.changed == 'true'

      - name: Deploy ${{ matrix.app }}
        if: matrix.changed == 'true'
        run: |
          echo "Deploying ${{ matrix.app }} to staging..."
        env:
          DEPLOY_TOKEN: ${{ secrets.STAGING_DEPLOY_TOKEN }}
```

---

## Template 4: Scheduled Maintenance Pipeline

Weekly security scans, dependency updates, and health checks.

```yaml
# =============================================================================
# Scheduled Maintenance Pipeline
# Runs weekly: security scan, dependency check, license audit
# =============================================================================

name: Scheduled Maintenance

on:
  schedule:
    # Every Monday at 06:00 UTC
    - cron: '0 6 * * 1'
  workflow_dispatch:
    inputs:
      scan-type:
        description: 'Type of scan to run'
        required: true
        default: 'all'
        type: choice
        options:
          - all
          - security
          - dependencies
          - licenses

permissions:
  contents: read
  security-events: write
  issues: write

env:
  NODE_VERSION: '20'

jobs:
  # ---------------------------------------------------------------------------
  # Dependency vulnerability scan
  # ---------------------------------------------------------------------------
  dependency-audit:
    name: Dependency Audit
    runs-on: ubuntu-latest
    timeout-minutes: 10
    if: >-
      github.event.inputs.scan-type == 'all' ||
      github.event.inputs.scan-type == 'dependencies' ||
      github.event_name == 'schedule'
    steps:
      - uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4.1.1

      - uses: actions/setup-node@60edb5dd545a775178f52524783378180af0d1f8 # v4.0.2
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'

      - run: npm ci --ignore-scripts

      - name: Run npm audit
        id: audit
        run: |
          npm audit --json > audit-report.json 2>&1 || true
          CRITICAL=$(cat audit-report.json | jq '.metadata.vulnerabilities.critical // 0')
          HIGH=$(cat audit-report.json | jq '.metadata.vulnerabilities.high // 0')
          echo "critical=$CRITICAL" >> $GITHUB_OUTPUT
          echo "high=$HIGH" >> $GITHUB_OUTPUT
          echo "## Dependency Audit Results" >> $GITHUB_STEP_SUMMARY
          echo "- Critical: $CRITICAL" >> $GITHUB_STEP_SUMMARY
          echo "- High: $HIGH" >> $GITHUB_STEP_SUMMARY

      - name: Check for outdated packages
        run: |
          echo "## Outdated Packages" >> $GITHUB_STEP_SUMMARY
          npm outdated --json > outdated.json 2>&1 || true
          cat outdated.json | jq -r 'to_entries[] | "- \(.key): \(.value.current) -> \(.value.latest)"' >> $GITHUB_STEP_SUMMARY

      - name: Create issue if critical vulnerabilities found
        if: steps.audit.outputs.critical > 0 || steps.audit.outputs.high > 0
        uses: actions/github-script@60a0d83039c74a4aee543508d2ffcb1c3799cdea # v7.0.1
        with:
          script: |
            const critical = ${{ steps.audit.outputs.critical }};
            const high = ${{ steps.audit.outputs.high }};
            await github.rest.issues.create({
              owner: context.repo.owner,
              repo: context.repo.repo,
              title: `[Security] ${critical} critical, ${high} high dependency vulnerabilities`,
              body: `## Automated Security Scan\n\nThe weekly dependency audit found:\n- **${critical}** critical vulnerabilities\n- **${high}** high vulnerabilities\n\nRun \`npm audit\` locally for details.\n\n---\n*This issue was created automatically by the scheduled maintenance pipeline.*`,
              labels: ['security', 'automated', 'dependencies']
            });

  # ---------------------------------------------------------------------------
  # Static analysis (Semgrep)
  # ---------------------------------------------------------------------------
  semgrep:
    name: Semgrep Scan
    runs-on: ubuntu-latest
    timeout-minutes: 20
    if: >-
      github.event.inputs.scan-type == 'all' ||
      github.event.inputs.scan-type == 'security' ||
      github.event_name == 'schedule'
    container:
      image: semgrep/semgrep:latest
    steps:
      - uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4.1.1

      - name: Run Semgrep full scan
        run: |
          semgrep scan \
            --config auto \
            --config p/owasp-top-ten \
            --config p/javascript \
            --config p/typescript \
            --sarif --output semgrep-results.sarif \
            --error --severity ERROR \
            --metrics=off
        env:
          SEMGREP_APP_TOKEN: ${{ secrets.SEMGREP_APP_TOKEN }}

      - name: Upload SARIF
        if: always()
        uses: github/codeql-action/upload-sarif@1b1aada464948af03b950897e5eb522f92603cc2 # v3
        with:
          sarif_file: semgrep-results.sarif

  # ---------------------------------------------------------------------------
  # Secrets scanning
  # ---------------------------------------------------------------------------
  secrets-scan:
    name: Secrets Scan
    runs-on: ubuntu-latest
    timeout-minutes: 10
    if: >-
      github.event.inputs.scan-type == 'all' ||
      github.event.inputs.scan-type == 'security' ||
      github.event_name == 'schedule'
    steps:
      - uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4.1.1
        with:
          fetch-depth: 0  # Full history for comprehensive scan

      - name: Run gitleaks
        uses: gitleaks/gitleaks-action@cb7149a9b57195b609c63e8518d2c6056677d2d0 # v2.3.4
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

  # ---------------------------------------------------------------------------
  # License compliance check
  # ---------------------------------------------------------------------------
  license-check:
    name: License Compliance
    runs-on: ubuntu-latest
    timeout-minutes: 10
    if: >-
      github.event.inputs.scan-type == 'all' ||
      github.event.inputs.scan-type == 'licenses' ||
      github.event_name == 'schedule'
    steps:
      - uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4.1.1

      - uses: actions/setup-node@60edb5dd545a775178f52524783378180af0d1f8 # v4.0.2
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'

      - run: npm ci --ignore-scripts

      - name: Check licenses
        run: |
          npx license-checker --summary --production > license-summary.txt
          echo "## License Summary" >> $GITHUB_STEP_SUMMARY
          cat license-summary.txt >> $GITHUB_STEP_SUMMARY

          # Fail on copyleft licenses in production dependencies
          npx license-checker --production --failOn "GPL-2.0;GPL-3.0;AGPL-1.0;AGPL-3.0" || {
            echo "::error::Copyleft license detected in production dependencies!"
            exit 1
          }

  # ---------------------------------------------------------------------------
  # Summary report
  # ---------------------------------------------------------------------------
  report:
    name: Maintenance Report
    runs-on: ubuntu-latest
    timeout-minutes: 5
    needs: [dependency-audit, semgrep, secrets-scan, license-check]
    if: always()
    steps:
      - name: Generate summary
        run: |
          echo "## Weekly Maintenance Report" >> $GITHUB_STEP_SUMMARY
          echo "" >> $GITHUB_STEP_SUMMARY
          echo "| Check | Status |" >> $GITHUB_STEP_SUMMARY
          echo "|-------|--------|" >> $GITHUB_STEP_SUMMARY
          echo "| Dependency Audit | ${{ needs.dependency-audit.result }} |" >> $GITHUB_STEP_SUMMARY
          echo "| Semgrep Scan | ${{ needs.semgrep.result }} |" >> $GITHUB_STEP_SUMMARY
          echo "| Secrets Scan | ${{ needs.secrets-scan.result }} |" >> $GITHUB_STEP_SUMMARY
          echo "| License Check | ${{ needs.license-check.result }} |" >> $GITHUB_STEP_SUMMARY
          echo "" >> $GITHUB_STEP_SUMMARY
          echo "*Run: $(date -u '+%Y-%m-%d %H:%M UTC')*" >> $GITHUB_STEP_SUMMARY
```

**Required GitHub Secrets:**

| Secret | Description | Where to obtain |
|--------|-------------|-----------------|
| `SEMGREP_APP_TOKEN` | Semgrep CI authentication token | semgrep.dev/manage/settings |
| `GITHUB_TOKEN` | Auto-provided by GitHub Actions | Automatic |

**Recommended CODEOWNERS:**

```
# All workflow files require DevOps review
.github/workflows/ @org/devops-team
.github/actions/ @org/devops-team
```
