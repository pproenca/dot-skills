---
title: Use a Generation Stamp to Skip the Per-Frame Clear
impact: MEDIUM
impactDescription: O(n) clear to O(1)
tags: mem, generation-counter, clear, sparse, large-maps
---

## Use a Generation Stamp to Skip the Per-Frame Clear

On a large map where each recompute lights only a small disc, even `fill(0)` over the whole visible buffer is wasted work — you clear a million tiles to light a few hundred. Store a per-tile frame stamp instead of a boolean: a tile is visible when its stamp equals the current frame counter. Marking a tile visible writes the counter; the "clear" is just incrementing the counter, turning an O(n) wipe into O(1).

**Incorrect (clear the whole buffer every recompute):**

```typescript
function recompute(state: FogState, grid: Grid, cx: number, cy: number, r: number): void {
  state.visible.fill(0); // touches every tile even if only 300 become visible
  castFov(grid, state.visible, cx, cy, r);
}
```

**Correct (generation stamp — O(1) reset):**

```typescript
class StampedFog {
  readonly stamp: Uint32Array;
  private frame = 0;
  constructor(size: number) { this.stamp = new Uint32Array(size); }

  recompute(grid: Grid, cx: number, cy: number, r: number): void {
    this.frame++; // the entire "clear" — no buffer wipe
    castFov(grid, (i: number) => { this.stamp[i] = this.frame; }, cx, cy, r);
  }
  isVisible(i: number): boolean { return this.stamp[i] === this.frame; }
}
```

**Warning (counter wraparound):**
- `Uint32Array` stamps wrap after ~4 billion frames (years of play). If you reset or reuse the structure, `fill(0)` once and restart the counter to avoid a stale stamp matching frame 0.

Reference: [MDN — Uint32Array](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Uint32Array)
