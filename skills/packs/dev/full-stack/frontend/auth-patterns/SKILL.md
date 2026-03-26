---
name: auth-patterns
description: "Use when adding authentication to web or mobile apps. Covers Auth.js v5, Lucia, OAuth, passkeys, RBAC, and session management. OSS-first: Auth.js and Lucia primary, Clerk and Supabase Auth as fallbacks. Triggers on: auth, login, signup, session, OAuth, NextAuth, Auth.js, Lucia, Clerk, passkey, RBAC."
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

# Auth Patterns -- Authentication for Modern Apps

## Why This Exists

| Problem | Solution |
|---------|----------|
| Auth is the #1 feature every app needs, zero coverage in plugin | Complete auth patterns for web and mobile |
| Developers default to expensive premium tools (Clerk) | OSS-first: Auth.js and Lucia as primary recommendations |
| Auth setup is error-prone and security-critical | Battle-tested patterns with security best practices built in |

## OSS-First Philosophy

| Recommended (OSS) | Aware Of (Premium) |
|-------------------|-------------------|
| Auth.js v5 (Next.js) | Clerk |
| Lucia (any framework) | Supabase Auth |
| Arctic (OAuth library) | Auth0 |

## Decision Framework

```
Need auth in Next.js?
  YES -> Auth.js v5 (best integration, least config)

Need auth in non-Next.js or want full control?
  YES -> Lucia (database-backed sessions, any framework)

Already using Supabase?
  YES -> Supabase Auth (built-in, no extra setup)

Enterprise requirement for Clerk?
  YES -> Clerk (document as premium fallback)
```

## Core Workflow

### 1. Auth.js v5 Setup (Next.js Primary Path)

```typescript
// auth.ts - Root configuration
import NextAuth from "next-auth"
import Google from "next-auth/providers/google"
import GitHub from "next-auth/providers/github"
import Credentials from "next-auth/providers/credentials"
import { DrizzleAdapter } from "@auth/drizzle-adapter"
import { db } from "@/lib/db"

export const { handlers, auth, signIn, signOut } = NextAuth({
  adapter: DrizzleAdapter(db),
  providers: [
    Google,
    GitHub,
    Credentials({
      credentials: { email: {}, password: {} },
      authorize: async (credentials) => {
        // Validate credentials against database
        // Use argon2id for password hashing
      }
    })
  ],
  callbacks: {
    session({ session, user }) {
      session.user.role = user.role
      return session
    }
  }
})
```

```typescript
// middleware.ts - Protected routes
import { auth } from "@/auth"

export default auth((req) => {
  if (!req.auth && req.nextUrl.pathname !== "/login") {
    return Response.redirect(new URL("/login", req.nextUrl))
  }
})

export const config = { matcher: ["/dashboard/:path*", "/api/protected/:path*"] }
```

```typescript
// app/api/auth/[...nextauth]/route.ts
import { handlers } from "@/auth"
export const { GET, POST } = handlers
```

### 2. Lucia Setup (Framework-Agnostic Path)

```typescript
// lib/auth.ts
import { Lucia } from "lucia"
import { DrizzlePostgreSQLAdapter } from "@lucia-auth/adapter-drizzle"
import { db, userTable, sessionTable } from "@/lib/db"

const adapter = new DrizzlePostgreSQLAdapter(db, sessionTable, userTable)

export const lucia = new Lucia(adapter, {
  sessionCookie: {
    attributes: { secure: process.env.NODE_ENV === "production" }
  },
  getUserAttributes: (attributes) => ({
    email: attributes.email,
    role: attributes.role
  })
})
```

### 3. OAuth Integration (3+ providers minimum)

For Auth.js: providers are plug-and-play via `next-auth/providers/*`.
For Lucia: use Arctic library for OAuth flows.

Required providers: Google, GitHub, Discord (minimum).
Optional: Apple, Microsoft, LinkedIn.

### 4. Protected Routes Pattern

```typescript
// Server Component protection
import { auth } from "@/auth"
import { redirect } from "next/navigation"

export default async function DashboardPage() {
  const session = await auth()
  if (!session) redirect("/login")
  return <Dashboard user={session.user} />
}
```

```typescript
// Server Action protection
"use server"
import { auth } from "@/auth"

export async function updateProfile(data: FormData) {
  const session = await auth()
  if (!session) throw new Error("Unauthorized")
  // ... update logic
}
```

### 5. RBAC (Role-Based Access Control)

```typescript
// lib/rbac.ts
type Role = "user" | "admin" | "editor"

const permissions: Record<Role, string[]> = {
  user: ["read:own"],
  editor: ["read:own", "write:own", "read:all"],
  admin: ["read:own", "write:own", "read:all", "write:all", "manage:users"]
}

export function hasPermission(role: Role, permission: string): boolean {
  return permissions[role]?.includes(permission) ?? false
}

// Middleware usage
export default auth((req) => {
  const role = req.auth?.user?.role ?? "user"
  if (req.nextUrl.pathname.startsWith("/admin") && !hasPermission(role, "manage:users")) {
    return Response.redirect(new URL("/unauthorized", req.nextUrl))
  }
})
```

### 6. Passkeys / WebAuthn

```typescript
// Use @simplewebauthn/server + @simplewebauthn/browser
import { generateRegistrationOptions, verifyRegistrationResponse } from "@simplewebauthn/server"

// Registration: server generates challenge -> client creates credential -> server verifies
// Authentication: server generates challenge -> client signs -> server verifies
```

### 7. Magic Link / Passwordless

With Auth.js: use the Email provider with Resend or Nodemailer.
With Lucia: implement custom token generation + email sending.

```typescript
// Auth.js Email provider
import Resend from "next-auth/providers/resend"

Resend({ from: "auth@yourdomain.com" })
```

## Rules

1. Auth.js v5 is the FIRST recommendation for Next.js projects
2. Lucia is the FIRST recommendation for non-Next.js or full-control needs
3. NEVER recommend Clerk as primary (document as premium alternative)
4. ALL passwords MUST use argon2id or bcrypt (NEVER MD5, SHA-1, SHA-256)
5. ALL auth checks MUST include server-side validation (never client-only)
6. JWT refresh tokens MUST implement rotation
7. Session cookies MUST have: httpOnly, secure, sameSite=lax
8. OAuth state parameter MUST be validated to prevent CSRF

## Anti-Patterns

| Anti-Pattern | Why Wrong | Do Instead |
|-------------|-----------|------------|
| Client-side only auth checks | Easily bypassed | Server-side validation in middleware + components |
| Storing passwords in plain text | Security disaster | argon2id or bcrypt with proper salt |
| JWT without refresh rotation | Token theft = permanent access | Short-lived access + rotating refresh tokens |
| Using localStorage for tokens | XSS vulnerability | httpOnly cookies |
| Hardcoding OAuth secrets | Secrets leak in version control | Environment variables, never committed |
| Same session for all environments | Dev tokens work in prod | Separate secrets per environment |
