---
title: Name prepared statements, and skip them behind a transaction pooler
tags: query, prepared-statements, placeholder, pooler
---

## Name prepared statements, and skip them behind a transaction pooler

Two things differ from the SQLite spelling of this optimization. First, `.prepare()` takes a **required** name on Postgres, because a prepared statement is a named server-side object rather than a client-side cached plan; reusing a name for a different query in the same session is an error. Second, and more consequential: the whole point of preparing is to reuse server-side state across calls, and a transaction-mode pooler gives you a different backend each time, so the reuse never happens. Preparing behind such a pooler is at best pointless and at worst an intermittent `prepared statement does not exist`. Decide by deployment topology, not by how hot the query looks.

```typescript
// lib/queries/session.ts — a direct or session-mode connection
import { sql } from 'drizzle-orm'

const sessionByToken = db
  .select()
  .from(sessions)
  .where(eq(sessions.token, sql.placeholder('token')))
  .limit(1)
  .prepare('session_by_token') // name is required on Postgres

export async function findSession(token: string) {
  const [session] = await sessionByToken.execute({ token })
  return session
}
```

`sql.placeholder()` is what makes the statement reusable — a value interpolated directly would be baked into the prepared plan and the statement could only ever answer that one question. Behind PgBouncer or Supavisor in transaction mode, drop the `.prepare()` and let the query compile per call; see [`conn-disable-prepare-behind-transaction-pooler`](conn-disable-prepare-behind-transaction-pooler.md).

Reference: [PostgreSQL — PREPARE](https://www.postgresql.org/docs/current/sql-prepare.html) · [Drizzle — Prepared statements](https://orm.drizzle.team/docs/perf-queries)
