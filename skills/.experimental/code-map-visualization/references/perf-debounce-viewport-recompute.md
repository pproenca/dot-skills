---
title: Debounce Viewport-to-Cell Recomputation
impact: HIGH
impactDescription: prevents recomputing the covering set per mouse move
tags: perf, debounce, viewport, covering-set, throttling
---

## Debounce Viewport-to-Cell Recomputation

Deriving which geohash cells cover the viewport ([[qry-bbox-range-decomposition]]) is real work — bbox decomposition, cache lookups, possibly a fetch ([[nav-tile-lazy-loading]]). Doing it on every pan delta recomputes essentially the same set 60 times a second. Render the existing geometry every frame for smoothness, but throttle the covering-set recompute so it fires only when the viewport has moved a meaningful fraction of a cell, or on a short trailing debounce after motion settles.

**Incorrect (full covering-set recompute every pan frame):**

```typescript
function onViewState(vs: ViewState) {
  const cells = coverBbox(vs.bounds, precisionForZoom(vs.zoom)); // 60x/sec, near-identical
  loadAndRender(cells, vs);
}
```

**Correct (draw every frame; recompute the set only when it can have changed):**

```typescript
const recompute = throttle((vs: ViewState) => {
  visibleCells = coverBbox(vs.bounds, precisionForZoom(vs.zoom));
  ensureLoaded(visibleCells);
}, 120);
function onViewState(vs: ViewState) { render(vs); recompute(vs); } // smooth pan, cheap set
```

**When NOT to apply:**
- At very low cell counts the covering-set recompute is negligible, and debouncing only adds latency to the first paint.

Reference: [MDN — Optimizing canvas](https://developer.mozilla.org/en-US/docs/Web/API/Canvas_API/Tutorial/Optimizing_canvas); [OSM Slippy Map](https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames)
