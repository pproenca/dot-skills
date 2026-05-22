---
title: Transform Octants With a Lookup Table, Not Eight Loops
impact: HIGH
impactDescription: eliminates eight duplicated scan loops
tags: fov, octants, transforms, lookup-table, code-reuse
---

## Transform Octants With a Lookup Table, Not Eight Loops

Field of view is radially symmetric, so the scan logic is identical in all eight octants up to a reflection or rotation of the (row, col) axes. Copy-pasting the loop once per octant — or trying to handle the full 360° sweep in one pass — multiplies the surface area for off-by-one slope bugs eightfold, and a fix applied to one copy silently misses the others. A small multiplier table maps local octant coordinates to world coordinates so one scan function serves all eight.

**Incorrect (eight near-identical loops):**

```typescript
function castOctant0(grid: Grid, cx: number, cy: number, r: number): void {
  for (let i = 1; i <= r; i++) {
    for (let dx = -i; dx <= 0; dx++) {
      grid.setVisible(cx + dx, cy - i); // octant 0 mapping baked in
      // ...slope bookkeeping...
    }
  }
}
function castOctant1(grid: Grid, cx: number, cy: number, r: number): void {
  for (let i = 1; i <= r; i++) {
    for (let dx = -i; dx <= 0; dx++) {
      grid.setVisible(cx - i, cy + dx); // octant 1 mapping baked in
      // ...same slope bookkeeping, copy-pasted...
    }
  }
}
// ...six more copies, each a place for a divergent bug...
```

**Correct (one scan, table-driven mapping):**

```typescript
const MULT: ReadonlyArray<ReadonlyArray<number>> = [
  [1, 0, 0, -1, -1, 0, 0, 1],
  [0, 1, -1, 0, 0, -1, 1, 0],
  [0, 1, 1, 0, 0, -1, -1, 0],
  [1, 0, 0, 1, -1, 0, 0, -1],
];

function toWorld(cx: number, cy: number, dx: number, dy: number, oct: number): [number, number] {
  return [
    cx + dx * MULT[0][oct] + dy * MULT[1][oct],
    cy + dx * MULT[2][oct] + dy * MULT[3][oct],
  ];
}

function computeFov(grid: Grid, cx: number, cy: number, r: number): void {
  grid.setVisible(cx, cy);
  for (let oct = 0; oct < 8; oct++) castLight(grid, cx, cy, r, 1, 1.0, 0.0, oct);
}
```

**Benefits:**
- One place to fix a slope bug; the table guarantees the other seven octants stay in sync.
- Symmetric quadrant variants reduce this further to a 4-quadrant transform (`fov-symmetric-shadowcasting`).

Reference: [Field of Vision using recursive shadowcasting (Björn Bergström)](https://www.roguebasin.com/index.php/FOV_using_recursive_shadowcasting)
