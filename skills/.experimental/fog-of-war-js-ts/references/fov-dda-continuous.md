---
title: Traverse Continuous Space With a DDA Grid Walk
impact: MEDIUM-HIGH
impactDescription: prevents missed thin walls
tags: fov, dda, raycasting, continuous, grid-traversal
---

## Traverse Continuous Space With a DDA Grid Walk

For sub-tile viewer positions or 2.5D raycasters, advancing a ray by a fixed step is a lose-lose: a large step skips walls thinner than the step (light leaks through corners) while a small step oversamples, marking the same cell many times. A DDA (digital differential analyzer) walk steps exactly to each cell boundary, so it visits every cell the ray crosses exactly once with no gaps and no repeats, regardless of direction.

**Incorrect (fixed-step sampling):**

```typescript
// STEP too large skips thin walls; STEP too small re-marks cells. Both are wrong.
function castRay(grid: Grid, x: number, y: number, dx: number, dy: number, maxDist: number): void {
  const STEP = 0.25;
  for (let t = 0; t < maxDist; t += STEP) {
    const tx = Math.floor(x + dx * t);
    const ty = Math.floor(y + dy * t);
    grid.setVisible(tx, ty);
    if (grid.isOpaque(tx, ty)) return;
  }
}
```

**Correct (DDA — one cell per boundary crossing):**

```typescript
function castRay(grid: Grid, px: number, py: number, dx: number, dy: number, maxDist: number): void {
  let cx = Math.floor(px);
  let cy = Math.floor(py);
  const stepX = dx >= 0 ? 1 : -1;
  const stepY = dy >= 0 ? 1 : -1;
  const tDeltaX = dx === 0 ? Infinity : Math.abs(1 / dx);
  const tDeltaY = dy === 0 ? Infinity : Math.abs(1 / dy);
  let tMaxX = dx === 0 ? Infinity : (stepX > 0 ? cx + 1 - px : px - cx) * tDeltaX;
  let tMaxY = dy === 0 ? Infinity : (stepY > 0 ? cy + 1 - py : py - cy) * tDeltaY;
  let dist = 0;
  while (dist <= maxDist) {
    grid.setVisible(cx, cy);
    if (grid.isOpaque(cx, cy)) return;
    if (tMaxX < tMaxY) { cx += stepX; dist = tMaxX; tMaxX += tDeltaX; }
    else { cy += stepY; dist = tMaxY; tMaxY += tDeltaY; }
  }
}
```

**When NOT to use this pattern:**
- Pure tile-based fog where the viewer always sits on a cell center — shadowcasting (`fov-recursive-shadowcasting`) is faster and needs no per-ray loop.
- Integer tile-to-tile yes/no checks — use the Bresenham single-ray (`fov-single-ray-los`). DDA earns its keep only when the origin or direction is sub-tile (continuous), where Bresenham's integer stepping would misplace the line.

Reference: [Line drawing on a grid (Red Blob Games)](https://www.redblobgames.com/grids/line-drawing/)
