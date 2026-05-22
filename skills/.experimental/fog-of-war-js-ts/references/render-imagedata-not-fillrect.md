---
title: Build Fog as One ImageData, Not Per-Tile fillRect
impact: HIGH
impactDescription: reduces thousands of draws to one blit
tags: render, imagedata, fillrect, batching, putimagedata
---

## Build Fog as One ImageData, Not Per-Tile fillRect

A separate `fillStyle` assignment plus `fillRect` per tile issues thousands of individual draw operations per repaint, each carrying state-change and path-setup overhead, when fog is really just a per-tile alpha grid. Write the fog directly into a single `ImageData` (one pixel per tile) and blit it once with `putImageData`, then scale that small bitmap up to tile size. One upload replaces the whole nested fill loop.

**Incorrect (one fillRect per tile):**

```typescript
function paintFog(ctx: CanvasRenderingContext2D): void {
  for (let i = 0; i < fog.length; i++) {
    const f = fog[i];
    ctx.fillStyle = f & VISIBLE ? "rgba(0,0,0,0)" : f & EXPLORED ? "rgba(0,0,0,0.55)" : "#000";
    ctx.fillRect((i % width) * TILE, Math.floor(i / width) * TILE, TILE, TILE);
  }
}
```

**Correct (one pixel per tile in an ImageData, blit once):**

```typescript
const tileFog = new OffscreenCanvas(width, height); // one texel per tile
const tileCtx = tileFog.getContext("2d")!;
const img = tileCtx.createImageData(width, height);
const px = img.data; // Uint8ClampedArray: 4 bytes per tile, RGB stay 0 (black)

function paintFog(main: CanvasRenderingContext2D): void {
  for (let i = 0; i < fog.length; i++) {
    const f = fog[i];
    px[i * 4 + 3] = f & VISIBLE ? 0 : f & EXPLORED ? 140 : 255; // only alpha varies
  }
  tileCtx.putImageData(img, 0, 0); // single upload replaces width*height fillRects
  main.drawImage(tileFog, 0, 0, width, height, 0, 0, width * TILE, height * TILE);
}
```

`createImageData` zero-fills, so the R, G, B bytes stay `0` (black fog) and only alpha changes per frame. For a tinted fog, write the RGB bytes once at setup and keep mutating only alpha in the loop.

**Benefits:**
- One `putImageData` plus one `drawImage` instead of `width × height` fill calls.
- The small per-tile bitmap upscales cheaply and enables soft edges (`render-lowres-soft-upscale`).

Reference: [MDN — CanvasRenderingContext2D.putImageData](https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/putImageData)
