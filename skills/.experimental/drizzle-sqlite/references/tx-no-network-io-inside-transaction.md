---
title: Never await external I/O inside a transaction
impact: MEDIUM-HIGH
impactDescription: prevents write-lock starvation across the cluster
tags: tx, transaction, write-lock, latency
---

## Never await external I/O inside a transaction

SQLite allows exactly one writer at a time. While a transaction holds the write lock, every other writer in the process (and across processes on the same file) blocks. Awaiting an HTTP call to Stripe, a Slack webhook, or any non-database I/O inside the transaction means the write lock is held for the duration of that network call — easily hundreds of milliseconds. Pull external I/O outside the transaction; do the DB work in a tight, in-memory critical section.

**Incorrect (external API inside the tx — write lock held for ~300ms):**

```typescript
await db.transaction(async (tx) => {
  const [order] = await tx.insert(orders).values(input).returning();
  const charge = await stripe.charges.create({ amount: order.total, currency: 'usd' });
  // ☠️ Every other writer is blocked while Stripe responds.
  await tx.update(orders)
    .set({ stripeChargeId: charge.id, status: 'paid' })
    .where(eq(orders.id, order.id));
});
```

**Correct (network outside, DB inside — short critical sections):**

```typescript
// 1. Create the order in a quick tx
const order = await db.transaction(async (tx) => {
  const [created] = await tx.insert(orders).values(input).returning();
  await tx.update(inventory).set({ stock: sql`stock - 1` }).where(eq(inventory.sku, input.sku));
  return created;
});

// 2. Network call — no lock held
const charge = await stripe.charges.create({ amount: order.total, currency: 'usd' });

// 3. Quick update in a second tx
await db.update(orders)
  .set({ stripeChargeId: charge.id, status: 'paid' })
  .where(eq(orders.id, order.id));
```

**For "must succeed or roll back" semantics across external calls — use the outbox pattern:**

If the order must either be fully charged or not exist at all, write to an outbox table inside the transaction and process it asynchronously:

```typescript
await db.transaction(async (tx) => {
  const [order] = await tx.insert(orders).values({ ...input, status: 'pending' }).returning();
  await tx.insert(outbox).values({
    kind: 'stripe.charge',
    payload: { orderId: order.id, amount: order.total },
  });
});
// A separate worker drains `outbox`, calls Stripe, and updates the order.
// If the worker crashes mid-call, idempotency keys on the Stripe side prevent double-charging.
```

**Same rule for `await fs.readFile`, `await fetch`, `await new Promise(setTimeout)` — anything that yields the event loop while the tx is open is a candidate write-lock hog. If you must yield, only yield for `tx.<...>` queries.**

Reference: [SQLite — File Locking And Concurrency](https://www.sqlite.org/lockingv3.html) · [Outbox pattern](https://microservices.io/patterns/data/transactional-outbox.html)
