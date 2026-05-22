---
title: Render Fog to a Separate Offscreen Layer
impact: HIGH
impactDescription: avoids per-frame fog rasterisation
tags: render, offscreen-canvas, layering, compositing, caching
---

## Render Fog to a Separate Offscreen Layer

Painting fog directly onto the main canvas forces you to repaint the map underneath it every frame, because 2D canvas drawing is destructive. Render the fog once to its own offscreen canvas and composite that bitmap over the map; on frames where only the camera or sprites move, you reuse the cached fog bitmap and skip regenerating it entirely. The fog is regenerated only when visibility actually changes.

**Incorrect (re-rasterise fog into the main canvas each frame):**

```typescript
const TILE = 16;
function frame(ctx: CanvasRenderingContext2D): void {
  drawMap(ctx);
  // Rebuilds the entire fog from the buffer on every animation frame.
  for (let i = 0; i < fog.length; i++) {
    ctx.fillStyle = fogColorFor(fog[i]);
    ctx.fillRect((i % width) * TILE, Math.floor(i / width) * TILE, TILE, TILE);
  }
  requestAnimationFrame(() => frame(ctx));
}
```

**Correct (cached offscreen fog layer):**

```typescript
const TILE = 16;
const fogLayer = new OffscreenCanvas(width * TILE, height * TILE);
const fogCtx = fogLayer.getContext("2d")!;

function onVisibilityChanged(changed: number[]): void {
  paintFog(fogCtx, changed); // regenerate fog only when it changes
}

function frame(main: CanvasRenderingContext2D): void {
  drawMap(main);                  // map repaints for camera/animation
  main.drawImage(fogLayer, 0, 0); // composite the cached fog bitmap
  requestAnimationFrame(() => frame(main));
}
```

**Benefits:**
- A stationary scene composites one cached bitmap instead of rasterising thousands of tiles.
- Separating layers lets fog and map redraw at independent cadences.

Reference: [MDN — OffscreenCanvas](https://developer.mozilla.org/en-US/docs/Web/API/OffscreenCanvas)
