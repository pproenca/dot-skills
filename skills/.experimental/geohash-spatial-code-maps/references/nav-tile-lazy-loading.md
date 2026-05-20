---
title: Load Only the Geohash Cells in the Viewport
impact: MEDIUM
impactDescription: loads the viewport, not the whole dataset
tags: nav, lazy-loading, tiles, viewport, fetching
---

## Load Only the Geohash Cells in the Viewport

Loading the entire dataset to render one screen wastes bandwidth and memory and does not scale. Because the viewport is a bounding box, its covering geohash cells ([[qry-bbox-range-decomposition]]) are exactly the data you need — fetch those cells lazily as the user pans, cache what you have, and request only the newly revealed cells. This is the geohash equivalent of map tile loading.

**Incorrect (load everything, filter client-side):**

```typescript
async function onPan(viewport: BBox) {
  const all = await fetchAllPoints();          // downloads the world on every pan
  return all.filter((p) => inBox(p, viewport));
}
```

**Correct (fetch only newly visible cells, with a cache):**

```typescript
const cache = new Map<string, Point[]>();

async function onPan(viewport: BBox, zoom: number) {
  const cells = coverBbox(viewport, precisionForZoom(zoom));
  const missing = cells.filter((c) => !cache.has(c));
  for (const [cell, points] of await fetchCells(missing)) cache.set(cell, points);
  return cells.flatMap((c) => cache.get(c) ?? []); // only the viewport's data
}
```

**When NOT to apply:**
- If the whole dataset fits comfortably in memory, load it once and skip the per-pan fetch — lazy tiling is for data too large to ship whole.

Reference: [OSM Slippy Map](https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames); [Redis Geospatial](https://redis.io/docs/latest/develop/data-types/geospatial/)
