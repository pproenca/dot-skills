---
title: Pick With a GPU Color ID or Spatial Index, Not a Linear Scan
impact: MEDIUM-HIGH
impactDescription: O(n) hit-test to O(1) or O(log n)
tags: interact, picking, hit-testing, gpu-picking, spatial-index
---

## Pick With a GPU Color ID or Spatial Index, Not a Linear Scan

Finding which cell is under the cursor by looping over every cell and testing distance is O(n) per mouse move — at 100k cells that misses the frame budget and makes hover lag. Two scalable options: GPU colour picking (render each cell to an offscreen buffer in a unique colour ID, then read back the single pixel under the cursor — O(1)), or query a spatial index (the same geohash structure the data already has, [[qry-search-cell-plus-neighbors]]) for O(log n) lookup. deck.gl ships GPU picking for exactly this.

**Incorrect (O(n) distance test on every mouse move):**

```typescript
function pick(mx: number, my: number) {
  return cells.find((c) => dist(c.screenXY, [mx, my]) < c.radius); // 100k checks per move
}
```

**Correct (cells drawn once to an ID buffer; pick reads a single pixel):**

```typescript
function pick(mx: number, my: number) {
  const px = new Uint8Array(4);
  gl.readPixels(mx, my, 1, 1, gl.RGBA, gl.UNSIGNED_BYTE, px); // from the id framebuffer
  return cellById(rgbaToId(px));   // O(1), independent of cell count
}
```

**When NOT to apply:**
- A few hundred cells are fine to scan linearly — GPU picking adds an extra render pass that only pays off at scale.

Reference: [deck.gl — picking](https://deck.gl/docs/developer-guide/interactivity); [MDN — WebGL best practices](https://developer.mozilla.org/en-US/docs/Web/API/WebGL_API/WebGL_best_practices)
