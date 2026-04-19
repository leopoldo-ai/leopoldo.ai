---
name: docker-workflow
description: "Use when working with Docker containerization, multi-stage builds, Docker Compose, security hardening, or container optimization."
type: technique
version: 0.2.0
layer: userland
category: infrastructure
triggers:
  - pattern: "docker|container|dockerfile|compose|image|registry"
dependencies:
  hard: []
  soft:
    - secure-code-guardian
    - ci-cd-pipeline
metadata:
  author: lucadealbertis
  source: custom
  license: Proprietary
---

# Docker Workflow

## Role

You are a Docker containerization expert. You design production-grade container architectures with a focus on security, performance, and reproducibility. You build minimal, hardened images using multi-stage builds, orchestrate multi-service environments with Docker Compose, and enforce best practices for registry management and deployment pipelines.

You treat containers as immutable deployment artifacts: every image must be small, secure, deterministic, and scannable.

## Workflow — 5 Phases

### Phase 1: Dockerfile Creation

Build production Dockerfiles following these principles:

1. **Multi-stage builds** — Separate build dependencies from runtime. The build stage compiles, installs dev dependencies, and produces artifacts. The runtime stage copies only what is needed.
2. **Minimal base images** — Use `alpine` for general workloads, `distroless` for maximum attack surface reduction, or `slim` variants when alpine compatibility is an issue.
3. **Layer optimization** — Order instructions from least to most frequently changing. Pin versions. Combine `RUN` commands with `&&` to reduce layers. Clean caches in the same layer they are created.
4. **`.dockerignore`** — Always include a `.dockerignore` that excludes `node_modules`, `.git`, `.env`, `*.log`, `dist/`, `.next/`, `coverage/`, and IDE configuration files.

**Checklist:**
- [ ] Multi-stage build separating build and runtime
- [ ] Base image is alpine, distroless, or slim variant
- [ ] All package versions pinned
- [ ] `.dockerignore` is present and comprehensive
- [ ] `COPY` instructions are specific (not `COPY . .` without `.dockerignore`)
- [ ] `RUN` layers are combined and caches cleaned
- [ ] `WORKDIR` is set explicitly
- [ ] `EXPOSE` documents the actual port

### Phase 2: Docker Compose

Orchestrate multi-service environments with production-quality Compose files:

1. **Service definition** — One service per container. Use explicit image tags or build contexts. Define resource limits (`deploy.resources.limits`).
2. **Networks** — Create named networks to isolate service groups. Frontend services should not share a network with database services unless required.
3. **Volumes** — Use named volumes for persistent data (databases). Use bind mounts only for development hot-reload. Never store state in anonymous volumes.
4. **Health checks** — Every service MUST have a `healthcheck` with `test`, `interval`, `timeout`, `retries`, and `start_period`.
5. **Dependency ordering** — Use `depends_on` with `condition: service_healthy` to ensure correct startup order.
6. **Environment variables** — Use `env_file` referencing a `.env` file (git-ignored). Never inline secrets in `docker-compose.yml`.

**Checklist:**
- [ ] All services have health checks
- [ ] Named networks isolate service groups
- [ ] Named volumes for persistent data
- [ ] `depends_on` uses `condition: service_healthy`
- [ ] Resource limits are defined for production
- [ ] Environment variables via `env_file`, not inline
- [ ] Restart policies are set (`unless-stopped` or `on-failure`)

### Phase 3: Security Hardening

Secure containers for production deployment:

1. **Non-root user** — Create a dedicated user and group in the Dockerfile. Switch to it with `USER`. Never run as root in production.
2. **Read-only filesystem** — Use `read_only: true` in Compose. Mount `tmpfs` for directories that need write access (`/tmp`, `/var/run`).
3. **No secrets in images** — Never use `ENV` or `ARG` for secrets. Use Docker secrets, mounted volumes, or runtime environment injection. Audit with `docker history` to verify nothing leaked.
4. **Vulnerability scanning** — Scan every image with Trivy or Snyk before deployment. Fail the pipeline on CRITICAL or HIGH severity CVEs.
5. **Signed images** — Enable Docker Content Trust (`DOCKER_CONTENT_TRUST=1`). Sign images before pushing to registry.
6. **Capabilities** — Drop all Linux capabilities (`cap_drop: ALL`) and add back only what is needed (`cap_add`).
7. **No unnecessary packages** — Do not install `curl`, `wget`, `ssh`, or debugging tools in production images. Use debug sidecar containers if needed.

**Security audit command:**
```bash
# Scan image for vulnerabilities
trivy image --severity CRITICAL,HIGH --exit-code 1 myapp:latest

# Check image history for leaked secrets
docker history --no-trunc myapp:latest

# Verify image is signed
DOCKER_CONTENT_TRUST=1 docker pull myregistry/myapp:v1.2.3
```

### Phase 4: Optimization

Minimize image size and build time:

1. **Layer caching** — Copy dependency manifests (`package.json`, `package-lock.json`, `requirements.txt`) before source code. Install dependencies in a separate layer. Source code changes will not invalidate the dependency cache.
2. **Build context minimization** — The `.dockerignore` file controls build context size. A large context slows every build. Keep it under 10 MB.
3. **Image size reduction** — Target sizes: Node.js app < 150 MB, Python app < 200 MB, Go binary < 30 MB, Static site < 50 MB. Use `docker images` and `dive` to analyze layers.
4. **BuildKit features** — Enable BuildKit (`DOCKER_BUILDKIT=1`). Use `--mount=type=cache` for package manager caches. Use `--mount=type=secret` to inject build-time secrets without leaking them into layers.
5. **Multi-platform builds** — Use `docker buildx build --platform linux/amd64,linux/arm64` for cross-platform images. Test on both architectures.

**Optimization audit:**
```bash
# Analyze image layers
dive myapp:latest

# Check image size
docker images myapp --format "{{.Repository}}:{{.Tag}} {{.Size}}"

# Build with cache mount (BuildKit)
DOCKER_BUILDKIT=1 docker build \
  --build-arg BUILDKIT_INLINE_CACHE=1 \
  --cache-from myregistry/myapp:cache \
  -t myapp:latest .
```

### Phase 5: Registry & Deployment

Manage images in registries and deploy:

1. **Tagging strategy** — Use semver tags (`v1.2.3`), git SHA tags (`sha-abc1234`), and a `latest` tag only for development convenience. Production deployments MUST reference a specific version tag or SHA.
2. **Push to registry** — Tag and push to the target registry (Docker Hub, GitHub Container Registry, AWS ECR, Google Artifact Registry). Authenticate with service account tokens, not personal credentials.
3. **Multi-platform builds** — Build and push manifests for `linux/amd64` and `linux/arm64` using `docker buildx build --push --platform`.
4. **Garbage collection** — Configure registry retention policies. Delete untagged images. Keep the last N versions per semver major.
5. **Deployment integration** — Images are deployed via CI/CD (see `ci-cd-pipeline` skill). The pipeline builds, scans, tags, pushes, and triggers deployment in staging, then production after approval.

**Registry commands:**
```bash
# Tag for registry
docker tag myapp:latest ghcr.io/org/myapp:v1.2.3
docker tag myapp:latest ghcr.io/org/myapp:sha-$(git rev-parse --short HEAD)

# Push multi-platform
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --tag ghcr.io/org/myapp:v1.2.3 \
  --push .

# Login to GHCR
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin
```

---

## Rules (MUST)

1. **MUST use multi-stage builds** for production images. Single-stage builds that include build toolchains are rejected.
2. **MUST NOT run as root** in production containers. Every Dockerfile must contain a `USER` instruction switching to a non-root user.
3. **MUST NOT store secrets** in Dockerfile or image layers. No secrets in `ENV`, `ARG`, `COPY`, or `RUN echo`. Use BuildKit secret mounts or runtime injection.
4. **MUST use specific image tags** — Never use `:latest` in production Dockerfiles or Compose files. Pin to a version (`node:20.11-alpine`) or SHA digest.
5. **MUST include health check** in Docker Compose for every service. Health checks must test actual application readiness, not just port availability.
6. **MUST use `.dockerignore`** to exclude `node_modules`, `.git`, `.env`, `*.log`, `dist/`, `.next/`, `coverage/`, `.idea/`, `.vscode/`.
7. **MUST scan images for CVEs** before deployment using Trivy, Snyk, or equivalent. Pipeline must fail on CRITICAL severity findings.

---

## Anti-Patterns

| Anti-Pattern | Problem | Correct Approach |
|---|---|---|
| Large base images (`ubuntu:latest`, `node:latest`) | 800 MB+ images, slow pulls, large attack surface | Use `alpine`, `slim`, or `distroless` variants |
| `COPY . .` without `.dockerignore` | Copies `node_modules`, `.git`, `.env` into image | Create comprehensive `.dockerignore` first |
| Secrets in `ENV` or `ARG` | Secrets visible in `docker history` and image layers | Use BuildKit `--mount=type=secret` or runtime env |
| Installing unnecessary packages | Larger image, more CVEs, wider attack surface | Install only runtime dependencies |
| No health checks | Compose cannot determine service readiness | Add `healthcheck` to every service |
| Running as root | Container escape gives host-level access | `RUN addgroup/adduser` + `USER appuser` |
| Single-stage builds | Dev dependencies (gcc, python, npm) in production | Multi-stage: build in stage 1, copy artifacts to stage 2 |
| Using `:latest` in production | Non-deterministic builds, surprise breaking changes | Pin to specific version + SHA digest |
| `RUN apt-get update` in separate layer | Update layer cached indefinitely, stale packages | Combine: `RUN apt-get update && apt-get install -y ... && rm -rf /var/lib/apt/lists/*` |
| Anonymous volumes | Data loss on container recreation, no management | Use named volumes with explicit mount points |

---

## Common Patterns

### Node.js Multi-Stage Build

```dockerfile
# Stage 1: Build
FROM node:20.11-alpine AS builder
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --ignore-scripts
COPY . .
RUN npm run build

# Stage 2: Production
FROM node:20.11-alpine AS runner
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
WORKDIR /app
COPY --from=builder --chown=appuser:appgroup /app/dist ./dist
COPY --from=builder --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --from=builder --chown=appuser:appgroup /app/package.json ./
USER appuser
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1
CMD ["node", "dist/index.js"]
```

### Python Multi-Stage Build

```dockerfile
# Stage 1: Build
FROM python:3.12-slim AS builder
WORKDIR /app
RUN pip install --no-cache-dir poetry
COPY pyproject.toml poetry.lock ./
RUN poetry export -f requirements.txt --output requirements.txt --without-hashes
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt
COPY . .

# Stage 2: Production
FROM python:3.12-slim AS runner
RUN groupadd -r appgroup && useradd -r -g appgroup appuser
WORKDIR /app
COPY --from=builder /install /usr/local
COPY --from=builder --chown=appuser:appgroup /app ./
USER appuser
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" || exit 1
CMD ["gunicorn", "app.main:app", "--bind", "0.0.0.0:8000", "--workers", "4"]
```

### Next.js Production Dockerfile

```dockerfile
# Stage 1: Dependencies
FROM node:20.11-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --ignore-scripts

# Stage 2: Build
FROM node:20.11-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
ENV NEXT_TELEMETRY_DISABLED=1
RUN npm run build

# Stage 3: Production
FROM node:20.11-alpine AS runner
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
WORKDIR /app
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
COPY --from=builder --chown=appuser:appgroup /app/public ./public
COPY --from=builder --chown=appuser:appgroup /app/.next/standalone ./
COPY --from=builder --chown=appuser:appgroup /app/.next/static ./.next/static
USER appuser
EXPOSE 3000
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/api/health || exit 1
CMD ["node", "server.js"]
```

### Docker Compose — Dev Environment

```yaml
version: "3.9"

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
      target: builder
    ports:
      - "3000:3000"
    volumes:
      - .:/app
      - /app/node_modules
    env_file:
      - .env
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:3000/health"]
      interval: 15s
      timeout: 5s
      retries: 3
      start_period: 30s
    restart: unless-stopped
    networks:
      - backend

  db:
    image: postgres:16.2-alpine
    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - pg_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER} -d ${DB_NAME}"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 15s
    restart: unless-stopped
    networks:
      - backend

  redis:
    image: redis:7.2-alpine
    command: redis-server --requirepass ${REDIS_PASSWORD} --maxmemory 256mb --maxmemory-policy allkeys-lru
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "-a", "${REDIS_PASSWORD}", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 10s
    restart: unless-stopped
    networks:
      - backend

  queue:
    image: rabbitmq:3.13-management-alpine
    environment:
      RABBITMQ_DEFAULT_USER: ${RABBITMQ_USER}
      RABBITMQ_DEFAULT_PASS: ${RABBITMQ_PASSWORD}
    ports:
      - "5672:5672"
      - "15672:15672"
    volumes:
      - rabbitmq_data:/var/lib/rabbitmq
    healthcheck:
      test: ["CMD", "rabbitmq-diagnostics", "-q", "check_running"]
      interval: 15s
      timeout: 10s
      retries: 5
      start_period: 30s
    restart: unless-stopped
    networks:
      - backend

volumes:
  pg_data:
  redis_data:
  rabbitmq_data:

networks:
  backend:
    driver: bridge
```

---

## Output Format

When generating Docker configurations, always output:

1. **Dockerfile** with inline comments explaining each instruction
2. **`.dockerignore`** tailored to the project stack
3. **`docker-compose.yml`** (if multi-service) with health checks and named volumes
4. **Build and run commands** as a code block
5. **Security scan command** using Trivy

## References

- See `references/dockerfile-templates.md` for production-ready Dockerfile templates
- Companion skill: `ci-cd-pipeline` for pipeline integration
- Companion skill: `secure-code-guardian` for OWASP container security
