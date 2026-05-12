---
title: Set busy_timeout so contention waits instead of failing
impact: MEDIUM
impactDescription: prevents transient lock contention surfacing as 500s
tags: conn, busy-timeout, pragma, locking
---

## Set busy_timeout so contention waits instead of failing

The default `busy_timeout` is **zero**. With it at zero, any attempt to acquire a contended lock returns `SQLITE_BUSY` immediately — every transient contention surfaces as an error in application code. Setting `busy_timeout = 5000` (ms) tells SQLite to retry internally for up to five seconds before giving up. Combined with WAL mode and the `IMMEDIATE` transaction behavior, this turns most contention into a brief wait rather than a user-visible failure. Set it per connection.

**Incorrect (no busy_timeout — contention is always an error):**

```typescript
import Database from 'better-sqlite3';
import { drizzle } from 'drizzle-orm/better-sqlite3';

const sqlite = new Database('./app.db');
sqlite.pragma('journal_mode = WAL');
// Missing busy_timeout — SQLITE_BUSY thrown on first lock conflict.
export const db = drizzle(sqlite);
```

**Correct (5-second timeout — most contention becomes invisible):**

```typescript
import Database from 'better-sqlite3';
import { drizzle } from 'drizzle-orm/better-sqlite3';

const sqlite = new Database('./app.db');
sqlite.pragma('journal_mode = WAL');
sqlite.pragma('busy_timeout = 5000');
sqlite.pragma('synchronous = NORMAL');
sqlite.pragma('foreign_keys = ON');
export const db = drizzle(sqlite);
```

**Choose the timeout based on workload:**
- **Short, fast writes (≤ 100 ms):** 1-2 s is plenty — long waits suggest a real problem.
- **Mixed read/write app:** 5 s is the standard recommendation.
- **Background imports against a serving database:** 10-30 s, but pair it with retry logic (see [tx-handle-busy-with-retry](tx-handle-busy-with-retry.md)).

**Diagnosing:** when you see `SQLITE_BUSY` even with a timeout, the lock is held for longer than the timeout — usually a runaway transaction or a network call inside `db.transaction()` (see [tx-no-network-io-inside-transaction](tx-no-network-io-inside-transaction.md)).

**For libsql/Turso remote:** there's no busy_timeout — the server manages concurrency. Retries on the client side cover transient errors instead.

Reference: [SQLite — PRAGMA busy_timeout](https://www.sqlite.org/pragma.html#pragma_busy_timeout)
