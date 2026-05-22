---
title: Choose the Radius Metric for the Shape You Want
impact: MEDIUM
impactDescription: reduces radius test to an integer compare
tags: geo, distance-metric, chebyshev, manhattan, radius
---

## Choose the Radius Metric for the Shape You Want

The distance metric defines both the lit shape and its cost. Squared-Euclidean (`dx² + dy²`) gives a circle, Chebyshev (`max(|dx|,|dy|)`) a square, and Manhattan (`|dx| + |dy|`) a diamond — each a cheap integer test. Computing a floating Euclidean distance and rounding to approximate one of these is both slower and the wrong shape. Decide which silhouette the game wants and use that metric's native integer form directly.

**Incorrect (float Euclidean, then round toward a square):**

```typescript
// Wanted a square sight range, but this is a rounded circle — and uses sqrt.
function inRange(dx: number, dy: number, r: number): boolean {
  return Math.round(Math.sqrt(dx * dx + dy * dy)) <= r;
}
```

**Correct (pick the metric that is the intended shape):**

```typescript
const r2 = r * r;
const circle = (dx: number, dy: number): boolean => dx * dx + dy * dy <= r2;
const square = (dx: number, dy: number): boolean => Math.max(Math.abs(dx), Math.abs(dy)) <= r;
const diamond = (dx: number, dy: number): boolean => Math.abs(dx) + Math.abs(dy) <= r;

// Choose ONE deliberately, e.g. Chebyshev for a torch that fills a square room:
const inRange = square;
```

**Benefits:**
- The lit area matches the intended silhouette exactly, with no rounding artifacts.
- Every metric reduces to integer compares — no `sqrt`, no `round` (see `geo-squared-distance`).

Reference: [Roguelike Vision Algorithms (Adam Milazzo)](http://www.adammil.net/blog/v125_Roguelike_Vision_Algorithms.html)
