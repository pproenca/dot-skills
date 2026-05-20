---
title: Bound the Tile and Geometry Cache
impact: HIGH
impactDescription: prevents unbounded memory growth over a long session
tags: perf, cache, lru, memory, tiles
---

## Bound the Tile and Geometry Cache

Lazy tile loading ([[nav-tile-lazy-loading]]) caches fetched cells so panning back is instant — but an unbounded cache grows for the whole session, and a long exploration eventually exhausts memory, triggering GC thrash or a tab crash. Cap the cache with an LRU keyed by geohash cell, evicting the least-recently-viewed tiles (and freeing their GPU buffers) once over a size or count budget. Bounded memory is what lets the map run for hours.

**Incorrect (cache grows forever):**

```typescript
const cache = new Map<string, TileGeometry>();
function get(cell: string) { return cache.get(cell); }   // never evicts -> OOM eventually
```

**Correct (LRU cap; evicting a tile frees its GPU buffer too):**

```typescript
const cache = new LRU<string, TileGeometry>({
  max: 512,
  dispose: (geom) => geom.glBuffer.delete(),   // release VRAM, not just the JS reference
});
function get(cell: string) { return cache.get(cell); }   // touch marks recently used
```

**When NOT to apply:**
- If the entire dataset's geometry fits comfortably in memory and VRAM, caching it all and skipping eviction is simpler.

Reference: [MDN — Optimizing canvas](https://developer.mozilla.org/en-US/docs/Web/API/Canvas_API/Tutorial/Optimizing_canvas); [MDN — Memory management](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Memory_management)
