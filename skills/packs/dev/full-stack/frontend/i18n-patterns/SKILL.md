---
name: i18n-patterns
description: "Use when adding internationalization to Next.js or React apps. Covers next-intl, i18next, locale routing, message extraction, and pluralization. OSS-first: next-intl and i18next primary. Triggers on: i18n, internationalization, localization, translation, locale, language, next-intl, i18next, multilingual."
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

# i18n Patterns -- Internationalization for React/Next.js

## Why This Exists

| Problem | Solution |
|---------|----------|
| Global apps need i18n, no guidance in plugin | Complete next-intl patterns for Next.js |
| i18n setup is complex (routing, SSR, extraction) | Step-by-step with proven patterns |

## OSS-First Philosophy

| Recommended (OSS) | Aware Of (Premium) |
|-------------------|-------------------|
| next-intl (Next.js) | Crowdin, Phrase, Lokalise |
| i18next + react-i18next (any React) | Transifex |
| ICU Message Format | -- |

## Core Workflow

### 1. next-intl Setup (Next.js)

```bash
npm install next-intl
```

```typescript
// i18n/request.ts
import { getRequestConfig } from "next-intl/server"

export default getRequestConfig(async ({ requestLocale }) => {
  const locale = await requestLocale
  return {
    locale,
    messages: (await import(`../messages/${locale}.json`)).default
  }
})
```

```typescript
// middleware.ts
import createMiddleware from "next-intl/middleware"

export default createMiddleware({
  locales: ["en", "it", "de", "fr"],
  defaultLocale: "en"
})

export const config = { matcher: ["/((?!api|_next|.*\\..*).*)"] }
```

### 2. Translation Files

```json
// messages/en.json
{
  "common": { "save": "Save", "cancel": "Cancel", "loading": "Loading..." },
  "auth": {
    "login": "Log in",
    "signup": "Sign up",
    "welcome": "Welcome, {name}!"
  },
  "products": {
    "count": "{count, plural, =0 {No products} one {1 product} other {{count} products}}"
  }
}
```

```json
// messages/it.json
{
  "common": { "save": "Salva", "cancel": "Annulla", "loading": "Caricamento..." },
  "auth": {
    "login": "Accedi",
    "signup": "Registrati",
    "welcome": "Benvenuto, {name}!"
  }
}
```

### 3. Usage in Components

```typescript
// Server Component
import { useTranslations } from "next-intl"

export default function Dashboard() {
  const t = useTranslations("common")
  return <button>{t("save")}</button>
}

// With variables
const t = useTranslations("auth")
<p>{t("welcome", { name: user.name })}</p>

// Pluralization
const t = useTranslations("products")
<p>{t("count", { count: products.length })}</p>

// Client Component
"use client"
import { useTranslations } from "next-intl"
// Same API works in client components
```

### 4. Locale Switching

```typescript
"use client"
import { useLocale } from "next-intl"
import { useRouter, usePathname } from "next-intl/navigation"

export function LocaleSwitcher() {
  const locale = useLocale()
  const router = useRouter()
  const pathname = usePathname()

  const switchLocale = (newLocale: string) => {
    router.replace(pathname, { locale: newLocale })
  }

  return (
    <select value={locale} onChange={(e) => switchLocale(e.target.value)}>
      <option value="en">English</option>
      <option value="it">Italiano</option>
      <option value="de">Deutsch</option>
    </select>
  )
}
```

## Rules

1. next-intl for Next.js projects (best App Router integration)
2. i18next for non-Next.js React projects
3. ICU Message Format for pluralization and variables
4. Locale in URL path (/en/about, /it/about), not cookies or headers
5. Default locale can omit prefix (/about = English)
6. Translate at component level, not at page level
7. Use namespaces to organize translations (auth, common, products)

## Anti-Patterns

| Anti-Pattern | Why Wrong | Do Instead |
|-------------|-----------|------------|
| Hardcoded strings in components | Impossible to translate | Always use t() function |
| Cookie-based locale detection only | Not SEO-friendly, not shareable | URL-based locale (/en/, /it/) |
| One giant translation file | Unmaintainable | Namespaced JSON files |
| String concatenation for dynamic text | Breaks in different languages | ICU Message Format with variables |
| Translating at build time only | No dynamic locale switching | Runtime translation with next-intl |
