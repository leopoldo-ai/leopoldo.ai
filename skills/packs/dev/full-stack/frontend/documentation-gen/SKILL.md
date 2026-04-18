---
name: documentation-gen
description: "Use when generating code documentation, API docs, or project wikis. Covers TypeDoc, TSDoc comments, Storybook Docs, and README generation. OSS-first: TypeDoc and TSDoc primary. Triggers on: documentation, TypeDoc, TSDoc, API docs, JSDoc, README, code docs, doc generation."
type: technique
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

# Documentation Gen -- Code Documentation for TypeScript Projects

## Why This Exists

| Problem | Solution |
|---------|----------|
| Code without docs is unmaintainable | Automated doc generation from code |
| Documentation drifts from implementation | TypeDoc generates from source, always in sync |
| No documentation workflow in plugin | Patterns for TSDoc, TypeDoc, and README |

Inspired by [anthropics/knowledge-work-plugins/engineering/documentation](https://github.com/anthropics/knowledge-work-plugins).

## OSS-First Philosophy

| Recommended (OSS) | Purpose |
|-------------------|---------|
| TypeDoc | API docs from TypeScript source |
| TSDoc | Standard comment format |
| Storybook Docs | Component documentation |
| Fumadocs | Documentation site framework |

## Core Workflow

### 1. TSDoc Comments

```typescript
/**
 * Calculates the total price including tax.
 *
 * @param items - Array of items with price and quantity
 * @param taxRate - Tax rate as decimal (e.g., 0.21 for 21%)
 * @returns Total price including tax, rounded to 2 decimal places
 *
 * @example
 * ```typescript
 * const total = calculateTotal(
 *   [{ price: 10, quantity: 2 }, { price: 5, quantity: 1 }],
 *   0.21
 * )
 * // Returns 30.25
 * ```
 *
 * @throws {Error} If items array is empty
 * @see {@link CartItem} for item structure
 */
export function calculateTotal(items: CartItem[], taxRate: number): number {
  if (items.length === 0) throw new Error("Items array cannot be empty")
  const subtotal = items.reduce((sum, item) => sum + item.price * item.quantity, 0)
  return Math.round((subtotal * (1 + taxRate)) * 100) / 100
}

/**
 * Represents an item in the shopping cart.
 */
export interface CartItem {
  /** Product name */
  name: string
  /** Price per unit in the base currency */
  price: number
  /** Number of units (must be >= 1) */
  quantity: number
}
```

### 2. TypeDoc Setup

```bash
npm install -D typedoc
```

```json
// typedoc.json
{
  "entryPoints": ["src/index.ts"],
  "out": "docs/api",
  "plugin": ["typedoc-plugin-markdown"],
  "readme": "none",
  "excludePrivate": true,
  "excludeInternal": true,
  "categorizeByGroup": true
}
```

```bash
npx typedoc # Generates docs/api/
```

### 3. README Template

```markdown
# Project Name

Brief description of what this project does.

## Quick Start

(bash)
npm install
npm run dev
(end)

## Architecture

(brief description of project structure)

## API Reference

[Generated docs](./docs/api/README.md)

## Contributing

(contribution guidelines)

## License

MIT
```

### 4. What to Document

| Always Document | Skip |
|----------------|------|
| Public API functions and types | Internal utility functions |
| Configuration options | Obvious getter/setter |
| Error conditions and edge cases | Self-explanatory code |
| Complex algorithms | Simple CRUD operations |
| Integration points | Framework boilerplate |

## Rules

1. TSDoc format for ALL public APIs (functions, types, interfaces)
2. Every @param, @returns, and @throws documented
3. Include at least one @example for complex functions
4. TypeDoc for automated API reference generation
5. README.md in every package/module root
6. Document the WHY, not just the WHAT
7. Keep docs close to code (TSDoc > wiki)

## Anti-Patterns

| Anti-Pattern | Why Wrong | Do Instead |
|-------------|-----------|------------|
| No documentation at all | Unmaintainable codebase | TSDoc on public APIs, README per module |
| Stale wiki pages | Documentation lies | TypeDoc from source (always current) |
| Documenting obvious code | Noise, not signal | Document complex logic and edge cases |
| README without Quick Start | New devs can't get started | Always include setup instructions |
| JSDoc instead of TSDoc | Different standard, less TypeScript support | TSDoc (TypeScript standard) |
