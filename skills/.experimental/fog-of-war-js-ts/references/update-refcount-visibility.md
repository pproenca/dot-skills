---
title: Count Viewers Per Tile for Incremental Multi-Viewer Updates
impact: CRITICAL
impactDescription: O(viewers) to O(1) per tile hide
tags: update, refcount, multi-viewer, incremental
---

## Count Viewers Per Tile for Incremental Multi-Viewer Updates

When several units share one visibility layer, a boolean "visible" flag cannot answer whether a tile is still seen by *another* unit after one unit looks away — so the only safe move is to clear everything and re-union all units. Store a per-tile integer count of how many viewers currently see it: increment when a viewer reveals a tile, decrement when it stops. The tile is visible while the count is above zero, so a single unit's move only touches its own old and new field of view.

**Incorrect (boolean flag forces full rebuild):**

```typescript
function onUnitMoved(world: World): void {
  world.visible.fill(0); // cannot tell which tiles others still see
  for (const u of world.units) {
    forEachVisible(world.grid, u.x, u.y, u.sight, (i) => { world.visible[i] = 1; });
  }
}
```

**Correct (per-tile reference count):**

```typescript
interface World {
  grid: Grid;
  seenBy: Uint16Array;  // how many units currently see tile i
  visible: Uint8Array;  // derived: seenBy[i] > 0
  explored: Uint8Array;
}

function moveUnit(world: World, u: Unit, nx: number, ny: number): void {
  forEachVisible(world.grid, u.x, u.y, u.sight, (i) => {
    if (--world.seenBy[i] === 0) world.visible[i] = 0; // last viewer left
  });
  u.x = nx;
  u.y = ny;
  forEachVisible(world.grid, nx, ny, u.sight, (i) => {
    if (world.seenBy[i]++ === 0) world.visible[i] = 1; // first viewer arrived
    world.explored[i] = 1;
  });
}
```

**When NOT to use this pattern:**
- A single viewer (one player) — a plain boolean/bitset (`state-bitset-layers`) is simpler and the rebuild is trivial.

Reference: [Roguelike Vision Algorithms (Adam Milazzo)](http://www.adammil.net/blog/v125_Roguelike_Vision_Algorithms.html)
