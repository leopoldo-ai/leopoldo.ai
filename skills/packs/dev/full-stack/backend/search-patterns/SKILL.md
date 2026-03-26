---
name: search-patterns
description: "Use when implementing search functionality with Meilisearch, Typesense, or full-text search. Covers indexing, faceted search, typo tolerance, and instant search UI. OSS-first: Meilisearch and Typesense primary, Algolia as premium aware. Triggers on: search, Meilisearch, Typesense, Algolia, full-text search, instant search, faceted search, indexing."
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

# Search Patterns -- Full-Text Search with Meilisearch

## Why This Exists

| Problem | Solution |
|---------|----------|
| SQL LIKE queries are slow and basic | Dedicated search engine with typo tolerance |
| Algolia is expensive at scale | Meilisearch: OSS, self-hostable |

## OSS-First Philosophy

| Recommended (OSS) | Aware Of (Premium) |
|-------------------|-------------------|
| Meilisearch (self-host) | Algolia |
| Typesense (self-host) | Elasticsearch Cloud |

## Core Workflow

### 1. Meilisearch Setup

```bash
# Docker
docker run -p 7700:7700 getmeili/meilisearch:latest

# Client
npm install meilisearch
```

```typescript
import { MeiliSearch } from "meilisearch"

const client = new MeiliSearch({ host: "http://localhost:7700", apiKey: process.env.MEILI_KEY })

// Index documents
const index = client.index("products")
await index.addDocuments([
  { id: 1, name: "Wireless Headphones", category: "electronics", price: 79.99 },
  { id: 2, name: "Running Shoes", category: "sports", price: 129.99 }
])

// Configure searchable attributes and facets
await index.updateSettings({
  searchableAttributes: ["name", "description", "category"],
  filterableAttributes: ["category", "price"],
  sortableAttributes: ["price", "created_at"]
})

// Search
const results = await index.search("headphones", {
  filter: ["category = electronics", "price < 100"],
  sort: ["price:asc"],
  limit: 20
})
```

### 2. Sync from Database

```typescript
// Keep search index in sync with database changes
async function syncToSearch(product: Product) {
  await client.index("products").addDocuments([product])
}

// Webhook or after-save hook
async function onProductUpdate(product: Product) {
  await db.update(products).set(product).where(eq(products.id, product.id))
  await syncToSearch(product) // Keep search in sync
}
```

## Rules

1. Meilisearch for search features (fast, typo-tolerant, OSS)
2. Sync search index from database (database is source of truth)
3. Configure searchable/filterable attributes explicitly
4. Use InstantSearch.js for frontend search UI
5. API key separation: search key (public), admin key (server only)

## Anti-Patterns

| Anti-Pattern | Why Wrong | Do Instead |
|-------------|-----------|------------|
| SQL LIKE for search | Slow, no typo tolerance, no ranking | Dedicated search engine |
| Search as source of truth | Data loss risk | Database is truth, search is index |
| Admin key in frontend | Full access to anyone | Search-only key for client |
| No sync strategy | Stale search results | Sync on every write (webhook or hook) |
