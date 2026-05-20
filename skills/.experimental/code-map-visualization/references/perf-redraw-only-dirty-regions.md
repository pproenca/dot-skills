---
title: Redraw Only Dirty Layers and Regions
impact: HIGH
impactDescription: prevents repainting static layers every frame
tags: perf, dirty-tracking, damage, layers, invalidation
---

## Redraw Only Dirty Layers and Regions

Most frames change very little — a hover highlight moves, one cell is selected — yet a naive renderer repaints every cell and label each frame. Track what actually changed and repaint only that: keep static cell geometry on its own layer that you redraw only when the data or camera changes, and redraw the cheap overlay layer ([[gpu-layer-canvas2d-over-webgl]]) for hover and selection. Damage tracking turns a full-scene repaint into a few-pixel update.

**Incorrect (a hover repaints the whole scene):**

```typescript
function onHover(id: number) {
  ctx.clearRect(0, 0, w, h);
  drawCells(ctx, cells);     // unchanged, but redrawn on every mouse move
  drawHighlight(ctx, id);
}
```

**Correct (the cells layer is untouched; only the overlay repaints):**

```typescript
function onHover(id: number) {
  overlayCtx.clearRect(0, 0, w, h);   // cheap transparent layer
  drawHighlight(overlayCtx, id);      // cells layer left as-is
}
```

**When NOT to apply:**
- While the camera is actively animating, the whole scene is dirty anyway — dirty tracking helps idle and micro-interaction frames, not a full zoom.

Reference: [MDN — Optimizing canvas](https://developer.mozilla.org/en-US/docs/Web/API/Canvas_API/Tutorial/Optimizing_canvas); [deck.gl](https://deck.gl/)
