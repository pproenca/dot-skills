---
title: Lock the row with .for('update') when a write depends on what you read
tags: tx, locking, race-condition, select-for-update
---

## Lock the row with .for('update') when a write depends on what you read

Wrapping a read and a write in `db.transaction()` feels like it makes the pair atomic, and it does not make it *serial*. Postgres defaults to `read committed`, where every statement sees a fresh snapshot: two concurrent transactions can both read `stock = 1`, both conclude there is inventory, and both decrement to `0`. The transaction guaranteed that each one's write landed completely — it never promised the value had not changed in between. `.for('update')` takes a row lock at read time, so the second transaction blocks until the first commits and then reads the updated value.

```typescript
const reservation = await db.transaction(async (tx) => {
  const [item] = await tx
    .select()
    .from(inventory)
    .where(eq(inventory.sku, sku))
    .for('update') // blocks concurrent readers-for-update of this row

  if (!item || item.stock < quantity) throw new Error('Insufficient stock')

  await tx
    .update(inventory)
    .set({ stock: item.stock - quantity })
    .where(eq(inventory.sku, sku))

  const [created] = await tx.insert(reservations).values({ sku, quantity }).returning()
  return created
})
```

**Alternative (no read needed):** when the new value is a pure function of the old one, push the arithmetic into SQL and skip the lock entirely — `set({ stock: sql\`${inventory.stock} - ${quantity}\` })` with a `where` clause of `gte(inventory.stock, quantity)` is atomic in one statement, and an affected-row count of zero means it was rejected. `.for('update', { skipLocked: true })` is the third variant, used to hand different workers different rows in a queue table.

Reference: [PostgreSQL — Explicit Locking: Row-Level Locks](https://www.postgresql.org/docs/current/explicit-locking.html#LOCKING-ROWS) · [Drizzle — Select: `.for()`](https://orm.drizzle.team/docs/select)
