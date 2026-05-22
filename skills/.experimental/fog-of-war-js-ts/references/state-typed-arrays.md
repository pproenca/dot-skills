---
title: Store Fog State in Typed Arrays, Not Arrays of Objects
impact: HIGH
impactDescription: eliminates per-cell object overhead
tags: state, typed-arrays, cache-locality, gc, memory
---

## Store Fog State in Typed Arrays, Not Arrays of Objects

Storing each tile as an object in a 2D array means every tile read chases a pointer to a heap object scattered across memory, defeating the CPU cache, and it creates `width × height` objects the garbage collector must scan on every cycle. Parallel typed arrays store one fixed-width value per tile contiguously, so a full sweep streams through cache lines and allocates nothing per tile.

**Incorrect (array of heap objects):**

```typescript
interface Tile { visible: boolean; explored: boolean; opaque: boolean; }

const grid: Tile[][] = [];
for (let y = 0; y < height; y++) {
  grid[y] = [];
  for (let x = 0; x < width; x++) {
    grid[y][x] = { visible: false, explored: false, opaque: false };
  }
}
// A 1000x1000 map = 1,000,000 heap objects for the GC to trace, each a pointer hop away.
const lit = grid[y][x].visible;
```

**Correct (parallel typed arrays):**

```typescript
const visible = new Uint8Array(width * height);
const explored = new Uint8Array(width * height);
const opaque = new Uint8Array(width * height);

const lit = visible[y * width + x] === 1; // contiguous read, zero GC pressure
```

**Benefits:**
- The visible buffer clears in one `fill(0)` instead of touching a million objects.
- Contiguous layout lets the JIT vectorise sweeps and keeps data in cache.

Reference: [MDN — Typed arrays](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Typed_arrays)
