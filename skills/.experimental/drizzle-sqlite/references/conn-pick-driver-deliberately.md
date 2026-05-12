---
title: Pick a SQLite driver deliberately — sync vs async matters
impact: MEDIUM
impactDescription: avoids API mismatches and wrong-tool perf
tags: conn, driver, better-sqlite3, libsql, bun-sqlite
---

## Pick a SQLite driver deliberately — sync vs async matters

Drizzle supports several SQLite drivers and they are **not** interchangeable: `better-sqlite3` is synchronous (no await, blocks the event loop), `libsql` is asynchronous (awaits return promises), `bun:sqlite` is synchronous and Bun-only, `op-sqlite` is for React Native, `Cloudflare D1` is async-only over HTTP. The wrong choice means rewriting every call site when you migrate. Pick by deployment target first, then by performance budget.

**Incorrect (better-sqlite3 picked by default — fails when shipped to a serverless edge):**

```typescript
// src/db/client.ts — works locally on the developer's Mac
import Database from 'better-sqlite3';
import { drizzle } from 'drizzle-orm/better-sqlite3';

const sqlite = new Database('./app.db');
export const db = drizzle(sqlite);

// Then deployed to Cloudflare Workers / Vercel Edge:
// → Build error: "better-sqlite3" depends on native bindings that don't exist on the edge runtime.
// → Every call site is sync (no await); migrating to libsql means rewriting all of them.
```

**Correct (pick the driver by deployment target — async if any target needs it):**

```typescript
// Deployment target: Cloudflare Workers / Vercel Edge / Turso
import { createClient } from '@libsql/client';
import { drizzle } from 'drizzle-orm/libsql';

const client = createClient({
  url: process.env.DATABASE_URL ?? 'file:local.db', // works for local dev too
  authToken: process.env.DATABASE_AUTH_TOKEN,
});
export const db = drizzle(client, { schema });

// All call sites are async — no rewrite when moving from local file to Turso:
const user = await db.select().from(users).get();
```

**Decision tree:**

```text
Local file, Node.js server, single process?
  → better-sqlite3 (sync, fastest on Node)

Local file, Bun runtime?
  → bun:sqlite (sync, native, ~2x better-sqlite3 on Bun)

Edge / serverless on Cloudflare?
  → Cloudflare D1 via drizzle-orm/d1 (async, HTTP)

Remote SQLite for many serverless replicas / multi-region?
  → libsql / Turso via drizzle-orm/libsql (async, HTTP+WS)

Local file but want async API for code symmetry with prod libsql?
  → libsql with `file:` URL via drizzle-orm/libsql (async)

React Native?
  → op-sqlite via drizzle-orm/op-sqlite (sync)

Expo SQLite?
  → expo-sqlite via drizzle-orm/expo-sqlite (sync)
```

**Alternative (sync-only deployment — better-sqlite3 is the fastest local choice):**

```typescript
import Database from 'better-sqlite3';
import { drizzle } from 'drizzle-orm/better-sqlite3';

const sqlite = new Database('./app.db');
// pragmas — see conn-enable-wal, conn-foreign-keys-pragma
export const db = drizzle(sqlite, { schema });

// No await — synchronous return:
const user = db.select().from(users).get();
```

**Symmetry tip — use libsql with `file:` for dev to match prod:**

If production is Turso (async) and dev is a local file, prefer libsql with `file:local.db` for both. You get the same async signatures everywhere; the only difference is the URL.

```typescript
const client = createClient({
  url: process.env.DATABASE_URL ?? 'file:local.db',
  authToken: process.env.DATABASE_AUTH_TOKEN, // undefined for local files
});
```

**Don't mix:**
- Code that imports both `drizzle-orm/better-sqlite3` and `drizzle-orm/libsql` indicates two clients in one process. Pick one.
- `bun:sqlite` only works under Bun — code that conditionally imports it crashes on Node.

**Performance rough-orders:**
- `bun:sqlite`: fastest local (~2x better-sqlite3 on Bun benchmarks).
- `better-sqlite3`: fastest Node.js local. Blocks the event loop on heavy queries — keep statements fast.
- `libsql` local file: ~equal to better-sqlite3, with async overhead.
- `libsql` remote / D1: bound by network round-trip latency (10-100ms per call) — see [tx-batch-for-libsql-roundtrips](tx-batch-for-libsql-roundtrips.md).

Reference: [Drizzle — Get started with SQLite](https://orm.drizzle.team/docs/get-started-sqlite) · [better-sqlite3 vs node-sqlite3 benchmark](https://github.com/WiseLibs/better-sqlite3/blob/master/docs/benchmark.md)
