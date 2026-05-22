---
title: Recompute Field of View Only When the Viewer Moves
impact: CRITICAL
impactDescription: prevents per-frame recompute
tags: update, caching, dirty-check, frame-budget
---

## Recompute Field of View Only When the Viewer Moves

Field of view depends only on the viewer's position and the map, and neither changes on most frames — yet the single most common fog-of-war performance bug is calling `computeFov()` inside the render loop. At 60fps a radius-12 sweep that recomputes nothing new runs 60 times a second for no reason. Cache the visibility result and recompute only when the viewer's tile changes or the map mutates, turning a per-frame cost into an occasional one.

**Incorrect (recompute every frame):**

```typescript
function frame(state: GameState): void {
  // Full sweep every animation frame, even standing still.
  state.visible.fill(0);
  computeFov(state.grid, state.player.x, state.player.y, state.player.sight);
  renderFog(state);
  requestAnimationFrame(() => frame(state));
}
```

**Correct (recompute on change only):**

```typescript
// Initialise the cached tile to a sentinel no tile can hold, so the first
// frame always computes — even if the player legitimately starts at (0, 0).
state.lastFovX = -1;
state.lastFovY = -1;

function frame(state: GameState): void {
  const { player } = state;
  const moved = player.x !== state.lastFovX || player.y !== state.lastFovY;
  if (moved || state.mapDirty) {
    state.visible.fill(0);
    computeFov(state.grid, player.x, player.y, player.sight);
    state.lastFovX = player.x;
    state.lastFovY = player.y;
    state.mapDirty = false;
  }
  renderFog(state); // rendering can still run every frame for camera/animation
  requestAnimationFrame(() => frame(state));
}
```

**Warning (sentinel, not zero):**
- Initialise `lastFovX`/`lastFovY` to `-1` (or any off-map value), not `0`. With `0`, a player who spawns on tile `(0, 0)` would compare equal on the first frame and never get an initial FOV.

**Benefits:**
- A stationary player costs zero FOV work; movement costs one sweep per tile stepped.
- Decouples FOV cost from frame rate, so a 144Hz display does not triple FOV cost.

Reference: [Roguelike Vision Algorithms (Adam Milazzo)](http://www.adammil.net/blog/v125_Roguelike_Vision_Algorithms.html)
