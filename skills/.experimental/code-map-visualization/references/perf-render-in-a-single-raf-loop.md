---
title: Render in a Single requestAnimationFrame Loop
impact: HIGH
impactDescription: reduces redraws to one per frame
tags: perf, requestanimationframe, render-loop, coalescing, scheduling
---

## Render in a Single requestAnimationFrame Loop

Redrawing directly inside every input event (mousemove, wheel, resize) can fire the renderer dozens of times per frame, doing work the screen never shows and starving the browser. Decouple input from drawing: events update state and request a single `requestAnimationFrame`; the rAF callback reads the latest state and draws once. This coalesces a burst of events into one redraw per frame and keeps the loop synced to the display's refresh.

**Incorrect (redraw inside every event):**

```typescript
canvas.onmousemove = (e) => { updateHover(e); render(); };  // many draws per frame
canvas.onwheel    = (e) => { updateZoom(e);  render(); };
```

**Correct (events request one frame; render runs once per frame):**

```typescript
let frame = 0;
const schedule = () => { frame ||= requestAnimationFrame(() => { frame = 0; render(); }); };
canvas.onmousemove = (e) => { updateHover(e); schedule(); };
canvas.onwheel    = (e) => { updateZoom(e);  schedule(); };   // coalesced to one redraw
```

**When NOT to apply:**
- A static map that redraws only on an explicit user action (not continuous interaction) can draw on demand without maintaining a loop.

Reference: [MDN — requestAnimationFrame](https://developer.mozilla.org/en-US/docs/Web/API/Window/requestAnimationFrame); [MDN — Optimizing canvas](https://developer.mozilla.org/en-US/docs/Web/API/Canvas_API/Tutorial/Optimizing_canvas)
