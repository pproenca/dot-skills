---
title: Reach for Standard Collection Operations Before Writing Loops
impact: CRITICAL
impactDescription: eliminates index variables and accumulator bugs; reduces 5-20 line loops to one expression
tags: reinvent, stdlib, collections, map-filter-reduce
---

## Reach for Standard Collection Operations Before Writing Loops

When a piece of code is "iterate, transform each element, and collect the result," the language almost certainly has a one-call form for it. Hand-written loops to do `map`, `filter`, `groupBy`, `flatMap`, `partition`, or `zip` carry their own index variables, accumulators, and edge cases — and reviewers must verify each one. A linter cannot tell you the loop is `array.map(...)`; that requires understanding intent.

**Incorrect (procedural reconstruction of `map`):**

```typescript
function getOrderTotals(orders: Order[]): number[] {
  const totals: number[] = [];
  for (let i = 0; i < orders.length; i++) {
    const order = orders[i];
    const total = order.items.reduce((sum, it) => sum + it.price * it.qty, 0);
    totals.push(total);
  }
  return totals;
  // 7 lines, index variable, mutable accumulator — all to express "for each order, compute total"
}
```

**Correct (declarative — intent reads off the page):**

```typescript
function getOrderTotals(orders: Order[]): number[] {
  return orders.map(order =>
    order.items.reduce((sum, it) => sum + it.price * it.qty, 0)
  );
  // The loop, the index, the mutable accumulator are all gone.
}
```

**When NOT to use this pattern:**

- The loop short-circuits on a condition (`break`/early return) — `find`/`some`/`every` may fit, but a loop is fine if not.
- The loop performs unrelated side effects per element — keep it imperative; don't fake-functional with `.forEach(sideEffect)` chains.
- Performance hot path with measured allocation pressure from intermediate arrays — but measure first.

**Sibling moves worth recognising:**

- `for` + `push` if predicate → `.filter(predicate)`
- Two nested loops flattening → `.flatMap(...)`
- `reduce` building `{key: [item, ...]}` → `Object.groupBy(items, fn)` (modern JS) or `lodash.groupBy`
- Walking two arrays in lockstep → `zip` (lodash, Ramda) or `array1.map((a, i) => [a, array2[i]])`

Reference: [MDN — Array methods](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array)
