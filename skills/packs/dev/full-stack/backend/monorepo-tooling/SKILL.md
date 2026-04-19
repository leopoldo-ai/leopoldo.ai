---
name: monorepo-tooling
description: "Use when setting up or managing monorepos with Turborepo, pnpm workspaces, or shared packages. Covers workspace structure, build pipelines, caching, and shared configs. OSS-first: Turborepo + pnpm primary. Triggers on: monorepo, Turborepo, pnpm workspace, workspace, shared packages, turbo.json."
type: technique
metadata:
  author: leopoldo
  source: custom
  created: 2026-03-24
  forge_strategy: build
license: MIT
upstream:
  url: null
  version: null
  last_checked: 2026-03-24
---

# Monorepo Tooling -- Turborepo and pnpm Workspaces

## Why This Exists

| Problem | Solution |
|---------|----------|
| Multi-package projects need monorepo structure | Turborepo + pnpm workspace patterns |
| Build times grow linearly with packages | Turborepo caching (local + remote) |

## OSS-First Philosophy

| Recommended (OSS) | Aware Of (Premium) |
|-------------------|-------------------|
| Turborepo (OSS) | Nx Cloud (premium caching) |
| pnpm workspaces | Lerna (deprecated model) |

## Core Workflow

### 1. Structure

```
my-monorepo/
  apps/
    web/           # Next.js frontend
    api/           # FastAPI or Express backend
    mobile/        # Expo app
  packages/
    ui/            # Shared React components
    config/        # Shared ESLint, TypeScript, Tailwind configs
    database/      # Shared Prisma/Drizzle schema
    types/         # Shared TypeScript types
  turbo.json
  pnpm-workspace.yaml
  package.json
```

### 2. pnpm Workspace Config

```yaml
# pnpm-workspace.yaml
packages:
  - "apps/*"
  - "packages/*"
```

```json
// package.json (root)
{
  "private": true,
  "scripts": {
    "dev": "turbo dev",
    "build": "turbo build",
    "lint": "turbo lint",
    "test": "turbo test"
  },
  "devDependencies": {
    "turbo": "^2"
  }
}
```

### 3. Turborepo Pipeline

```json
// turbo.json
{
  "$schema": "https://turbo.build/schema.json",
  "tasks": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": [".next/**", "dist/**"]
    },
    "dev": {
      "cache": false,
      "persistent": true
    },
    "lint": {},
    "test": {
      "dependsOn": ["build"]
    }
  }
}
```

### 4. Shared Package

```json
// packages/ui/package.json
{
  "name": "@myapp/ui",
  "version": "0.0.0",
  "private": true,
  "exports": {
    "./button": "./src/button.tsx",
    "./card": "./src/card.tsx"
  }
}
```

```typescript
// apps/web/package.json - consume shared package
{ "dependencies": { "@myapp/ui": "workspace:*" } }

// apps/web/app/page.tsx
import { Button } from "@myapp/ui/button"
```

## Rules

1. pnpm workspaces + Turborepo as default monorepo setup
2. Shared code in packages/, apps in apps/
3. Use `workspace:*` for internal dependencies
4. Turborepo caching: define outputs for every cached task
5. Keep shared packages small and focused (one concern each)
6. TypeScript project references for fast type checking

## Anti-Patterns

| Anti-Pattern | Why Wrong | Do Instead |
|-------------|-----------|------------|
| Copy-pasting code between apps | Drift, maintenance burden | Shared package in packages/ |
| No Turborepo caching | Slow CI, rebuilds everything | Define outputs in turbo.json |
| Giant shared package | Everything coupled | Small focused packages (ui, types, config) |
| npm/yarn for monorepo | Slower, worse workspace support | pnpm (fastest, strictest) |
