---
name: web-quality
description: "Use when optimizing web performance, accessibility, SEO, or Core Web Vitals. Covers Lighthouse audits, LCP/INP/CLS optimization, image optimization, font loading, and technical SEO. Triggers on: performance, Lighthouse, Core Web Vitals, LCP, INP, CLS, SEO, page speed, web vitals, optimization, meta tags, Open Graph, schema.org."
type: technique
metadata:
  author: leopoldo
  source: https://github.com/addyosmani/web-quality-skills
  created: 2026-03-24
  forge_strategy: adapt
  forge_sources:
    - https://github.com/addyosmani/web-quality-skills
license: MIT
upstream:
  url: https://github.com/addyosmani/web-quality-skills
  version: main
  last_checked: 2026-03-24
---

# Web Quality -- Performance, SEO, and Core Web Vitals

## Why This Exists

| Problem | Solution |
|---------|----------|
| No performance or SEO guidance in plugin | Complete Lighthouse + CWV + SEO patterns |
| Developers ship slow sites without metrics | Measurable targets with actionable fixes |
| SEO is an afterthought | Technical SEO built into development workflow |

Adapted from [addyosmani/web-quality-skills](https://github.com/addyosmani/web-quality-skills) (Google Chrome team).

## Core Web Vitals Targets

| Metric | Good | Needs Improvement | Poor |
|--------|------|-------------------|------|
| LCP (Largest Contentful Paint) | < 2.5s | 2.5-4.0s | > 4.0s |
| INP (Interaction to Next Paint) | < 200ms | 200-500ms | > 500ms |
| CLS (Cumulative Layout Shift) | < 0.1 | 0.1-0.25 | > 0.25 |

## Core Workflow

### 1. LCP Optimization

```typescript
// Priority: images, fonts, critical CSS

// Next.js Image (automatic optimization)
import Image from "next/image"
<Image src="/hero.jpg" alt="Hero" width={1200} height={600} priority />

// Preload critical resources
// app/layout.tsx
export const metadata = {
  other: { "link": [{ rel: "preload", href: "/fonts/inter.woff2", as: "font", crossOrigin: "anonymous" }] }
}

// Avoid render-blocking CSS
// Use next/font for font optimization (zero layout shift)
import { Inter } from "next/font/google"
const inter = Inter({ subsets: ["latin"], display: "swap" })
```

**LCP checklist:**
- Hero image: use `priority` prop, serve WebP/AVIF, correct dimensions
- Fonts: use `next/font`, `display: swap`, preload critical fonts
- CSS: inline critical CSS, defer non-critical
- Server: fast TTFB (< 800ms), use CDN, enable compression

### 2. INP Optimization

```typescript
// Break up long tasks
// Use React.startTransition for non-urgent updates
import { startTransition } from "react"

function SearchPage() {
  const [query, setQuery] = useState("")
  const [results, setResults] = useState([])

  const handleSearch = (value: string) => {
    setQuery(value) // Urgent: update input immediately
    startTransition(() => {
      setResults(filterResults(value)) // Non-urgent: can be deferred
    })
  }
}

// Debounce expensive handlers
import { useDebouncedCallback } from "use-debounce"
const handleResize = useDebouncedCallback(() => recalculate(), 150)

// Virtualize long lists
import { useVirtualizer } from "@tanstack/react-virtual"
```

### 3. CLS Optimization

```typescript
// Always set explicit dimensions on images/videos
<Image src="/photo.jpg" width={800} height={600} alt="Photo" />

// Reserve space for dynamic content
<div className="min-h-[200px]">{isLoading ? <Skeleton /> : <Content />}</div>

// Use CSS contain for isolated components
.card { contain: layout style paint; }

// Avoid injecting content above existing content
// Load ads/embeds with fixed containers
```

### 4. Technical SEO

```typescript
// app/layout.tsx - Global metadata
import { Metadata } from "next"

export const metadata: Metadata = {
  title: { template: "%s | MySite", default: "MySite" },
  description: "Your site description",
  openGraph: {
    type: "website",
    locale: "en_US",
    url: "https://mysite.com",
    siteName: "MySite",
    images: [{ url: "/og-image.jpg", width: 1200, height: 630 }]
  },
  twitter: { card: "summary_large_image", creator: "@handle" },
  robots: { index: true, follow: true },
  alternates: { canonical: "https://mysite.com" }
}

// Per-page metadata
export const metadata: Metadata = {
  title: "About Us",
  description: "Learn about our team and mission"
}

// Structured data (JSON-LD)
export default function ProductPage({ product }) {
  return (
    <>
      <script type="application/ld+json" dangerouslySetInnerHTML={{
        __html: JSON.stringify({
          "@context": "https://schema.org",
          "@type": "Product",
          name: product.name,
          description: product.description,
          offers: { "@type": "Offer", price: product.price, priceCurrency: "USD" }
        })
      }} />
      <ProductContent product={product} />
    </>
  )
}

// sitemap.ts
export default async function sitemap() {
  const posts = await getPosts()
  return [
    { url: "https://mysite.com", lastModified: new Date() },
    ...posts.map((post) => ({
      url: `https://mysite.com/blog/${post.slug}`,
      lastModified: post.updatedAt
    }))
  ]
}

// robots.ts
export default function robots() {
  return {
    rules: { userAgent: "*", allow: "/", disallow: "/api/" },
    sitemap: "https://mysite.com/sitemap.xml"
  }
}
```

### 5. Image Optimization

```typescript
// Next.js Image: automatic WebP/AVIF, responsive sizes, lazy loading
<Image
  src="/photo.jpg"
  alt="Description"
  width={800}
  height={600}
  sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 33vw"
  placeholder="blur"
  blurDataURL={blurHash}
/>

// For backgrounds: use CSS with image-set for format negotiation
// For icons: use inline SVG or sprite sheet
// For hero images: always use priority prop
```

## Rules

1. Measure BEFORE optimizing (Lighthouse CI, Web Vitals reporting)
2. LCP < 2.5s, INP < 200ms, CLS < 0.1 for all pages
3. Every page MUST have: title, description, Open Graph, canonical URL
4. Images MUST have alt text, explicit dimensions, and lazy loading (except hero)
5. Use next/font for all fonts (zero CLS, automatic optimization)
6. Structured data (JSON-LD) for products, articles, organizations
7. sitemap.xml and robots.txt are mandatory
8. Run Lighthouse in CI to catch regressions

## Anti-Patterns

| Anti-Pattern | Why Wrong | Do Instead |
|-------------|-----------|------------|
| No explicit image dimensions | CLS from layout shift | Always set width/height or aspect-ratio |
| Render-blocking third-party scripts | Destroys LCP and INP | Defer or load after interaction |
| Missing meta tags | Poor SEO, bad social sharing | Full metadata in layout + per-page |
| Optimizing without measuring | Wasted effort on wrong things | Lighthouse CI, Real User Monitoring |
| Client-side rendering for content pages | Bad SEO, slow LCP | SSR or SSG for content pages |
| No sitemap or robots.txt | Search engines can't crawl efficiently | Always generate both |
