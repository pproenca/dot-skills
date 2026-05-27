---
title: Use reduce / Object.groupBy / Map.groupBy for aggregation instead of imperative accumulators
tags: stream, reduce, fold, group-by, aggregation
---

## Use reduce / Object.groupBy / Map.groupBy for aggregation instead of imperative accumulators

A model trained on procedural code defaults to `let total = 0; for (…) total += x` for sums, `const seen = {}; for (…) if (!seen[k]) seen[k] = []; seen[k].push(x)` for grouping, and similar accumulator-mutation loops for indexes, counts, and histograms. These work but bury the intent: a reader must scan the whole loop body to discover whether you're summing, indexing, or doing something side-effecting. `reduce` names the fold; `Object.groupBy` and `Map.groupBy` (TC39 Stage 4, TypeScript 5.4+) name the most common reduce shape — partition by key. Reach for the imperative loop only when the body has effects (writes to a stream, awaits one network call at a time, breaks early).

### Shapes to recognize

- `let total/count/min/max = …; for (…) total = …` — classic fold-into-scalar
- `const acc = {} | new Map(); for (…) acc[key] = …` — indexing or grouping by a derived key
- `const groups: Record<K, T[]> = {}; for (…) { if (!groups[k]) groups[k] = []; groups[k].push(x) }` — manual groupBy
- `for (…) histogram[bucket]++` — frequency counts
- Repeated patterns above across the codebase that should reuse a small set of fold helpers

**Incorrect (imperative accumulation for sum, count, and group):**

```typescript
function summarise(orders: Order[]): Summary {
  let totalAmount = 0;
  let openCount = 0;
  const byCustomer: Record<string, Order[]> = {};

  for (const order of orders) {
    totalAmount += order.amount;
    if (order.status === 'open') openCount++;
    if (!byCustomer[order.customerId]) byCustomer[order.customerId] = [];
    byCustomer[order.customerId].push(order);
  }

  return { totalAmount, openCount, byCustomer };
}
```

**Correct (named folds, single declarative statement each):**

```typescript
function summarise(orders: Order[]): Summary {
  return {
    totalAmount: orders.reduce((sum, o) => sum + o.amount, 0),
    openCount:   orders.filter((o) => o.status === 'open').length,
    byCustomer:  Object.groupBy(orders, (o) => o.customerId),
  };
}
```

Each line states what it computes; the reader does not need to scan a loop body for hidden effects. `Object.groupBy` is in TypeScript 5.4+ / Node 21+; for older targets, the explicit reduce is two lines:

```typescript
const byCustomer = orders.reduce<Record<string, Order[]>>((acc, o) => {
  (acc[o.customerId] ??= []).push(o);
  return acc;
}, {});
```

### Common pitfalls

- **String concat via reduce is O(n²).** `arr.reduce((s, x) => s + x.name, '')` allocates a new string at every step. Use `.map(x => x.name).join('')` (or a single join when the input is already strings) which is O(n). The model-default reduce here silently quadratics on long inputs.
- **`acc.push(x); return acc` is a loop in disguise.** That's a mutated accumulator, not a fold. It's *acceptable* (and faster than `acc.concat(x)` which is O(n²)) — but if you find yourself mutating, an explicit `for-of` is honest. Don't dress up a loop in `reduce` clothing for style points.
- **`reduce` with `concat` is the bait.** `arr.reduce((acc, x) => acc.concat(f(x)), [])` is O(n²) — `concat` allocates a new array each step. Use `flatMap` for one-to-many, or push-mutating reduce for general accumulation.
- **`Object.groupBy` keys coerce to strings.** Grouping by an object key won't disambiguate two distinct objects with the same `toString`; use `Map.groupBy` (also Stage 4) when keys are non-primitive.

### Performance trade-offs

- **Time:** `reduce` is the same O(n) as a hand-rolled loop in V8 — the function-call overhead is negligible until you hit very tight inner loops (millions of iterations). String-concat reduce is the one notable footgun (see pitfalls).
- **Allocations:** `Object.groupBy` allocates one outer object and one array per group — equivalent to the hand-rolled version. The reduce-with-concat anti-pattern allocates n intermediate arrays — avoid.
- **Readability is the win**, not raw speed. The same code reads in O(1) cognitive cost ("this is a fold") instead of O(loop-body) cost.

### When NOT to apply (keep the imperative loop)

- The body has meaningful **side effects** — writing to a file, sending one network request at a time, awaiting sequentially — `for-of` plus `await` is correct and `reduce` of promises is a confused shape
- You need to **break early** based on the accumulator state (e.g., stop reading orders once the total exceeds a budget) — `reduce` can't short-circuit; `for-of` with `break` is right
- You're in a **hot path** measured to be reduce-bound and a tight loop with a typed accumulator is meaningfully faster — measure first

### Related

- GoF class form: [`behavioral-iterator`](../../implementation-design-patterns/references/behavioral-iterator.md) — folding a tree via Visitor is the class equivalent of `reduce`
- One-to-many transforms: [`stream-flatmap-over-nested-loops`](stream-flatmap-over-nested-loops.md)
- When the chain has three passes: [`stream-prefer-single-pass-over-chained-passes`](stream-prefer-single-pass-over-chained-passes.md)

Reference: [MDN — `Array.prototype.reduce`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/reduce) · [MDN — `Object.groupBy`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/groupBy)
