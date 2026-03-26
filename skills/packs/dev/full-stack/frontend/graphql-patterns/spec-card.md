# Spec Card: graphql-patterns

## Identity
- **Pack:** full-stack
- **Sub-pack:** frontend
- **Layer:** userland

## Scope
GraphQL client-side patterns for React applications. Covers schema design awareness, client setup, queries, mutations, caching, and code generation. OSS-first: Apollo Client and urql as primary clients, Relay as "aware of" advanced option.

Does NOT cover: GraphQL server implementation (covered by graphql-backend in backend sub-pack), REST API design (covered by api-designer), or database queries.

## Expected Inputs
- User wants to consume a GraphQL API in React/Next.js
- User mentions Apollo Client, urql, GraphQL, queries, mutations
- User needs caching, optimistic updates, or real-time subscriptions

## Expected Outputs
- GraphQL client setup (Apollo Client or urql)
- Query and mutation patterns with TypeScript
- Cache management and invalidation strategies
- Code generation setup (graphql-codegen)
- Real-time subscription patterns

## Must-Have Features
1. Apollo Client 4.x setup with Next.js App Router
2. urql setup as lightweight alternative
3. TypeScript code generation with graphql-codegen
4. Query patterns: useQuery, useSuspenseQuery, prefetching
5. Mutation patterns: optimistic updates, cache updates
6. Error handling and loading states
7. Pagination patterns (cursor-based, offset-based)
8. Fragment colocation pattern

## Nice-to-Have Features
1. GraphQL subscriptions (WebSocket)
2. Persisted queries for performance
3. Relay-style patterns (connections, edges, nodes)
4. Apollo DevTools usage
5. Schema-first vs code-first awareness

## Anti-Patterns
- Manual TypeScript types for GraphQL (use codegen)
- Fetching entire objects when fragments suffice
- Not using cache normalization
- Over-fetching without field selection

## Integration Points
- `graphql-backend`: Server-side GraphQL (Apollo Server, Yoga)
- `state-management`: Apollo cache as state management
- `vitest-testing`: Mocking GraphQL queries in tests
- `nextjs-developer`: SSR with GraphQL (RSC data fetching)

## Success Criteria
- Apollo Client works with Next.js App Router and RSC
- Code generation produces typed hooks from schema
- Optimistic updates work for mutations
- Cache invalidation is predictable and debuggable

## Key Rules
- Apollo Client for full-featured needs (caching, devtools, ecosystem)
- urql for lightweight needs (smaller bundle, simpler API)
- ALWAYS use graphql-codegen for TypeScript types
- Fragment colocation: keep queries close to components
- Normalize cache by default (InMemoryCache with typePolicies)
