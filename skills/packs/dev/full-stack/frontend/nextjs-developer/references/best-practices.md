# Next.js Best Practices
> Consolidated from next-best-practices skill (source: vercel-labs/next-skills, license: none/no-license)

Apply these rules when writing or reviewing Next.js code.

## File Conventions

See [best-practices/file-conventions.md](./best-practices/file-conventions.md) for:
- Project structure and special files
- Route segments (dynamic, catch-all, groups)
- Parallel and intercepting routes
- Middleware rename in v16 (middleware -> proxy)

## RSC Boundaries

Detect invalid React Server Component patterns.

See [best-practices/rsc-boundaries.md](./best-practices/rsc-boundaries.md) for:
- Async client component detection (invalid)
- Non-serializable props detection
- Server Action exceptions

## Async Patterns

Next.js 15+ async API changes.

See [best-practices/async-patterns.md](./best-practices/async-patterns.md) for:
- Async `params` and `searchParams`
- Async `cookies()` and `headers()`
- Migration codemod

## Runtime Selection

See [best-practices/runtime-selection.md](./best-practices/runtime-selection.md) for:
- Default to Node.js runtime
- When Edge runtime is appropriate

## Directives

See [best-practices/directives.md](./best-practices/directives.md) for:
- `'use client'`, `'use server'` (React)
- `'use cache'` (Next.js)

## Functions

See [best-practices/functions.md](./best-practices/functions.md) for:
- Navigation hooks: `useRouter`, `usePathname`, `useSearchParams`, `useParams`
- Server functions: `cookies`, `headers`, `draftMode`, `after`
- Generate functions: `generateStaticParams`, `generateMetadata`

## Error Handling

See [best-practices/error-handling.md](./best-practices/error-handling.md) for:
- `error.tsx`, `global-error.tsx`, `not-found.tsx`
- `redirect`, `permanentRedirect`, `notFound`
- `forbidden`, `unauthorized` (auth errors)
- `unstable_rethrow` for catch blocks

## Data Patterns

See [best-practices/data-patterns.md](./best-practices/data-patterns.md) for:
- Server Components vs Server Actions vs Route Handlers
- Avoiding data waterfalls (`Promise.all`, Suspense, preload)
- Client component data fetching

## Route Handlers

See [best-practices/route-handlers.md](./best-practices/route-handlers.md) for:
- `route.ts` basics
- GET handler conflicts with `page.tsx`
- Environment behavior (no React DOM)
- When to use vs Server Actions

## Metadata & OG Images

See [best-practices/metadata.md](./best-practices/metadata.md) for:
- Static and dynamic metadata
- `generateMetadata` function
- OG image generation with `next/og`
- File-based metadata conventions

## Image Optimization

See [best-practices/image.md](./best-practices/image.md) for:
- Always use `next/image` over `<img>`
- Remote images configuration
- Responsive `sizes` attribute
- Blur placeholders
- Priority loading for LCP

## Font Optimization

See [best-practices/font.md](./best-practices/font.md) for:
- `next/font` setup
- Google Fonts, local fonts
- Tailwind CSS integration
- Preloading subsets

## Bundling

See [best-practices/bundling.md](./best-practices/bundling.md) for:
- Server-incompatible packages
- CSS imports (not link tags)
- Polyfills (already included)
- ESM/CommonJS issues
- Bundle analysis

## Scripts

See [best-practices/scripts.md](./best-practices/scripts.md) for:
- `next/script` vs native script tags
- Inline scripts need `id`
- Loading strategies
- Google Analytics with `@next/third-parties`

## Hydration Errors

See [best-practices/hydration-error.md](./best-practices/hydration-error.md) for:
- Common causes (browser APIs, dates, invalid HTML)
- Debugging with error overlay
- Fixes for each cause

## Suspense Boundaries

See [best-practices/suspense-boundaries.md](./best-practices/suspense-boundaries.md) for:
- CSR bailout with `useSearchParams` and `usePathname`
- Which hooks require Suspense boundaries

## Parallel & Intercepting Routes

See [best-practices/parallel-routes.md](./best-practices/parallel-routes.md) for:
- Modal patterns with `@slot` and `(.)` interceptors
- `default.tsx` for fallbacks
- Closing modals correctly with `router.back()`

## Self-Hosting

See [best-practices/self-hosting.md](./best-practices/self-hosting.md) for:
- `output: 'standalone'` for Docker
- Cache handlers for multi-instance ISR
- What works vs needs extra setup

## Debug Tricks

See [best-practices/debug-tricks.md](./best-practices/debug-tricks.md) for:
- MCP endpoint for AI-assisted debugging
- Rebuild specific routes with `--debug-build-paths`
