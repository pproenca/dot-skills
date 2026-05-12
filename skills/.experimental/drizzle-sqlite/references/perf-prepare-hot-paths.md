---
title: Prepare hot-path queries with sql.placeholder
impact: MEDIUM-HIGH
impactDescription: 2-5x speedup on high-frequency lookups
tags: perf, prepare, placeholder, hot-path
---

## Prepare hot-path queries with sql.placeholder

Every Drizzle query compiles its builder tree to a SQL string on each call. For a query that runs once per request — auth lookups, feature-flag fetches, cache reads — that compile step (~50-200 µs) becomes a meaningful fraction of total latency. `.prepare()` plus `sql.placeholder('name')` compiles once and stores the statement on the underlying driver; subsequent calls only bind parameters and execute. The win is largest on `better-sqlite3` where the prepared statement also caches SQLite's plan in memory.

**Incorrect (rebuilt on every call — needless compile):**

```typescript
import { eq } from 'drizzle-orm';

// Called on every authenticated request:
async function getUserByToken(token: string) {
  const [user] = await db
    .select({ id: users.id, email: users.email })
    .from(users)
    .innerJoin(sessions, eq(sessions.userId, users.id))
    .where(eq(sessions.token, token))
    .limit(1);
  return user;
}
```

**Correct (prepare once at module load, execute many):**

```typescript
import { sql, eq } from 'drizzle-orm';

const getUserByTokenStmt = db
  .select({ id: users.id, email: users.email })
  .from(users)
  .innerJoin(sessions, eq(sessions.userId, users.id))
  .where(eq(sessions.token, sql.placeholder('token')))
  .limit(1)
  .prepare(); // ← compiled once

export async function getUserByToken(token: string) {
  // .get() returns single row; .all() returns array; SQLite drivers expose both.
  return getUserByTokenStmt.get({ token });
}
```

**Placeholders for limit / offset (`db.query.*` relational queries):**

```typescript
import { sql } from 'drizzle-orm';

const recentByAuthor = db.query.posts
  .findMany({
    where: (p, { eq }) => eq(p.authorId, sql.placeholder('authorId')),
    orderBy: (p, { desc }) => desc(p.publishedAt),
    limit: sql.placeholder('limit'),
  })
  .prepare();

const top10 = await recentByAuthor.execute({ authorId: 42, limit: 10 });
```

**When NOT to use:**
- Queries built dynamically (different `where` clauses per call) — there's no fixed SQL to prepare. For these, the query builder cost is unavoidable.
- One-off queries (admin scripts, migrations) — preparation overhead exceeds the savings.

**Anti-pattern: preparing inside a request handler.** That re-prepares on every request, defeating the point. Prepare at module top-level (or inside a memoized factory).

Reference: [Drizzle — Performance & prepared statements](https://orm.drizzle.team/docs/perf-queries) · [SQLite — Prepared Statements](https://www.sqlite.org/c3ref/prepare.html)
