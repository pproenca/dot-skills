---
title: Use db.batch() to collapse round trips on libsql/Turso/D1
impact: MEDIUM-HIGH
impactDescription: eliminates N-1 network round trips per transaction
tags: tx, batch, libsql, turso, d1, network
---

## Use db.batch() to collapse round trips on libsql/Turso/D1

`db.transaction()` is the right tool against a **local** SQLite file — each statement is microseconds away. Against a **remote** libsql (Turso) or D1 database, each awaited statement crosses the network. Five sequential writes in a transaction become five network round trips even though they're inside one logical transaction. `db.batch([s1, s2, s3, s4, s5])` ships all five statements in one request, runs them sequentially inside an implicit transaction on the server, and returns an array of results. One round trip, full atomicity. Supported on libsql, Neon, and D1 drivers.

**Incorrect (sequential awaits over the network — N round trips):**

```typescript
import { drizzle } from 'drizzle-orm/libsql';

// 5 round trips to Turso, each ~50ms = 250ms minimum:
await db.transaction(async (tx) => {
  await tx.insert(orders).values(order);
  await tx.insert(orderItems).values(items);
  await tx.update(inventory).set({ stock: sql`${inventory.stock} - 1` });
  await tx.insert(auditLog).values({ action: 'order.created' });
  await tx.update(users).set({ orderCount: sql`${users.orderCount} + 1` });
});
```

**Correct (single batch — one round trip):**

```typescript
import { eq, sql } from 'drizzle-orm';

const [createdOrder, , , , ] = await db.batch([
  db.insert(orders).values(order).returning(),
  db.insert(orderItems).values(items),
  db.update(inventory).set({ stock: sql`${inventory.stock} - 1` }).where(eq(inventory.sku, sku)),
  db.insert(auditLog).values({ action: 'order.created' }),
  db.update(users).set({ orderCount: sql`${users.orderCount} + 1` }).where(eq(users.id, userId)),
]);
// 50ms total; atomic; results in array order.
```

**Result tuple is typed per statement:**

```typescript
type BatchResponse = [
  { id: number }[],   // .returning() projects to { id }
  ResultSet,          // insert without .returning()
  ResultSet,          // update
  ResultSet,          // insert
  ResultSet,          // update
];
```

**When NOT to use db.batch():**
- Statements that depend on each other's results (e.g., "insert order, then use the new ID in the items"). Batch statements run server-side without round-tripping data back, so the client can't reference an in-flight result. For dependent statements either:
  - Run them in a regular `db.transaction()` (accepting the round trips), or
  - Generate the ID on the client (`$defaultFn(() => crypto.randomUUID())`) so dependent statements can be prepared in advance.
- Statements that need to make a decision based on a query result mid-batch — batches are non-interactive.

**Driver matrix:**
- ✅ libsql / Turso — full support
- ✅ Neon HTTP driver — full support
- ✅ Cloudflare D1 — full support; `.returning()` works but the response shape is per-statement (each entry is a `D1Result`-flavored object)
- ❌ better-sqlite3 / bun:sqlite — no `db.batch()` (use `db.transaction()` — there's no network to amortize)

Reference: [Drizzle — Batch API](https://orm.drizzle.team/docs/batch-api)
