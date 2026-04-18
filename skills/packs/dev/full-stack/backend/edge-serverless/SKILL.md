---
name: edge-serverless
description: "Use when building edge-first applications with Cloudflare Workers, Hono, or serverless patterns. Covers Workers, D1, KV, Durable Objects, and Hono framework. OSS-first: Cloudflare Workers (generous free tier) and Hono (OSS). Triggers on: Cloudflare Workers, edge, serverless, Hono, D1, KV, Durable Objects, edge functions, Bun, Deno."
type: technique
metadata:
  author: leopoldo
  source: https://github.com/jezweb/claude-skills
  created: 2026-03-24
  forge_strategy: adapt
  forge_sources:
    - https://github.com/jezweb/claude-skills
license: MIT
upstream:
  url: https://github.com/jezweb/claude-skills
  version: main
  last_checked: 2026-03-24
---

# Edge Serverless -- Cloudflare Workers and Hono

## Why This Exists

| Problem | Solution |
|---------|----------|
| Plugin only covers Vercel deploy, edge computing missing | Cloudflare Workers + Hono patterns |
| Traditional serverless has cold starts | Edge: zero cold start, global by default |

Adapted from [jezweb/claude-skills](https://github.com/jezweb/claude-skills).

## OSS-First Philosophy

| Recommended (OSS/Free) | Aware Of (Premium) |
|------------------------|-------------------|
| Cloudflare Workers (100K req/day free) | AWS Lambda@Edge |
| Hono (OSS web framework) | Vercel Edge Functions |
| D1 (SQLite at edge) | PlanetScale |
| Bun / Deno (runtimes) | -- |

## Core Workflow

### 1. Hono Setup (Cloudflare Workers)

```bash
npm create hono@latest my-api
# Select: cloudflare-workers
cd my-api && npm install
```

```typescript
// src/index.ts
import { Hono } from "hono"
import { cors } from "hono/cors"
import { logger } from "hono/logger"
import { zValidator } from "@hono/zod-validator"
import { z } from "zod"

type Bindings = {
  DB: D1Database
  KV: KVNamespace
  AI: Ai
}

const app = new Hono<{ Bindings: Bindings }>()

app.use("*", logger())
app.use("/api/*", cors())

// Type-safe routes with Zod validation
const createUserSchema = z.object({
  name: z.string().min(2),
  email: z.string().email()
})

app.post("/api/users", zValidator("json", createUserSchema), async (c) => {
  const { name, email } = c.req.valid("json")
  const result = await c.env.DB.prepare(
    "INSERT INTO users (name, email) VALUES (?, ?) RETURNING *"
  ).bind(name, email).first()
  return c.json(result, 201)
})

app.get("/api/users", async (c) => {
  const { results } = await c.env.DB.prepare("SELECT * FROM users").all()
  return c.json(results)
})

export default app
```

### 2. D1 Database (SQLite at Edge)

```bash
npx wrangler d1 create my-db
npx wrangler d1 migrations create my-db init
```

```sql
-- migrations/0001_init.sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

```bash
npx wrangler d1 migrations apply my-db        # Local
npx wrangler d1 migrations apply my-db --remote # Production
```

### 3. KV Storage

```typescript
// Key-Value for caching, sessions, config
app.get("/api/config/:key", async (c) => {
  const key = c.req.param("key")
  const cached = await c.env.KV.get(key)
  if (cached) return c.json(JSON.parse(cached))

  const fresh = await fetchConfig(key)
  await c.env.KV.put(key, JSON.stringify(fresh), { expirationTtl: 3600 })
  return c.json(fresh)
})
```

### 4. Wrangler Config

```toml
# wrangler.toml
name = "my-api"
main = "src/index.ts"
compatibility_date = "2026-03-01"

[[d1_databases]]
binding = "DB"
database_name = "my-db"
database_id = "xxx"

[[kv_namespaces]]
binding = "KV"
id = "xxx"
```

### 5. Deploy

```bash
npx wrangler dev          # Local development
npx wrangler deploy       # Deploy to Cloudflare
```

### 6. Runtime Awareness (Bun/Deno)

Hono works on multiple runtimes:
- **Cloudflare Workers**: Primary target, zero cold start
- **Bun**: `bun run src/index.ts` for local dev, deploy on Fly.io
- **Deno**: `deno run src/index.ts`, deploy on Deno Deploy
- **Node.js**: Via @hono/node-server for traditional hosting

## Rules

1. Hono for edge API development (fast, tiny, multi-runtime)
2. Cloudflare Workers for deployment (generous free tier, global edge)
3. D1 for relational data at edge (SQLite, zero latency)
4. KV for caching and key-value needs
5. Zod validation on all inputs (zValidator middleware)
6. Keep functions small (Workers have 10ms CPU time on free plan)
7. Use wrangler for local dev and deployment

## Anti-Patterns

| Anti-Pattern | Why Wrong | Do Instead |
|-------------|-----------|------------|
| Express at the edge | Too heavy, not edge-native | Hono (12KB, edge-optimized) |
| PostgreSQL connections from Workers | Connection pooling impossible at edge | D1 (SQLite) or Hyperdrive for PG |
| Large npm dependencies in Workers | Bundle size limits (1-10MB) | Tree-shake, use edge-compatible libs |
| No local development | Slow feedback loop | wrangler dev (local Workers runtime) |
