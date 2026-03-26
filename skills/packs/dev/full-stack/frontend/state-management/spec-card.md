# Spec Card: state-management

## Identity
- **Pack:** full-stack
- **Sub-pack:** frontend
- **Layer:** userland

## Scope
Client-side state management patterns for React applications. Covers local state, global state, server state, and URL state. OSS-first: Zustand for global state, TanStack Query for server state, Jotai for atomic state. Redux Toolkit as "aware of" legacy.

Does NOT cover: server-side state (covered by nextjs-developer), form state (covered by form-patterns), or database state (covered by backend sub-pack).

## Expected Inputs
- User asks about state management, global state, caching
- User mentions Zustand, TanStack Query, Jotai, Redux, Context API
- User has prop drilling or state synchronization issues

## Expected Outputs
- State management strategy recommendation based on app complexity
- Store setup and patterns for chosen library
- Server state caching and invalidation patterns
- Decision framework: when to use what

## Must-Have Features
1. Decision framework: local vs global vs server vs URL state
2. Zustand: store creation, selectors, middleware (persist, devtools)
3. TanStack Query: queries, mutations, cache invalidation, optimistic updates
4. Jotai: atoms, derived atoms, async atoms
5. React Context + useReducer for simple cases
6. URL state with nuqs or useSearchParams
7. Hydration patterns for SSR (Next.js)
8. DevTools integration for debugging

## Nice-to-Have Features
1. Redux Toolkit patterns (legacy awareness)
2. Zustand + TanStack Query combination patterns
3. State machine patterns (XState awareness)
4. Performance optimization: selector patterns, equality functions

## Anti-Patterns
- Using Redux for new projects (Zustand is simpler and lighter)
- Putting server state in global store (use TanStack Query)
- React Context for frequently changing values (causes re-renders)
- Prop drilling more than 2 levels without considering alternatives

## Integration Points
- `nextjs-developer`: SSR hydration, Server Components
- `react-best-practices`: Re-render optimization
- `form-patterns`: Form state management
- `tanstack-ecosystem`: TanStack Router state

## Success Criteria
- Developer can choose correct state solution in under 1 minute
- Zustand store works with Next.js SSR without hydration issues
- TanStack Query patterns handle optimistic updates correctly
- No unnecessary re-renders from state changes

## Key Rules
- Zustand for global client state, ALWAYS over Redux for new projects
- TanStack Query for server state, ALWAYS over manual fetch+state
- React Context is fine for themes, locale, auth (infrequent changes)
- URL state for filters, pagination, search (shareable, bookmarkable)
- Start simple (useState), escalate only when needed
