---
title: Compare Squared Distances to Avoid Per-Cell sqrt
impact: MEDIUM
impactDescription: eliminates per-cell sqrt
tags: geo, squared-distance, sqrt, radius, hot-loop
---

## Compare Squared Distances to Avoid Per-Cell sqrt

The radius test runs once per cell in the field-of-view sweep, so calling `Math.sqrt` (or `Math.hypot`) to get a true distance there pays for a relatively expensive operation thousands of times per recompute, purely to compare against a constant. Since distance is monotonic in distance-squared, compare `dx*dx + dy*dy` against `r*r` instead — same result, integer multiplies only, no transcendental call.

**Incorrect (sqrt per cell):**

```typescript
function inRadius(dx: number, dy: number, r: number): boolean {
  return Math.sqrt(dx * dx + dy * dy) <= r; // sqrt per cell, every recompute
}
```

**Correct (compare squared values):**

```typescript
function inRadius(dx: number, dy: number, r2: number): boolean {
  return dx * dx + dy * dy <= r2; // pass r*r once; integer multiplies only
}

const r2 = radius * radius; // computed once before the sweep
```

**Benefits:**
- Removes a transcendental call from the innermost loop on integer-grid inputs.
- Precomputing `r*r` once hoists even the squaring of the radius out of the loop.

Reference: [MDN — Math.hypot](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Math/hypot)
