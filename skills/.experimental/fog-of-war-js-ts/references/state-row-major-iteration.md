---
title: Iterate Row-Major to Match the Buffer's Memory Layout
impact: MEDIUM
impactDescription: reduces cache misses
tags: state, iteration, cache-locality, loop-order, hot-loop
---

## Iterate Row-Major to Match the Buffer's Memory Layout

A flat tile buffer is laid out row by row, so iterating with the `x` loop innermost walks contiguous memory and streams whole cache lines at once. Iterating with `y` innermost jumps `width` elements every step, missing the cache on nearly every access — the same loop body can run several times slower purely from iteration order on a large map. Hoist the row base out of the inner loop so the index is a single add.

**Incorrect (column-major — cache miss per access):**

```typescript
for (let x = 0; x < width; x++) {
  for (let y = 0; y < height; y++) {
    // Each step jumps `width` elements forward — defeats the cache line.
    accumulate(fog[y * width + x]);
  }
}
```

**Correct (row-major with hoisted row base):**

```typescript
for (let y = 0; y < height; y++) {
  const row = y * width;      // computed once per row
  for (let x = 0; x < width; x++) {
    accumulate(fog[row + x]); // contiguous, cache-friendly
  }
}
```

**Benefits:**
- Sequential access lets the prefetcher and SIMD-friendly JIT keep the pipeline full.
- Hoisting `row` removes a multiply from the innermost loop.

Reference: [MDN — Typed arrays](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Typed_arrays)
