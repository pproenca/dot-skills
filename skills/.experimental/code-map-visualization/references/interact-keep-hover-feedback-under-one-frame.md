---
title: Keep Hover Feedback Under One Frame
impact: MEDIUM
impactDescription: prevents hover lag behind the cursor
tags: interact, hover, latency, overlay, feedback
---

## Keep Hover Feedback Under One Frame

Hover is the map's main affordance — it must feel instant. If a hover triggers a full-scene repaint ([[perf-redraw-only-dirty-regions]]) or a synchronous data fetch, the highlight lags the cursor and the map feels broken. Resolve the hovered cell with fast picking ([[interact-pick-with-gpu-color-id-or-spatial-index]]), draw the highlight on the cheap overlay layer, and load any rich tooltip data asynchronously — show a lightweight label immediately and fill in details when they arrive.

**Incorrect (hover blocks on a fetch and repaints everything):**

```typescript
async function onHover(id: number) {
  const details = await fetchDetails(id);     // cursor outruns the highlight
  redrawEverythingWithTooltip(id, details);
}
```

**Correct (highlight now on the overlay; details stream in after):**

```typescript
function onHover(id: number) {
  drawHighlight(overlayCtx, id);              // instant, one cheap layer
  fetchDetails(id).then((d) => { if (hoveredId === id) showTooltip(d); });
}
```

**When NOT to apply:**
- If all tooltip data is already in memory, render it synchronously — the async split only matters when details require I/O.

Reference: [deck.gl — picking](https://deck.gl/docs/developer-guide/interactivity); [MDN — Optimizing canvas](https://developer.mozilla.org/en-US/docs/Web/API/Canvas_API/Tutorial/Optimizing_canvas)
