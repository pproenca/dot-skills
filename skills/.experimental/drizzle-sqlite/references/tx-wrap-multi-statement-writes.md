---
title: Wrap multi-statement writes in db.transaction()
impact: MEDIUM-HIGH
impactDescription: atomicity + 5-50x throughput on batched writes
tags: tx, transaction, atomicity, throughput
---

## Wrap multi-statement writes in db.transaction()

Every standalone write in SQLite takes the write lock, fsyncs to the WAL, and releases the lock. Inserting 100 rows as 100 separate statements does that 100 times — easily 1-2 seconds on commodity disk. `db.transaction(async (tx) => { ... })` opens one transaction, performs every write inside it, and commits with a single fsync at the end. The same pattern provides atomicity: if statement 47 throws, the previous 46 roll back. Always reach for a transaction when more than one write needs to succeed-or-fail-together, even on logically independent inserts.

**Incorrect (separate writes — no atomicity, slow):**

```typescript
async function createOrderWithItems(order: NewOrder, items: NewOrderItem[]) {
  const [created] = await db.insert(orders).values(order).returning();
  for (const item of items) {
    await db.insert(orderItems).values({ ...item, orderId: created.id });
    // If the 4th insert throws, the order + first 3 items are orphaned in the DB.
  }
  return created;
}
```

**Correct (transaction — atomic + one fsync):**

```typescript
async function createOrderWithItems(order: NewOrder, items: NewOrderItem[]) {
  return db.transaction(async (tx) => {
    const [created] = await tx.insert(orders).values(order).returning();
    if (items.length > 0) {
      // One multi-row insert is cheaper than N single-row inserts:
      await tx.insert(orderItems).values(items.map((i) => ({ ...i, orderId: created.id })));
    }
    return created;
  });
  // If anything inside throws, everything rolls back.
}
```

**Early rollback — throw to abort, or call `tx.rollback()`:**

```typescript
await db.transaction(async (tx) => {
  const [account] = await tx.select().from(accounts).where(eq(accounts.id, accountId));
  if (account.balance < amount) {
    tx.rollback(); // throws TransactionRollbackError — caught by the runner
  }
  await tx.update(accounts).set({ balance: account.balance - amount }).where(eq(accounts.id, accountId));
});
```

**Transaction behavior — pick the right mode:**

SQLite supports three transaction modes — Drizzle exposes them as `behavior`:

```typescript
await db.transaction(
  async (tx) => { /* ... */ },
  { behavior: 'immediate' },
);
```

- `deferred` (default) — takes the write lock lazily on first write. Risks `SQLITE_BUSY` when another writer grabs it first.
- `immediate` — takes the reserved lock at `BEGIN`. Use for any transaction that **will** write; fails fast on contention.
- `exclusive` — takes the exclusive lock immediately. Rarely needed; serializes all readers too.

**For RMW (read-modify-write) transactions, always use `immediate`** so the read sees data consistent with the write that's about to happen.

Reference: [Drizzle — Transactions](https://orm.drizzle.team/docs/transactions) · [SQLite — BEGIN TRANSACTION](https://www.sqlite.org/lang_transaction.html)
