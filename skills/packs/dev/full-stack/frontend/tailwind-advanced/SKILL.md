---
name: tailwind-advanced
description: "Use when working with advanced Tailwind CSS patterns: v4 features, custom plugins, design tokens, dark mode, responsive design, and animation. Triggers on: Tailwind v4, custom plugin, design tokens, CSS variables, dark mode, responsive, container queries, @apply, theme."
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

# Tailwind Advanced -- Tailwind CSS v4 Deep Patterns

## Why This Exists

| Problem | Solution |
|---------|----------|
| Tailwind knowledge fragmented across 4+ skills | Dedicated deep skill for advanced patterns |
| Tailwind v4 has breaking changes from v3 | Up-to-date v4 patterns and migration |
| Design tokens and theming are complex | Structured patterns for tokens, dark mode, custom plugins |

## Core Workflow

### 1. Tailwind v4 Setup

```css
/* app.css - Tailwind v4 uses CSS-first configuration */
@import "tailwindcss";

@theme {
  --color-primary: #3A6B55;
  --color-primary-light: #4A8B6A;
  --color-primary-dark: #2A5B45;
  --color-accent: #D4A853;

  --font-display: "Instrument Serif", serif;
  --font-body: "Inter", sans-serif;
  --font-mono: "JetBrains Mono", monospace;

  --spacing-page: 1rem;
  --radius-card: 0.75rem;

  /* Responsive breakpoints (customizable in v4) */
  --breakpoint-sm: 640px;
  --breakpoint-md: 768px;
  --breakpoint-lg: 1024px;
  --breakpoint-xl: 1280px;
}
```

### 2. Design Tokens via CSS Variables

```css
/* Semantic color tokens */
@theme {
  --color-surface: var(--color-white);
  --color-surface-elevated: var(--color-gray-50);
  --color-text-primary: var(--color-gray-900);
  --color-text-secondary: var(--color-gray-500);
  --color-border: var(--color-gray-200);
}

/* Dark mode overrides */
@media (prefers-color-scheme: dark) {
  :root {
    --color-surface: var(--color-gray-950);
    --color-surface-elevated: var(--color-gray-900);
    --color-text-primary: var(--color-gray-50);
    --color-text-secondary: var(--color-gray-400);
    --color-border: var(--color-gray-800);
  }
}
```

```html
<!-- Usage: semantic classes work in both light and dark -->
<div class="bg-surface text-text-primary border-border rounded-card p-page">
  Content adapts to color scheme automatically
</div>
```

### 3. Dark Mode

```typescript
// Class-based dark mode (manual toggle)
// tailwind.config.ts (v3) or @theme directive (v4)

// Toggle component
"use client"
import { useTheme } from "next-themes"

export function ThemeToggle() {
  const { theme, setTheme } = useTheme()
  return (
    <button onClick={() => setTheme(theme === "dark" ? "light" : "dark")}>
      {theme === "dark" ? "Light" : "Dark"}
    </button>
  )
}

// Usage in classes
<div className="bg-white dark:bg-gray-950 text-gray-900 dark:text-gray-50">
```

### 4. Container Queries

```html
<!-- Parent defines container -->
<div class="@container">
  <!-- Children respond to container width, not viewport -->
  <div class="@sm:flex @md:grid @md:grid-cols-2 @lg:grid-cols-3">
    <Card />
  </div>
</div>
```

### 5. Custom Animations

```css
@theme {
  --animate-fade-in: fade-in 0.3s ease-out;
  --animate-slide-up: slide-up 0.4s ease-out;
  --animate-scale-in: scale-in 0.2s ease-out;
}

@keyframes fade-in {
  from { opacity: 0; }
  to { opacity: 1; }
}

@keyframes slide-up {
  from { opacity: 0; transform: translateY(8px); }
  to { opacity: 1; transform: translateY(0); }
}

@keyframes scale-in {
  from { opacity: 0; transform: scale(0.95); }
  to { opacity: 1; transform: scale(1); }
}
```

```html
<div class="animate-fade-in">Appears with fade</div>
<div class="motion-reduce:animate-none">Respects prefers-reduced-motion</div>
```

### 6. Responsive Patterns

```html
<!-- Mobile-first responsive -->
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">

<!-- Responsive typography -->
<h1 class="text-2xl sm:text-3xl md:text-4xl lg:text-5xl font-display">

<!-- Responsive spacing -->
<section class="px-4 sm:px-6 lg:px-8 py-8 sm:py-12 lg:py-16">

<!-- Hide/show at breakpoints -->
<nav class="hidden md:flex">Desktop nav</nav>
<button class="md:hidden">Mobile menu</button>
```

### 7. Component Patterns with cn()

```typescript
// lib/utils.ts
import { clsx, type ClassValue } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

// Component with variants
interface ButtonProps {
  variant?: "primary" | "secondary" | "ghost"
  size?: "sm" | "md" | "lg"
}

export function Button({ variant = "primary", size = "md", className, ...props }: ButtonProps) {
  return (
    <button className={cn(
      "rounded-lg font-medium transition-colors",
      variant === "primary" && "bg-primary text-white hover:bg-primary-dark",
      variant === "secondary" && "bg-surface border border-border hover:bg-surface-elevated",
      variant === "ghost" && "hover:bg-surface-elevated",
      size === "sm" && "px-3 py-1.5 text-sm",
      size === "md" && "px-4 py-2 text-base",
      size === "lg" && "px-6 py-3 text-lg",
      className
    )} {...props} />
  )
}
```

## Rules

1. Tailwind v4: use CSS-first config (@theme), not tailwind.config.ts
2. Design tokens via CSS variables (semantic naming, theme-aware)
3. Always mobile-first (base styles for mobile, add breakpoint modifiers)
4. Use cn() (clsx + twMerge) for conditional and mergeable classes
5. Always add motion-reduce variants for animations
6. Container queries for component-level responsiveness
7. Dark mode: prefer system preference, allow manual override

## Anti-Patterns

| Anti-Pattern | Why Wrong | Do Instead |
|-------------|-----------|------------|
| @apply for everything | Defeats purpose of utility-first | Use @apply sparingly, prefer utility classes |
| Hardcoded colors in classes | No theming, no dark mode | Use design tokens via CSS variables |
| Viewport-only responsive | Components break in different containers | Container queries for component responsiveness |
| No motion-reduce consideration | Accessibility violation | Always add motion-reduce:animate-none |
| tailwind.config.ts in v4 | v4 uses CSS-first config | Use @theme directive in CSS |
