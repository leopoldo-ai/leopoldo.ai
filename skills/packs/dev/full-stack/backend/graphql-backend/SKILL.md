---
name: graphql-backend
description: "Use when building GraphQL servers with Apollo Server, GraphQL Yoga, or implementing GraphQL Federation. Covers schema design, resolvers, dataloaders, auth, and subscriptions. OSS-first. Triggers on: Apollo Server, GraphQL Yoga, GraphQL server, schema, resolvers, dataloader, federation, supergraph."
metadata:
  author: leopoldo
  source: https://github.com/apollographql/skills
  created: 2026-03-24
  forge_strategy: adapt
  forge_sources:
    - https://github.com/apollographql/skills
    - https://github.com/wundergraph/graphql-federation-skill
license: MIT
upstream:
  url: https://github.com/apollographql/skills
  version: main
  last_checked: 2026-03-24
---

# GraphQL Backend -- Server-Side GraphQL

## Why This Exists

| Problem | Solution |
|---------|----------|
| graphql-patterns covers client only, server side missing | Complete GraphQL server patterns |
| GraphQL servers have unique challenges (N+1, auth, federation) | Patterns for DataLoader, context, and federation |

Adapted from [apollographql/skills](https://github.com/apollographql/skills) and [wundergraph/graphql-federation-skill](https://github.com/wundergraph/graphql-federation-skill).

## OSS-First Philosophy

| Recommended (OSS) | Aware Of (Premium) |
|-------------------|-------------------|
| GraphQL Yoga (lightweight) | Hasura (auto-generated) |
| Apollo Server 4 (full-featured) | Apollo GraphOS (cloud) |
| Pothos (code-first schema) | -- |
| Cosmo (federation, OSS) | Apollo Federation (managed) |

## Core Workflow

### 1. GraphQL Yoga Setup (Lightweight)

```typescript
import { createSchema, createYoga } from "graphql-yoga"
import { createServer } from "node:http"

const yoga = createYoga({
  schema: createSchema({
    typeDefs: `
      type Query {
        users: [User!]!
        user(id: ID!): User
      }
      type User {
        id: ID!
        name: String!
        email: String!
        posts: [Post!]!
      }
      type Post {
        id: ID!
        title: String!
        author: User!
      }
    `,
    resolvers: {
      Query: {
        users: (_, __, ctx) => ctx.db.user.findMany(),
        user: (_, { id }, ctx) => ctx.db.user.findUnique({ where: { id } })
      },
      User: {
        posts: (parent, _, ctx) => ctx.postLoader.load(parent.id)
      }
    }
  }),
  context: ({ request }) => ({
    db: prisma,
    postLoader: createPostLoader(),
    user: getUserFromToken(request.headers.get("authorization"))
  })
})

const server = createServer(yoga)
server.listen(4000)
```

### 2. Code-First with Pothos

```typescript
import SchemaBuilder from "@pothos/core"
import PrismaPlugin from "@pothos/plugin-prisma"

const builder = new SchemaBuilder({
  plugins: [PrismaPlugin],
  prisma: { client: prisma }
})

builder.prismaObject("User", {
  fields: (t) => ({
    id: t.exposeID("id"),
    name: t.exposeString("name"),
    email: t.exposeString("email"),
    posts: t.relation("posts")
  })
})

builder.queryType({
  fields: (t) => ({
    users: t.prismaField({
      type: ["User"],
      resolve: (query) => prisma.user.findMany({ ...query })
    })
  })
})

export const schema = builder.toSchema()
```

### 3. DataLoader (N+1 Prevention)

```typescript
import DataLoader from "dataloader"

function createPostLoader() {
  return new DataLoader<string, Post[]>(async (userIds) => {
    const posts = await prisma.post.findMany({
      where: { authorId: { in: [...userIds] } }
    })
    const postsByUser = new Map<string, Post[]>()
    posts.forEach((p) => {
      const existing = postsByUser.get(p.authorId) || []
      postsByUser.set(p.authorId, [...existing, p])
    })
    return userIds.map((id) => postsByUser.get(id) || [])
  })
}
```

### 4. Authentication in Context

```typescript
const yoga = createYoga({
  context: async ({ request }) => {
    const token = request.headers.get("authorization")?.replace("Bearer ", "")
    const user = token ? await verifyToken(token) : null
    return { user, db: prisma }
  }
})

// In resolver: check auth
const resolvers = {
  Mutation: {
    createPost: (_, args, ctx) => {
      if (!ctx.user) throw new GraphQLError("Unauthorized", { extensions: { code: "UNAUTHORIZED" } })
      return ctx.db.post.create({ data: { ...args.input, authorId: ctx.user.id } })
    }
  }
}
```

### 5. Next.js Route Handler

```typescript
// app/api/graphql/route.ts
import { createYoga } from "graphql-yoga"
import { schema } from "@/lib/graphql/schema"

const { handleRequest } = createYoga({
  schema,
  graphqlEndpoint: "/api/graphql",
  fetchAPI: { Response }
})

export { handleRequest as GET, handleRequest as POST }
```

## Rules

1. GraphQL Yoga for new projects (simpler, lighter, maintained by The Guild)
2. Apollo Server when you need federation or extensive plugin ecosystem
3. ALWAYS use DataLoader to prevent N+1 queries
4. Auth in context, check in resolvers (not middleware)
5. Code-first with Pothos for TypeScript projects (type-safe schema)
6. Schema-first for team collaboration (designers can read the schema)
7. Create new DataLoader instance per request (prevents cache leaks)

## Anti-Patterns

| Anti-Pattern | Why Wrong | Do Instead |
|-------------|-----------|------------|
| No DataLoader | N+1 queries, slow responses | DataLoader for all batched relations |
| Auth in each resolver manually | Repetitive, error-prone | Auth in context + directive or plugin |
| Global DataLoader instance | Cache leaks between requests | New DataLoader per request in context |
| Exposing all database fields | Over-exposure, security risk | Explicitly expose only needed fields |
| No error handling | Unformatted errors leak to client | GraphQL error codes and formatted messages |
