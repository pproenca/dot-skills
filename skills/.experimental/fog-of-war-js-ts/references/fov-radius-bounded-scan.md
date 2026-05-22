---
title: Bound the Scan to the Sight Radius and Map Edges
impact: HIGH
impactDescription: O(width by height) to O(radius squared)
tags: fov, radius, bounds, clamping, early-out
---

## Bound the Scan to the Sight Radius and Map Edges

Iterating the whole grid to test each tile's distance scales the cost with map size, not sight range, so a small torch on a large map still pays for every tile off-screen. Clamp the scan rectangle to the viewer's radius box intersected with the map bounds, and reject cells outside the circle with a squared-distance test. Cost then tracks the lit area, and the bounds clamp doubles as the cheapest possible out-of-bounds guard.

**Incorrect (scans the entire map):**

```typescript
const r2 = radius * radius;
for (let y = 0; y < grid.height; y++) {
  for (let x = 0; x < grid.width; x++) {
    // Every tile on a 1000x1000 map is tested for a radius-8 torch.
    if ((x - cx) ** 2 + (y - cy) ** 2 <= r2 && hasLineOfSight(grid, cx, cy, x, y)) {
      grid.setVisible(x, y);
    }
  }
}
```

**Correct (clamped bounding box):**

```typescript
const r2 = radius * radius;
const x0 = Math.max(0, cx - radius);
const x1 = Math.min(grid.width - 1, cx + radius);
const y0 = Math.max(0, cy - radius);
const y1 = Math.min(grid.height - 1, cy + radius);
for (let y = y0; y <= y1; y++) {
  const dy = y - cy;
  for (let x = x0; x <= x1; x++) {
    const dx = x - cx;
    if (dx * dx + dy * dy <= r2 && hasLineOfSight(grid, cx, cy, x, y)) {
      grid.setVisible(x, y);
    }
  }
}
```

**When NOT to use this pattern:**
- Prefer shadowcasting (`fov-recursive-shadowcasting`) over per-cell `hasLineOfSight`; the bounded box still applies, but shadowcasting already restricts itself to the radius via its slope range and `dx*dx + dy*dy <= r2` test.

Reference: [Roguelike Vision Algorithms (Adam Milazzo)](http://www.adammil.net/blog/v125_Roguelike_Vision_Algorithms.html)
