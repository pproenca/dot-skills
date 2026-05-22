---
title: Hoist Allocations Out of the FOV Scan Loop
impact: MEDIUM
impactDescription: eliminates per-cell allocation
tags: mem, closures, hot-loop, allocation, gc
---

## Hoist Allocations Out of the FOV Scan Loop

The field-of-view scan runs its body once per visited cell — thousands of times per recompute — so any object, array, or closure created inside it multiplies into thousands of short-lived allocations and steady GC pressure. Allocate scratch structures and callbacks once, outside the loop (or pass primitives), so the hot path allocates nothing and the JIT can keep it in registers.

**Incorrect (allocates per cell):**

```typescript
function castFov(grid: Grid, cx: number, cy: number, r: number): void {
  for (let i = 1; i <= r; i++) {
    for (let dx = -i; dx <= 0; dx++) {
      const cell = { x: cx + dx, y: cy - i };      // new object per cell
      const handlers = [() => mark(cell)];          // new array + closure per cell
      handlers.forEach((h) => h());
    }
  }
}
```

**Correct (no allocation in the loop):**

```typescript
function castFov(grid: Grid, cx: number, cy: number, r: number, mark: (i: number) => void): void {
  for (let i = 1; i <= r; i++) {
    const rowY = cy - i;
    for (let dx = -i; dx <= 0; dx++) {
      mark((rowY) * grid.width + (cx + dx)); // pass an integer; allocate nothing
    }
  }
}
```

**Benefits:**
- The recompute produces zero garbage, so movement no longer triggers GC spikes.
- Passing a plain index instead of a coordinate object avoids boxing and pointer chasing.

Reference: [MDN — Memory management](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Memory_management)
