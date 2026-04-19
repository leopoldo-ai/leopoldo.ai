---
name: prisma-orm
description: "Use when working with Prisma ORM: schema design, migrations, queries, relations, and performance. OSS-first: Prisma is fully OSS. Use alongside postgres-pro for database optimization. Triggers on: Prisma, prisma schema, prisma migrate, prisma client, PrismaClient, findMany, findUnique, prisma studio."
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

# Prisma ORM -- Type-Safe Database Access

## Why This Exists

| Problem | Solution |
|---------|----------|
| Plugin has Drizzle but not Prisma (5x larger community) | Complete Prisma patterns |
| Prisma has unique patterns (schema-first, migrate, client) | Dedicated skill for Prisma-specific workflows |

## OSS-First Philosophy

Prisma is fully OSS (Apache 2.0). Prisma Accelerate/Pulse are optional premium add-ons.

| Recommended (OSS) | Aware Of (Premium) |
|-------------------|-------------------|
| Prisma ORM | Prisma Accelerate (connection pooling) |
| Prisma Migrate | Prisma Pulse (real-time) |
| Prisma Studio | -- |

## Core Workflow

### 1. Setup

```bash
npm install prisma @prisma/client
npx prisma init
```

### 2. Schema Design

```prisma
// prisma/schema.prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id        String   @id @default(cuid())
  email     String   @unique
  name      String?
  role      Role     @default(USER)
  posts     Post[]
  profile   Profile?
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@index([email])
}

model Post {
  id          String   @id @default(cuid())
  title       String
  slug        String   @unique
  content     String?
  published   Boolean  @default(false)
  author      User     @relation(fields: [authorId], references: [id])
  authorId    String
  categories  Category[]
  publishedAt DateTime?
  createdAt   DateTime @default(now())

  @@index([authorId])
  @@index([slug])
}

model Profile {
  id     String @id @default(cuid())
  bio    String?
  avatar String?
  user   User   @relation(fields: [userId], references: [id], onDelete: Cascade)
  userId String @unique
}

model Category {
  id    String @id @default(cuid())
  name  String @unique
  posts Post[]
}

enum Role {
  USER
  ADMIN
  EDITOR
}
```

### 3. Migrations

```bash
npx prisma migrate dev --name init        # Create + apply migration
npx prisma migrate deploy                  # Production deploy
npx prisma db push                         # Quick sync (no migration file)
npx prisma generate                        # Regenerate client
npx prisma studio                          # Visual DB browser
```

### 4. Queries

```typescript
import { PrismaClient } from "@prisma/client"

// Singleton pattern for Next.js
const globalForPrisma = globalThis as unknown as { prisma: PrismaClient }
export const prisma = globalForPrisma.prisma || new PrismaClient()
if (process.env.NODE_ENV !== "production") globalForPrisma.prisma = prisma

// Find with relations
const user = await prisma.user.findUnique({
  where: { id: userId },
  include: { posts: { where: { published: true }, orderBy: { createdAt: "desc" } }, profile: true }
})

// Create with nested
const post = await prisma.post.create({
  data: {
    title: "New Post",
    slug: "new-post",
    author: { connect: { id: userId } },
    categories: { connect: [{ id: catId1 }, { id: catId2 }] }
  },
  include: { author: true, categories: true }
})

// Transaction
const [post, user] = await prisma.$transaction([
  prisma.post.create({ data: { ... } }),
  prisma.user.update({ where: { id: userId }, data: { postCount: { increment: 1 } } })
])

// Pagination
const posts = await prisma.post.findMany({
  where: { published: true },
  orderBy: { createdAt: "desc" },
  skip: (page - 1) * pageSize,
  take: pageSize
})
```

### 5. Performance

```typescript
// Select only needed fields
const users = await prisma.user.findMany({
  select: { id: true, name: true, email: true } // NOT include (loads all fields)
})

// Use raw queries for complex operations
const result = await prisma.$queryRaw`
  SELECT u.name, COUNT(p.id) as post_count
  FROM "User" u LEFT JOIN "Post" p ON u.id = p."authorId"
  GROUP BY u.id ORDER BY post_count DESC LIMIT 10
`
```

## Rules

1. Singleton PrismaClient in Next.js (avoid connection exhaustion)
2. Use `select` over `include` when you don't need all fields
3. Always add @@index for foreign keys and frequently queried columns
4. Use `prisma migrate dev` in development, `prisma migrate deploy` in production
5. Never use `db push` in production (no migration history)
6. Use transactions for operations that must be atomic
7. Generate client after every schema change

## Anti-Patterns

| Anti-Pattern | Why Wrong | Do Instead |
|-------------|-----------|------------|
| New PrismaClient per request | Connection pool exhaustion | Singleton pattern with global |
| No indexes on foreign keys | Slow joins | @@index on every foreign key |
| db push in production | No migration history, data loss risk | prisma migrate deploy |
| include with nested includes | N+1 queries, over-fetching | select specific fields |
| Raw SQL for simple queries | Loses type safety | Prisma Client for standard CRUD |
