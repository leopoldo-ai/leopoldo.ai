# Spec Card: auth-patterns

## Identity
- **Pack:** full-stack
- **Sub-pack:** frontend
- **Layer:** userland

## Scope
Authentication and authorization patterns for modern web and mobile apps. Covers session-based auth, JWT, OAuth, magic links, passkeys, and role-based access control. OSS-first: Auth.js and Lucia are primary, Clerk and Supabase Auth as "aware of" alternatives.

Does NOT cover: backend-only auth (covered by python-backend), security hardening (covered by secure-code-guardian), or API key management.

## Expected Inputs
- User asks to add auth to a Next.js/React app
- User mentions login, signup, session, OAuth, social login, passkeys
- User asks about Auth.js, NextAuth, Lucia, Clerk, Supabase Auth

## Expected Outputs
- Auth implementation plan with recommended stack
- Code patterns for session management, protected routes, middleware
- OAuth provider setup (Google, GitHub, Discord, etc.)
- Role-based access control (RBAC) patterns
- Migration guides between auth providers

## Must-Have Features
1. Auth.js v5 (Next.js App Router) setup and configuration
2. Lucia auth setup (database-backed sessions)
3. OAuth provider integration (Google, GitHub, Discord minimum)
4. Protected route patterns (middleware, server-side, client-side)
5. Session management (JWT vs database sessions, refresh tokens)
6. Role-based access control (RBAC) with middleware
7. Magic link / passwordless authentication
8. Passkey / WebAuthn patterns

## Nice-to-Have Features
1. Clerk integration patterns (premium fallback)
2. Supabase Auth patterns (premium fallback)
3. Multi-tenant auth patterns
4. Rate limiting on auth endpoints

## Anti-Patterns
- Recommending Clerk as primary (it's premium, OSS-first)
- Storing passwords without proper hashing (bcrypt/argon2)
- JWT without refresh token rotation
- Client-side only auth checks without server validation

## Integration Points
- `nextjs-developer`: App Router middleware, server actions
- `supabase-patterns`: Supabase Auth as alternative
- `secure-code-guardian`: OWASP auth security
- `python-backend`: Backend auth patterns (FastAPI/Django)

## Success Criteria
- Can scaffold Auth.js v5 in a Next.js 14+ app in under 5 minutes
- OAuth flow works with at least 3 providers
- Protected routes work with middleware pattern
- RBAC pattern is reusable across projects

## Key Rules
- Auth.js is ALWAYS the first recommendation for Next.js
- Lucia is the first recommendation for non-Next.js or custom needs
- Clerk is documented but never recommended first
- All auth patterns must include server-side validation
- Passwords must use argon2id or bcrypt, never MD5/SHA
