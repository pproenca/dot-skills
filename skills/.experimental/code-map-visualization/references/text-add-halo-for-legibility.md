---
title: Add a Halo So Labels Stay Legible Over Busy Fills
impact: MEDIUM
impactDescription: prevents text disappearing into varied cell colours
tags: text, halo, legibility, contrast, stroke
---

## Add a Halo So Labels Stay Legible Over Busy Fills

A label drawn straight onto the map crosses many cell colours, and wherever the text colour matches the fill beneath it the glyphs vanish. A halo — a contrasting outline drawn behind the glyphs (stroke first, then fill) — guarantees a consistent contrast edge no matter what is underneath, the same trick every cartographic map uses for place names. It is the cheapest fix for "the label is there but I cannot read it" and complements basemap contrast control ([[color-control-contrast-against-basemap]]).

**Incorrect (fill only):**

```typescript
ctx.fillStyle = "#111";
ctx.fillText(region.name, x, y);   // dark text vanishes wherever it crosses a dark cell
```

**Correct (light halo behind dark glyphs):**

```typescript
ctx.lineWidth = 3;
ctx.strokeStyle = "rgba(255,255,255,0.9)";  // halo drawn first, under the glyphs
ctx.strokeText(region.name, x, y);
ctx.fillStyle = "#111";
ctx.fillText(region.name, x, y);            // consistent contrast over any fill
```

**When NOT to apply:**
- Labels confined to a flat, uniform background (a side panel, not the map) need no halo — their contrast is already controlled.

Reference: [MapLibre GL JS (text-halo)](https://maplibre.org/); [MDN — strokeText](https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/strokeText)
