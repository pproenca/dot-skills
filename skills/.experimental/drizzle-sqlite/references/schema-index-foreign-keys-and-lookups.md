---
title: Index foreign keys and frequent WHERE columns
impact: CRITICAL
impactDescription: O(n) full-table scan to O(log n) index lookup
tags: schema, index, query-performance, foreign-key
---

## Index foreign keys and frequent WHERE columns

SQLite does **not** automatically create an index on foreign key columns (unlike MySQL/InnoDB). Every `WHERE authorId = ?` and every parent-side cascade then scans the full child table. Add an `index()` for every FK column and for any column you filter on hot paths. Composite indexes serve `WHERE a = ? AND b = ?` and `WHERE a = ? ORDER BY b` patterns only when columns are in the right order — leading-column queries hit the index, trailing-column queries do not.

**Incorrect (FK with no index — `SELECT * FROM posts WHERE authorId = ?` scans the whole table):**

```typescript
import { integer, sqliteTable, text } from 'drizzle-orm/sqlite-core';

export const posts = sqliteTable('posts', {
  id: integer().primaryKey({ autoIncrement: true }),
  authorId: integer()
    .notNull()
    .references(() => users.id, { onDelete: 'cascade' }),
  publishedAt: integer({ mode: 'timestamp_ms' }),
  body: text().notNull(),
});
```

**Correct (explicit indexes for FK + listing pattern):**

```typescript
import { index, integer, sqliteTable, text } from 'drizzle-orm/sqlite-core';

export const posts = sqliteTable(
  'posts',
  {
    id: integer().primaryKey({ autoIncrement: true }),
    authorId: integer()
      .notNull()
      .references(() => users.id, { onDelete: 'cascade' }),
    publishedAt: integer({ mode: 'timestamp_ms' }),
    body: text().notNull(),
  },
  (table) => [
    index('posts_author_idx').on(table.authorId),
    // Serves "feed for author X ordered by recency":
    index('posts_author_published_idx').on(table.authorId, table.publishedAt),
  ],
);
```

**Partial index — when most rows don't match the filter, index only the ones that do:**

```typescript
import { sql } from 'drizzle-orm';

(table) => [
  index('posts_published_recent_idx')
    .on(table.publishedAt)
    .where(sql`${table.publishedAt} is not null`),
]
```

**Verify with `EXPLAIN QUERY PLAN`:**

```typescript
const plan = await db.all(sql`EXPLAIN QUERY PLAN
  SELECT * FROM posts WHERE author_id = 1 ORDER BY published_at DESC LIMIT 20`);
// Expect "SEARCH posts USING INDEX posts_author_published_idx", not "SCAN posts"
```

Reference: [SQLite — Query Planner](https://www.sqlite.org/queryplanner.html) · [Drizzle — Indexes](https://orm.drizzle.team/docs/indexes-constraints#indexes)
