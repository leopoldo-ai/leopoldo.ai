---
name: graphql-patterns
description: "Use when consuming GraphQL APIs in React/Next.js apps. Covers Apollo Client, urql, code generation, caching, mutations, and subscriptions. OSS-first: Apollo Client and urql primary. Triggers on: GraphQL, Apollo Client, urql, useQuery, useMutation, graphql-codegen, gql, schema, subscription."
type: technique
metadata:
  author: leopoldo
  source: https://github.com/apollographql/skills
  created: 2026-03-24
  forge_strategy: adapt
  forge_sources:
    - https://github.com/apollographql/skills
license: MIT
upstream:
  url: https://github.com/apollographql/skills
  version: main
  last_checked: 2026-03-24
---

# GraphQL Patterns -- Client-Side GraphQL for React

## Why This Exists

| Problem | Solution |
|---------|----------|
| GraphQL is in 50%+ of modern backends, zero coverage | Complete client-side GraphQL patterns |
| Manual TypeScript types for GraphQL are error-prone | Code generation with graphql-codegen |
| Caching and invalidation are hard without guidance | Apollo Client normalized cache patterns |

Adapted from official [apollographql/skills](https://github.com/apollographql/skills).

## OSS-First Philosophy

| Recommended (OSS) | Aware Of (Alternative) |
|-------------------|----------------------|
| Apollo Client 4.x | Relay (advanced) |
| urql (lightweight) | graphql-request (minimal) |
| graphql-codegen | Manual types |

## Decision Framework

```
Full-featured needs (caching, devtools, large app)?
  -> Apollo Client

Lightweight needs (small app, simple queries)?
  -> urql

Minimal needs (just fetch, no cache)?
  -> graphql-request with codegen types
```

## Core Workflow

### 1. Apollo Client Setup (Next.js)

```typescript
// lib/apollo-client.ts
import { ApolloClient, InMemoryCache, HttpLink } from "@apollo/client"
import { registerApolloClient } from "@apollo/experimental-nextjs-app-support"

export const { getClient } = registerApolloClient(() => {
  return new ApolloClient({
    cache: new InMemoryCache(),
    link: new HttpLink({ uri: process.env.GRAPHQL_URL })
  })
})

// app/layout.tsx - Provider
import { ApolloWrapper } from "@/lib/apollo-wrapper"

export default function RootLayout({ children }) {
  return <ApolloWrapper>{children}</ApolloWrapper>
}
```

### 2. Code Generation (graphql-codegen)

```bash
npm install -D @graphql-codegen/cli @graphql-codegen/typescript @graphql-codegen/typescript-operations @graphql-codegen/typed-document-node
```

```yaml
# codegen.ts
import { CodegenConfig } from "@graphql-codegen/cli"

const config: CodegenConfig = {
  schema: "http://localhost:4000/graphql",
  documents: ["src/**/*.graphql", "src/**/*.tsx"],
  generates: {
    "./src/generated/graphql.ts": {
      plugins: [
        "typescript",
        "typescript-operations",
        "typed-document-node"
      ]
    }
  }
}
export default config
```

```graphql
# queries/users.graphql
query GetUsers($limit: Int) {
  users(limit: $limit) {
    id
    name
    email
    avatar
  }
}

mutation UpdateUser($id: ID!, $input: UpdateUserInput!) {
  updateUser(id: $id, input: $input) {
    id
    name
    email
  }
}
```

### 3. Queries

```typescript
import { useQuery, useSuspenseQuery } from "@apollo/client"
import { GetUsersDocument } from "@/generated/graphql"

// Standard query
function UserList() {
  const { data, loading, error } = useQuery(GetUsersDocument, {
    variables: { limit: 10 }
  })
  if (loading) return <Skeleton />
  if (error) return <Error message={error.message} />
  return data.users.map((user) => <UserCard key={user.id} user={user} />)
}

// Suspense query (React 18+, recommended)
function UserList() {
  const { data } = useSuspenseQuery(GetUsersDocument, {
    variables: { limit: 10 }
  })
  return data.users.map((user) => <UserCard key={user.id} user={user} />)
}
```

### 4. Mutations with Optimistic Updates

```typescript
import { useMutation } from "@apollo/client"
import { UpdateUserDocument, GetUsersDocument } from "@/generated/graphql"

function EditUser({ user }) {
  const [updateUser] = useMutation(UpdateUserDocument, {
    optimisticResponse: {
      updateUser: { ...user, name: "Updating...", __typename: "User" }
    },
    update(cache, { data }) {
      // Cache automatically updates by ID (normalized cache)
    },
    refetchQueries: [{ query: GetUsersDocument }]
  })

  const handleSave = (input) => {
    updateUser({ variables: { id: user.id, input } })
  }
}
```

### 5. Fragment Colocation

```graphql
# components/UserCard.graphql
fragment UserCardFields on User {
  id
  name
  avatar
  role
}
```

```typescript
// Keep fragment close to the component that uses it
import { FragmentType, useFragment } from "@/generated/graphql"
import { UserCardFieldsFragmentDoc } from "@/generated/graphql"

function UserCard({ user }: { user: FragmentType<typeof UserCardFieldsFragmentDoc> }) {
  const data = useFragment(UserCardFieldsFragmentDoc, user)
  return <div>{data.name}</div>
}
```

### 6. Pagination

```typescript
// Cursor-based pagination
const { data, fetchMore } = useQuery(GetUsersDocument, {
  variables: { first: 10 }
})

const loadMore = () => {
  fetchMore({
    variables: { after: data.users.pageInfo.endCursor },
    updateQuery: (prev, { fetchMoreResult }) => ({
      users: {
        ...fetchMoreResult.users,
        edges: [...prev.users.edges, ...fetchMoreResult.users.edges]
      }
    })
  })
}
```

### 7. urql (Lightweight Alternative)

```typescript
import { Client, cacheExchange, fetchExchange } from "urql"

const client = new Client({
  url: process.env.GRAPHQL_URL,
  exchanges: [cacheExchange, fetchExchange]
})

// Usage is similar to Apollo but with lighter bundle
import { useQuery } from "urql"

function UserList() {
  const [result] = useQuery({ query: GetUsersQuery })
  const { data, fetching, error } = result
}
```

## Rules

1. Apollo Client for full-featured needs (caching, devtools, ecosystem)
2. urql for lightweight needs (smaller bundle, simpler mental model)
3. ALWAYS use graphql-codegen for TypeScript (never manual types)
4. Fragment colocation: keep queries close to components that use them
5. Normalize cache by default (InMemoryCache with proper typePolicies)
6. Use useSuspenseQuery over useQuery in React 18+ (cleaner loading states)
7. Optimistic updates for mutations that affect visible UI

## Anti-Patterns

| Anti-Pattern | Why Wrong | Do Instead |
|-------------|-----------|------------|
| Manual TypeScript types for GQL | Drift from schema, maintenance burden | graphql-codegen (auto-generated, type-safe) |
| Fetching entire objects always | Over-fetching, wasted bandwidth | Fragments for exactly the fields needed |
| No cache normalization | Stale data, duplicate requests | InMemoryCache with proper type policies |
| refetchQueries for every mutation | Wasteful network calls | Optimistic updates + cache updates |
| Not using Suspense in React 18+ | Complex loading state management | useSuspenseQuery + Suspense boundaries |
| Inline query strings everywhere | Hard to find, no colocation | .graphql files colocated with components |
