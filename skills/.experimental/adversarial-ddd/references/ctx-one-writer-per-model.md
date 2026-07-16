---
title: Give each stored model exactly one writing context
tags: ctx, bounded-context, ownership, data-integrity
---

## Give each stored model exactly one writing context

The wrong default is letting a second context write "just this one field" into another context's storage — the fulfillment service updating `orders.status` directly because publishing an event felt heavyweight. Two writers means two enforcement points for every invariant and two contexts whose languages must stay accidentally aligned; the owning context's guards are bypassed by construction. Ownership of a model means being the only one who changes it.

**Evidence of violation:** write operations (inserts, updates, deletes, `save`/`persist` calls) against the same stored entity — table, collection, or aggregate — from two or more contexts, both visible in the target. Cite both write sites. **Prerequisite:** the target has two or more identifiable contexts; otherwise N/A — say so.

**Carve-outs (must be cited to claim):** the second context writing **through the owner's published surface** (its API, its commands, its event handlers) is the fix, not a violation — the owner still enforces its rules; cite the surface being used. One-off migration or backfill scripts clearly outside runtime flow — cite their location.

**Incorrect (Fulfillment bypasses every rule Ordering enforces):**

```ts
// fulfillment/complete-shipment.ts
await db.query(
  "UPDATE orders SET status = 'delivered' WHERE id = $1", // Ordering's table
  [shipment.orderId],
) // Ordering's cancel-guard, notification, and audit rules all skipped
```

**Correct (the owner is asked, and applies its own rules):**

```ts
// fulfillment/complete-shipment.ts
await orderingApi.markDelivered(shipment.orderId)
// or: publish(new ShipmentDelivered(shipment.orderId)) — Ordering's handler updates its own model
```

Reference: [Eric Evans — Domain-Driven Design Reference: Aggregates, Context Map](https://www.domainlanguage.com/ddd/reference/), [Martin Fowler — BoundedContext](https://martinfowler.com/bliki/BoundedContext.html)
