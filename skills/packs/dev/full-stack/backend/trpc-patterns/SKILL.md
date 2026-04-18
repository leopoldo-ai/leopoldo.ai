---
name: trpc-patterns
description: "Use when building type-safe APIs with tRPC. Covers router setup, procedures, middleware, and React Query integration. OSS-first: tRPC is fully OSS. Triggers on: tRPC, type-safe API, router, procedure, createTRPCRouter, middleware, React Query, end-to-end type safety."
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

# tRPC Patterns -- End-to-End Type-Safe APIs

## Why This Exists

| Problem | Solution |
|---------|----------|
| REST APIs lose type safety between client and server | tRPC: shared types, zero codegen |
| GraphQL requires schema + codegen overhead | tRPC: direct TypeScript, no schema language |

## Core Workflow

### 1. Setup

```bash
npm install @trpc/server @trpc/client @trpc/react-query @trpc/next
```

### 2. Server Router

```typescript
// server/trpc.ts
import { initTRPC, TRPCError } from "@trpc/server"
import { z } from "zod"

const t = initTRPC.context<{ user?: User; db: Database }>().create()

export const router = t.router
export const publicProcedure = t.procedure
export const protectedProcedure = t.procedure.use(({ ctx, next }) => {
  if (!ctx.user) throw new TRPCError({ code: "UNAUTHORIZED" })
  return next({ ctx: { ...ctx, user: ctx.user } })
})

// server/routers/users.ts
export const userRouter = router({
  list: publicProcedure.query(({ ctx }) => ctx.db.query.users.findMany()),

  byId: publicProcedure
    .input(z.object({ id: z.string() }))
    .query(({ ctx, input }) => ctx.db.query.users.findFirst({ where: eq(users.id, input.id) })),

  update: protectedProcedure
    .input(z.object({ name: z.string().min(2), bio: z.string().optional() }))
    .mutation(({ ctx, input }) =>
      ctx.db.update(users).set(input).where(eq(users.id, ctx.user.id))
    )
})

// server/routers/index.ts
export const appRouter = router({ user: userRouter })
export type AppRouter = typeof appRouter
```

### 3. Client Usage

```typescript
// In React components (via TanStack Query integration)
function UserProfile({ userId }: { userId: string }) {
  const { data: user } = trpc.user.byId.useQuery({ id: userId })
  const updateMutation = trpc.user.update.useMutation()

  // Fully typed: user has correct type, mutation input is validated
  return (
    <form onSubmit={() => updateMutation.mutate({ name: "New Name" })}>
      <p>{user?.name}</p>
    </form>
  )
}
```

## Rules

1. tRPC for TypeScript-only full-stack apps (no external API consumers)
2. Use Zod for ALL input validation
3. Separate routers by domain (userRouter, postRouter, etc.)
4. Protected procedures for authenticated endpoints
5. If you need a public API for external consumers, use REST or GraphQL instead

## Anti-Patterns

| Anti-Pattern | Why Wrong | Do Instead |
|-------------|-----------|------------|
| tRPC for public APIs | Not HTTP-standard, TypeScript only | REST with OpenAPI for public APIs |
| No input validation | Unsafe, untyped inputs | Zod schemas on every procedure |
| One giant router | Unmaintainable | Split into domain routers, merge |
| tRPC + GraphQL in same project | Redundant, confusing | Pick one based on needs |
