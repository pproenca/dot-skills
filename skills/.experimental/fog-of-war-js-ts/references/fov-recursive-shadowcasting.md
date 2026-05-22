---
title: Use Recursive Shadowcasting, Not Ray-Per-Cell FOV
impact: CRITICAL
impactDescription: eliminates redundant ray overlap
tags: fov, shadowcasting, raycasting, octants, line-of-sight
---

## Use Recursive Shadowcasting, Not Ray-Per-Cell FOV

Casting a separate ray to every perimeter cell re-walks the cells near the viewer once per ray, so the area close to the origin is recomputed dozens of times, and the angular gaps between adjacent rays let light leak past thin walls. Recursive shadowcasting sweeps each octant once, narrowing the visible slope range as it meets walls, so every cell is visited a single time and occlusion is exact.

**Incorrect (ray-per-perimeter-cell):**

```typescript
interface Grid {
  width: number;
  height: number;
  isOpaque(x: number, y: number): boolean;
  setVisible(x: number, y: number): void;
}

// One ray per degree. Cells near the origin are walked by hundreds of
// overlapping rays, and gaps between rays leak light past thin walls.
function computeFov(grid: Grid, cx: number, cy: number, radius: number): void {
  for (let a = 0; a < 360; a++) {
    const dx = Math.cos((a * Math.PI) / 180);
    const dy = Math.sin((a * Math.PI) / 180);
    let x = cx + 0.5;
    let y = cy + 0.5;
    for (let step = 0; step < radius; step++) {
      const tx = Math.floor(x);
      const ty = Math.floor(y);
      grid.setVisible(tx, ty);
      if (grid.isOpaque(tx, ty)) break;
      x += dx;
      y += dy;
    }
  }
}
```

**Correct (octant sweep, each cell visited once):**

```typescript
// [transformX, transformY] multipliers map local octant coords to world coords.
const MULT: ReadonlyArray<ReadonlyArray<number>> = [
  [1, 0, 0, -1, -1, 0, 0, 1],
  [0, 1, -1, 0, 0, -1, 1, 0],
  [0, 1, 1, 0, 0, -1, -1, 0],
  [1, 0, 0, 1, -1, 0, 0, -1],
];

function castLight(
  grid: Grid, cx: number, cy: number, radius: number,
  row: number, start: number, end: number, oct: number,
): void {
  if (start < end) return;
  const r2 = radius * radius;
  let newStart = 0;
  for (let i = row; i <= radius; i++) {
    const dy = -i;
    let blocked = false;
    for (let dx = -i; dx <= 0; dx++) {
      const lSlope = (dx - 0.5) / (dy + 0.5);
      const rSlope = (dx + 0.5) / (dy - 0.5);
      if (start < rSlope) continue;
      if (end > lSlope) break;
      const mx = cx + dx * MULT[0][oct] + dy * MULT[1][oct];
      const my = cy + dx * MULT[2][oct] + dy * MULT[3][oct];
      if (dx * dx + dy * dy <= r2) grid.setVisible(mx, my);
      if (blocked) {
        if (grid.isOpaque(mx, my)) { newStart = rSlope; continue; }
        blocked = false;
        start = newStart;
      } else if (grid.isOpaque(mx, my) && i < radius) {
        blocked = true;
        castLight(grid, cx, cy, radius, i + 1, start, lSlope, oct); // recurse past the wall
        newStart = rSlope;
      }
    }
    if (blocked) break;
  }
}

function computeFov(grid: Grid, cx: number, cy: number, radius: number): void {
  grid.setVisible(cx, cy);
  for (let oct = 0; oct < 8; oct++) castLight(grid, cx, cy, radius, 1, 1.0, 0.0, oct);
}
```

**When NOT to use this pattern:**
- Single point-to-point checks ("can the guard see the player?") — walk one line instead (`fov-single-ray-los`).
- Smooth vector lighting on non-grid worlds — build a visibility polygon (`fov-visibility-polygon`).

Reference: [Field of Vision using recursive shadowcasting (Björn Bergström)](https://www.roguebasin.com/index.php/FOV_using_recursive_shadowcasting)
