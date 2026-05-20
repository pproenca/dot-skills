---
title: Layer Canvas2D Over WebGL for Crisp Overlays
impact: HIGH
impactDescription: prevents blurry text and per-frame GPU label cost
tags: gpu, canvas2d, webgl, compositing, layering
---

## Layer Canvas2D Over WebGL for Crisp Overlays

WebGL is the only practical way to draw 100k+ cells per frame, but it is the wrong tool for crisp text, selection outlines, and UI chrome — rasterising glyphs into GL textures is fiddly and tends to blur. Stack two canvases: a WebGL canvas for the bulk cell geometry and a transparent Canvas2D canvas on top for labels, hover highlights, and the legend. The 2D layer redraws only when those overlays change ([[perf-redraw-only-dirty-regions]]), so labels stay sharp at any pixel ratio ([[gpu-size-canvas-to-devicepixelratio]]) without re-rendering the cells.

**Incorrect (text drawn in WebGL):**

```typescript
glDrawCells(gl, cells);
glDrawText(gl, labels);   // bespoke glyph atlas just to show region names -> blurry, costly
```

**Correct (bulk geometry on GL, overlays on a 2D canvas above it):**

```typescript
glDrawCells(gl, cells);                 // 100k cells, one pass
const ov = overlay.getContext("2d");    // transparent <canvas> stacked over the GL canvas
ov.clearRect(0, 0, w, h);
drawLabels(ov, labels);                 // crisp native text, redrawn only on change
```

**When NOT to apply:**
- If the whole map is a few thousand cells and a handful of labels, a single Canvas2D layer is simpler and fast enough — the split earns its keep at GL-scale counts.

Reference: [MDN — WebGL best practices](https://developer.mozilla.org/en-US/docs/Web/API/WebGL_API/WebGL_best_practices); [MDN — Optimizing canvas](https://developer.mozilla.org/en-US/docs/Web/API/Canvas_API/Tutorial/Optimizing_canvas)
