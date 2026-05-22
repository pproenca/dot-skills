---
title: Handle Diagonal Wall Corners Deliberately
impact: LOW-MEDIUM
impactDescription: prevents diagonal light leaks
tags: correct, corners, diagonals, wall-expansion, leaks
---

## Handle Diagonal Wall Corners Deliberately

When two walls meet at a diagonal, a field of view that treats the shared corner as passable lets the viewer see through the one-point gap — light leaks diagonally into rooms it should not reach, and players exploit it to peek around corners. Pick a corner policy and apply it everywhere: either expand walls so a diagonal touch blocks sight, or explicitly allow corner-peeking as a design choice. The bug is leaving it to chance per algorithm path.

**Incorrect (diagonal gap leaks light by accident):**

```typescript
// A ray slipping exactly through the corner between two walls is treated as open,
// so light leaks diagonally into the sealed room behind them.
function blocksDiagonal(grid: Grid, x: number, y: number, dx: number, dy: number): boolean {
  return grid.isOpaque(x + dx, y + dy); // ignores the two flanking corner walls
}
```

**Correct (treat a diagonal pinch as blocked):**

```typescript
// A diagonal step is blocked unless at least one orthogonal neighbour is open.
function blocksDiagonal(grid: Grid, x: number, y: number, dx: number, dy: number): boolean {
  if (grid.isOpaque(x + dx, y + dy)) return true;
  const sideA = grid.isOpaque(x + dx, y);
  const sideB = grid.isOpaque(x, y + dy);
  return sideA && sideB; // both flanking walls present -> the corner seals the gap
}
```

**Benefits:**
- Sealed rooms stay sealed; no diagonal peeking unless you choose to allow it.
- A single corner policy keeps shadowcasting and line-of-sight checks consistent.

Reference: [Roguelike Vision Algorithms (Adam Milazzo)](http://www.adammil.net/blog/v125_Roguelike_Vision_Algorithms.html)
