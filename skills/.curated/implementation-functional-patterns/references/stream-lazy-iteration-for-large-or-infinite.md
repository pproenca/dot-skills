---
title: Use generators or Iterator helpers for early-exit over large or infinite sequences
tags: stream, generator, iterator-helpers, lazy-evaluation, early-exit
---

## Use generators or Iterator helpers for early-exit over large or infinite sequences

A model trained on eager array methods writes `arr.filter(p).slice(0, 10)` for "give me the first ten matches." On a 10-million-row array, that materializes **every** match before throwing all but ten away — O(n) time guaranteed, O(matched-total) memory. The functional answer is lazy iteration: a generator or a TC39 Iterator helper chain that produces values on demand and stops the moment the consumer is satisfied. Time becomes O(matched-needed), memory becomes O(1) per step plus the small output buffer. For finite small arrays the eager form is fine and often faster (one tight loop beats per-step iterator protocol overhead); the rule fires when the input is large, expensive to produce, or unbounded.

### Shapes to recognize

- `.filter(...).slice(0, N)` or `.filter(...).find(...)` over arrays with > ~10⁴ items
- Reading lines from a large file, JSON-streaming an API response, or paginating a backend — each "page" is expensive
- Any loop where the input is conceptually infinite (random sampling until convergence, retry-with-backoff, polling)
- Manually keeping a counter inside a `for-of` to bail out at N matches — the imperative shape of a take(N)

**Incorrect (eager: materialize all matches, throw most away):**

```typescript
function firstTenOverdue(invoices: Invoice[]): Invoice[] {
  return invoices.filter((i) => i.dueDate < new Date()).slice(0, 10);
  // Walks every invoice; allocates one Invoice[] sized = all overdue; returns 10.
}
```

**Correct (lazy: stop after the tenth match):**

```typescript
function firstTenOverdue(invoices: Iterable<Invoice>): Invoice[] {
  const now = new Date();
  return Iterator.from(invoices)
    .filter((i) => i.dueDate < now)
    .take(10)
    .toArray();
  // Iterator helpers (TC39 Stage 4, Node 22+ / TS 5.6+): stops after the 10th match.
}
```

For older targets without iterator helpers, a generator + a take helper:

```typescript
function* overdue(invoices: Iterable<Invoice>): Generator<Invoice> {
  const now = new Date();
  for (const i of invoices) if (i.dueDate < now) yield i;
}

function take<T>(iter: Iterable<T>, n: number): T[] {
  const out: T[] = [];
  for (const x of iter) {
    if (out.length >= n) break;
    out.push(x);
  }
  return out;
}

const firstTen = take(overdue(invoices), 10);
```

The reader sees the early-exit and the laziness explicitly. The `for-of` driver loop is just a manual implementation of what `Iterator.prototype.take` does built-in.

### Common pitfalls

- **`Array.from(infiniteIterable)` materializes forever.** `Array.from(naturals())` never returns. Only call `.toArray()` / `Array.from` / spread on bounded iterators — guard with `.take(n)` upstream.
- **Array methods on an array are eager regardless.** `[...largeArr].filter(...).take(...)` does NOT save work — `filter` on an Array still walks the whole array before `take` runs. You must move into iterator-land with `Iterator.from(arr)` or a generator function for laziness to kick in.
- **Generators close on early return.** Code in a `try/finally` block inside a generator runs when the consumer stops iterating (e.g., `break`s out, `take` finishes). Use this for cleanup of file handles, network streams, DB cursors.
- **`async function*` is separate.** Async iterators (`for await…of`) are how you do this over streaming I/O. Don't mix sync and async iterator protocols silently.

### Performance trade-offs

- **Time:** O(matched-needed) vs O(n) when bailing early. For "first 10 of 10M" with a 1% match rate, that's reading ~1000 items vs all 10M — a 10⁴× saving.
- **Memory:** O(1) per-step (the iterator's internal state) plus the output buffer, vs O(matched-total) for eager. For a stream of 1KB records and 100K matches, that's 100MB held in flight vs <1MB.
- **Constant-factor cost:** Iterator protocol overhead (per-step method calls) is real. For **small arrays** (< a few hundred items) or chains that always consume everything, eager array methods are faster. The rule fires only when the upstream is large, expensive, or unbounded.
- **Native iterator helpers vs library helpers:** built-in `Iterator.prototype.*` (TC39 Stage 4) avoids the overhead of a library wrapper class. Prefer native when target supports it.

### When NOT to apply (keep the eager array form)

- **Small finite arrays** (< ~1000 items) where the entire result is consumed — eager is simpler and often faster
- The chain has **no early-exit** and consumes every element anyway — laziness gains nothing, only protocol overhead
- You need **array-only methods** (`.reverse`, `.sort`, indexed access, `.length`) — iterators don't expose those; materialize first
- Working in code that targets Node < 22 / TS < 5.6 AND you don't want to write the generator+take boilerplate — the eager form is fine for small data

### Related

- Adjacent stream rule for transforming finite collections: [`stream-flatmap-over-nested-loops`](stream-flatmap-over-nested-loops.md)
- Avoiding the multi-pass cost when laziness isn't enough: [`stream-prefer-single-pass-over-chained-passes`](stream-prefer-single-pass-over-chained-passes.md)
- GoF class form: [`behavioral-iterator`](../../../.experimental/implementation-design-patterns/references/behavioral-iterator.md) — Iterator-as-a-class is the eager imperative ancestor of these generators

Reference: [TC39 — Iterator Helpers proposal](https://github.com/tc39/proposal-iterator-helpers) · [MDN — Iterator protocol](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Iteration_protocols)
