---
title: Reuse a singleton Drizzle client — don't construct per request
impact: MEDIUM
impactDescription: keeps statement cache warm and prevents fd exhaustion
tags: conn, singleton, lifecycle, statement-cache
---

## Reuse a singleton Drizzle client — don't construct per request

The Drizzle client wraps an underlying driver connection (better-sqlite3 / libsql / bun:sqlite). The driver maintains a cache of prepared statements; the OS reserves a file descriptor; SQLite walks its lock state. Constructing a new `drizzle(...)` per request throws all of that away every call: the statement cache is cold, the file descriptor count climbs until `EMFILE`, and on libsql you re-do the TLS handshake. The pattern is the same as any database client — module-scope singleton, never per-request.

**Incorrect (constructed inside the handler — leaks file descriptors, cold cache):**

```typescript
// app/api/users/route.ts
import Database from 'better-sqlite3';
import { drizzle } from 'drizzle-orm/better-sqlite3';

export async function GET() {
  const sqlite = new Database('./app.db'); // new fd every request
  const db = drizzle(sqlite);
  // ...
  // sqlite never explicitly closed → process eventually hits ulimit -n.
}
```

**Correct (singleton module — one connection for the process lifetime):**

```typescript
// src/db/client.ts
import Database from 'better-sqlite3';
import { drizzle } from 'drizzle-orm/better-sqlite3';
import * as schema from './schema';

const sqlite = new Database(process.env.DATABASE_URL ?? './app.db');
sqlite.pragma('journal_mode = WAL');
sqlite.pragma('foreign_keys = ON');
sqlite.pragma('busy_timeout = 5000');
sqlite.pragma('synchronous = NORMAL');

export const db = drizzle(sqlite, { schema });
export const rawSqlite = sqlite; // expose if you need pragmas / iterate() etc.
```

```typescript
// app/api/users/route.ts — just import
import { db } from '@/db/client';

export async function GET() {
  return Response.json(await db.query.users.findMany({ limit: 50 }));
}
```

**Serverless caveat (Vercel, Cloudflare Workers, AWS Lambda):**

Cold starts construct the module once per container. Use module-level singletons exactly as above, but expect a brand-new connection per cold start. For very high cold-start rates, prefer **libsql / Turso** (HTTP-based, no persistent connection) or **D1** (managed pool) over local SQLite files.

**Hot reload in dev (Next.js, Vite, Bun):**

Hot-module reload can re-execute the module and leak connections in dev. Guard with `globalThis`:

```typescript
declare global {
  // eslint-disable-next-line no-var
  var __sqlite__: Database.Database | undefined;
}

const sqlite = globalThis.__sqlite__ ??= new Database('./app.db');
if (!globalThis.__sqlite__) {
  sqlite.pragma('journal_mode = WAL');
  // ...
}

export const db = drizzle(sqlite, { schema });
```

**For multi-tenant SQLite-per-tenant**, build a `Map<tenantId, db>` cache rather than constructing on every request — same singleton principle, scoped by tenant.

Reference: [better-sqlite3 — Database constructor](https://github.com/WiseLibs/better-sqlite3/blob/master/docs/api.md) · [Drizzle — Getting started](https://orm.drizzle.team/docs/get-started-sqlite)
