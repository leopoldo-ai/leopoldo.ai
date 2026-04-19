---
name: state-management
description: "Use when choosing or implementing state management in React apps. Covers Zustand (global), TanStack Query (server), Jotai (atomic), URL state, and React Context. OSS-first: Zustand and TanStack Query primary, Redux as legacy fallback. Triggers on: state management, global state, Zustand, TanStack Query, Jotai, Redux, Context, prop drilling, caching, server state."
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

# State Management -- Client and Server State for React

## Why This Exists

| Problem | Solution |
|---------|----------|
| No state management guidance in plugin | Decision framework + patterns for every state type |
| Developers default to Redux or put server state in stores | Modern patterns: Zustand + TanStack Query |
| SSR hydration issues with state libraries | Next.js-compatible patterns for all libraries |

## OSS-First Philosophy

| Recommended (OSS) | Aware Of (Legacy/Premium) |
|-------------------|--------------------------|
| Zustand (global client state) | Redux Toolkit |
| TanStack Query (server state) | SWR |
| Jotai (atomic state) | Recoil (deprecated) |
| nuqs (URL state) | manual useSearchParams |

## Decision Framework

```
What kind of state?

SERVER STATE (data from API, needs caching/sync)
  -> TanStack Query. Always. No exceptions.

GLOBAL CLIENT STATE (theme, sidebar, user preferences)
  -> Zustand. Simple API, tiny bundle, devtools.

ATOMIC/GRANULAR STATE (many independent pieces, derived values)
  -> Jotai. Bottom-up, no providers needed.

SIMPLE LOCAL STATE (form input, toggle, counter)
  -> useState. Don't overthink it.

INFREQUENT GLOBAL STATE (locale, theme, auth context)
  -> React Context + useReducer. Fine for rare updates.

SHAREABLE/BOOKMARKABLE STATE (filters, pagination, search)
  -> URL state with nuqs or useSearchParams.
```

## Core Workflow

### 1. Zustand (Global Client State)

```typescript
// stores/use-sidebar-store.ts
import { create } from "zustand"
import { persist, devtools } from "zustand/middleware"

interface SidebarStore {
  isOpen: boolean
  toggle: () => void
  close: () => void
}

export const useSidebarStore = create<SidebarStore>()(
  devtools(
    persist(
      (set) => ({
        isOpen: true,
        toggle: () => set((s) => ({ isOpen: !s.isOpen })),
        close: () => set({ isOpen: false })
      }),
      { name: "sidebar-store" }
    )
  )
)

// Usage in component (auto-selects, no unnecessary re-renders)
function Sidebar() {
  const isOpen = useSidebarStore((s) => s.isOpen)
  const toggle = useSidebarStore((s) => s.toggle)
  // ...
}
```

### 2. TanStack Query (Server State)

```typescript
// hooks/use-users.ts
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query"

export function useUsers() {
  return useQuery({
    queryKey: ["users"],
    queryFn: () => fetch("/api/users").then((r) => r.json()),
    staleTime: 5 * 60 * 1000, // 5 minutes
  })
}

export function useUpdateUser() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (user: User) =>
      fetch(`/api/users/${user.id}`, {
        method: "PATCH",
        body: JSON.stringify(user)
      }),
    // Optimistic update
    onMutate: async (newUser) => {
      await queryClient.cancelQueries({ queryKey: ["users"] })
      const previous = queryClient.getQueryData(["users"])
      queryClient.setQueryData(["users"], (old: User[]) =>
        old.map((u) => (u.id === newUser.id ? { ...u, ...newUser } : u))
      )
      return { previous }
    },
    onError: (_, __, context) => {
      queryClient.setQueryData(["users"], context?.previous)
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ["users"] })
    }
  })
}
```

### 3. Jotai (Atomic State)

```typescript
import { atom, useAtom, useAtomValue } from "jotai"

// Base atoms
const countAtom = atom(0)
const doubledAtom = atom((get) => get(countAtom) * 2) // Derived

// Async atom
const userAtom = atom(async () => {
  const res = await fetch("/api/me")
  return res.json()
})

// Usage
function Counter() {
  const [count, setCount] = useAtom(countAtom)
  const doubled = useAtomValue(doubledAtom)
  // ...
}
```

### 4. URL State (nuqs)

```typescript
import { useQueryState, parseAsInteger } from "nuqs"

function ProductList() {
  const [page, setPage] = useQueryState("page", parseAsInteger.withDefault(1))
  const [search, setSearch] = useQueryState("q", { defaultValue: "" })
  const [sort, setSort] = useQueryState("sort", { defaultValue: "name" })
  // URL: /products?page=2&q=shoes&sort=price
}
```

### 5. Next.js SSR Hydration

```typescript
// Zustand with SSR (avoid hydration mismatch)
import { create } from "zustand"

// Option A: Suppress hydration warning for client-only state
const useStore = create(() => ({ count: 0 }))

// Option B: Initialize from server props
// In Server Component: pass initial data as prop
// In Client Component: initialize store from prop

// TanStack Query with SSR (prefetching)
import { HydrationBoundary, dehydrate } from "@tanstack/react-query"

export default async function Page() {
  const queryClient = new QueryClient()
  await queryClient.prefetchQuery({ queryKey: ["users"], queryFn: getUsers })

  return (
    <HydrationBoundary state={dehydrate(queryClient)}>
      <UserList />
    </HydrationBoundary>
  )
}
```

## Rules

1. TanStack Query for ALL server state. Never put API data in Zustand/Redux.
2. Zustand for global client state. Simpler than Redux, smaller bundle.
3. Start with useState. Escalate only when you hit a real problem.
4. URL state for anything that should be shareable/bookmarkable.
5. React Context is fine for theme/locale/auth (infrequent updates only).
6. Use selectors in Zustand to prevent unnecessary re-renders.
7. Set staleTime in TanStack Query (default 0 means refetch on every mount).

## Anti-Patterns

| Anti-Pattern | Why Wrong | Do Instead |
|-------------|-----------|------------|
| Redux for new projects | Over-complex for most apps | Zustand (90% simpler API) |
| Server state in Zustand/Redux | No caching, stale data, manual sync | TanStack Query (built-in cache + sync) |
| React Context for frequent updates | Re-renders entire tree | Zustand or Jotai (granular subscriptions) |
| Prop drilling > 2 levels | Unmaintainable, rigid | Zustand store or composition pattern |
| No staleTime on queries | Refetch on every mount (wasteful) | Set staleTime based on data freshness needs |
| Global state for form values | Over-engineering | Local useState or form library |
