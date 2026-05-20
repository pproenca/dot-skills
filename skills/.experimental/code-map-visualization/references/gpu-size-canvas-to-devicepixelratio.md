---
title: Size the Canvas to devicePixelRatio
impact: HIGH
impactDescription: prevents blurry output or 4x overdraw on HiDPI
tags: gpu, devicepixelratio, hidpi, canvas, resolution
---

## Size the Canvas to devicePixelRatio

A canvas has two sizes — its CSS layout size and its backing-store pixel size. Setting only the CSS size on a HiDPI display makes the browser upscale a low-resolution buffer (blurry cells and text); setting the backing store but forgetting to account for the ratio elsewhere can silently render 4x the pixels (overdraw, halved frame rate). Size the backing store to `cssSize × devicePixelRatio`, scale the 2D context by that ratio, and set the GL viewport to the backing-store size.

**Incorrect (backing store ignores device pixel ratio):**

```typescript
canvas.width = cssWidth;       // upscaled by the browser -> blurry on Retina
canvas.height = cssHeight;
```

**Correct (backing store at device resolution; context scaled to match):**

```typescript
const dpr = window.devicePixelRatio || 1;
canvas.width = Math.round(cssWidth * dpr);
canvas.height = Math.round(cssHeight * dpr);
canvas.style.width = `${cssWidth}px`;
ctx.setTransform(dpr, 0, 0, dpr, 0, 0);   // 1 unit == 1 CSS px, output stays sharp
```

**When NOT to apply:**
- Capping the ratio at 2 on very high-density phones is a deliberate tradeoff — past 2x the sharpness gain rarely justifies the overdraw.

Reference: [MDN — Optimizing canvas](https://developer.mozilla.org/en-US/docs/Web/API/Canvas_API/Tutorial/Optimizing_canvas); [MDN — Window.devicePixelRatio](https://developer.mozilla.org/en-US/docs/Web/API/Window/devicePixelRatio)
