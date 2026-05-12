---
title: Avoid count(*) over large tables — use approximations or counters
impact: MEDIUM
impactDescription: O(n) full-table scan to O(1) lookup
tags: perf, count, pagination, materialized
---

## Avoid count(*) over large tables — use approximations or counters

`SELECT count(*) FROM posts` is O(n) — SQLite walks every row. On a 10M-row table that's seconds, and the result is stale the moment it returns. UIs that show `"Showing 1-20 of 9,847,123"` pay this cost on every page load. Three better options: drop the total count (use cursor-based pagination with "more" indicators), maintain a counter row in a separate table, or use a windowing trick to fetch one page + 1 to know if there's a next page.

**Incorrect (count(*) per page request — full scan every time):**

```typescript
import { count, eq, desc } from 'drizzle-orm';

async function listPosts(page: number, pageSize = 20) {
  const [{ total }] = await db
    .select({ total: count() })
    .from(posts)
    .where(eq(posts.published, true));
  // ↑ Full scan, even with an index on `published`.

  const rows = await db
    .select()
    .from(posts)
    .where(eq(posts.published, true))
    .orderBy(desc(posts.publishedAt))
    .limit(pageSize)
    .offset(page * pageSize);

  return { rows, total, totalPages: Math.ceil(total / pageSize) };
}
```

**Correct (keyset pagination + "has more" flag — best for feeds):**

```typescript
import { and, desc, eq, lt } from 'drizzle-orm';

async function listPosts(cursor?: Date, pageSize = 20) {
  const rows = await db
    .select()
    .from(posts)
    .where(
      cursor
        ? and(eq(posts.published, true), lt(posts.publishedAt, cursor))
        : eq(posts.published, true),
    )
    .orderBy(desc(posts.publishedAt))
    .limit(pageSize + 1); // fetch one extra to detect "has more"

  const hasMore = rows.length > pageSize;
  return { rows: rows.slice(0, pageSize), hasMore, nextCursor: rows[pageSize - 1]?.publishedAt };
}
```

**Alternative (maintained counter row — when you really need the total):**

```typescript
// schema.ts
export const stats = sqliteTable('stats', {
  key: text().primaryKey(),
  value: integer().notNull().default(0),
});

// Update on every insert / soft-delete inside a transaction:
await db.transaction(async (tx) => {
  await tx.insert(posts).values(newPost);
  await tx
    .insert(stats)
    .values({ key: 'published_posts', value: 1 })
    .onConflictDoUpdate({
      target: stats.key,
      set: { value: sql`${stats.value} + 1` },
    });
});

// Reads are now O(1):
const [{ value: total }] = await db
  .select({ value: stats.value })
  .from(stats)
  .where(eq(stats.key, 'published_posts'));
```

**Alternative (sqlite_stat tables for rough estimates):**

If you only need an approximate count for display ("about 9 million"), `ANALYZE` the table and read from `sqlite_stat1` — orders of magnitude faster than `count(*)`:

```sql
ANALYZE posts;
SELECT stat FROM sqlite_stat1 WHERE tbl = 'posts'; -- "9847123 1.2k 1" — first number is row estimate
```

Reference: [SQLite — Query Planner & sqlite_stat1](https://www.sqlite.org/queryplanner-ng.html) · [Use the Index, Luke — Pagination](https://use-the-index-luke.com/no-offset)
