---
title: Turn Cached Fields Into Getters Until Profiling Proves Otherwise
impact: HIGH
impactDescription: eliminates invalidation bugs and the "stale cache" class of failures
tags: derive, caching, getters, premature-optimization
---

## Turn Cached Fields Into Getters Until Profiling Proves Otherwise

A surprising amount of code is a stored field that "caches" a cheap computation, with elaborate logic to keep the cache in sync. Most of these cases are premature — the computation is fast enough that the field gains you nothing, but it costs you a permanent risk of "cache out of sync." Start with a getter; promote to a cached field only when profiling shows a real cost.

**Incorrect (cached field with manual invalidation):**

```typescript
class Order {
  items: LineItem[] = [];
  private _total: number = 0;
  private _totalDirty: boolean = true;

  addItem(item: LineItem) {
    this.items.push(item);
    this._totalDirty = true;
  }

  removeItem(id: string) {
    this.items = this.items.filter(i => i.id !== id);
    this._totalDirty = true;
  }

  applyDiscount(percent: number) {
    this.items.forEach(i => { i.price *= (1 - percent / 100); });
    this._totalDirty = true;
    // Did we remember to invalidate everywhere we mutate items? No — there's a mutation
    // in `bulkImport()` 200 lines below that forgets to set `_totalDirty = true`. Bug.
  }

  get total(): number {
    if (this._totalDirty) {
      this._total = this.items.reduce((s, i) => s + i.price * i.qty, 0);
      this._totalDirty = false;
    }
    return this._total;
  }
}
// 20 lines of caching machinery for a sum that takes microseconds.
```

**Correct (just compute it):**

```typescript
class Order {
  items: LineItem[] = [];

  get total(): number {
    return this.items.reduce((s, i) => s + i.price * i.qty, 0);
  }

  addItem(item: LineItem)         { this.items.push(item); }
  removeItem(id: string)          { this.items = this.items.filter(i => i.id !== id); }
  applyDiscount(percent: number)  { this.items.forEach(i => { i.price *= (1 - percent / 100); }); }
}
// The "cache invalidation" failure mode is gone because there is no cache.
// If profiling later shows `total` is a hot path with thousands of items, add memoisation.
```

**The promote-to-cache test (apply IN ORDER, stop at first "no"):**

1. **Profile.** Is `total` (or whichever derivation) measurably expensive in a real scenario?
2. **Count calls.** Is it called many times per change, or once per change?
3. **Check the change-to-read ratio.** Caching pays off when reads ≫ writes.
4. **Only then add memoisation.** And do it with a single well-known pattern (a `WeakMap` keyed on the source, a memoise helper from a library) — not a custom dirty-flag system.

**Symptoms of premature caching:**

- A `_dirty` flag, a `lastUpdated` field, or "remember to invalidate the cache" comments.
- A method whose only job is to mark caches dirty.
- A bug pattern "the displayed value is stale."
- Tests that assert specific cached-vs-fresh behaviour.

**When NOT to use this pattern:**

- The derivation is *genuinely* expensive (a network call, a database query, a multi-second computation) — caching is the right answer; just use a proven pattern, not hand-rolled flags.
- The derivation produces a value used as a key in some collection where identity matters — then you need stable references and a careful cache.

Reference: [Donald Knuth — Structured Programming with go to Statements (§1)](https://dl.acm.org/doi/10.1145/356635.356640) (the "premature optimization" essay)
