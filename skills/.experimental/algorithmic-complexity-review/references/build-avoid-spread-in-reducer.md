---
title: Push to a Mutable Accumulator Instead of Spreading
impact: HIGH
impactDescription: O(n²) to O(n) — common 100-1000× speedup on JS reducers
tags: build, reduce, spread, immutability, accumulator
---

## Push to a Mutable Accumulator Instead of Spreading

`acc => [...acc, x]` looks like a clean append but is `O(|acc|)` — it allocates a new array and copies every prior element on each step. Used as a `reduce` callback over n items, the total work is O(n²). The same trap appears with `acc.concat(x)`. The fix is to mutate the accumulator (`acc.push(x); return acc`) — the reducer's accumulator is internal to the reduce; there's no aliasing problem and no actual immutability gain. Linters that flag mutation in reducers are wrong about this specific pattern.

**Incorrect (spread on every step — O(n²)):**

```javascript
const doubled = numbers.reduce((acc, n) => [...acc, n * 2], []);
// 10,000 numbers → 50,000,000 copy operations (~seconds in V8)
```

**Correct (mutate the accumulator — O(n)):**

```javascript
const doubled = numbers.reduce((acc, n) => {
  acc.push(n * 2);
  return acc;
}, []);
// 10,000 operations total
```

**Alternative (just use `map` when the shape is "transform each"):**

```javascript
const doubled = numbers.map(n => n * 2);
// Same O(n) but clearer intent; the reduce was overkill here
```

**Alternative (filter+map composition):**

```javascript
// Avoid: spread builds a fresh array every step
const result = items.reduce(
  (acc, x) => x.active ? [...acc, transform(x)] : acc,
  []
);

// Better: chain
const result = items.filter(x => x.active).map(transform);
```

**When NOT to use this pattern:**
- When the reducer is intentionally producing new immutable snapshots (e.g., Redux), and each step's result is held by something else (time-travel debugging). Then the cost is paying for a feature you want.

Reference: [V8 blog — array spread copies elements](https://v8.dev/blog/elements-kinds)
