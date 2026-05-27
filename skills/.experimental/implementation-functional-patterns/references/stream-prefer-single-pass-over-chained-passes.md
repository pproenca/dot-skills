---
title: Collapse .filter().map().filter() chains into a single pass when the input is large or the chain is hot
tags: stream, single-pass, allocation-cost, hot-path-performance
---

## Collapse .filter().map().filter() chains into a single pass when the input is large or the chain is hot

Each call in `arr.filter(p).map(f).filter(q)` is its own complete walk plus an intermediate array. Three chained Array methods on a 100k-row array do **three full traversals** and allocate **two intermediate arrays** (the output of `.filter(p)` and the output of `.map(f)`) before producing the final one. For small data this is invisible; for large data or a hot path, the constant factor adds up to 2–5× over an equivalent single pass via `reduce` or `for-of`, and peak memory roughly doubles because the intermediate arrays exist simultaneously while the next stage builds. The fix is not "never chain" — it's "chain when the chain is intent-revealing and short, collapse when the chain is in a hot path or the data is large."

### Shapes to recognize

- Three or more `.filter`/`.map`/`.flatMap` calls in a row over a non-tiny array
- A chain ending in `.length` to count matches — every intermediate array is built and discarded
- A chain inside a render path, a request handler, or an event loop tick — fires on every interaction
- A chain that begins with `.filter(p)` whose predicate is cheap but the array is huge — half the work is producing an intermediate of ~half the size, only to throw it away after one more pass
- A `.filter(...).map(...)` that could be a `.flatMap(x => p(x) ? [f(x)] : [])` or, better, a `reduce`

**Incorrect (three passes + two intermediate arrays):**

```typescript
function activeUserEmails(users: User[]): string[] {
  return users
    .filter((u) => u.status === 'active')          // pass 1, allocates User[]
    .map((u) => ({ ...u, email: u.email.trim() })) // pass 2, allocates {...User}[]
    .filter((u) => u.email.endsWith('@acme.com'))  // pass 3, allocates User[]
    .map((u) => u.email);                          // pass 4, allocates string[]
}
```

Four passes, four allocations of size proportional to surviving input.

**Correct (single pass, single output array):**

```typescript
function activeUserEmails(users: User[]): string[] {
  return users.reduce<string[]>((out, u) => {
    if (u.status !== 'active') return out;
    const email = u.email.trim();
    if (!email.endsWith('@acme.com')) return out;
    out.push(email);
    return out;
  }, []);
}
```

One pass, one allocation (the output, sized to actual matches, not generously-sized intermediates). The mutated accumulator is fine here — it's the documented "fold with push" shape, and the alternative (`acc.concat(email)`) is O(n²).

Equivalent with a generator if you also want laziness:

```typescript
function* activeUserEmails(users: Iterable<User>): Generator<string> {
  for (const u of users) {
    if (u.status !== 'active') continue;
    const email = u.email.trim();
    if (email.endsWith('@acme.com')) yield email;
  }
}
```

### Common pitfalls

- **The order of `.filter` and `.map` matters for cost.** Always filter *before* map when possible — mapping then filtering does work on rows you're about to discard. `arr.map(expensive).filter(p)` is strictly worse than `arr.filter(p).map(expensive)` whenever `p` doesn't depend on `expensive`'s output.
- **`.length` after a chain.** `arr.filter(p).length` is a chain that allocates an intermediate array just to count it. Use `arr.reduce((n, x) => p(x) ? n + 1 : n, 0)` or a `for-of` counter.
- **Premature collapse hurts readability.** A two-step `.filter(active).map(name)` on a small list is clearer chained than reduced. The rule fires on chains of **three or more** stages over **large or hot** data — not on every two-step chain.
- **Don't reach for `reduce` if the chain is already a `flatMap`.** `flatMap` is one pass at this level; chaining `.filter().flatMap()` is two, but combining into a `flatMap(x => p(x) ? [f(x)] : [])` is one and idiomatic.

### Performance trade-offs

- **Time:** chained Array methods are O(k·n) where k is the chain length, single-pass is O(n). The constant factor (function-call overhead per step) means for small n the chained form may even win — measure if it matters.
- **Memory peak:** chained is O(n_after_filter1 + n_after_map + n_after_filter2 + …) held simultaneously while the next pass runs. Single-pass is O(output) only. For a 100MB array filtering down to 10MB, chained peaks at ~200MB+; single-pass peaks at ~110MB.
- **GC pressure:** each intermediate array is short-lived garbage. In server hot paths under load, that's per-request allocation churn that costs latency tail percentiles.
- **Native iterator helpers** (TC39 Stage 4) — `Iterator.from(arr).filter(p).map(f).filter(q).toArray()` — produce *one* output array regardless of chain length, because each helper is lazy and pulls one item at a time. For arrays this is the prettiest single-pass form that retains the chained look.

### When NOT to apply (keep the chain)

- **Small arrays** (< a few hundred items) — readability dominates; the perf difference is unmeasurable
- **Cold code paths** — a startup config transform, a one-off script — readability wins
- **The chain is the documentation** — `.filter(active).filter(verified).filter(notArchived)` reads as a clear three-way conjunction; collapsing it into a reduce with three nested `if`s is worse
- **You're already using iterator helpers** — `Iterator.from(arr).filter(...).map(...)...toArray()` is already a single pass; further collapsing buys nothing

### Related

- The fold tool used in the single-pass form: [`stream-reduce-over-imperative-accumulation`](stream-reduce-over-imperative-accumulation.md)
- For early-exit cases (the chain ends in `.slice(0, n)` or `.find`): [`stream-lazy-iteration-for-large-or-infinite`](stream-lazy-iteration-for-large-or-infinite.md)
- One-to-many in one step: [`stream-flatmap-over-nested-loops`](stream-flatmap-over-nested-loops.md)

Reference: [MDN — `Array.prototype.reduce`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/reduce) · [V8 blog — Array iteration performance](https://v8.dev/blog/elements-kinds)
