---
name: full-stack
version: 1.0.0
description: "Full Stack: 81 skills in 3 sub-packs (frontend, backend, security) for modern software teams. OSS-first philosophy."
author: leopoldo
license: MIT
skillos_min_version: "0.3.0"
sub_packs:
  - name: frontend
    path: frontend/
    skills_count: 30
    description: "UI, React/Next.js, mobile, design systems, auth, AI, GraphQL, testing"
  - name: backend
    path: backend/
    skills_count: 32
    description: "API, database, infrastructure, deploy, DevOps, edge, payments, IaC"
  - name: security
    path: security/
    skills_count: 19
    description: "Security auditing, TDD, code quality, red team"
dependencies:
  packs: ["essentials"]
tags: ["development", "tdd", "frontend", "backend", "security", "mobile", "graphql", "iac", "edge", "oss-first"]
---

# Full Stack -- Development Plugin

Plugin for modern software engineering teams. 3 sub-packs covering the entire stack: frontend, backend, and security. OSS-first philosophy: every skill teaches the open-source solution as default, with premium alternatives documented as fallbacks.

## Target

- Software engineering teams
- Full-stack developers
- DevOps / platform engineers
- Frontend / mobile developers
- Security engineers

## Architecture

```
full-stack/
  frontend/     UI, React, Next.js, mobile, design, component testing
  backend/      API, database, infra, deploy, DevOps, architecture
  security/     Auditing, TDD, code quality, red team, SAST
```

## OSS-First Philosophy

Every skill recommends open-source tools as the primary path:

| Pattern | Example |
|---------|---------|
| Auth | Auth.js (OSS) first, Clerk (premium) aware |
| Search | Meilisearch (OSS) first, Algolia (premium) aware |
| Payments | Polar (OSS) first, Stripe (premium) aware |
| Observability | OpenTelemetry (OSS) first, Datadog (premium) aware |
| Database | Supabase (self-host) first, Firebase (premium) aware |

## Sub-Pack: frontend (12 skills)

### Core Stack

| Skill | Scope |
|-------|-------|
| `nextjs-developer` | Next.js 14+ App Router, Server Components, Vercel deploy |
| `typescript-pro` | TypeScript strict mode, generics, utility types |
| `react-best-practices` | 57 React/Next.js performance rules |

### Design and Components

| Skill | Scope |
|-------|-------|
| `shadcnblocks-components` | 1338 blocks + 1189 shadcn/ui components |
| `frontend-design` | Production-grade UI/UX, design system |
| `tremor-design-system` | Dashboard analytics with Tremor |
| `dashboard-builder` | Full-stack dashboard React + shadcn + Recharts |
| `accessibility` | WCAG 2.2 compliance, ARIA, keyboard navigation |
| `ux-researcher-designer` | Personas, journey maps, usability testing |
| `motion-design` | 7 animation categories with a11y and performance |
| `brand-to-ui` | brand-kit.yaml to design tokens pipeline |

### Testing

| Skill | Scope |
|-------|-------|
| `e2e-testing-patterns` | E2E Playwright/Cypress patterns |

## Sub-Pack: backend (15 skills)

### Core Stack

| Skill | Scope |
|-------|-------|
| `api-designer` | REST API design, OpenAPI 3.1, error handling |
| `postgres-pro` | PostgreSQL optimization, indexing, JSONB |
| `neon-postgres-setup` | Neon Serverless Postgres setup |
| `drizzle-orm-patterns` | Drizzle ORM relations, transactions, migrations |
| `python-backend` | FastAPI, Django, Flask patterns |

### Architecture

| Skill | Scope |
|-------|-------|
| `rag-architect` | RAG systems, vector DB, embeddings |
| `senior-architect` | Architecture diagrams, system design |
| `database-optimizer` | EXPLAIN ANALYZE, indexing, query optimization |

### Deploy and Infrastructure

| Skill | Scope |
|-------|-------|
| `vercel-deploy` | Automated Vercel deploy |
| `docker-workflow` | Docker, multi-stage builds, Compose |
| `ci-cd-pipeline` | GitHub Actions CI/CD |
| `release-manager` | Semantic versioning, changelog |
| `project-scaffolder` | Init Next.js 14+ project |
| `git-workflow` | Conventional commits, feature branches |

### CMS

| Skill | Scope |
|-------|-------|
| `wordpress-pro` | WordPress theme dev, plugin dev, Gutenberg, REST API |

## Sub-Pack: security (19 skills)

### Security Auditing (15 skills)

| Skill | Scope |
|-------|-------|
| `secure-code-guardian` | OWASP Top 10, auth, input validation |
| `performing-security-testing` | OWASP Testing Guide v4.2 |
| `supply-chain-security` | Dependency scanning, SBOM, license compliance |
| `semgrep` | Static analysis with custom rules |
| `semgrep-rule-creator` | Custom Semgrep rule creation |
| `insecure-defaults` | Hardcoded secrets, weak auth detection |
| `sharp-edges` | Error-prone APIs, dangerous configs |
| `differential-review` | Security-focused diff/PR review |
| `fix-review` | Security fix completeness review |
| `audit-prep-assistant` | Codebase audit preparation |
| `audit-coordinator` | Orchestrates security pipeline |
| `codeql` | CodeQL interprocedural analysis |
| `sarif-parsing` | SARIF file parsing and CI/CD integration |
| `variant-analysis` | Find similar vulnerabilities |
| `threat-modeler` | STRIDE threat model, attack trees |

### Quality and Testing (4 skills)

| Skill | Scope |
|-------|-------|
| `tdd-red-green-refactor` | Rigorous RED-GREEN-REFACTOR |
| `tdd-vertical-slicing` | TDD with vertical slicing, deep modules |
| `test-master` | Testing strategy (unit, integration, E2E) |
| `code-reviewer` | Principal-engineer-level review |
