---
title: Always limit listing queries
impact: HIGH
impactDescription: prevents unbounded memory growth as tables scale
tags: query, limit, pagination, memory
---

## Always limit listing queries

A `db.select().from(posts).orderBy(desc(posts.publishedAt))` works in development when `posts` has 50 rows and returns silently with 500_000 rows in production — exhausting Node memory, blocking the event loop on deserialization, and triggering OOM kills on the container. Every listing query needs a `.limit()`. For unbounded result sets that you must process completely (exports, migrations), use the streaming iterator API (`.iterate()` in better-sqlite3) rather than loading everything into memory.

**Incorrect (no limit — works fine until production data grows):**

```typescript
import { desc } from 'drizzle-orm';

async function recentPosts() {
  return db.select().from(posts).orderBy(desc(posts.publishedAt));
}
// Today: 50 rows, instant. Six months from now: 500K rows, container OOMs.
```

**Correct (explicit limit with keyset or offset pagination):**

```typescript
import { and, desc, lt } from 'drizzle-orm';

async function recentPosts(cursor?: { publishedAt: Date; id: number }, pageSize = 20) {
  const query = db
    .select()
    .from(posts)
    .where(
      cursor
        ? // Keyset: pick up where we left off. Stable under inserts.
          and(
            lt(posts.publishedAt, cursor.publishedAt),
            // Tie-break on id for stable ordering on duplicate timestamps:
            // (use sql`(published_at, id) < (${cursor.publishedAt}, ${cursor.id})`
            //  if you want the strict tuple comparison)
          )
        : undefined,
    )
    .orderBy(desc(posts.publishedAt), desc(posts.id))
    .limit(pageSize);
  return query;
}
```

**Streaming for full-table operations (better-sqlite3 sync driver):**

```typescript
import Database from 'better-sqlite3';
import { sql } from 'drizzle-orm';

// Drop down to the raw better-sqlite3 statement for cursor semantics:
const stmt = sqlite.prepare('SELECT id, body FROM posts ORDER BY id');
for (const row of stmt.iterate()) {
  // Processed lazily — only one row in memory at a time.
}
```

**For libsql/Turso async streaming:** loop with `.limit(N)` + cursor — there is no `.iterate()` over the network.

Reference: [Drizzle — limit/offset](https://orm.drizzle.team/docs/select#limit--offset) · [better-sqlite3 — Statement.iterate()](https://github.com/WiseLibs/better-sqlite3/blob/master/docs/api.md#iteratebindparameters---iterator)
