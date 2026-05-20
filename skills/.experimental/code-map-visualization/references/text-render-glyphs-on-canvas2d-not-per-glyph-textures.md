---
title: Render Label Text on Canvas2D, Not Per-Glyph GL Textures
impact: MEDIUM-HIGH
impactDescription: prevents per-glyph texture uploads and blur
tags: text, canvas2d, glyphs, sdf, rendering
---

## Render Label Text on Canvas2D, Not Per-Glyph GL Textures

Native Canvas2D `fillText` is hinted, kerned, and crisp at any pixel ratio, and the browser caches its glyph rasterisation. Re-implementing text in WebGL by uploading a texture per glyph or per label is slow (uploads stall the pipeline), blurry (no hinting), and a lot of code. Draw labels with `fillText` on the 2D overlay layer ([[gpu-layer-canvas2d-over-webgl]]); only reach for GL text via a signed-distance-field atlas when labels must rotate and scale with the camera in 3D, which a flat code map rarely needs.

**Incorrect (rasterise each label to a texture and upload it):**

```typescript
for (const l of labels) {
  const tex = uploadTexture(rasterizeLabel(l.name)); // pipeline stall per label, blurry
  drawTexturedQuad(gl, tex, l.xy);
}
```

**Correct (native text on the 2D overlay):**

```typescript
overlayCtx.font = "12px Inter";
for (const l of labels) overlayCtx.fillText(l.name, l.x, l.y); // hinted, kerned, cached
```

**When NOT to apply:**
- A true 3D scene where labels billboard and scale with perspective needs SDF glyph atlases — the 2D overlay cannot track 3D depth.

Reference: [MDN — Optimizing canvas](https://developer.mozilla.org/en-US/docs/Web/API/Canvas_API/Tutorial/Optimizing_canvas); [MapLibre GL JS (SDF glyphs)](https://maplibre.org/)
