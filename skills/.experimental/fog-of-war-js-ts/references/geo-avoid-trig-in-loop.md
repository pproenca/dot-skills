---
title: Precompute Directions Instead of Calling Trig Per Cell
impact: MEDIUM
impactDescription: eliminates per-cell trig
tags: geo, trigonometry, precompute, cone, hot-loop
---

## Precompute Directions Instead of Calling Trig Per Cell

Cone or directional fields of view often check each cell's angle against the facing direction, and calling `Math.atan2`, `sin`, or `cos` per cell loads a transcendental into the innermost loop. Trig of a constant facing belongs outside the loop: precompute the facing vector once and test cells with a dot product, or compare against precomputed cone-edge slopes — both are plain multiplies and adds.

**Incorrect (atan2 per cell):**

```typescript
function inCone(cx: number, cy: number, facing: number, halfAngle: number, x: number, y: number): boolean {
  const a = Math.atan2(y - cy, x - cx);          // atan2 per cell
  let diff = Math.abs(a - facing);
  if (diff > Math.PI) diff = 2 * Math.PI - diff;
  return diff <= halfAngle;
}
```

**Correct (precompute facing vector, use a dot product):**

```typescript
// Computed once per viewer, not per cell.
const fx = Math.cos(facing);
const fy = Math.sin(facing);
const cosHalf = Math.cos(halfAngle);

function inCone(cx: number, cy: number, x: number, y: number): boolean {
  const dx = x - cx;
  const dy = y - cy;
  const len = Math.sqrt(dx * dx + dy * dy) || 1;
  return (dx * fx + dy * fy) / len >= cosHalf; // dot product vs precomputed threshold
}
```

**Benefits:**
- The per-cell cost drops to a dot product and one normalisation; the trig runs once per viewer.
- Combine with `geo-squared-distance` to fuse the cone test with the radius test cheaply.

Reference: [MDN — Math.atan2](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Math/atan2)
