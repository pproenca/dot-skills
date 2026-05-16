---
title: Compose Pipelines When the Mutation-Builder Hides the Intent
impact: MEDIUM-HIGH
impactDescription: reduces 10-20 line accumulator-builder blocks to a 3-5 line composed pipeline
tags: proc, pipeline, composition, mutation
---

## Compose Pipelines When the Mutation-Builder Hides the Intent

This is the *second* level of "declarative beats imperative" — beyond replacing a single loop with `.map`. When a transformation has *multiple steps* (filter, then transform, then group, then summarise), the imperative form usually builds a mutable accumulator and threads it through a long block. The composed-pipeline form names each step. The judgment skill is recognising that a series of named operations communicates the *shape of the computation* — what you might call the "query" — far better than a 20-line accumulator block.

This rule is the multi-step sibling of [`reinvent-stdlib-collection-ops`](reinvent-stdlib-collection-ops.md): that one is "the for-loop is `.map`"; this one is "the for-loop *plus the helper function plus the early-return inside the if* is a pipeline."

**Incorrect (a mutation-builder hiding a four-step query):**

```typescript
function topCustomersByRevenue(orders: Order[]): CustomerSummary[] {
  const byCustomer: Record<string, { id: string; total: number; orderCount: number }> = {};

  for (const order of orders) {
    if (order.status !== 'completed') continue;
    if (!byCustomer[order.customerId]) {
      byCustomer[order.customerId] = { id: order.customerId, total: 0, orderCount: 0 };
    }
    byCustomer[order.customerId].total += order.total;
    byCustomer[order.customerId].orderCount += 1;
  }

  const summaries: CustomerSummary[] = [];
  for (const id of Object.keys(byCustomer)) {
    summaries.push(byCustomer[id]);
  }

  summaries.sort((a, b) => b.total - a.total);
  return summaries.slice(0, 10);
  // 14 lines. The query "completed orders, grouped by customer, top 10 by revenue" is
  // distributed across an if, an else-init, two += statements, a key-loop, and a sort+slice.
  // A reader has to assemble the pipeline mentally.
}
```

**Correct (the pipeline reads off the page):**

```typescript
function topCustomersByRevenue(orders: Order[]): CustomerSummary[] {
  const completed = orders.filter(o => o.status === 'completed');
  const grouped   = Object.groupBy(completed, o => o.customerId);

  return Object.entries(grouped)
    .map(([id, custOrders]) => ({
      id,
      total:      custOrders!.reduce((s, o) => s + o.total, 0),
      orderCount: custOrders!.length,
    }))
    .sort((a, b) => b.total - a.total)
    .slice(0, 10);
  // Five named stages: filter → group → map → sort → take.
  // Each stage's purpose is the operation's name. Reordering would be a refactor, not a bug fix.
}
```

**When the pipeline doesn't help — keep the imperative form:**

```typescript
// A chain that does N passes when one suffices isn't always better:
const result = items
  .filter(i => i.active)
  .map(i => transform(i))
  .reduce((s, i) => s + i.value, 0);

// vs:
const result = items.reduce((s, i) =>
  i.active ? s + transform(i).value : s, 0);
// The reduce form is one pass and one allocation. For large hot-path arrays, prefer it.
// For small arrays where readability wins, the chain is fine.
```

**Cues for pipeline vs imperative:**

| Choose pipeline when... | Choose imperative when... |
|-------------------------|---------------------------|
| Each step has a recognisable name (filter, map, group) | The "step" doesn't have a name; it's bespoke logic |
| Steps are independent (could reorder without changing semantics) | Steps interact through shared state |
| The shape is data-flow: input → transform → output | The shape involves side effects, early termination, or fan-out |
| The reader cares about *what* the function computes | The reader cares about *how* and *when* it computes it |

**Symptoms of "this should be a pipeline":**

- An accumulator object/Map that's both built and later read in the same function.
- Multiple `for` loops on the same data, threading values through intermediate structures.
- A `continue` near the top of the loop — that's a `.filter` in disguise.
- A "post-processing" loop that walks the accumulator after the main loop.
- Comments that describe the function as a query ("get the top N customers by ...").

**When NOT to use this pattern:**

- The accumulation involves multi-key lookups, look-back, or running state that genuinely needs imperative flow (a state machine over the items, a state-dependent transform). Then the pipeline form contorts more than it clarifies.
- Performance-critical hot paths where intermediate-array allocation cost is measurable.
- The pipeline would require helper functions that are themselves harder to name than the original imperative block — the pipeline form should *expose* intent, not hide it behind small named helpers nobody else reuses.

Reference: [LINQ design rationale](https://learn.microsoft.com/en-us/dotnet/csharp/linq/) — same idea from C#'s side; explains why pipeline composition reads as a query.
