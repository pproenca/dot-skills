---
title: Cap FOV Recomputes Per Frame With a Time Budget
impact: MEDIUM
impactDescription: maintains a fixed frame budget
tags: scale, budget, time-slicing, scheduling, frame-rate
---

## Cap FOV Recomputes Per Frame With a Time Budget

When many units move on the same frame — a whole squad marching — recomputing every dirty unit's field of view at once produces a single huge frame spike and a dropped frame. Spread the work: process dirty viewers from a queue until a per-frame budget (a unit count or a millisecond cap) is hit, then resume next frame. Visibility lags by a frame or two for distant units, which is imperceptible, while the frame rate stays smooth.

**Incorrect (recompute all dirty units in one frame):**

```typescript
function update(world: World): void {
  for (const v of world.viewers) {
    if (v.dirty) { recomputeFov(world, v); v.dirty = false; } // 200 sweeps = dropped frame
  }
}
```

**Correct (budgeted queue, spread across frames):**

```typescript
const MAX_MS = 2; // FOV time budget per frame

function update(world: World, queue: Viewer[]): void {
  const deadline = performance.now() + MAX_MS;
  while (queue.length > 0 && performance.now() < deadline) {
    const v = queue.shift()!;
    recomputeFov(world, v);
    v.dirty = false;
  }
  // Remaining dirty viewers stay queued for the next frame.
}
```

**When NOT to use this pattern:**
- The local player's own field of view — recompute it immediately so the player never sees stale fog around themselves; budget only the secondary viewers.

Reference: [MDN — performance.now](https://developer.mozilla.org/en-US/docs/Web/API/Performance/now)
