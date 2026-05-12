---
title: Handle SQLITE_BUSY with bounded retries on writes
impact: MEDIUM-HIGH
impactDescription: prevents transient lock contention surfacing as 500s
tags: tx, busy, retry, sqlite-busy
---

## Handle SQLITE_BUSY with bounded retries on writes

`PRAGMA busy_timeout = 5000` (see [conn-set-busy-timeout](conn-set-busy-timeout.md)) tells SQLite to wait up to 5 s for a contended lock before returning `SQLITE_BUSY`. Under heavy write contention — many concurrent requests or many processes sharing the file — that timeout still expires and the driver throws. Without a retry wrapper, every such event bubbles up to the caller as a 500. Add a small bounded retry around `db.transaction()` for transient busy errors; leave non-retryable failures (constraint violation, syntax error) to propagate.

**Incorrect (no retry — every transient busy is a user-visible error):**

```typescript
await db.transaction(async (tx) => {
  await tx.update(counters).set({ value: sql`value + 1` }).where(eq(counters.key, 'hits'));
});
// SqliteError: SQLITE_BUSY: database is locked → propagates to the request handler.
```

**Correct (bounded retry with backoff, only on busy errors):**

```typescript
async function withBusyRetry<T>(fn: () => Promise<T>, attempts = 4): Promise<T> {
  for (let attempt = 0; attempt < attempts; attempt++) {
    try {
      return await fn();
    } catch (err) {
      if (!isBusyError(err) || attempt === attempts - 1) throw err;
      // Exponential backoff with jitter: 25ms, 50ms, 100ms
      const delay = 25 * 2 ** attempt + Math.random() * 25;
      await new Promise((resolve) => setTimeout(resolve, delay));
    }
  }
  throw new Error('unreachable');
}

function isBusyError(err: unknown): boolean {
  // better-sqlite3:  err.code === 'SQLITE_BUSY' (or SQLITE_BUSY_SNAPSHOT)
  // libsql:          err.code === 'SQLITE_BUSY'
  // bun:sqlite:      err.code === 'SQLITE_BUSY'
  return (
    typeof err === 'object' &&
    err !== null &&
    'code' in err &&
    typeof (err as { code: unknown }).code === 'string' &&
    (err as { code: string }).code.startsWith('SQLITE_BUSY')
  );
}

await withBusyRetry(() =>
  db.transaction(async (tx) => {
    await tx.update(counters).set({ value: sql`value + 1` }).where(eq(counters.key, 'hits'));
  }, { behavior: 'immediate' }),
);
```

**Don't retry:**
- `SQLITE_CONSTRAINT` (unique/foreign-key violation) — the next attempt will fail the same way.
- `SQLITE_ERROR` (syntax) — your code is wrong, retrying won't fix it.
- Any error you can't positively identify as transient.

**Reduce busy errors before adding retries:**
1. Enable WAL mode ([conn-enable-wal](conn-enable-wal.md)) — readers and one writer can proceed concurrently.
2. Raise `busy_timeout` to 5-15 seconds ([conn-set-busy-timeout](conn-set-busy-timeout.md)).
3. Use `behavior: 'immediate'` for write transactions so contention surfaces at `BEGIN`, not mid-transaction.
4. Keep transactions short (see [tx-no-network-io-inside-transaction](tx-no-network-io-inside-transaction.md)).

Reference: [SQLite — Locking and Concurrency](https://www.sqlite.org/lockingv3.html) · [SQLite — Result codes (SQLITE_BUSY)](https://www.sqlite.org/rescode.html#busy)
