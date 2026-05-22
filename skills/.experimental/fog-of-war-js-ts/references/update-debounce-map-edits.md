---
title: Batch Map Edits and Recompute Affected Viewers Once
impact: MEDIUM-HIGH
impactDescription: reduces N edits to 1 recompute
tags: update, batching, destructible, map-edits
---

## Batch Map Edits and Recompute Affected Viewers Once

Destructible terrain usually changes many tiles in one logical action — an explosion clears a 5×5 area, a door opens, a wall collapses — and recomputing field of view after each individual tile edit repeats the sweep once per tile for a single event. Collect edits into a dirty-tile set during the action, then at end of frame recompute only the viewers whose sight radius overlaps any dirty tile, exactly once.

**Incorrect (recompute per tile edited):**

```typescript
function setOpaque(world: World, x: number, y: number, opaque: boolean): void {
  world.grid.set(x, y, opaque);
  recomputeAllViewers(world); // a 25-tile explosion runs this 25 times
}
```

**Correct (queue edits, flush once):**

```typescript
function setOpaque(world: World, x: number, y: number, opaque: boolean): void {
  world.grid.set(x, y, opaque);
  world.dirtyTiles.add(y * world.grid.width + x); // just record it
}

function endFrame(world: World): void {
  if (world.dirtyTiles.size === 0) return;
  for (const v of world.viewers) {
    if (radiusOverlapsAny(v, world.dirtyTiles, world.grid.width)) {
      computeFovInto(world, v); // only viewers near the change, once
    }
  }
  world.dirtyTiles.clear();
}
```

**Benefits:**
- One explosion costs one recompute per nearby viewer instead of one per changed tile.
- Distant viewers that cannot see the edit are skipped entirely.

Reference: [Roguelike Vision Algorithms (Adam Milazzo)](http://www.adammil.net/blog/v125_Roguelike_Vision_Algorithms.html)
