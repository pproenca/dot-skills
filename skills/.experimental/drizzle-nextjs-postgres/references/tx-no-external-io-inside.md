---
title: Keep network calls and cache invalidation out of the transaction body
tags: tx, pool, latency, outbox
---

## Keep network calls and cache invalidation out of the transaction body

A transaction is the natural place to put "everything that must happen together", so the Stripe charge, the email, and the `updateTag` end up inside it. In Postgres a transaction pins one backend connection for its entire body — the connection is unavailable to anyone else from `BEGIN` to `COMMIT`. A 400 ms call to a payment provider therefore removes a connection from a pool of ten for 400 ms, and under load the pool empties, requests queue for connections, and the whole app stalls on a dependency that has nothing to do with the database. External services also cannot be rolled back, so wrapping them in a transaction buys no atomicity — only the illusion of it.

```typescript
// 1. Short transaction: database work only.
const invoice = await db.transaction(async (tx) => {
  const [created] = await tx.insert(invoices).values(draft).returning()
  await tx
    .update(organizations)
    .set({ outstandingCents: sql`${organizations.outstandingCents} + ${draft.amountCents}` })
    .where(eq(organizations.id, draft.organizationId))
  return created
})

// 2. Network call — no connection held.
const charge = await stripe.charges.create({ amount: invoice.amountCents, currency: 'usd' })

// 3. Second short transaction to record the outcome.
await db.update(invoices).set({ stripeChargeId: charge.id, status: 'paid' }).where(eq(invoices.id, invoice.id))

updateTag(`org-${invoice.organizationId}-invoices`)
```

**When the two genuinely must be atomic**, use an outbox: write the intent to a table inside the transaction and let a worker perform the call and mark it done. That gives real atomicity — the intent and the row commit together — instead of a lock held across a network.

Reference: [PostgreSQL — Transactions](https://www.postgresql.org/docs/current/tutorial-transactions.html) · [Drizzle — Transactions](https://orm.drizzle.team/docs/transactions)
