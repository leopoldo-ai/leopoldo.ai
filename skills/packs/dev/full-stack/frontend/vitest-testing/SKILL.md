---
name: vitest-testing
description: "Use when writing unit or component tests, setting up test configuration, or migrating from Jest. Covers Vitest setup, React Testing Library, mocking, coverage, and CI integration. OSS-first: Vitest is the standard, Jest as legacy fallback. Triggers on: vitest, unit test, component test, testing, mock, coverage, vi.fn, vi.mock."
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

# Vitest Testing -- Modern Unit and Component Testing

## Why This Exists

| Problem | Solution |
|---------|----------|
| test-master skill is generic, no Vitest-specific patterns | Deep Vitest patterns for React/Next.js |
| Jest is slow and requires complex ESM config | Vitest: native ESM, TypeScript, 10x faster |
| Component testing patterns missing from plugin | React Testing Library integration with best practices |

## OSS-First Philosophy

| Recommended (OSS) | Aware Of (Legacy) |
|-------------------|-------------------|
| Vitest | Jest |
| React Testing Library | Enzyme (deprecated) |
| MSW (API mocking) | Manual fetch mocks |
| v8 coverage | Istanbul |

## Core Workflow

### 1. Setup

```typescript
// vitest.config.ts
import { defineConfig } from "vitest/config"
import react from "@vitejs/plugin-react"
import tsconfigPaths from "vite-tsconfig-paths"

export default defineConfig({
  plugins: [react(), tsconfigPaths()],
  test: {
    environment: "jsdom",
    globals: true,
    setupFiles: ["./vitest.setup.ts"],
    css: true,
    coverage: {
      provider: "v8",
      reporter: ["text", "lcov", "html"],
      thresholds: { statements: 80, branches: 80, functions: 80, lines: 80 }
    }
  }
})
```

```typescript
// vitest.setup.ts
import "@testing-library/jest-dom/vitest"
import { cleanup } from "@testing-library/react"
import { afterEach } from "vitest"

afterEach(() => cleanup())
```

### 2. Component Testing

```typescript
import { render, screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, it, expect } from "vitest"
import { Counter } from "./Counter"

describe("Counter", () => {
  it("increments on click", async () => {
    const user = userEvent.setup()
    render(<Counter initialCount={0} />)

    expect(screen.getByText("Count: 0")).toBeInTheDocument()
    await user.click(screen.getByRole("button", { name: /increment/i }))
    expect(screen.getByText("Count: 1")).toBeInTheDocument()
  })
})
```

### 3. Mocking Patterns

```typescript
// Module mock
vi.mock("@/lib/api", () => ({
  fetchUsers: vi.fn().mockResolvedValue([{ id: 1, name: "Alice" }])
}))

// Function spy
const onClick = vi.fn()
render(<Button onClick={onClick} />)
await user.click(screen.getByRole("button"))
expect(onClick).toHaveBeenCalledOnce()

// Timer mock
vi.useFakeTimers()
// ... trigger debounced action
vi.advanceTimersByTime(300)
vi.useRealTimers()

// Environment variable mock
vi.stubEnv("API_URL", "http://test.local")
```

### 4. API Mocking with MSW

```typescript
import { setupServer } from "msw/node"
import { http, HttpResponse } from "msw"

const server = setupServer(
  http.get("/api/users", () =>
    HttpResponse.json([{ id: 1, name: "Alice" }])
  )
)

beforeAll(() => server.listen())
afterEach(() => server.resetHandlers())
afterAll(() => server.close())
```

### 5. Testing Next.js Patterns

```typescript
// Testing Server Components (render as async)
import { render, screen } from "@testing-library/react"

// Mock next/navigation
vi.mock("next/navigation", () => ({
  useRouter: () => ({ push: vi.fn(), back: vi.fn() }),
  usePathname: () => "/dashboard",
  useSearchParams: () => new URLSearchParams()
}))

// Mock next/headers
vi.mock("next/headers", () => ({
  cookies: () => ({ get: vi.fn(), set: vi.fn() }),
  headers: () => new Headers()
}))
```

### 6. Coverage and CI

```json
// package.json scripts
{
  "test": "vitest",
  "test:ci": "vitest run --coverage",
  "test:watch": "vitest --watch",
  "test:ui": "vitest --ui"
}
```

```yaml
# GitHub Actions
- name: Run tests
  run: npm run test:ci
- name: Upload coverage
  uses: codecov/codecov-action@v4
  with:
    files: ./coverage/lcov.info
```

## Rules

1. Vitest for ALL new projects. Jest only for existing codebases.
2. Use @testing-library/react, NEVER enzyme
3. Use userEvent over fireEvent (more realistic interactions)
4. Test behavior, not implementation (query by role, text, label)
5. MSW for API mocking, not manual vi.mock on fetch
6. Coverage thresholds: 80% minimum, enforce in CI
7. One assertion focus per test (clear failure messages)
8. Setup files for global cleanup and matchers

## Anti-Patterns

| Anti-Pattern | Why Wrong | Do Instead |
|-------------|-----------|------------|
| Testing implementation details | Brittle, breaks on refactor | Test behavior: what user sees and does |
| Snapshot-only tests | False confidence, lazy testing | Meaningful assertions on specific elements |
| Mocking everything | Tests don't catch real bugs | Mock boundaries (API, timers), test real logic |
| No cleanup between tests | State leaks, flaky tests | afterEach cleanup (automatic with setup) |
| Using Jest in new projects | Slower, ESM config pain | Vitest: zero config for ESM + TypeScript |
| No coverage thresholds | Coverage erodes silently | Set 80% threshold, enforce in CI |
