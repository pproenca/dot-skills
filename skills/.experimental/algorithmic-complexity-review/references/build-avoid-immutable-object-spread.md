---
title: Use a Plain Object Build Phase, Then Freeze
impact: MEDIUM-HIGH
impactDescription: O(n*k) to O(n) — k = property count of the growing object
tags: build, object-spread, immutability, reducer, freeze
---

## Use a Plain Object Build Phase, Then Freeze

`{...acc, [k]: v}` inside a reducer copies every existing key on every step. Building a 1,000-entry lookup table this way is ~500,000 copy operations, not 1,000. The fix is identical to the array spread case: mutate a plain object during construction (`acc[k] = v; return acc`), and if you need immutability afterwards, `Object.freeze` once at the end. The "no mutation" rule is about object identity stability for callers — it doesn't apply to the private accumulator inside reduce.

**Incorrect (object spread per step — O(n²)):**

```javascript
const byId = items.reduce((acc, item) => ({
  ...acc,
  [item.id]: item,
}), {});
// 1,000 items × avg 500 keys copied = 500,000 ops; 10,000 items → 50M ops
```

**Correct (mutate during build, freeze if needed):**

```javascript
const byId = items.reduce((acc, item) => {
  acc[item.id] = item;
  return acc;
}, {});
// 1,000 inserts, O(n) total
```

**Alternative (built-in `Object.fromEntries`):**

```javascript
const byId = Object.fromEntries(items.map(item => [item.id, item]));
// O(n) — and clearer intent than a reduce
```

**Alternative (`Map` when keys aren't statically known to be strings):**

```javascript
const byId = new Map(items.map(item => [item.id, item]));
// O(n), preserves insertion order, accepts any key type
```

**When NOT to use this pattern:**
- When you actually need a snapshot at each step (rare: typically only Redux-style time travel). Then the O(n²) is the price of the feature.
- For tiny objects (< 5 keys) — the constant factors don't show up; readability wins.

Reference: [MDN — `Object.fromEntries`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/fromEntries)
