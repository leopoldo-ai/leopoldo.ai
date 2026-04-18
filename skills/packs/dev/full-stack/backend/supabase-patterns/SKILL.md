---
name: supabase-patterns
description: "Use when building with Supabase: database, auth, storage, realtime, and edge functions. OSS-first: Supabase is self-hostable. Triggers on: Supabase, supabase-js, Supabase Auth, Supabase Realtime, Supabase Storage, edge functions, RLS, row level security."
type: technique
metadata:
  author: leopoldo
  source: https://github.com/supabase/agent-skills
  created: 2026-03-24
  forge_strategy: adapt
  forge_sources:
    - https://github.com/supabase/agent-skills
license: MIT
upstream:
  url: https://github.com/supabase/agent-skills
  version: main
  last_checked: 2026-03-24
---

# Supabase Patterns -- Full-Stack Backend with Supabase

## Why This Exists

| Problem | Solution |
|---------|----------|
| Firebase is not self-hostable, vendor lock-in | Supabase: OSS, self-hostable, Postgres-based |
| Backend setup is complex (auth + DB + storage + realtime) | Supabase bundles all in one platform |

Adapted from official [supabase/agent-skills](https://github.com/supabase/agent-skills).

## OSS-First Philosophy

| Recommended (OSS) | Aware Of (Premium) |
|-------------------|-------------------|
| Supabase (self-host option) | Firebase |
| PostgreSQL (underlying DB) | PlanetScale (MySQL) |
| Supabase Auth | Auth0 |

## Core Workflow

### 1. Setup

```bash
npm install @supabase/supabase-js
```

```typescript
// lib/supabase/client.ts (browser)
import { createBrowserClient } from "@supabase/ssr"

export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  )
}

// lib/supabase/server.ts (server components)
import { createServerClient } from "@supabase/ssr"
import { cookies } from "next/headers"

export async function createClient() {
  const cookieStore = await cookies()
  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    { cookies: { getAll: () => cookieStore.getAll(),
      setAll: (cookies) => cookies.forEach(({ name, value, options }) =>
        cookieStore.set(name, value, options)) } }
  )
}
```

### 2. Database Queries (Type-Safe)

```bash
npx supabase gen types typescript --project-id your-project > database.types.ts
```

```typescript
import { createClient } from "@/lib/supabase/server"

// Select
const { data: posts, error } = await supabase
  .from("posts")
  .select("id, title, content, author:users(name, avatar)")
  .eq("status", "published")
  .order("created_at", { ascending: false })
  .limit(10)

// Insert
const { data, error } = await supabase
  .from("posts")
  .insert({ title: "New Post", content: "...", author_id: user.id })
  .select()
  .single()

// Update
const { error } = await supabase
  .from("posts")
  .update({ title: "Updated" })
  .eq("id", postId)

// Delete
const { error } = await supabase.from("posts").delete().eq("id", postId)
```

### 3. Row Level Security (RLS)

```sql
-- Enable RLS on table
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- Public read
CREATE POLICY "Public can read published posts" ON posts
  FOR SELECT USING (status = 'published');

-- Authenticated users can create
CREATE POLICY "Users can create posts" ON posts
  FOR INSERT WITH CHECK (auth.uid() = author_id);

-- Users can update their own
CREATE POLICY "Users can update own posts" ON posts
  FOR UPDATE USING (auth.uid() = author_id);
```

### 4. Auth

```typescript
// Sign up
const { data, error } = await supabase.auth.signUp({
  email: "user@example.com",
  password: "secure-password"
})

// Sign in
const { data, error } = await supabase.auth.signInWithPassword({
  email, password
})

// OAuth
const { data, error } = await supabase.auth.signInWithOAuth({
  provider: "google",
  options: { redirectTo: `${origin}/auth/callback` }
})

// Get current user (server)
const { data: { user } } = await supabase.auth.getUser()
```

### 5. Realtime Subscriptions

```typescript
const channel = supabase
  .channel("posts")
  .on("postgres_changes", {
    event: "INSERT",
    schema: "public",
    table: "posts"
  }, (payload) => {
    console.log("New post:", payload.new)
  })
  .subscribe()

// Cleanup
return () => { supabase.removeChannel(channel) }
```

### 6. Storage

```typescript
// Upload
const { data, error } = await supabase.storage
  .from("avatars")
  .upload(`${userId}/avatar.jpg`, file, {
    cacheControl: "3600",
    upsert: true
  })

// Get public URL
const { data: { publicUrl } } = supabase.storage
  .from("avatars")
  .getPublicUrl(`${userId}/avatar.jpg`)
```

## Rules

1. ALWAYS enable RLS on every table (security by default)
2. Generate TypeScript types from schema (supabase gen types)
3. Use @supabase/ssr for Next.js (not raw supabase-js)
4. Use service role key ONLY in server-side code, NEVER in client
5. Use Supabase Auth for auth (don't build custom auth on top of Supabase)
6. Realtime: always clean up subscriptions on component unmount

## Anti-Patterns

| Anti-Pattern | Why Wrong | Do Instead |
|-------------|-----------|------------|
| RLS disabled on tables | Data exposed to all authenticated users | Enable RLS, write policies for every table |
| Service role key in client | Full database access to anyone | Anon key in client, service role only on server |
| Manual TypeScript types | Drift from schema | Generate from database with CLI |
| Not using @supabase/ssr | Cookie handling breaks in Next.js | Always use SSR package for Next.js |
