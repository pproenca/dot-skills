---
title: Use .toSQL() and EXPLAIN QUERY PLAN to verify generated SQL
impact: MEDIUM-HIGH
impactDescription: prevents O(n) full-table scans reaching production
tags: query, explain, debugging, performance
---

## Use .toSQL() and EXPLAIN QUERY PLAN to verify generated SQL

Drizzle's chainable builder makes it easy to write queries whose generated SQL you've never actually read — and those queries can have full table scans, redundant joins, or unindexed `WHERE` clauses hiding behind the type system. `.toSQL()` shows the SQL + parameters before execution. Combining that with SQLite's `EXPLAIN QUERY PLAN` tells you whether the planner will use an index (`SEARCH USING INDEX ...`) or scan (`SCAN ...`). Catch the missing index in development, not the on-call rotation.

**Incorrect (ship the query untested — full scan only shows up under prod load):**

```typescript
import { and, desc, eq } from 'drizzle-orm';

// Looks fine. Tests pass. Goes live. p99 spikes to 2 seconds at peak.
async function feed(authorId: number) {
  return db
    .select({ id: posts.id, title: posts.title })
    .from(posts)
    .where(and(eq(posts.authorId, authorId), eq(posts.published, true)))
    .orderBy(desc(posts.publishedAt))
    .limit(20);
}
// Hidden in the plan: SCAN posts USE TEMP B-TREE FOR ORDER BY.
// No index covered (author_id, published, published_at).
```

**Correct (inspect the SQL + plan during development):**

```typescript
import { and, desc, eq, sql } from 'drizzle-orm';

const query = db
  .select({ id: posts.id, title: posts.title })
  .from(posts)
  .where(and(eq(posts.authorId, 42), eq(posts.published, true)))
  .orderBy(desc(posts.publishedAt))
  .limit(20);

// Step 1 — see the SQL Drizzle generated:
console.log(query.toSQL());
// {
//   sql: 'select "id", "title" from "posts" where ("author_id" = ? and "published" = ?) order by "published_at" desc limit ?',
//   params: [42, 1, 20]
// }

// Step 2 — ask SQLite how it will execute:
const plan = await db.all<{ id: number; parent: number; notused: number; detail: string }>(
  sql`EXPLAIN QUERY PLAN
      SELECT id, title FROM posts
      WHERE author_id = 42 AND published = 1
      ORDER BY published_at DESC LIMIT 20`,
);
console.table(plan);
// Want: "SEARCH posts USING INDEX posts_author_published_idx (author_id=? AND published=?)"
// Bad:  "SCAN posts" or "USE TEMP B-TREE FOR ORDER BY"
```

**Make this a test for hot paths:**

```typescript
import { test, expect } from 'vitest';
import { sql } from 'drizzle-orm';

test('feed query uses the author+published index', async () => {
  const plan = await db.all<{ detail: string }>(
    sql`EXPLAIN QUERY PLAN
        SELECT id, title FROM posts
        WHERE author_id = 1 AND published = 1
        ORDER BY published_at DESC LIMIT 20`,
  );
  const detail = plan.map((r) => r.detail).join(' | ');
  expect(detail).toMatch(/USING INDEX posts_author_published_idx/);
  expect(detail).not.toMatch(/SCAN/); // no full-table scans in hot paths
});
```

**When the plan is wrong, the fix is usually one of:**
- Add a composite index covering the `WHERE` columns in order, plus the `ORDER BY` column.
- Rewrite to put indexable predicates before non-indexable ones (`LIKE 'foo%'` is indexable; `LIKE '%foo'` is not).
- Use a covering index that includes the projected columns so the planner can skip the table read.

Reference: [SQLite — EXPLAIN QUERY PLAN](https://www.sqlite.org/eqp.html) · [Drizzle — Building queries dynamically](https://orm.drizzle.team/docs/dynamic-query-building)
