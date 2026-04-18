---
name: meta-frameworks
description: "Use when choosing a React meta-framework or building with Astro, SvelteKit, or Remix. Provides decision framework for when to use Next.js vs alternatives. Awareness skill, not deep implementation. Triggers on: Astro, SvelteKit, Remix, framework choice, which framework, Next.js alternative, content site, static site."
type: pattern
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

# Meta-Frameworks -- When to Use What

## Why This Exists

| Problem | Solution |
|---------|----------|
| Plugin is Next.js focused, but alternatives matter | Decision framework for framework selection |
| Developers use Next.js for everything, even wrong use cases | Guide to pick the right tool for the job |

This is an AWARENESS skill, not a deep implementation guide. For deep Next.js patterns, use `nextjs-developer`. For deep TanStack Start, use `tanstack-ecosystem`.

## Decision Framework

```
CONTENT-HEAVY SITE (blog, docs, marketing)?
  -> Astro (best performance, zero JS by default)

FORM-HEAVY APP (dashboards with lots of mutations)?
  -> Remix (best form handling, progressive enhancement)

PERFORMANCE-CRITICAL with rich interactivity?
  -> SvelteKit (smallest bundle, compiled framework)

FULL-STACK APP (API + frontend + auth + DB)?
  -> Next.js (ecosystem, Vercel, most mature)

VITE-BASED with type-safe routing?
  -> TanStack Start (see tanstack-ecosystem skill)
```

## Framework Comparison

| Feature | Next.js | Astro | Remix | SvelteKit |
|---------|---------|-------|-------|-----------|
| Primary use case | Full-stack apps | Content sites | Form-heavy apps | Performance apps |
| Rendering | SSR, SSG, ISR, RSC | Static-first, islands | SSR, streaming | SSR, SSG |
| JS shipped to client | Moderate | Minimal (islands) | Moderate | Minimal (compiled) |
| Data fetching | Server Components, fetch | Astro.glob, content collections | Loaders (web standard) | Load functions |
| Forms | Server Actions | Astro Actions | Native form handling | SvelteKit Actions |
| Routing | File-based (app/) | File-based (pages/) | File-based (routes/) | File-based (routes/) |
| Deploy | Vercel, self-host | Any static host, SSR adapters | Any Node host, Cloudflare | Any adapter |
| TypeScript | Excellent | Good | Good | Excellent |
| Learning curve | Medium | Low | Medium | Low-Medium |
| Ecosystem size | Largest | Growing fast | Medium | Medium |
| Best for | SaaS, dashboards, e-commerce | Blogs, docs, marketing, portfolios | CRUD apps, admin panels | Performance-critical apps |

## When NOT to Use Next.js

| Scenario | Better Alternative | Why |
|----------|-------------------|-----|
| Static marketing site | Astro | Zero JS, faster build, simpler |
| Documentation site | Astro (Starlight) | Built-in docs features, MDX native |
| Simple blog | Astro | Content collections, no React overhead |
| Edge-first app | SvelteKit or Remix | Better Cloudflare Workers support |
| Form-heavy CRUD | Remix | Progressive enhancement, native forms |

## When to Stick with Next.js

| Scenario | Why Next.js |
|----------|-------------|
| Full-stack SaaS | RSC + Server Actions + Auth.js + Vercel |
| E-commerce | ISR, image optimization, middleware |
| Team already knows React | Largest ecosystem, most hiring |
| Needs Vercel integration | Best DX on Vercel platform |
| Complex data fetching | RSC + streaming + Suspense |

## Rules

1. Next.js is the DEFAULT recommendation (largest ecosystem, most versatile)
2. Suggest alternatives ONLY when there's a clear advantage for the use case
3. Astro for content sites (blog, docs, marketing): measurably better performance
4. Remix for form-heavy apps: better progressive enhancement
5. SvelteKit for performance-critical: smaller bundles, compiled framework
6. Never recommend framework switching mid-project (too costly)

## Anti-Patterns

| Anti-Pattern | Why Wrong | Do Instead |
|-------------|-----------|------------|
| Next.js for a static blog | Overkill, slow builds | Astro (purpose-built for content) |
| Framework hopping mid-project | Enormous cost, team disruption | Commit to choice, optimize within it |
| Choosing based on hype | Framework fatigue | Choose based on USE CASE and team skills |
| Ignoring deployment target | Framework-host mismatch | Match framework to where you deploy |
