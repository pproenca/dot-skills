---
title: Allocate Fog Buffers Once and Reuse Them
impact: MEDIUM-HIGH
impactDescription: prevents per-frame GC pauses
tags: mem, allocation, gc, buffer-reuse, jank
---

## Allocate Fog Buffers Once and Reuse Them

Allocating a fresh `Uint8Array` for the visibility buffer on every recompute hands the garbage collector a large short-lived object each frame; the resulting GC cycles surface as periodic frame-time spikes — visible stutter exactly when the player is moving and triggering recomputes. Allocate the buffers once at map load and reuse them; clearing in place (`mem-clear-with-fill`) costs a fraction of an allocation and produces no garbage.

**Incorrect (allocate per recompute):**

```typescript
function computeVisibility(grid: Grid, cx: number, cy: number, r: number): Uint8Array {
  const visible = new Uint8Array(grid.width * grid.height); // garbage every move
  castFov(grid, visible, cx, cy, r);
  return visible;
}
```

**Correct (reuse a preallocated buffer):**

```typescript
class FogState {
  readonly visible: Uint8Array;
  readonly explored: Uint8Array;
  constructor(readonly width: number, readonly height: number) {
    this.visible = new Uint8Array(width * height);  // allocated once
    this.explored = new Uint8Array(width * height);
  }
  recompute(grid: Grid, cx: number, cy: number, r: number): void {
    this.visible.fill(0);                 // reuse, no allocation
    castFov(grid, this.visible, cx, cy, r);
  }
}
```

**Benefits:**
- Steady-state movement allocates nothing, so there are no GC pauses tied to recomputes.
- A single owning object keeps the visible/explored buffers in sync and cache-adjacent.

Reference: [MDN — Memory management](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Memory_management)
