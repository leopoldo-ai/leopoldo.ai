---
name: payload-cms
description: "Use when building content-managed sites with Payload CMS. Covers collections, globals, access control, hooks, and Next.js integration. OSS-first: Payload (self-hostable) primary, Contentful and Sanity as premium alternatives. Triggers on: Payload, CMS, headless CMS, content management, collections, admin panel, Payload CMS."
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

# Payload CMS -- Headless CMS with Next.js

## Why This Exists

| Problem | Solution |
|---------|----------|
| Content-managed sites need a CMS, only WordPress covered | Payload: OSS, TypeScript-native, Next.js integrated |
| Premium CMS (Contentful, Sanity) are expensive at scale | Payload is self-hostable, no per-seat pricing |

## OSS-First Philosophy

| Recommended (OSS) | Aware Of (Premium) |
|-------------------|-------------------|
| Payload CMS (self-host) | Contentful |
| -- | Sanity |
| -- | Strapi (partially OSS) |

## Core Workflow

### 1. Setup

```bash
npx create-payload-app@latest my-cms
# Select: Next.js, PostgreSQL (with Drizzle), TypeScript
```

### 2. Collections (Content Types)

```typescript
// collections/Posts.ts
import { CollectionConfig } from "payload"

export const Posts: CollectionConfig = {
  slug: "posts",
  admin: { useAsTitle: "title" },
  access: {
    read: () => true,           // Public read
    create: ({ req }) => !!req.user,  // Auth required
    update: ({ req }) => req.user?.role === "admin",
    delete: ({ req }) => req.user?.role === "admin"
  },
  fields: [
    { name: "title", type: "text", required: true },
    { name: "slug", type: "text", unique: true, admin: { position: "sidebar" } },
    { name: "content", type: "richText" },
    { name: "coverImage", type: "upload", relationTo: "media" },
    { name: "author", type: "relationship", relationTo: "users" },
    { name: "status", type: "select", options: ["draft", "published"],
      defaultValue: "draft" },
    { name: "publishedAt", type: "date", admin: {
      condition: (data) => data.status === "published"
    }}
  ],
  hooks: {
    beforeChange: [({ data }) => {
      if (!data.slug) data.slug = data.title?.toLowerCase().replace(/\s+/g, "-")
      return data
    }]
  }
}
```

### 3. Querying in Next.js

```typescript
// app/(frontend)/blog/page.tsx
import { getPayload } from "payload"
import config from "@payload-config"

export default async function BlogPage() {
  const payload = await getPayload({ config })
  const posts = await payload.find({
    collection: "posts",
    where: { status: { equals: "published" } },
    sort: "-publishedAt",
    limit: 10
  })

  return (
    <div>
      {posts.docs.map((post) => (
        <article key={post.id}>
          <h2>{post.title}</h2>
        </article>
      ))}
    </div>
  )
}
```

### 4. Globals (Singletons)

```typescript
// globals/SiteSettings.ts
import { GlobalConfig } from "payload"

export const SiteSettings: GlobalConfig = {
  slug: "site-settings",
  fields: [
    { name: "siteName", type: "text", required: true },
    { name: "description", type: "textarea" },
    { name: "logo", type: "upload", relationTo: "media" },
    { name: "socialLinks", type: "array", fields: [
      { name: "platform", type: "select", options: ["twitter", "github", "linkedin"] },
      { name: "url", type: "text" }
    ]}
  ]
}
```

## Rules

1. Payload for new CMS projects (TypeScript-native, Next.js integrated)
2. Self-host on your own infrastructure (no vendor lock-in)
3. Use access control on every collection (never leave defaults)
4. Use hooks for computed fields and side effects
5. Separate admin routes from frontend routes in Next.js
6. Use Payload Local API in Server Components (no HTTP overhead)

## Anti-Patterns

| Anti-Pattern | Why Wrong | Do Instead |
|-------------|-----------|------------|
| No access control | All data public/writable | Define access per operation per collection |
| REST API for same-server queries | HTTP overhead, unnecessary | Payload Local API in Server Components |
| Contentful for simple blog | Expensive, vendor lock-in | Payload (free, self-hosted) |
| Hardcoding content in code | Not editable by non-devs | CMS-managed content with admin panel |
