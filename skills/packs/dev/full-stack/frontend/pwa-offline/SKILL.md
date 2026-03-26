---
name: pwa-offline
description: "Use when building Progressive Web Apps with offline support. Covers service workers, caching strategies, install prompts, and push notifications. OSS-first: Serwist and Workbox primary. Triggers on: PWA, progressive web app, offline, service worker, cache, install prompt, push notifications, Serwist, Workbox."
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

# PWA Offline -- Progressive Web Apps

## Why This Exists

| Problem | Solution |
|---------|----------|
| Mobile-first experiences need offline support | Service worker patterns with Serwist |
| PWA reduces dependency on app stores | Installable web apps with cache strategies |

## OSS-First Philosophy

| Recommended (OSS) | Aware Of |
|-------------------|----------|
| Serwist (modern Workbox fork) | Workbox (Google) |
| next-pwa / @serwist/next | -- |
| Web Push API | OneSignal (premium) |

## Core Workflow

### 1. Setup with Serwist (Next.js)

```bash
npm install @serwist/next serwist
```

```typescript
// next.config.ts
import withSerwistInit from "@serwist/next"

const withSerwist = withSerwistInit({
  swSrc: "app/sw.ts",
  swDest: "public/sw.js"
})

export default withSerwist({ /* your next config */ })
```

```typescript
// app/sw.ts
import { defaultCache } from "@serwist/next/worker"
import { Serwist } from "serwist"

const serwist = new Serwist({
  precacheEntries: self.__SW_MANIFEST,
  skipWaiting: true,
  clientsClaim: true,
  runtimeCaching: defaultCache
})

serwist.addEventListeners()
```

### 2. Web App Manifest

```json
// public/manifest.json
{
  "name": "My App",
  "short_name": "MyApp",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#3A6B55",
  "icons": [
    { "src": "/icon-192.png", "sizes": "192x192", "type": "image/png" },
    { "src": "/icon-512.png", "sizes": "512x512", "type": "image/png" }
  ]
}
```

### 3. Caching Strategies

```typescript
// Cache-first for static assets (fonts, images)
// Network-first for API data (fresh data preferred)
// Stale-while-revalidate for pages (fast + eventually fresh)

import { CacheFirst, NetworkFirst, StaleWhileRevalidate } from "serwist"

const runtimeCaching = [
  { urlPattern: /\.(?:png|jpg|jpeg|svg|gif|webp)$/, handler: new CacheFirst({
    cacheName: "images", expiration: { maxEntries: 100, maxAgeSeconds: 30 * 24 * 60 * 60 }
  })},
  { urlPattern: /\/api\//, handler: new NetworkFirst({
    cacheName: "api", expiration: { maxEntries: 50, maxAgeSeconds: 5 * 60 }
  })},
  { urlPattern: /\/$/, handler: new StaleWhileRevalidate({ cacheName: "pages" }) }
]
```

### 4. Install Prompt

```typescript
"use client"
import { useEffect, useState } from "react"

export function InstallPrompt() {
  const [deferredPrompt, setDeferredPrompt] = useState<any>(null)

  useEffect(() => {
    window.addEventListener("beforeinstallprompt", (e) => {
      e.preventDefault()
      setDeferredPrompt(e)
    })
  }, [])

  if (!deferredPrompt) return null

  return (
    <button onClick={async () => {
      deferredPrompt.prompt()
      const { outcome } = await deferredPrompt.userChoice
      setDeferredPrompt(null)
    }}>
      Install App
    </button>
  )
}
```

## Rules

1. Serwist for Next.js PWA (modern Workbox fork, maintained)
2. Cache-first for assets, network-first for API, SWR for pages
3. Web app manifest is mandatory (name, icons, display mode)
4. Test offline mode in Chrome DevTools > Application > Service Workers
5. Always provide fallback offline page
6. Service worker updates: skipWaiting + clientsClaim for immediate activation

## Anti-Patterns

| Anti-Pattern | Why Wrong | Do Instead |
|-------------|-----------|------------|
| Caching everything aggressively | Stale data, storage waste | Strategy per resource type |
| No offline fallback page | Blank page when offline | Cache a minimal offline.html |
| Ignoring SW update lifecycle | Users stuck on old version | skipWaiting + notification to refresh |
| PWA without HTTPS | SW requires secure context | Always deploy with HTTPS |
