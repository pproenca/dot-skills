---
title: Reach other contexts through their published interface, never their internals
tags: ctx, bounded-context, boundaries, coupling
---

## Reach other contexts through their published interface, never their internals

The wrong default is treating context boundaries as folder decoration: when Billing needs an order's total, it imports `ordering/domain/order.ts` directly. The import compiles, but it welds Billing's correctness to Ordering's internal model — every internal refactor in Ordering now breaks a context that was supposed to be insulated, and the two contexts' languages start bleeding into each other. A bounded context that others can reach into is not bounded.

**Evidence of violation:** an import or reference from context A into context B's **internal domain modules** — paths reaching through another context's `domain/`, `model/`, or non-exported internals rather than its published surface (its exported API module, client, published events, or shared contract types). **Prerequisite:** the target has two or more identifiable contexts (separate top-level modules, packages, services, or apps); when it does not, this rule is N/A — say so.

**Carve-outs (must be cited to claim):** a declared **shared kernel** — a module explicitly documented as jointly owned by the contexts that import it; cite the declaration (a README line, an ownership note), not just the folder name `shared/`. Contract/DTO packages published for consumption are the interface, not a violation.

**Incorrect (Billing's correctness now depends on Ordering's internals):**

```ts
// billing/invoice-builder.ts
import { Order } from "../ordering/domain/order" // internal model of another context

export function buildInvoice(order: Order): Invoice {
  return Invoice.forAmount(order.lines.reduce((t, l) => t.plus(l.price), Money.zero("EUR")))
}
```

**Correct (Billing consumes Ordering's published contract):**

```ts
// billing/invoice-builder.ts
import { OrderPlaced } from "@app/contracts/ordering-events" // published event schema

export function buildInvoice(placed: OrderPlaced): Invoice {
  return Invoice.forAmount(placed.total) // Ordering computes its own total
}
```

Reference: [Martin Fowler — BoundedContext](https://martinfowler.com/bliki/BoundedContext.html), [Eric Evans — Domain-Driven Design Reference: Context Map, Published Language](https://www.domainlanguage.com/ddd/reference/)
