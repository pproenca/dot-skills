---
title: Track x and y Directly Instead of Modulo-Deindexing
impact: MEDIUM
impactDescription: eliminates per-cell modulo
tags: geo, modulo, indexing, hot-loop, integer-division
---

## Track x and y Directly Instead of Modulo-Deindexing

Recovering tile coordinates from a flat index with `i % width` and `Math.floor(i / width)` puts an integer division and a modulo on the hot path for every cell — and integer division is one of the slowest arithmetic operations. When you iterate the grid, keep `x` and `y` as loop variables (or carry a running row base), so the index is a single addition and the coordinates are already in hand.

**Incorrect (deindex every iteration):**

```typescript
for (let i = 0; i < fog.length; i++) {
  const x = i % width;              // modulo per cell
  const y = (i / width) | 0;        // integer division per cell
  if (isVisible(fog[i])) drawTile(x, y);
}
```

**Correct (iterate coordinates, derive index by addition):**

```typescript
let i = 0;
for (let y = 0; y < height; y++) {
  for (let x = 0; x < width; x++, i++) {
    // x, y already known; i advances by one add — no modulo, no division.
    if (isVisible(fog[i])) drawTile(x, y);
  }
}
```

**When NOT to use this pattern:**
- Iterating a sparse list of changed indices (from `update-delta-not-clear`) where you visit scattered tiles, not the full grid — there a single `% width` per changed tile is fine because the set is small.

Reference: [MDN — Bitwise OR (the `| 0` integer-truncation idiom used above)](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Bitwise_OR)
