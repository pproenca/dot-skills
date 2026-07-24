---
title: Retry serializable transactions on SQLSTATE 40001
tags: tx, isolation, serializable, retry
---

## Retry serializable transactions on SQLSTATE 40001

Raising the isolation level to `serializable` is treated as a way to make concurrency someone else's problem, and it moves the problem rather than removing it. Postgres implements serializable optimistically: it lets conflicting transactions proceed and aborts one at commit time with `could not serialize access due to read/write dependencies among transactions`, SQLSTATE `40001`. That is not a bug and not a bug in your query — it is the contract. Code that does not retry turns an isolation upgrade into a source of user-visible 500s that appear only under concurrency, which is the hardest condition to reproduce. `repeatable read` raises the same class of error (`40001`) on write conflicts.

```typescript
// Drizzle wraps driver errors, so the Postgres SQLSTATE may sit on `cause`.
async function withSerializableRetry<T>(work: () => Promise<T>, attempts = 3): Promise<T> {
  for (let attempt = 1; ; attempt++) {
    try {
      return await work()
    } catch (error) {
      const code = (error as { cause?: { code?: string }; code?: string }).cause?.code
        ?? (error as { code?: string }).code
      if (code !== '40001' || attempt >= attempts) throw error
      // Back off before retrying; the conflicting transaction needs time to commit.
      await new Promise((resolve) => setTimeout(resolve, 25 * 2 ** attempt))
    }
  }
}

const settlement = await withSerializableRetry(() =>
  db.transaction(
    async (tx) => {
      const rows = await tx.select().from(ledgerEntries).where(eq(ledgerEntries.accountId, accountId))
      const balance = rows.reduce((total, row) => total + row.amountCents, 0)
      const [entry] = await tx.insert(ledgerEntries).values({ accountId, amountCents: -balance }).returning()
      return entry
    },
    { isolationLevel: 'serializable' },
  ),
)
```

The retry must re-run the whole transaction, not just the failed statement — the aborted transaction's snapshot is gone. Keep serializable transactions short and free of external I/O for the same reason; every retry pays the full cost again.

Reference: [PostgreSQL — Transaction Isolation: Serializable](https://www.postgresql.org/docs/current/transaction-iso.html#XACT-SERIALIZABLE) · [PostgreSQL — Error Codes](https://www.postgresql.org/docs/current/errcodes-appendix.html)
