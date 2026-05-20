---
title: Pack Tiles and Glyphs into a Texture Atlas
impact: HIGH
impactDescription: prevents a texture rebind per tile or glyph
tags: gpu, texture-atlas, tiles, glyphs, binding
---

## Pack Tiles and Glyphs into a Texture Atlas

Binding a texture is a state change ([[gpu-batch-to-cut-draw-calls-and-state-changes]]), and a map drawing one texture per tile, or one per glyph, rebinds constantly and flushes the pipeline each time. Pack many tiles — or the glyph set for labels — into a single large atlas texture, bound once, and address each piece by a UV offset carried as a per-instance attribute. One bind then serves the whole frame.

**Incorrect (a bind per tile):**

```typescript
for (const t of visibleTiles) {
  gl.bindTexture(gl.TEXTURE_2D, t.texture);   // N pipeline flushes per frame
  drawTile(t);
}
```

**Correct (all tiles in one atlas; instance carries its UV rect):**

```typescript
gl.bindTexture(gl.TEXTURE_2D, tileAtlas);     // bound once for the frame
for (const t of visibleTiles) packUV(buf, t.atlasRect);
gl.drawArraysInstanced(gl.TRIANGLE_FAN, 0, 4, visibleTiles.length);
```

**When NOT to apply:**
- A handful of large tiles (a low-zoom overview) may exceed the GPU's max texture size — then page across several atlases, but still avoid one-bind-per-tile.

Reference: [MDN — WebGL best practices](https://developer.mozilla.org/en-US/docs/Web/API/WebGL_API/WebGL_best_practices); [MapLibre GL JS](https://maplibre.org/)
