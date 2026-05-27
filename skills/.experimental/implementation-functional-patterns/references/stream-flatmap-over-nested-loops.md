---
title: Use flatMap for one-to-many transforms instead of nested loops or map().reduce(concat)
tags: stream, flatmap, one-to-many, collection-transform
---

## Use flatMap for one-to-many transforms instead of nested loops or map().reduce(concat)

A model trained on imperative loops writes nested `for` blocks with a mutated accumulator array when "for each user, expand to all their orders, then collect everything." The result is hard to follow because the iteration mechanics dominate the data transform. `Array.prototype.flatMap` says exactly one thing — "for each input, produce zero or more outputs, then concatenate" — and removes the accumulator entirely. The shape "map then flatten by one level" is so common that flatMap exists as a single call. Avoid `map().flat()` (two passes, two allocations) unless you specifically need the depth-N variant via `flat(N)`.

### Shapes to recognize

- `const out: T[] = []` followed by `for ... { for ... { out.push(...) } }` where the outer iteration is per-parent and the inner is per-child
- `.map(x => f(x)).reduce((acc, xs) => acc.concat(xs), [])` — the manual fold of map's array-of-arrays output
- `.map(x => f(x)).flat()` — equivalent to `flatMap` but two passes; reach for `flat(N)` only when you need depth > 1

**Incorrect (nested loop with mutated accumulator):**

```typescript
function allOrderLineItems(users: User[]): LineItem[] {
  const items: LineItem[] = [];
  for (const user of users) {
    for (const order of user.orders) {
      for (const item of order.lineItems) {
        items.push(item);
      }
    }
  }
  return items;
}
```

**Correct (chained flatMap):**

```typescript
function allOrderLineItems(users: User[]): LineItem[] {
  return users.flatMap((user) => user.orders.flatMap((order) => order.lineItems));
}
```

The chained form reads top-down as "users → their orders → their line items" — the same way the type names compose. The imperative version forces the reader to track `items.push` across three nesting levels and confirm nothing else mutates the accumulator.

### Common pitfalls

- **`flatMap` with `async` returns `Promise[]`, not `Promise<flat[]>`.** `arr.flatMap(async x => fetch(x))` produces an array of promises that flattens by one level into… still an array of promises. Use `Promise.all(arr.map(...))` for parallel awaiting, or `for await…of` for sequential. The model frequently writes this anti-pattern when porting imperative async loops.
- **`map().flat()` is two passes.** Equivalent to `flatMap` only if you don't need `flat(N)` for depth > 1. Default to `flatMap`; reach for `flat(N)` only when the nesting depth is the explicit thing you're collapsing.
- **`flatMap` doesn't preserve indices.** If the outer-index of the originating row matters downstream, capture it inside the mapping (`users.flatMap((u, i) => u.orders.map(o => ({ ...o, userIndex: i })))`) — `flatMap` itself doesn't expose the path.
- **Empty arrays are silent.** `users.flatMap(u => u.orders)` over a user with no orders just skips that user; you lose the row. Use `.map(u => ({ user: u, orders: u.orders }))` if you want to preserve the parent.

### Performance trade-offs

- **Time:** `flatMap` is O(n + total-output) — the inner walks dominate. Tight nested `for-of` loops with `push` are typically **1.5–3× faster** on V8 for large inputs (10k+ rows), mostly due to closure allocation and intermediate-array setup.
- **Allocations:** `flatMap` allocates one intermediate array per level. Three-deep `flatMap` allocates 3 arrays; the nested loop allocates 1.
- **Readability vs throughput trade-off:** the chained `flatMap` form costs 1.5–3× CPU and proportional GC. For a per-render UI transform of a few hundred items, this is unmeasurable. For a server hot path over 100k+ items, the loop wins. Profile, don't guess.
- **For huge inputs:** consider switching to iterator helpers (`Iterator.from(arr).flatMap(...)`) which avoids intermediate arrays — see [`stream-lazy-iteration-for-large-or-infinite`](stream-lazy-iteration-for-large-or-infinite.md).

### When NOT to apply (keep the loop)

- The body has meaningful side effects that benefit from early-`break` (writing to a stream, awaiting one network call at a time, stopping on first match) — `for...of` plus `break` is correct; `flatMap` doesn't short-circuit
- Performance matters and the inputs are very large — see Performance trade-offs above
- The transform is asynchronous and order-sensitive — use `for...of` with `await`, not `flatMap` of promises (which gives `Promise[]`, not `Promise<flat[]>`)

### Related

- GoF class form: [`behavioral-iterator`](../../implementation-design-patterns/references/behavioral-iterator.md) — a custom Iterator class to walk a tree is rarely needed when `flatMap` covers the same job
- Aggregation cousin: `reduce` for fold-to-single-value (counts, sums, groups)

Reference: [MDN — `Array.prototype.flatMap`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/flatMap)
