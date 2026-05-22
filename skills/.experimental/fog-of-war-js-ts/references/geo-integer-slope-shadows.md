---
title: Use Rational Slopes to Avoid Floating-Point Drift
impact: MEDIUM
impactDescription: prevents float-drift artifacts
tags: geo, slopes, integer-math, precision, artifacts
---

## Use Rational Slopes to Avoid Floating-Point Drift

Shadowcasting compares cell-edge slopes to decide what a wall occludes. Computing those slopes in floating point accumulates rounding error, so at larger radii the lit/shadowed boundary drifts by a fraction of a cell — visible as edges that flicker or shift asymmetrically as the viewer steps sideways. Represent each slope as an exact rational `[numerator, denominator]` of integers and compare by cross-multiplication, so the comparison is exact and the boundary is stable.

**Incorrect (floating-point slopes drift):**

```typescript
const slope = (col: number, depth: number): number => (2 * col - 1) / (2 * depth);
// Float rounding makes the boundary wobble at large depth.
if (slope(colA, depthA) < slope(colB, depthB)) extendShadow();
```

**Correct (exact rational comparison):**

```typescript
type Slope = readonly [num: number, den: number];

// Edge slope as integers: numerator = 2*col - 1, denominator = 2*depth.
const edge = (col: number, depth: number): Slope => [2 * col - 1, 2 * depth];

// a/b < c/d  <=>  a*d < c*b  (denominators are positive here).
const lessThan = (a: Slope, b: Slope): boolean => a[0] * b[1] < b[0] * a[1];

if (lessThan(edge(colA, depthA), edge(colB, depthB))) extendShadow();
```

**Benefits:**
- The lit/shadow boundary is identical at every radius and viewer position — no flicker.
- Integer comparisons are also faster than float division on the hot path.

Reference: [Symmetric Shadowcasting (Albert Ford)](https://www.albertford.com/shadowcasting/)
