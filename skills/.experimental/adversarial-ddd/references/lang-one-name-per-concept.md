---
title: Give each domain concept exactly one name within a context
tags: lang, ubiquitous-language, synonyms, naming
---

## Give each domain concept exactly one name within a context

The wrong default is coining a fresh synonym whenever a concept is touched from a new angle — `Order` in the model, `Purchase` in the API layer, `Cart` in a helper — and gluing them together with rename-only mappings. Every synonym doubles the vocabulary the team and the model must keep aligned, and the mapping code exists solely to service the drift. Within one bounded context, one concept gets one name; that is the entire discipline of a ubiquitous language.

**Evidence of violation:** any of — (a) a **pure-rename mapping** between two differently-named types: every field copied across with no transformation, narrowing, unit change, or enrichment; (b) an **alias declaration** binding two domain names to one referent: `type Client = Customer`, `const purchase = order`, `import { Order as Purchase }`; (c) an **operation/parameter mismatch** where a function's name and its own parameter or return types name the same referent differently: `cancelBooking(order: Order)`. Cite both names and the connecting evidence.

**Carve-outs (must be cited to claim):** the two names live in **different bounded contexts** with genuinely different models — cite the structural difference between the two type shapes; if the shapes are field-for-field identical, the different-context claim has no evidence and the violation stands. An import alias forced by a same-file name collision is excused when the colliding declaration is cited.

**Incorrect (a mapping whose only job is servicing a synonym):**

```ts
// fulfillment/purchase.ts — same context as ordering/order.ts
export function toPurchase(order: Order): Purchase {
  return {
    purchaseId: order.orderId,
    purchaseLines: order.lines,
    purchasedAt: order.placedAt,
    buyer: order.customer,
  } // field-for-field rename; no transformation, no new information
}
```

**Correct (one name, no mapping to maintain):**

```ts
// fulfillment/allocate.ts — speaks the same language as ordering/
export function allocateWarehouses(order: Order): ShipmentPlan {
  // a real transformation: Order lines grouped by stocking warehouse
  return planShipments(groupByWarehouse(order.lines))
}
```

Reference: [Martin Fowler — UbiquitousLanguage](https://martinfowler.com/bliki/UbiquitousLanguage.html), [Eric Evans — Domain-Driven Design Reference](https://www.domainlanguage.com/ddd/reference/)
