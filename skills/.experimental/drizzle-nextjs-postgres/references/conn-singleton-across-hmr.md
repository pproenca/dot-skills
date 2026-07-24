---
title: Cache the pool on globalThis so HMR does not leak connections
tags: conn, pool, hot-reload, development
---

## Cache the pool on globalThis so HMR does not leak connections

The obvious `export const db = drizzle(new Pool(...))` is correct in production and broken in development. Next.js hot module replacement re-evaluates a changed module and everything downstream of it, so every save that touches the schema or the db module constructs a *new* `Pool`. The previous pool is unreferenced but its sockets stay open until Postgres times them out, so after twenty saves a local server holds a hundred idle backends and the next query fails with `sorry, too many clients already`. Pinning the pool to `globalThis` survives module re-evaluation because the global object is not part of the module registry HMR replaces.

```typescript
// lib/db/index.ts
import 'server-only'
import { Pool } from 'pg'
import { drizzle } from 'drizzle-orm/node-postgres'
import * as schema from './schema'

const globalForDb = globalThis as unknown as { pool?: Pool }

const pool =
  globalForDb.pool ??
  new Pool({
    connectionString: process.env.DATABASE_URL,
    max: 10,
    idleTimeoutMillis: 5_000,
  })

// Only in dev — in production the module is evaluated once per instance and
// keeping a global reference would hide the pool from teardown handlers.
if (process.env.NODE_ENV !== 'production') globalForDb.pool = pool

export const db = drizzle(pool, { schema })
```

The same reasoning applies to anything else the db module constructs once — a `postgres()` client, a Redis connection, a migration lock.

Reference: [node-postgres — Pooling](https://node-postgres.com/features/pooling) · [Next.js — Fast Refresh](https://nextjs.org/docs/architecture/fast-refresh)
