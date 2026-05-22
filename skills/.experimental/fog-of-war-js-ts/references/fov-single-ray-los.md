---
title: Use a Single Line-of-Sight Ray for Point-to-Point Checks
impact: HIGH
impactDescription: O(radius squared) to O(radius)
tags: fov, line-of-sight, bresenham, point-query, ai
---

## Use a Single Line-of-Sight Ray for Point-to-Point Checks

Computing a full field of view to answer one yes/no question — "can this guard see the player?" — pays the entire radius-squared sweep when a single tile-to-tile answer is all you need. Walk one Bresenham line from source to target and stop at the first opaque tile: O(radius) instead of O(radius²). Use this for AI perception, line-of-fire checks, and trigger volumes, where you query a known target rather than reveal an area.

**Incorrect (full FOV sweep for one query):**

```typescript
function canSee(grid: Grid, gx: number, gy: number, px: number, py: number): boolean {
  const seen = new Set<number>();
  const probe: Grid = {
    width: grid.width, height: grid.height,
    isOpaque: (x, y) => grid.isOpaque(x, y),
    setVisible: (x, y) => seen.add(y * grid.width + x), // builds the whole radius
  };
  computeFov(probe, gx, gy, 12);
  return seen.has(py * grid.width + px);
}
```

**Correct (one ray, early exit at the first wall):**

```typescript
function canSee(grid: Grid, x0: number, y0: number, x1: number, y1: number): boolean {
  const dx = Math.abs(x1 - x0);
  const dy = -Math.abs(y1 - y0);
  const sx = x0 < x1 ? 1 : -1;
  const sy = y0 < y1 ? 1 : -1;
  let err = dx + dy;
  let x = x0;
  let y = y0;
  for (;;) {
    if (x === x1 && y === y1) return true;
    if ((x !== x0 || y !== y0) && grid.isOpaque(x, y)) return false;
    const e2 = 2 * err;
    if (e2 >= dy) { err += dy; x += sx; }
    if (e2 <= dx) { err += dx; y += sy; }
  }
}
```

**When NOT to use this pattern:**
- Revealing an area for fog display — use shadowcasting (`fov-recursive-shadowcasting`); N single rays to N targets is slower than one octant sweep.

Reference: [Line drawing on a grid (Red Blob Games)](https://www.redblobgames.com/grids/line-drawing/)
