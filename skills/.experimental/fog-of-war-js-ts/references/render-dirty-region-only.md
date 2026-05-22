---
title: Repaint Only the Dirty Fog Region
impact: HIGH
impactDescription: O(map) to O(changed tiles)
tags: render, dirty-region, partial-redraw, delta, bounding-box
---

## Repaint Only the Dirty Fog Region

Even on its own layer, re-rasterising the whole fog when one tile changes wastes the entire canvas. Repaint only the tiles that changed — or the bounding rectangle that encloses them. Fed by visibility deltas (`update-delta-not-clear`), a one-tile move repaints a handful of tiles instead of the full map, which is the difference between a constant per-frame cost and one that scales with movement.

**Incorrect (clear and redraw the whole layer):**

```typescript
function repaintFog(ctx: CanvasRenderingContext2D): void {
  ctx.clearRect(0, 0, width * TILE, height * TILE); // wipes everything
  for (let i = 0; i < fog.length; i++) drawTile(ctx, i); // redraws every tile
}
```

**Correct (repaint only changed tiles):**

```typescript
function repaintChanged(ctx: CanvasRenderingContext2D, changed: number[]): void {
  for (const i of changed) {
    const x = (i % width) * TILE;
    const y = Math.floor(i / width) * TILE;
    ctx.clearRect(x, y, TILE, TILE); // clear just this tile's cell
    drawTile(ctx, i);                // repaint just this tile
  }
}
```

**Benefits:**
- Render work tracks the visibility delta, not the sight radius or map size.
- For many scattered changes, clear the single enclosing bounding box once, then redraw inside it.

Reference: [MDN — CanvasRenderingContext2D.clearRect](https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/clearRect)
