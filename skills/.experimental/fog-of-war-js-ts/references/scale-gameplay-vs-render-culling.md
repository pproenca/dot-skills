---
title: Separate Gameplay Visibility From On-Screen Render Culling
impact: MEDIUM
impactDescription: prevents culling gameplay state
tags: scale, culling, gameplay, rendering, viewport
---

## Separate Gameplay Visibility From On-Screen Render Culling

It is tempting to skip field-of-view work for units off-screen, but gameplay visibility (does the enemy detect my scout? does this tile reveal on the minimap?) must stay correct whether or not the camera is looking. Conflating the two causes bugs where an off-screen unit "forgets" what it sees, or fog state desyncs when the camera pans back. Always compute gameplay visibility; cull only the *rendering* of fog tiles outside the viewport.

**Incorrect (skip FOV for off-screen units):**

```typescript
function update(world: World, camera: Rect): void {
  for (const u of world.units) {
    if (!inViewport(u, camera)) continue; // BUG: off-screen units stop seeing
    recomputeFov(world, u);
  }
}
```

**Correct (compute everywhere, render only what's on screen):**

```typescript
function update(world: World): void {
  for (const u of world.units) recomputeFov(world, u); // gameplay: always correct
}

function renderFog(ctx: CanvasRenderingContext2D, world: World, camera: Rect): void {
  const [x0, y0, x1, y1] = tileBounds(camera);
  for (let y = y0; y <= y1; y++) {       // render: only visible viewport tiles
    for (let x = x0; x <= x1; x++) drawFogTile(ctx, world, x, y);
  }
}
```

**Benefits:**
- Detection, minimap, and AI stay correct regardless of camera position.
- Render cost still scales with the viewport, not the map — the safe place to cull.

Reference: [rot.js field-of-view documentation](https://ondras.github.io/rot.js/manual/#fov)
