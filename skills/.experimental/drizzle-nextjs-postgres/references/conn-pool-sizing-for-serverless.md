---
title: Size the pool for instance count, not for request count
tags: conn, pool, serverless, max-connections
---

## Size the pool for instance count, not for request count

A pool config tuned for a single long-running server is the wrong shape for serverless, and the instinctive fix — `max: 1`, "one connection per function" — makes it worse rather than better. Total connections is `instances × max`, so dropping `max` to 1 does not reduce the ceiling; it just removes the pool's ability to serve concurrent requests on the same instance, serializing them behind one socket. The real failure mode is different: a suspended instance stops running its idle-timeout timers, so connections it was holding stay open on the Postgres side until the backend forcibly closes them. That is why a short idle timeout plus an explicit suspend hook matters more than a small `max`.

```typescript
// lib/db/index.ts
import 'server-only'
import { Pool } from 'pg'
import { attachDatabasePool } from '@vercel/functions'
import { drizzle } from 'drizzle-orm/node-postgres'
import * as schema from './schema'

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  max: 10,
  min: 1,
  idleTimeoutMillis: 5_000,
})

// Closes idle connections before the instance suspends, so they are not
// stranded open on the Postgres side until the server times them out.
attachDatabasePool(pool)

export const db = drizzle(pool, { schema })
```

This example omits the `globalThis` guard from [`conn-singleton-across-hmr`](conn-singleton-across-hmr.md) for brevity — a real db module needs both: the guard so dev HMR does not leak pools, and `attachDatabasePool` so prod suspension does not strand connections. `min: 1` keeps exactly one connection warm to avoid a cold connect on every invocation; it does not fight the idle-timeout point, because `attachDatabasePool` closes connections at suspend time regardless of the minimum.

When instance count is genuinely unbounded, no pool config saves you — put a pooler (PgBouncer, Supavisor, Neon's pooled endpoint) between the app and Postgres so the app's connections are cheap proxy connections rather than real backends. See [`conn-disable-prepare-behind-transaction-pooler`](conn-disable-prepare-behind-transaction-pooler.md) for what that changes about the driver.

Reference: [Vercel — Connection pooling with functions](https://vercel.com/guides/connection-pooling-with-functions) · [PostgreSQL — Connections and Authentication](https://www.postgresql.org/docs/current/runtime-config-connection.html)
