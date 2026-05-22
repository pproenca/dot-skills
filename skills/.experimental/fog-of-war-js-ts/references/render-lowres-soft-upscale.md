---
title: Render Soft Fog at Tile Resolution and Upscale on the GPU
impact: MEDIUM-HIGH
impactDescription: eliminates per-pixel CPU blur
tags: render, soft-fog, upscaling, bilinear, gpu
---

## Render Soft Fog at Tile Resolution and Upscale on the GPU

Soft, feathered fog edges computed per screen pixel on the CPU cost millions of operations per frame for a blur the GPU does for free. Render the fog at tile resolution — one texel per tile — into a small buffer, then let the hardware bilinear-filter it up to screen size when you draw it. The CPU writes one value per tile; the smoothing happens during the scaled blit.

**Incorrect (per-pixel CPU blur of a full-res fog bitmap):**

```typescript
// Box-blur every screen pixel of the full-resolution fog every frame.
function blurFog(src: Uint8ClampedArray, dst: Uint8ClampedArray, w: number, h: number): void {
  for (let y = 1; y < h - 1; y++) {
    for (let x = 1; x < w - 1; x++) {
      let sum = 0;
      for (let oy = -1; oy <= 1; oy++) {
        for (let ox = -1; ox <= 1; ox++) sum += src[((y + oy) * w + (x + ox)) * 4 + 3];
      }
      dst[(y * w + x) * 4 + 3] = sum / 9; // millions of ops per frame
    }
  }
}
```

**Correct (tile-res fog, GPU bilinear upscale):**

```typescript
const tileFog = new OffscreenCanvas(width, height); // one texel per tile
// ...write one alpha per tile into tileFog via ImageData (render-imagedata-not-fillrect)...

function compositeFog(main: CanvasRenderingContext2D): void {
  main.imageSmoothingEnabled = true; // bilinear filtering during upscale = soft edges
  main.drawImage(tileFog, 0, 0, width, height, 0, 0, width * TILE, height * TILE);
}
```

**Benefits:**
- The blur is hardware-interpolated for free; CPU work drops to one write per tile.
- The small fog buffer also uploads faster to a WebGL texture (`render-webgl-texsubimage`).

Reference: [MDN — CanvasRenderingContext2D.imageSmoothingEnabled](https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/imageSmoothingEnabled)
