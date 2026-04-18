---
name: tanstack-ecosystem
description: "Use when working with TanStack Router, TanStack Start, or TanStack Form. Covers type-safe routing, full-stack framework patterns, and form management within the TanStack ecosystem. Triggers on: TanStack Router, TanStack Start, TanStack Form, file-based routing, type-safe routes, createFileRoute, createRootRoute."
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

# TanStack Ecosystem -- Router, Start, and Form

## Why This Exists

| Problem | Solution |
|---------|----------|
| TanStack is more than Query, Router and Start are rising fast | Complete TanStack Router + Start patterns |
| Type-safe routing is unique to TanStack Router | Patterns that leverage full type inference |
| Plugin covers Next.js but not Vite-based alternatives | TanStack Start as OSS full-stack Vite framework |

## OSS-First Philosophy

All TanStack tools are OSS (MIT licensed). No premium alternatives needed.

| Tool | Purpose |
|------|---------|
| TanStack Router | Type-safe file-based routing for React |
| TanStack Start | Full-stack React framework (Vite-based) |
| TanStack Form | Headless form management with validation |

## Core Workflow

### 1. TanStack Router Setup

```bash
npm install @tanstack/react-router @tanstack/router-devtools
npm install -D @tanstack/router-plugin
```

```typescript
// vite.config.ts
import { TanStackRouterVite } from "@tanstack/router-plugin/vite"

export default defineConfig({
  plugins: [TanStackRouterVite(), react()]
})
```

### 2. File-Based Routes

```
routes/
  __root.tsx        # Root layout
  index.tsx         # /
  about.tsx         # /about
  posts/
    index.tsx       # /posts
    $postId.tsx     # /posts/:postId (dynamic)
  _authenticated/   # Layout group (underscore prefix)
    dashboard.tsx   # /dashboard (requires auth)
```

```typescript
// routes/__root.tsx
import { createRootRoute, Outlet } from "@tanstack/react-router"

export const Route = createRootRoute({
  component: () => (
    <div>
      <header><Nav /></header>
      <main><Outlet /></main>
    </div>
  )
})

// routes/posts/$postId.tsx
import { createFileRoute } from "@tanstack/react-router"

export const Route = createFileRoute("/posts/$postId")({
  // Type-safe params
  loader: async ({ params }) => {
    return fetchPost(params.postId) // postId is typed as string
  },
  component: PostPage
})

function PostPage() {
  const post = Route.useLoaderData() // Fully typed
  const { postId } = Route.useParams() // Fully typed
  return <article>{post.title}</article>
}
```

### 3. Type-Safe Navigation

```typescript
import { Link, useNavigate } from "@tanstack/react-router"

// Link: type-checks route paths and params
<Link to="/posts/$postId" params={{ postId: "123" }}>View Post</Link>

// Navigate: imperative, also type-safe
const navigate = useNavigate()
navigate({ to: "/posts/$postId", params: { postId: "123" } })

// Search params (type-safe)
export const Route = createFileRoute("/posts")({
  validateSearch: (search) => ({
    page: Number(search.page) || 1,
    filter: (search.filter as string) || "all"
  })
})

function PostsPage() {
  const { page, filter } = Route.useSearch() // Typed
}
```

### 4. TanStack Start (Full-Stack)

```bash
npm create @tanstack/start my-app
```

```typescript
// Server functions (like Next.js Server Actions)
import { createServerFn } from "@tanstack/start"

const getUsers = createServerFn("GET", async () => {
  const users = await db.query.users.findMany()
  return users
})

// Use in component (runs on server, returns typed data)
export const Route = createFileRoute("/users")({
  loader: () => getUsers(),
  component: UsersPage
})
```

### 5. TanStack Form

```typescript
import { useForm } from "@tanstack/react-form"
import { zodValidator } from "@tanstack/zod-form-adapter"
import { z } from "zod"

function ContactForm() {
  const form = useForm({
    defaultValues: { name: "", email: "", message: "" },
    validatorAdapter: zodValidator(),
    onSubmit: async ({ value }) => {
      await submitContact(value)
    }
  })

  return (
    <form onSubmit={(e) => { e.preventDefault(); form.handleSubmit() }}>
      <form.Field name="name" validators={{
        onChange: z.string().min(2, "Name required")
      }}>
        {(field) => (
          <div>
            <input value={field.state.value}
              onChange={(e) => field.handleChange(e.target.value)} />
            {field.state.meta.errors.map((e) => <span key={e}>{e}</span>)}
          </div>
        )}
      </form.Field>
      <button type="submit">Submit</button>
    </form>
  )
}
```

## Rules

1. TanStack Router for Vite-based React projects (not Next.js)
2. TanStack Start when you want a full-stack Vite framework
3. Type-safe routes are the main advantage: leverage them fully
4. Use loaders for data fetching (not useEffect)
5. File-based routing: follow conventions ($ for params, _ for layouts)
6. TanStack Form when already in TanStack ecosystem (otherwise React Hook Form)

## Anti-Patterns

| Anti-Pattern | Why Wrong | Do Instead |
|-------------|-----------|------------|
| TanStack Router in Next.js | Next.js has its own router | Use TanStack Router with Vite or Start |
| useEffect for data fetching | Race conditions, no loader benefits | Route loaders with typed data |
| Manual route definitions | Lose file-based type generation | Use file-based routing with plugin |
| Ignoring search param validation | Unsafe, untyped URL state | validateSearch on every route |
| TanStack Form everywhere | Heavier than React Hook Form | Use TanStack Form in TanStack ecosystem only |
