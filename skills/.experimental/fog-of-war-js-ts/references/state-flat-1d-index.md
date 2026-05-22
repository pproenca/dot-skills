---
title: Index a Flat Buffer With y times width plus x, Not Nested Arrays
impact: HIGH
impactDescription: eliminates per-row array indirection
tags: state, flat-array, indexing, cache-locality, allocation
---

## Index a Flat Buffer With y times width plus x, Not Nested Arrays

A nested `grid[y][x]` layout allocates one sub-array per row, so a tile read first dereferences the outer array to find the row, then indexes the row — two memory hops, and the rows themselves sit scattered across the heap. A single flat buffer indexed by `y * width + x` is one contiguous block: one hop per access, the whole grid clears in a single `fill`, and adjacent tiles are adjacent in memory.

**Incorrect (nested per-row arrays):**

```typescript
const grid: Uint8Array[] = [];
for (let y = 0; y < height; y++) grid[y] = new Uint8Array(width);

const lit = grid[y][x];      // dereference row array, then index it
grid.forEach((row) => row.fill(0)); // height separate clears, scattered rows
```

**Correct (single flat buffer):**

```typescript
const grid = new Uint8Array(width * height);

const idx = (x: number, y: number): number => y * width + x;
const lit = grid[idx(x, y)]; // one contiguous read
grid.fill(0);                // clears the entire grid in one pass
```

**Benefits:**
- Neighbour lookups become index arithmetic (`i - width` is the tile above), enabling cheap edge/corner handling.
- One allocation instead of `height + 1`, and one `fill(0)` to reset the frame.

Reference: [MDN — Typed arrays](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Typed_arrays)
