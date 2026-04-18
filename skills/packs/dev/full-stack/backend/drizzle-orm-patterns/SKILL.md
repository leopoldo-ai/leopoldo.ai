---
name: drizzle-orm-patterns
description: "Use when working with Drizzle ORM: defining schemas, running migrations, debugging database issues, or applying migration safety rules. Triggers on: Drizzle, schema, migration, db:push, $inferSelect, array column."
type: technique
---

# Drizzle ORM Patterns

Common pitfalls and correct patterns for Drizzle ORM.

## Critical Rules

- **NEVER** change primary key types (`serial` > `varchar` or `varchar` > `uuid`) in production. Breaks migrations.
- Array columns: `text('col').array()` (CORRECT), not `array(text('col'))`.
- Always export `$inferSelect` and `$inferInsert` types for every table.
- Use `drizzle-zod` (`createInsertSchema`/`createSelectSchema`) for validation.
- Always use `.returning()` on inserts/updates when you need the result.
- Use `{ mode: 'date' }` on timestamp columns to get Date objects instead of strings.
- Use `$onUpdate(() => new Date())` for `updatedAt` columns.

## Relations

**One-to-many:** Use `relations()` with `many()` and `one()` linking via `fields`/`references`.

**Many-to-many:** Create a junction table with composite primary key, define `relations()` on all three tables.

**Self-referencing:** Use `relationName` parameter to disambiguate parent/children.

**Eager loading (relational API):**
```typescript
const usersWithPosts = await db.query.users.findMany({
  with: { posts: { with: { comments: true } } },
  columns: { id: true, name: true },
});
```

**Manual joins** when you need custom shapes: `innerJoin`, `leftJoin` with `eq()`.

## Transactions

- `db.transaction(async (tx) => { ... })` runs atomically.
- Nested transactions use PostgreSQL savepoints. Inner failure rolls back only inner block.
- Throw inside transaction to trigger automatic rollback.
- **Optimistic locking:** Add `version` column, include `eq(table.version, expectedVersion)` in WHERE, increment on update. Empty result = conflict.

## Advanced Patterns

**Soft delete:** Add `deletedAt: timestamp('deleted_at')`, filter with `isNull(table.deletedAt)` everywhere. Create reusable `notDeleted()` helper.

**Pagination (offset):** `.limit(pageSize).offset((page - 1) * pageSize)` + count query.

**Pagination (cursor, preferred for large datasets):** Fetch `pageSize + 1`, check `hasMore`, return `nextCursor`.

**Full-text search:** Custom `tsvector` type + GIN index + `plainto_tsquery` in WHERE + `ts_rank` for ordering.

**JSONB:** Use `jsonb('col').$type<YourType>()`. Query with `->>'key'` operator. Update single key with `|| '{"key": "value"}'::jsonb`.

**Database enums:** `pgEnum('name', ['val1', 'val2'])`, use in table definitions.

**Computed columns:** Use `sql` in selects or `generatedAlwaysAs()` for stored generated columns (PG 12+).

## Migration Safety

**NEVER rename columns directly.** Use three-step approach:
1. Add new column
2. Backfill data (in batches for large tables)
3. Drop old column after all code references new column

**Zero-downtime rules:**
- Additive only per deploy (add columns/tables/indexes, never remove)
- New code must work with both old and new schema during rollout
- `CREATE INDEX CONCURRENTLY` for large tables (not via `db:push`)
- `NOT NULL` additions require a `DEFAULT` or backfill step

**Migration checklist:**
- Run `drizzle-kit generate` and review SQL before applying
- Test on production-size data copy, not empty tables
- Verify no `DROP COLUMN` or `ALTER TYPE` on high-traffic tables without a plan
- Measure migration duration on production-size dataset
- Test rollback capability

## Common Pitfalls

| Pitfall | Problem | Fix |
|---------|---------|-----|
| N+1 queries | Loop fetching related rows | Use `db.query.*.findMany({ with: ... })` or manual JOIN |
| Missing FK indexes | PostgreSQL does NOT auto-create indexes on FK columns | Add explicit `index()` on all FK columns |
| Forgetting `.returning()` | Insert/update returns nothing useful | Always chain `.returning()` |
| `.get()` vs `.all()` | `.get()` returns single row, silently discards rest (SQLite only) | Use `.all()` for multiple rows |
| Timestamp strings | Drizzle defaults to string mode for timestamps | Use `timestamp('col', { mode: 'date' })` |
| Batch insert OOM | Large arrays cause memory issues | Chunk into batches of ~1000 rows |

## Performance

- **Prepared statements:** `db.select().from(table).where(eq(col, placeholder('param'))).prepare('name')` then `.execute({ param: value })`.
- **Batch inserts:** Pass array to `.values()`. Chunk 10K+ rows.
- **Upsert:** `.onConflictDoUpdate({ target: col, set: { ... } })`.
- **Connection pooling:** Neon HTTP for serverless (one query/request), Neon WebSocket or `pg.Pool` for long-running (supports transactions).
- **Logging:** `{ logger: true }` in drizzle config, or custom `LogWriter`. Use `.toSQL()` for debugging without executing.

## Quick Checklist

- [ ] No primary key type changes
- [ ] Array columns use `text().array()` syntax
- [ ] Insert/select types exported for all models
- [ ] Using drizzle-zod for validation
- [ ] Migration tested in dev before prod
- [ ] Foreign key columns have indexes
- [ ] `.returning()` used on inserts/updates
- [ ] Relations defined for all foreign keys
- [ ] Transactions used for multi-table writes
- [ ] Soft delete filter applied globally where needed
