# Dockerfile Templates — Production Ready

Five production-grade Dockerfile templates for common application stacks. Each template follows the rules defined in the `docker-workflow` skill: multi-stage builds, non-root user, specific image tags, health checks, and layer optimization.

---

## Template 1: Node.js API Server (Express / Fastify)

Suitable for REST APIs, GraphQL servers, and background workers running on Node.js.

```dockerfile
# =============================================================================
# Node.js API Server — Multi-Stage Production Build
# Base: node:20.11-alpine (~180 MB build, ~80 MB production)
# =============================================================================

# --- Stage 1: Install dependencies ---
FROM node:20.11-alpine AS deps
WORKDIR /app

# Copy only dependency manifests for layer caching
COPY package.json package-lock.json ./

# Install production dependencies only
# --ignore-scripts prevents postinstall attacks from compromised packages
RUN npm ci --omit=dev --ignore-scripts

# --- Stage 2: Build application ---
FROM node:20.11-alpine AS builder
WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci --ignore-scripts

# Copy source code (after deps for cache optimization)
COPY tsconfig.json ./
COPY src ./src

# Compile TypeScript
RUN npm run build

# --- Stage 3: Production runtime ---
FROM node:20.11-alpine AS runner

# Security: install dumb-init for proper signal handling (PID 1 problem)
RUN apk add --no-cache dumb-init

# Security: create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy production dependencies from stage 1
COPY --from=deps --chown=appuser:appgroup /app/node_modules ./node_modules

# Copy compiled application from stage 2
COPY --from=builder --chown=appuser:appgroup /app/dist ./dist
COPY --from=builder --chown=appuser:appgroup /app/package.json ./

# Set production environment
ENV NODE_ENV=production
ENV PORT=3000

# Switch to non-root user
USER appuser

# Document exposed port
EXPOSE 3000

# Health check: verify the /health endpoint responds
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

# Use dumb-init as entrypoint for proper signal forwarding
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "dist/index.js"]
```

**`.dockerignore` for this template:**
```
node_modules
dist
.git
.gitignore
.env
.env.*
*.log
npm-debug.log*
Dockerfile
docker-compose*.yml
.dockerignore
README.md
docs/
coverage/
.nyc_output/
.vscode/
.idea/
*.test.ts
*.spec.ts
__tests__/
```

**Build and run:**
```bash
DOCKER_BUILDKIT=1 docker build -t myapi:v1.0.0 .
docker run -d --name myapi -p 3000:3000 --env-file .env --read-only \
  --tmpfs /tmp myapi:v1.0.0
```

---

## Template 2: Next.js 14+ Standalone Production

Optimized for Next.js applications using the `standalone` output mode for minimal production images.

```dockerfile
# =============================================================================
# Next.js 14+ Standalone — Multi-Stage Production Build
# Base: node:20.11-alpine (~250 MB build, ~120 MB production)
# Requires: next.config.js with output: 'standalone'
# =============================================================================

# --- Stage 1: Install dependencies ---
FROM node:20.11-alpine AS deps
WORKDIR /app

# libc6-compat required for some native Node modules on Alpine
RUN apk add --no-cache libc6-compat

COPY package.json package-lock.json ./
RUN npm ci --ignore-scripts

# --- Stage 2: Build ---
FROM node:20.11-alpine AS builder
WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Disable Next.js telemetry during build
ENV NEXT_TELEMETRY_DISABLED=1

# Build arguments for public env vars (injected at build time)
ARG NEXT_PUBLIC_API_URL
ARG NEXT_PUBLIC_SITE_URL
ENV NEXT_PUBLIC_API_URL=$NEXT_PUBLIC_API_URL
ENV NEXT_PUBLIC_SITE_URL=$NEXT_PUBLIC_SITE_URL

RUN npm run build

# --- Stage 3: Production ---
FROM node:20.11-alpine AS runner
WORKDIR /app

# Security: non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

# Copy only the standalone output and static assets
# The standalone output includes a minimal server.js and only required node_modules
COPY --from=builder --chown=appuser:appgroup /app/public ./public
COPY --from=builder --chown=appuser:appgroup /app/.next/standalone ./
COPY --from=builder --chown=appuser:appgroup /app/.next/static ./.next/static

USER appuser

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/api/health || exit 1

CMD ["node", "server.js"]
```

**`next.config.js` requirement:**
```js
/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'standalone',
};
module.exports = nextConfig;
```

**Build and run:**
```bash
DOCKER_BUILDKIT=1 docker build \
  --build-arg NEXT_PUBLIC_API_URL=https://api.example.com \
  --build-arg NEXT_PUBLIC_SITE_URL=https://example.com \
  -t myapp:v1.0.0 .

docker run -d --name myapp -p 3000:3000 --env-file .env.production \
  --read-only --tmpfs /tmp myapp:v1.0.0
```

---

## Template 3: Python FastAPI / Django

Suitable for Python web applications using FastAPI, Django, or Flask with Gunicorn as the WSGI/ASGI server.

```dockerfile
# =============================================================================
# Python FastAPI — Multi-Stage Production Build
# Base: python:3.12-slim (~350 MB build, ~150 MB production)
# =============================================================================

# --- Stage 1: Build dependencies ---
FROM python:3.12-slim AS builder
WORKDIR /app

# Install build tools needed for some Python packages (psycopg2, etc.)
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc libpq-dev && \
    rm -rf /var/lib/apt/lists/*

# Install pip dependencies into a prefix directory for clean copy
COPY requirements.txt ./
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# --- Stage 2: Production runtime ---
FROM python:3.12-slim AS runner
WORKDIR /app

# Install only runtime libraries (no compilers)
RUN apt-get update && \
    apt-get install -y --no-install-recommends libpq5 wget && \
    rm -rf /var/lib/apt/lists/*

# Security: non-root user
RUN groupadd -r appgroup && useradd -r -g appgroup -d /app -s /sbin/nologin appuser

# Copy installed Python packages from builder
COPY --from=builder /install /usr/local

# Copy application source
COPY --chown=appuser:appgroup . .

# Remove unnecessary files from production image
RUN rm -rf tests/ docs/ *.md requirements*.txt Dockerfile .dockerignore

ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV PORT=8000

USER appuser

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8000/health || exit 1

# Gunicorn with Uvicorn workers for FastAPI (ASGI)
CMD ["gunicorn", "app.main:app", \
     "--bind", "0.0.0.0:8000", \
     "--workers", "4", \
     "--worker-class", "uvicorn.workers.UvicornWorker", \
     "--timeout", "120", \
     "--graceful-timeout", "30", \
     "--access-logfile", "-", \
     "--error-logfile", "-"]
```

**`.dockerignore` for Python projects:**
```
__pycache__
*.pyc
*.pyo
.git
.gitignore
.env
.env.*
*.log
Dockerfile
docker-compose*.yml
.dockerignore
README.md
docs/
tests/
.pytest_cache/
.mypy_cache/
.ruff_cache/
htmlcov/
coverage.xml
.coverage
.venv/
venv/
.vscode/
.idea/
```

**Build and run:**
```bash
DOCKER_BUILDKIT=1 docker build -t myapi:v1.0.0 .
docker run -d --name myapi -p 8000:8000 --env-file .env \
  --read-only --tmpfs /tmp myapi:v1.0.0
```

---

## Template 4: Go Binary (Distroless)

Maximum security and minimal size for Go applications. The final image contains only the compiled binary with no shell, no package manager, and no OS tools.

```dockerfile
# =============================================================================
# Go Binary — Distroless Production Build
# Base: golang:1.22-alpine build, gcr.io/distroless/static-debian12 runtime
# Result: ~10-30 MB production image
# =============================================================================

# --- Stage 1: Build ---
FROM golang:1.22-alpine AS builder
WORKDIR /app

# Install git for module downloads and ca-certificates for HTTPS
RUN apk add --no-cache git ca-certificates tzdata

# Download modules first for layer caching
COPY go.mod go.sum ./
RUN go mod download && go mod verify

# Copy source and build
COPY . .

# Build static binary with CGO disabled for distroless compatibility
# -ldflags: strip debug info and set version
# -trimpath: remove build paths from binary
ARG VERSION=dev
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build \
    -ldflags="-w -s -X main.version=${VERSION}" \
    -trimpath \
    -o /app/server ./cmd/server

# --- Stage 2: Production (distroless — no shell, no package manager) ---
FROM gcr.io/distroless/static-debian12 AS runner

# Copy timezone data and CA certificates from builder
COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Copy the compiled binary
COPY --from=builder /app/server /server

# distroless images run as nonroot (UID 65534) by default
USER nonroot:nonroot

EXPOSE 8080

# Note: distroless has no shell, so HEALTHCHECK CMD won't work here
# Health checks should be performed externally (Docker Compose, Kubernetes)

ENTRYPOINT ["/server"]
```

**Docker Compose health check for distroless (external):**
```yaml
services:
  api:
    image: myapi:v1.0.0
    ports:
      - "8080:8080"
    healthcheck:
      # Use a helper container or curl from the host network
      test: ["CMD-SHELL", "wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1"]
      interval: 30s
      timeout: 5s
      retries: 3
    read_only: true
```

**Build multi-platform:**
```bash
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --build-arg VERSION=v1.0.0 \
  --tag ghcr.io/org/myapi:v1.0.0 \
  --push .
```

---

## Template 5: Static Site (Nginx)

For React, Vue, Angular, or any SPA that compiles to static HTML/CSS/JS.

```dockerfile
# =============================================================================
# Static Site (React/Vue/Angular) — Multi-Stage with Nginx
# Base: node:20.11-alpine build, nginx:1.25-alpine runtime
# Result: ~30-50 MB production image
# =============================================================================

# --- Stage 1: Build ---
FROM node:20.11-alpine AS builder
WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci --ignore-scripts

COPY . .

# Build arguments for environment-specific config
ARG VITE_API_URL
ARG VITE_APP_ENV=production
ENV VITE_API_URL=$VITE_API_URL
ENV VITE_APP_ENV=$VITE_APP_ENV

RUN npm run build

# --- Stage 2: Production Nginx ---
FROM nginx:1.25-alpine AS runner

# Remove default nginx config and html
RUN rm -rf /etc/nginx/conf.d/default.conf /usr/share/nginx/html/*

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built assets from builder
COPY --from=builder /app/dist /usr/share/nginx/html

# Security: run nginx as non-root
# Create nginx user directories with correct permissions
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    touch /var/run/nginx.pid && \
    chown nginx:nginx /var/run/nginx.pid

USER nginx

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1

CMD ["nginx", "-g", "daemon off;"]
```

**`nginx.conf` for SPA with security headers:**
```nginx
server {
    listen 8080;
    server_name _;
    root /usr/share/nginx/html;
    index index.html;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Content-Security-Policy "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self'; connect-src 'self' https://api.example.com;" always;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml text/javascript image/svg+xml;

    # Cache static assets aggressively (hashed filenames)
    location /assets/ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Health check endpoint
    location /health {
        access_log off;
        return 200 "OK";
        add_header Content-Type text/plain;
    }

    # SPA fallback: serve index.html for all routes
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Deny access to hidden files
    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }
}
```

**Build and run:**
```bash
DOCKER_BUILDKIT=1 docker build \
  --build-arg VITE_API_URL=https://api.example.com \
  -t mysite:v1.0.0 .

docker run -d --name mysite -p 8080:8080 --read-only \
  --tmpfs /var/cache/nginx --tmpfs /var/run --tmpfs /var/log/nginx \
  mysite:v1.0.0
```

---

## Universal `.dockerignore`

A comprehensive `.dockerignore` that works for most project types:

```
# Version control
.git
.gitignore
.gitattributes

# Dependencies (will be installed in container)
node_modules
.pnp.*
.yarn/cache
.yarn/unplugged
__pycache__
*.pyc
.venv
venv

# Build output (will be built in container)
dist
build
.next
out
.nuxt

# Environment and secrets
.env
.env.*
!.env.example

# IDE and OS
.vscode
.idea
*.swp
*.swo
.DS_Store
Thumbs.db

# Docker files (prevent recursive context)
Dockerfile
Dockerfile.*
docker-compose*.yml
.dockerignore

# Documentation
README.md
CHANGELOG.md
LICENSE
docs/

# Testing
coverage
.nyc_output
.pytest_cache
.coverage
htmlcov
*.test.*
*.spec.*
__tests__
e2e

# CI/CD
.github
.gitlab-ci.yml
.circleci

# Misc
*.log
npm-debug.log*
yarn-debug.log*
```
