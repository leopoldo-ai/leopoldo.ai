---
name: brand-to-ui
description: "Use when bootstrapping UI from brand identity or syncing brand changes to code, transforming brand-kit.yaml into design tokens: Tailwind config, CSS custom properties, TypeScript constants, React ThemeProvider."
type: technique
version: 0.1.0
layer: userland
category: frontend
triggers:
  - pattern: "design tokens|brand to code|tailwind config from brand|theme provider|css variables from brand|design system setup"
dependencies:
  hard:
    - brand-kit
  soft:
    - frontend-design
    - nextjs-developer
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
metadata:
  author: lucadealbertis
  source: custom
  domain: frontend
  triggers: tokens,brand,tailwind,theme,css-variables,design-system
  role: specialist
  scope: generation
  output-format: code
  related-skills: brand-kit,frontend-design,nextjs-developer,motion-design
license: proprietary
---

# Brand to UI — Design Token Pipeline

Transforms `brand-kit.yaml` into production-ready design tokens and framework integrations. No external dependencies — generates code directly from brand values.

## Role Definition

You are a design systems engineer bridging brand identity and frontend implementation. You understand that design tokens are the contract between designers and developers — a single source of truth that prevents drift between brand guidelines and shipped code.

## When to Use

- Bootstrapping a new project's design system from brand-kit.yaml
- Syncing brand changes to code after brand-kit.yaml updates
- Setting up Tailwind theme, CSS variables, or React ThemeProvider
- Creating a dark mode from brand-kit values

## When NOT to Use

- Brand identity doesn't exist yet (use `brand-kit-builder` first)
- Pure document generation (document skills read brand-kit directly)
- Animation patterns (use `motion-design`)

---

## Stack Detection

**Before generating, detect the project's tech stack:**

1. Check for `tailwind.config.*` → generate Tailwind theme extension
2. Check for `package.json` with `react` dependency → generate React ThemeProvider
3. Check for `next.config.*` → use Next.js-specific patterns
4. **Always generate:** CSS custom properties + TypeScript constants (universal)

If stack is unclear, ask the user. Don't generate Tailwind config for a non-Tailwind project.

---

## Pipeline

```
brand-kit.yaml
    ↓ (1) Read + validate
Structured brand values
    ↓ (2) Generate tokens
    ├── tokens.css        (always)
    ├── tokens.ts         (always)
    ├── tailwind.config.ts (if Tailwind detected)
    ↓ (3) Generate integration
    ├── ThemeProvider.tsx  (if React detected)
    └── useTheme.ts       (if React detected)
```

---

## Step 1: Read Brand Kit

Use the `brand-kit` skill's discovery protocol:
1. Check `./brand-kit.yaml`
2. Check `./.brand/brand-kit.yaml`
3. Validate schema
4. If not found → error: "No brand-kit.yaml found. Run brand-kit-builder or create one from a preset."

---

## Step 2: Generate CSS Custom Properties

**File:** `src/styles/tokens.css` (or project's styles directory)

```css
:root {
  /* Brand Colors */
  --color-primary: #1B3A5C;
  --color-secondary: #2E86AB;
  --color-accent: #F18F01;

  /* Neutral Scale */
  --color-neutral-50: #FAFAFA;
  --color-neutral-100: #F5F5F5;
  --color-neutral-200: #E5E5E5;
  --color-neutral-300: #D4D4D4;
  --color-neutral-400: #A3A3A3;
  --color-neutral-500: #737373;
  --color-neutral-600: #525252;
  --color-neutral-700: #404040;
  --color-neutral-800: #262626;
  --color-neutral-900: #171717;

  /* Semantic Colors */
  --color-success: #16A34A;
  --color-warning: #EAB308;
  --color-error: #DC2626;
  --color-info: #2563EB;

  /* Typography */
  --font-heading: 'Inter', system-ui, sans-serif;
  --font-body: 'Inter', system-ui, sans-serif;
  --font-mono: 'JetBrains Mono', monospace;

  /* Type Scale (base: 16px, ratio: 1.25) */
  --text-xs: 0.64rem;
  --text-sm: 0.80rem;
  --text-base: 1rem;
  --text-lg: 1.25rem;
  --text-xl: 1.563rem;
  --text-2xl: 1.953rem;
  --text-3xl: 2.441rem;
  --text-4xl: 3.052rem;

  /* Spacing (unit: 4px) */
  --space-0: 0;
  --space-1: 0.25rem;
  --space-2: 0.5rem;
  --space-3: 0.75rem;
  --space-4: 1rem;
  --space-5: 1.25rem;
  --space-6: 1.5rem;
  --space-8: 2rem;
  --space-10: 2.5rem;
  --space-12: 3rem;
  --space-16: 4rem;
  --space-20: 5rem;
  --space-24: 6rem;
}

/* Dark Mode */
[data-theme="dark"] {
  --color-primary: /* lightened 15% */;
  --color-secondary: /* lightened 10% */;
  --color-neutral-50: var(--color-neutral-900);
  --color-neutral-100: var(--color-neutral-800);
  /* ... reversed neutral scale */
  --color-neutral-800: var(--color-neutral-100);
  --color-neutral-900: var(--color-neutral-50);
}
```

---

## Step 3: Generate TypeScript Constants

**File:** `src/lib/tokens.ts`

```typescript
export const colors = {
  primary: '#1B3A5C',
  secondary: '#2E86AB',
  accent: '#F18F01',
  neutral: {
    50: '#FAFAFA', 100: '#F5F5F5', 200: '#E5E5E5',
    300: '#D4D4D4', 400: '#A3A3A3', 500: '#737373',
    600: '#525252', 700: '#404040', 800: '#262626', 900: '#171717',
  },
  semantic: {
    success: '#16A34A', warning: '#EAB308',
    error: '#DC2626', info: '#2563EB',
  },
} as const

export const typography = {
  heading: { family: "'Inter', system-ui, sans-serif", weights: [600, 700] },
  body: { family: "'Inter', system-ui, sans-serif", weights: [400, 500] },
  mono: { family: "'JetBrains Mono', monospace", weights: [400, 500] },
  scale: { base: 16, ratio: 1.25 },
} as const

export const spacing = {
  unit: 4,
  scale: [0, 1, 2, 3, 4, 5, 6, 8, 10, 12, 16, 20, 24],
} as const

export type BrandColors = typeof colors
export type BrandTypography = typeof typography
```

---

## Step 4: Generate Tailwind Config (if detected)

**File:** `tailwind.config.ts` (extend existing, don't replace)

```typescript
import type { Config } from 'tailwindcss'

const config: Config = {
  // ... existing config preserved
  theme: {
    extend: {
      colors: {
        brand: {
          primary: '#1B3A5C',
          secondary: '#2E86AB',
          accent: '#F18F01',
        },
        neutral: {
          50: '#FAFAFA', 100: '#F5F5F5', /* ... */
        },
        success: '#16A34A',
        warning: '#EAB308',
        error: '#DC2626',
        info: '#2563EB',
      },
      fontFamily: {
        heading: ['Inter', 'system-ui', 'sans-serif'],
        body: ['Inter', 'system-ui', 'sans-serif'],
        mono: ['JetBrains Mono', 'monospace'],
      },
      fontSize: {
        xs: '0.64rem', sm: '0.80rem', base: '1rem',
        lg: '1.25rem', xl: '1.563rem', '2xl': '1.953rem',
        '3xl': '2.441rem', '4xl': '3.052rem',
      },
    },
  },
}
export default config
```

**Important:** If `tailwind.config.ts` already exists, MERGE into the `extend` block. Never overwrite existing configuration.

---

## Step 5: Generate React ThemeProvider (if detected)

**File:** `src/components/ThemeProvider.tsx`

```tsx
'use client'

import { createContext, useContext, useEffect, useState, type ReactNode } from 'react'
import { colors, typography, spacing } from '@/lib/tokens'

type Theme = 'light' | 'dark'

interface ThemeContextValue {
  theme: Theme
  setTheme: (theme: Theme) => void
  toggleTheme: () => void
  colors: typeof colors
  typography: typeof typography
  spacing: typeof spacing
}

const ThemeContext = createContext<ThemeContextValue | null>(null)

export function ThemeProvider({ children, defaultTheme = 'light' }: {
  children: ReactNode
  defaultTheme?: Theme
}) {
  const [theme, setTheme] = useState<Theme>(defaultTheme)

  useEffect(() => {
    document.documentElement.setAttribute('data-theme', theme)
  }, [theme])

  const toggleTheme = () => setTheme(t => t === 'light' ? 'dark' : 'light')

  return (
    <ThemeContext.Provider value={{ theme, setTheme, toggleTheme, colors, typography, spacing }}>
      {children}
    </ThemeContext.Provider>
  )
}

export function useTheme() {
  const context = useContext(ThemeContext)
  if (!context) throw new Error('useTheme must be used within ThemeProvider')
  return context
}
```

---

## Dark Mode Derivation

Auto-generate dark mode from light mode values:

1. **Primary/Secondary:** Increase lightness by 15-20% in HSL
2. **Neutral scale:** Reverse (50 ↔ 900, 100 ↔ 800, etc.)
3. **Semantic colors:** Increase lightness by 10% for dark backgrounds
4. **Accent:** Keep as-is (accents work on both light and dark)

Apply via `[data-theme="dark"]` CSS selector (set by ThemeProvider).

---

## Incremental Updates

When brand-kit.yaml changes:
1. Re-read brand-kit.yaml
2. Diff against current tokens
3. Update only changed values in all output files
4. Report changes: "Updated primary color #1B3A5C → #1A3050 in tokens.css, tokens.ts, tailwind.config.ts"

---

## Adaptive Output Summary

| Detected Stack | Files Generated |
|---------------|----------------|
| Tailwind + React + Next.js | tokens.css, tokens.ts, tailwind.config.ts, ThemeProvider.tsx |
| Tailwind + React | tokens.css, tokens.ts, tailwind.config.ts, ThemeProvider.tsx |
| React (no Tailwind) | tokens.css, tokens.ts, ThemeProvider.tsx |
| Tailwind (no React) | tokens.css, tokens.ts, tailwind.config.ts |
| Neither | tokens.css, tokens.ts |

---

**Version:** 0.1.0
**Dipendenze:** brand-kit (hard), frontend-design (soft)
**Trigger:** Skill-router quando si menziona design tokens, brand to code, tailwind config, theme provider
