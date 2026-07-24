---
title: Choose the driver by whether you need to branch on an intermediate result
tags: conn, neon, driver, transactions, batch
---

## Choose the driver by whether you need to branch on an intermediate result

Drizzle exposes `db.transaction()` on every Postgres driver, so the API gives no hint that one of them cannot honour it. `drizzle-orm/neon-http` sends statements over HTTP with no session to hold a transaction open, and its `transaction()` throws `No transactions support in neon-http driver` at runtime. The tempting conclusion — that the HTTP driver gives up atomicity — is wrong, and choosing on that basis costs you a driver you did not need to abandon. `db.batch()` on `neon-http` submits its statements as a single **non-interactive** Postgres transaction: it is atomic and it does roll back. What it cannot do is let you read a value, decide something in JavaScript, and then write based on that decision, because every statement is sent at once. That — read-then-decide-then-write — is the real dividing line.

**Non-interactive is enough (`neon-http` + `db.batch()`): atomic, one round trip.**

```typescript
import { drizzle } from 'drizzle-orm/neon-http'

// Both statements commit together or neither does.
const [[order], _] = await db.batch([
  db.insert(orders).values(draft).returning(),
  db.update(inventory).set({ stock: sql`${inventory.stock} - ${draft.quantity}` }).where(eq(inventory.sku, draft.sku)),
])
```

**Interactive is required (a JS decision sits between the read and the write): use a session-holding driver.**

```typescript
import ws from 'ws'
import { Pool, neonConfig } from '@neondatabase/serverless'
import { drizzle } from 'drizzle-orm/neon-serverless'
import * as schema from './schema'

neonConfig.webSocketConstructor = ws // required where WebSocket is not global

export const db = drizzle(new Pool({ connectionString: process.env.DATABASE_URL }), { schema })

await db.transaction(async (tx) => {
  const [item] = await tx.select().from(inventory).where(eq(inventory.sku, draft.sku)).for('update')
  if (item.stock < draft.quantity) throw new Error('Insufficient stock') // ← the branch batch cannot express
  await tx.update(inventory).set({ stock: item.stock - draft.quantity }).where(eq(inventory.sku, draft.sku))
  return tx.insert(orders).values(draft).returning()
})
```

`node-postgres` and `postgres-js` hold a session too, so the same reasoning picks between them and the HTTP driver on any host, not just Neon.

Reference: [Drizzle — Connect to Neon](https://orm.drizzle.team/docs/connect-neon) · `drizzle-orm@0.45.2/neon-http/session.js` (`transaction()` throws; `batch()` delegates to `client.transaction()`) · `@neondatabase/serverless@1.1.0/index.d.ts` ("submitted (over HTTP) as a single, non-interactive Postgres transaction")
