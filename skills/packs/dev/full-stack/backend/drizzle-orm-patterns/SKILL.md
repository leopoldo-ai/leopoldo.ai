---
name: drizzle-orm-patterns
version: 0.2.0
description: "Drizzle ORM patterns and migration safety rules. Use when defining schemas, running migrations, or debugging database issues. Triggers on: Drizzle, schema, migration, db:push, $inferSelect, array column."
metadata:
  author: BarisSozen
  source: https://github.com/BarisSozen/claude
license: none (no-license)
---

# Drizzle ORM Pitfalls

Common pitfalls and correct patterns for Drizzle ORM.

## When to Use

- Defining database schemas
- Running migrations (db:push)
- Creating insert/select types
- Working with array columns
- Reviewing Drizzle ORM code

## Workflow

### Step 1: Verify Schema Types

Check that types are exported correctly.

### Step 2: Check Array Syntax

Verify array columns use correct syntax.

### Step 3: Test Migrations Safely

Never change primary key types in production.

---

## Critical Rules

```typescript
// ❌ NEVER change primary key types
// serial → varchar or varchar → uuid BREAKS migrations

// ✅ Array columns - correct syntax
allowedTokens: text('allowed_tokens').array()  // CORRECT
// ❌ WRONG: array(text('allowed_tokens'))

// ✅ Always create insert/select types
export type Strategy = typeof strategies.$inferSelect;
export type NewStrategy = typeof strategies.$inferInsert;

// ✅ Use drizzle-zod for validation
import { createInsertSchema } from 'drizzle-zod';
export const insertStrategySchema = createInsertSchema(strategies);
```

## Migration Safety

```bash
# Safe schema sync
npm run db:push

# If data-loss warning and you're sure
npm run db:push --force

# NEVER in production without backup
```

## Type Inference Pattern

```typescript
// ✅ Infer types from schema
import { strategies } from './schema';

type Strategy = typeof strategies.$inferSelect;
type NewStrategy = typeof strategies.$inferInsert;

// ✅ With Zod validation
import { createInsertSchema, createSelectSchema } from 'drizzle-zod';
import { z } from 'zod';

const insertSchema = createInsertSchema(strategies);
type StrategyInput = z.infer<typeof insertSchema>;
```

## Quick Checklist

- [ ] No primary key type changes
- [ ] Array columns use `text().array()` syntax
- [ ] Insert/select types exported for models
- [ ] Using drizzle-zod for validation
- [ ] Migration tested in dev before prod
- [ ] Foreign key columns have indexes
- [ ] `.returning()` used on inserts/updates when you need the result
- [ ] Relations defined for all foreign keys
- [ ] Transactions used for multi-table writes
- [ ] Soft delete filter applied globally where needed

---

## Relations & Joins

Drizzle supports a relational query API that maps foreign keys to traversable relations.

### Defining Relations

```typescript
import { pgTable, serial, text, integer, timestamp } from 'drizzle-orm/pg-core';
import { relations } from 'drizzle-orm';

// --- Tables ---

export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  name: text('name').notNull(),
  email: text('email').notNull().unique(),
  createdAt: timestamp('created_at').defaultNow().notNull(),
});

export const posts = pgTable('posts', {
  id: serial('id').primaryKey(),
  title: text('title').notNull(),
  content: text('content'),
  authorId: integer('author_id').notNull().references(() => users.id),
  createdAt: timestamp('created_at').defaultNow().notNull(),
});

export const comments = pgTable('comments', {
  id: serial('id').primaryKey(),
  body: text('body').notNull(),
  postId: integer('post_id').notNull().references(() => posts.id),
  authorId: integer('author_id').notNull().references(() => users.id),
});
```

### One-to-Many Relations

```typescript
// User has many posts
export const usersRelations = relations(users, ({ many }) => ({
  posts: many(posts),
  comments: many(comments),
}));

// Post belongs to user, has many comments
export const postsRelations = relations(posts, ({ one, many }) => ({
  author: one(users, {
    fields: [posts.authorId],
    references: [users.id],
  }),
  comments: many(comments),
}));

export const commentsRelations = relations(comments, ({ one }) => ({
  post: one(posts, {
    fields: [comments.postId],
    references: [posts.id],
  }),
  author: one(users, {
    fields: [comments.authorId],
    references: [users.id],
  }),
}));
```

### Many-to-Many Through Junction Tables

```typescript
export const tags = pgTable('tags', {
  id: serial('id').primaryKey(),
  name: text('name').notNull().unique(),
});

// Junction table
export const postsToTags = pgTable('posts_to_tags', {
  postId: integer('post_id').notNull().references(() => posts.id),
  tagId: integer('tag_id').notNull().references(() => tags.id),
}, (t) => ({
  pk: primaryKey({ columns: [t.postId, t.tagId] }),
}));

export const postsToTagsRelations = relations(postsToTags, ({ one }) => ({
  post: one(posts, {
    fields: [postsToTags.postId],
    references: [posts.id],
  }),
  tag: one(tags, {
    fields: [postsToTags.tagId],
    references: [tags.id],
  }),
}));

export const tagsRelations = relations(tags, ({ many }) => ({
  postsToTags: many(postsToTags),
}));

// Extend posts relations to include tags
// (merge with existing postsRelations above)
// postsToTags: many(postsToTags),
```

### Self-Referencing Relations (Categories / Tree)

```typescript
export const categories = pgTable('categories', {
  id: serial('id').primaryKey(),
  name: text('name').notNull(),
  parentId: integer('parent_id').references((): AnyPgColumn => categories.id),
});

export const categoriesRelations = relations(categories, ({ one, many }) => ({
  parent: one(categories, {
    fields: [categories.parentId],
    references: [categories.id],
    relationName: 'subcategories',
  }),
  children: many(categories, {
    relationName: 'subcategories',
  }),
}));
```

### Querying Relations (Eager Loading)

```typescript
// Fetch users with their posts (eager load)
const usersWithPosts = await db.query.users.findMany({
  with: {
    posts: true,
  },
});

// Nested eager loading: users → posts → comments
const usersDeep = await db.query.users.findMany({
  with: {
    posts: {
      with: {
        comments: true,
      },
    },
  },
});

// Selective columns + filtered relations
const usersFiltered = await db.query.users.findMany({
  columns: {
    id: true,
    name: true,
  },
  with: {
    posts: {
      where: (posts, { eq }) => eq(posts.published, true),
      limit: 5,
      orderBy: (posts, { desc }) => [desc(posts.createdAt)],
      columns: {
        id: true,
        title: true,
      },
    },
  },
});
```

### Lazy Loading (Manual Joins)

When you need more control, use explicit joins instead of the relational API:

```typescript
import { eq } from 'drizzle-orm';

// Inner join
const result = await db
  .select({
    postTitle: posts.title,
    authorName: users.name,
  })
  .from(posts)
  .innerJoin(users, eq(posts.authorId, users.id));

// Left join (includes posts without comments)
const postsWithComments = await db
  .select()
  .from(posts)
  .leftJoin(comments, eq(posts.id, comments.postId));

// Multiple joins
const fullData = await db
  .select({
    post: posts,
    author: users,
    comment: comments,
  })
  .from(posts)
  .innerJoin(users, eq(posts.authorId, users.id))
  .leftJoin(comments, eq(posts.id, comments.postId))
  .where(eq(users.id, userId));
```

---

## Transactions

### Basic Transaction Syntax

```typescript
import { db } from './db';

// All queries inside run atomically — all succeed or all roll back
const result = await db.transaction(async (tx) => {
  const [user] = await tx.insert(users).values({
    name: 'Alice',
    email: 'alice@example.com',
  }).returning();

  await tx.insert(posts).values({
    title: 'First Post',
    content: 'Hello world',
    authorId: user.id,
  });

  return user;
});
```

### Nested Transactions (Savepoints)

Drizzle supports nested transactions via PostgreSQL savepoints:

```typescript
await db.transaction(async (tx) => {
  await tx.insert(users).values({ name: 'Alice', email: 'alice@example.com' });

  // Nested transaction — creates a savepoint
  // If this fails, only work inside the nested block rolls back
  try {
    await tx.transaction(async (tx2) => {
      await tx2.insert(posts).values({
        title: 'Risky Post',
        authorId: 999, // may fail due to FK constraint
      });
    });
  } catch (e) {
    console.log('Nested transaction rolled back, outer continues');
  }

  // This still commits even if the nested transaction failed
  await tx.insert(posts).values({
    title: 'Safe Post',
    authorId: 1,
  });
});
```

### Error Handling and Rollback

```typescript
try {
  await db.transaction(async (tx) => {
    await tx.insert(users).values({ name: 'Bob', email: 'bob@example.com' });

    // Explicit rollback by throwing
    const balance = await getBalance(tx, accountId);
    if (balance < amount) {
      // Throw to trigger automatic rollback of the entire transaction
      throw new Error('Insufficient funds');
    }

    await tx.update(accounts)
      .set({ balance: sql`${accounts.balance} - ${amount}` })
      .where(eq(accounts.id, accountId));
  });
} catch (error) {
  // Transaction has been rolled back automatically
  console.error('Transaction failed:', error.message);
}
```

### Optimistic Locking Pattern

Use a version column to detect concurrent modifications:

```typescript
export const products = pgTable('products', {
  id: serial('id').primaryKey(),
  name: text('name').notNull(),
  stock: integer('stock').notNull().default(0),
  version: integer('version').notNull().default(0),
});

async function updateStock(productId: number, newStock: number, expectedVersion: number) {
  const result = await db
    .update(products)
    .set({
      stock: newStock,
      version: sql`${products.version} + 1`,
    })
    .where(
      and(
        eq(products.id, productId),
        eq(products.version, expectedVersion), // only update if version matches
      )
    )
    .returning();

  if (result.length === 0) {
    throw new Error('Conflict: product was modified by another transaction. Retry.');
  }

  return result[0];
}
```

---

## Advanced Patterns

### Soft Delete

```typescript
export const articles = pgTable('articles', {
  id: serial('id').primaryKey(),
  title: text('title').notNull(),
  deletedAt: timestamp('deleted_at'), // null = active, set = soft-deleted
});

// Soft delete a record
await db.update(articles)
  .set({ deletedAt: new Date() })
  .where(eq(articles.id, articleId));

// Query only active records (apply this filter everywhere)
const activeArticles = await db
  .select()
  .from(articles)
  .where(isNull(articles.deletedAt));

// Restore a soft-deleted record
await db.update(articles)
  .set({ deletedAt: null })
  .where(eq(articles.id, articleId));

// Helper: reusable "not deleted" filter
import { isNull, and, SQL } from 'drizzle-orm';

function notDeleted<T extends { deletedAt: any }>(table: T): SQL {
  return isNull(table.deletedAt);
}

// Usage
const results = await db.select().from(articles).where(notDeleted(articles));
```

### Pagination — Offset-Based

```typescript
async function getPageOffset(page: number, pageSize: number = 20) {
  const results = await db
    .select()
    .from(posts)
    .orderBy(desc(posts.createdAt))
    .limit(pageSize)
    .offset((page - 1) * pageSize);

  const [{ count }] = await db
    .select({ count: sql<number>`count(*)` })
    .from(posts);

  return {
    data: results,
    pagination: {
      page,
      pageSize,
      totalItems: Number(count),
      totalPages: Math.ceil(Number(count) / pageSize),
    },
  };
}
```

### Pagination — Cursor-Based (Preferred for Large Datasets)

```typescript
async function getPageCursor(cursor?: number, pageSize: number = 20) {
  const where = cursor
    ? lt(posts.id, cursor)  // fetch items with id less than cursor
    : undefined;

  const results = await db
    .select()
    .from(posts)
    .where(where)
    .orderBy(desc(posts.id))
    .limit(pageSize + 1); // fetch one extra to detect "has more"

  const hasMore = results.length > pageSize;
  const data = hasMore ? results.slice(0, pageSize) : results;
  const nextCursor = hasMore ? data[data.length - 1].id : null;

  return {
    data,
    nextCursor,
    hasMore,
  };
}
```

### Full-Text Search with PostgreSQL tsvector

```typescript
import { pgTable, serial, text, index, customType } from 'drizzle-orm/pg-core';
import { sql } from 'drizzle-orm';

// Custom type for tsvector
const tsvector = customType<{ data: string }>({
  dataType() {
    return 'tsvector';
  },
});

export const documents = pgTable('documents', {
  id: serial('id').primaryKey(),
  title: text('title').notNull(),
  body: text('body').notNull(),
  searchVector: tsvector('search_vector'),
}, (table) => ({
  searchIdx: index('search_idx').using('gin', table.searchVector),
}));

// Create trigger in migration to auto-update the vector:
// CREATE TRIGGER documents_search_update BEFORE INSERT OR UPDATE
// ON documents FOR EACH ROW EXECUTE FUNCTION
// tsvector_update_trigger(search_vector, 'pg_catalog.english', title, body);

// Full-text search query
const results = await db
  .select()
  .from(documents)
  .where(
    sql`${documents.searchVector} @@ plainto_tsquery('english', ${searchTerm})`
  )
  .orderBy(
    sql`ts_rank(${documents.searchVector}, plainto_tsquery('english', ${searchTerm})) DESC`
  )
  .limit(20);
```

### JSONB Columns

```typescript
import { pgTable, serial, text, jsonb } from 'drizzle-orm/pg-core';

export const settings = pgTable('settings', {
  id: serial('id').primaryKey(),
  userId: integer('user_id').notNull().references(() => users.id),
  preferences: jsonb('preferences').$type<{
    theme: 'light' | 'dark';
    notifications: boolean;
    language: string;
  }>().default({ theme: 'light', notifications: true, language: 'en' }),
  metadata: jsonb('metadata').$type<Record<string, unknown>>(),
});

// Insert with JSONB
await db.insert(settings).values({
  userId: 1,
  preferences: { theme: 'dark', notifications: false, language: 'it' },
  metadata: { source: 'onboarding', version: 2 },
});

// Query JSONB fields using SQL operators
const darkModeUsers = await db
  .select()
  .from(settings)
  .where(sql`${settings.preferences}->>'theme' = 'dark'`);

// Query nested JSONB values
const italianUsers = await db
  .select()
  .from(settings)
  .where(sql`${settings.preferences}->>'language' = 'it'`);

// Update a single key inside JSONB (without overwriting the whole object)
await db.update(settings)
  .set({
    preferences: sql`${settings.preferences} || '{"theme": "light"}'::jsonb`,
  })
  .where(eq(settings.userId, 1));

// Check if JSONB contains a key
const withMetadata = await db
  .select()
  .from(settings)
  .where(sql`${settings.metadata} ? 'source'`);
```

### Computed / Virtual Columns

Drizzle does not support virtual columns natively, but you can use `sql` in selects for computed values:

```typescript
const usersWithPostCount = await db
  .select({
    id: users.id,
    name: users.name,
    postCount: sql<number>`(
      SELECT count(*) FROM ${posts} WHERE ${posts.authorId} = ${users.id}
    )`.as('post_count'),
  })
  .from(users);

// Or use a generated column in the schema (PostgreSQL 12+)
export const orders = pgTable('orders', {
  id: serial('id').primaryKey(),
  quantity: integer('quantity').notNull(),
  unitPrice: integer('unit_price').notNull(), // in cents
  // Generated column — computed by the database, stored on disk
  totalPrice: integer('total_price').generatedAlwaysAs(
    sql`${orders.quantity} * ${orders.unitPrice}`
  ),
});
```

### Database Enums

```typescript
import { pgEnum, pgTable, serial, text } from 'drizzle-orm/pg-core';

// Define the enum
export const statusEnum = pgEnum('status', ['draft', 'published', 'archived']);
export const roleEnum = pgEnum('role', ['admin', 'editor', 'viewer']);

// Use in a table
export const articles = pgTable('articles', {
  id: serial('id').primaryKey(),
  title: text('title').notNull(),
  status: statusEnum('status').default('draft').notNull(),
});

export const memberships = pgTable('memberships', {
  id: serial('id').primaryKey(),
  userId: integer('user_id').notNull().references(() => users.id),
  role: roleEnum('role').default('viewer').notNull(),
});

// Query with enum value
const drafts = await db
  .select()
  .from(articles)
  .where(eq(articles.status, 'draft'));
```

---

## Migration Safety (Expanded)

### Never Rename Columns Directly

Renaming a column in Drizzle generates `ALTER TABLE RENAME COLUMN`, which causes downtime if the old code still references the old name. Use the three-step approach instead:

```sql
-- Step 1: Add new column
ALTER TABLE users ADD COLUMN display_name text;

-- Step 2: Backfill data (can be done in batches)
UPDATE users SET display_name = name WHERE display_name IS NULL;

-- Step 3: Once all code references display_name, drop the old column
ALTER TABLE users DROP COLUMN name;
```

In Drizzle schema, manage this across multiple deployments:

```typescript
// Deploy 1: add new column, keep old column
export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  name: text('name'),               // OLD — still used by running code
  displayName: text('display_name'), // NEW — being populated
});

// Deploy 2: code now reads from displayName, drop name
export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  displayName: text('display_name').notNull(),
});
```

### Zero-Downtime Migration Patterns

1. **Additive only** — Only add columns, tables, indexes. Never remove or rename in the same deploy.
2. **Backward compatible** — New code must work with both old and new schema during rollout.
3. **Two-phase deploy** — Phase 1: deploy code that writes to both old and new columns. Phase 2: deploy code that reads from new column only, then drop old.
4. **Index creation** — Always use `CREATE INDEX CONCURRENTLY` in production to avoid table locks:

```sql
-- In a custom migration (not db:push)
CREATE INDEX CONCURRENTLY idx_posts_author ON posts (author_id);
```

### Migration Testing Checklist

- [ ] Run `drizzle-kit generate` and review the generated SQL before applying
- [ ] Test migration on a copy of production data (not just empty tables)
- [ ] Verify no `DROP COLUMN` or `ALTER TYPE` on high-traffic tables without a plan
- [ ] Check that `NOT NULL` additions have a `DEFAULT` or a backfill step
- [ ] Confirm indexes are created `CONCURRENTLY` for large tables
- [ ] Test rollback: can you deploy the previous schema version without data loss?
- [ ] Measure migration duration on production-size dataset

### Handling Data Backfills

```typescript
// Backfill in batches to avoid locking the table or running out of memory
async function backfillDisplayName(db: PostgresJsDatabase, batchSize = 1000) {
  let affected = 0;
  let totalUpdated = 0;

  do {
    const result = await db.execute(sql`
      UPDATE users
      SET display_name = name
      WHERE display_name IS NULL
      AND id IN (
        SELECT id FROM users
        WHERE display_name IS NULL
        LIMIT ${batchSize}
      )
    `);

    affected = result.rowCount ?? 0;
    totalUpdated += affected;
    console.log(`Backfilled ${totalUpdated} rows so far...`);
  } while (affected > 0);

  console.log(`Backfill complete: ${totalUpdated} total rows updated.`);
}
```

---

## Type Safety Patterns

### Inferring Types from Schema

```typescript
import { users, posts, comments } from './schema';

// Select type — represents a row read from the database
type User = typeof users.$inferSelect;
type Post = typeof posts.$inferSelect;
type Comment = typeof comments.$inferSelect;

// Insert type — represents a row to be written (no id, defaults optional)
type NewUser = typeof users.$inferInsert;
type NewPost = typeof posts.$inferInsert;
type NewComment = typeof comments.$inferInsert;
```

### Partial Types for Updates

```typescript
// For update operations, all fields are optional except the WHERE clause
type UserUpdate = Partial<typeof users.$inferInsert>;

async function updateUser(id: number, data: UserUpdate) {
  return db.update(users).set(data).where(eq(users.id, id)).returning();
}

// Usage — only updates the fields you pass
await updateUser(1, { name: 'New Name' });
await updateUser(1, { email: 'new@example.com' });
```

### Zod Integration (drizzle-zod)

```typescript
import { createInsertSchema, createSelectSchema } from 'drizzle-zod';
import { z } from 'zod';

// Auto-generate Zod schemas from Drizzle table definitions
const insertUserSchema = createInsertSchema(users, {
  // Override/refine individual fields
  email: z.string().email('Invalid email format'),
  name: z.string().min(2, 'Name must be at least 2 characters'),
});

const selectUserSchema = createSelectSchema(users);

// Use in API routes
export async function POST(request: Request) {
  const body = await request.json();

  // Validate input — throws ZodError if invalid
  const validated = insertUserSchema.parse(body);

  // Type-safe insert — validated matches NewUser shape
  const [user] = await db.insert(users).values(validated).returning();

  return Response.json(user);
}

// Partial schema for PATCH endpoints
const patchUserSchema = insertUserSchema.partial().omit({ id: true });

export async function PATCH(request: Request) {
  const body = await request.json();
  const validated = patchUserSchema.parse(body);
  const [updated] = await db.update(users)
    .set(validated)
    .where(eq(users.id, body.id))
    .returning();
  return Response.json(updated);
}
```

---

## Performance

### Prepared Statements

```typescript
import { eq, placeholder } from 'drizzle-orm';

// Prepare once, execute many times — avoids re-parsing the SQL
const getUserById = db
  .select()
  .from(users)
  .where(eq(users.id, placeholder('id')))
  .prepare('get_user_by_id');

// Execute with different parameters
const user1 = await getUserById.execute({ id: 1 });
const user2 = await getUserById.execute({ id: 42 });

// Prepared statement with multiple placeholders
const getPostsByAuthor = db
  .select()
  .from(posts)
  .where(
    and(
      eq(posts.authorId, placeholder('authorId')),
      eq(posts.status, placeholder('status')),
    )
  )
  .limit(placeholder('limit'))
  .prepare('get_posts_by_author');

const published = await getPostsByAuthor.execute({
  authorId: 1,
  status: 'published',
  limit: 10,
});
```

### Batch Inserts

```typescript
// Insert multiple rows in a single query — much faster than individual inserts
const newUsers = [
  { name: 'Alice', email: 'alice@example.com' },
  { name: 'Bob', email: 'bob@example.com' },
  { name: 'Charlie', email: 'charlie@example.com' },
];

const inserted = await db.insert(users).values(newUsers).returning();

// For very large batches (10k+ rows), chunk to avoid memory issues
function chunk<T>(arr: T[], size: number): T[][] {
  return Array.from({ length: Math.ceil(arr.length / size) }, (_, i) =>
    arr.slice(i * size, i * size + size)
  );
}

async function batchInsert(records: NewUser[], chunkSize = 1000) {
  const chunks = chunk(records, chunkSize);
  const results = [];

  for (const batch of chunks) {
    const inserted = await db.insert(users).values(batch).returning();
    results.push(...inserted);
  }

  return results;
}

// Upsert (insert or update on conflict)
await db.insert(users)
  .values({ name: 'Alice', email: 'alice@example.com' })
  .onConflictDoUpdate({
    target: users.email,
    set: { name: 'Alice Updated' },
  });
```

### Connection Pooling (Neon Serverless Adapter)

```typescript
import { neon } from '@neondatabase/serverless';
import { drizzle } from 'drizzle-orm/neon-http';
import * as schema from './schema';

// HTTP-based (serverless functions — one query per request)
const sql = neon(process.env.DATABASE_URL!);
const db = drizzle(sql, { schema });

// WebSocket-based (long-running, supports transactions)
import { Pool } from '@neondatabase/serverless';
import { drizzle } from 'drizzle-orm/neon-serverless';

const pool = new Pool({ connectionString: process.env.DATABASE_URL });
const db = drizzle(pool, { schema });

// Standard node-postgres pool (non-serverless)
import { Pool } from 'pg';
import { drizzle } from 'drizzle-orm/node-postgres';

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  max: 20,              // max connections in pool
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 5000,
});
const db = drizzle(pool, { schema });
```

### Query Logging and Debugging

```typescript
import { drizzle } from 'drizzle-orm/node-postgres';

// Enable built-in logger
const db = drizzle(pool, {
  schema,
  logger: true, // logs all SQL to console
});

// Custom logger for structured logging
import { DefaultLogger, LogWriter } from 'drizzle-orm';

class CustomLogWriter implements LogWriter {
  write(message: string) {
    // Send to your logging service (Datadog, Sentry, etc.)
    logger.info('[Drizzle]', { query: message, timestamp: Date.now() });
  }
}

const db = drizzle(pool, {
  schema,
  logger: new DefaultLogger({ writer: new CustomLogWriter() }),
});

// One-off debugging: wrap a query with .toSQL() to inspect without executing
const query = db
  .select()
  .from(users)
  .where(eq(users.email, 'test@example.com'))
  .toSQL();

console.log(query.sql);    // SELECT ... FROM "users" WHERE "email" = $1
console.log(query.params); // ['test@example.com']
```

---

## Common Pitfalls (Expanded)

### N+1 Queries with Relations

```typescript
// ❌ N+1 — executes 1 query for users + N queries for each user's posts
const users = await db.select().from(usersTable);
for (const user of users) {
  const posts = await db.select().from(postsTable)
    .where(eq(postsTable.authorId, user.id));
  user.posts = posts;
}

// ✅ Single query with eager loading via relational API
const usersWithPosts = await db.query.users.findMany({
  with: { posts: true },
});

// ✅ Alternative: manual join + grouping if you need custom shape
const rows = await db
  .select()
  .from(usersTable)
  .leftJoin(postsTable, eq(usersTable.id, postsTable.authorId));
```

### Missing Indexes on Foreign Keys

PostgreSQL does NOT auto-create indexes on foreign key columns. You must add them manually:

```typescript
import { pgTable, serial, integer, index } from 'drizzle-orm/pg-core';

export const posts = pgTable('posts', {
  id: serial('id').primaryKey(),
  authorId: integer('author_id').notNull().references(() => users.id),
}, (table) => ({
  // ✅ Always index foreign key columns used in JOINs and WHERE
  authorIdx: index('idx_posts_author_id').on(table.authorId),
}));

// Composite index for common query patterns
export const comments = pgTable('comments', {
  id: serial('id').primaryKey(),
  postId: integer('post_id').notNull().references(() => posts.id),
  authorId: integer('author_id').notNull().references(() => users.id),
  createdAt: timestamp('created_at').defaultNow().notNull(),
}, (table) => ({
  postIdx: index('idx_comments_post_id').on(table.postId),
  authorIdx: index('idx_comments_author_id').on(table.authorId),
  // Composite index for "recent comments on a post"
  postCreatedIdx: index('idx_comments_post_created').on(table.postId, table.createdAt),
}));
```

### Forgetting `.returning()` on Inserts

```typescript
// ❌ No returning — you get back nothing useful (just { rowCount: 1 })
await db.insert(users).values({ name: 'Alice', email: 'alice@example.com' });

// ✅ With returning — you get back the inserted row with id and defaults
const [user] = await db.insert(users)
  .values({ name: 'Alice', email: 'alice@example.com' })
  .returning();

console.log(user.id);        // auto-generated id
console.log(user.createdAt); // server-set default

// ✅ Return only specific columns
const [{ id }] = await db.insert(users)
  .values({ name: 'Alice', email: 'alice@example.com' })
  .returning({ id: users.id });

// Same applies to updates
const [updated] = await db.update(users)
  .set({ name: 'Alice Updated' })
  .where(eq(users.id, 1))
  .returning();
```

### Using `.get()` vs `.all()` Incorrectly

This applies to the **SQLite / D1 driver** (not PostgreSQL). For `better-sqlite3` and Cloudflare D1:

```typescript
// .get() — returns a single row or undefined
const user = await db.select().from(users).where(eq(users.id, 1)).get();

// .all() — returns an array of rows
const allUsers = await db.select().from(users).all();

// ❌ Common mistake: using .get() when multiple rows expected
const posts = await db.select().from(posts).where(eq(posts.authorId, 1)).get();
// Returns only the FIRST match, silently discards the rest

// ✅ Correct: use .all() for multiple rows
const posts = await db.select().from(posts).where(eq(posts.authorId, 1)).all();

// Note: PostgreSQL drivers (node-postgres, Neon) always return arrays.
// .get()/.all() distinction only matters for SQLite-based drivers.
```

### Timestamp Gotchas

```typescript
// ❌ Drizzle timestamps default to string mode
// This returns a string, not a Date object
const user = await db.select().from(users);
console.log(typeof user[0].createdAt); // 'string'

// ✅ Use mode: 'date' to get Date objects
export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  createdAt: timestamp('created_at', { mode: 'date' }).defaultNow().notNull(),
  updatedAt: timestamp('updated_at', { mode: 'date' })
    .defaultNow()
    .notNull()
    .$onUpdate(() => new Date()),
});

// ✅ The $onUpdate hook sets updatedAt on every update automatically
await db.update(users)
  .set({ name: 'New Name' })
  .where(eq(users.id, 1));
// updatedAt is auto-set to new Date() by Drizzle
```
