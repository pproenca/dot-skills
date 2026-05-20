---
title: Model the Camera as View-State, Not DOM Scroll
impact: MEDIUM-HIGH
impactDescription: prevents drift between zoom, data, and URL
tags: interact, camera, view-state, zoom, transform
---

## Model the Camera as View-State, Not DOM Scroll

A map's camera is a small piece of state — centre (projected x/y) and zoom — from which the world-to-screen transform, the visible cell set, and the deep link all derive. Driving the view from DOM scroll position or ad-hoc CSS transforms scatters the source of truth, so zoom level, loaded data, and the URL drift apart, and pinch or programmatic "fly to" become impossible. Keep one view-state object; every consumer reads from it, and the precision-to-zoom mapping ([[nav-precision-to-zoom-levels]]) is derived, never duplicated.

**Incorrect (camera scattered across DOM scroll and CSS):**

```typescript
container.scrollTop;                       // pan lives here
mapEl.style.transform = `scale(${k})`;     // zoom lives here; the URL knows neither
```

**Correct (one view-state; transform, cells, and URL all derive from it):**

```typescript
type ViewState = { x: number; y: number; zoom: number };
const transform = transformFromViewState(view);   // world -> screen
const cells     = coverBbox(boundsOf(view), precisionForZoom(view.zoom));
syncUrl(view);                                     // see interact-sync-view-state-to-the-url
```

**When NOT to apply:**
- A non-interactive thumbnail with a fixed view needs no camera model — hardcode the transform.

Reference: [deck.gl — views and view state](https://deck.gl/docs/developer-guide/views); [MapLibre GL JS](https://maplibre.org/)
