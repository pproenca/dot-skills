---
title: Find Edit-Affected Viewers With a Spatial Index
impact: MEDIUM
impactDescription: O(viewers) to O(nearby viewers)
tags: scale, spatial-index, grid-buckets, map-edits, culling
---

## Find Edit-Affected Viewers With a Spatial Index

When a wall is destroyed, only viewers whose sight radius reaches the changed tile need recomputing — but scanning the whole viewer list to find them is O(viewers) per edit, which dominates once you have hundreds of units. Bucket viewers into a coarse spatial grid keyed by `chunkX, chunkY`; an edit queries only the buckets within sight range of the changed tile, so the cost scales with local density, not total population.

**Incorrect (scan every viewer per edit):**

```typescript
function onWallDestroyed(world: World, tx: number, ty: number): void {
  for (const v of world.viewers) { // O(viewers) for one local edit
    if (within(v, tx, ty, v.sight)) recomputeFov(world, v);
  }
}
```

**Correct (query a spatial bucket index):**

```typescript
const CELL = 16; // bucket size in tiles
const buckets = new Map<number, Set<Viewer>>();
const bkey = (x: number, y: number): number => ((y / CELL) | 0) * bucketsWide + ((x / CELL) | 0);

function onWallDestroyed(world: World, tx: number, ty: number, maxSight: number): void {
  const reach = Math.ceil(maxSight / CELL);
  const bx = (tx / CELL) | 0;
  const by = (ty / CELL) | 0;
  for (let cy = by - reach; cy <= by + reach; cy++) {
    for (let cx = bx - reach; cx <= bx + reach; cx++) {
      const here = buckets.get(cy * bucketsWide + cx);
      if (here) for (const v of here) if (within(v, tx, ty, v.sight)) recomputeFov(world, v);
    }
  }
}
```

**When NOT to use this pattern:**
- A handful of viewers — the linear scan is cheaper than maintaining bucket membership on every move.

Reference: [Roguelike Vision Algorithms (Adam Milazzo)](http://www.adammil.net/blog/v125_Roguelike_Vision_Algorithms.html)
