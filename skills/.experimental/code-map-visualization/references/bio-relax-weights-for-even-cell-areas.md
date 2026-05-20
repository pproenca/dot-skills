---
title: Relax Voronoi Weights for Even Cell Areas, Not Seed Positions
impact: MEDIUM
impactDescription: prevents unreadable slivers and oversized cells
tags: bio, centroidal-voronoi, lloyd, weights, area
---

## Relax Voronoi Weights for Even Cell Areas, Not Seed Positions

A raw Voronoi diagram from clustered code produces wildly uneven cells — tiny slivers where files bunch up, huge cells in sparse areas — which misreads as importance. A weighted (power) Voronoi with Lloyd-style iteration on the cell *weights* drives each cell toward a target area (say, proportional to LOC), the technique behind Voronoi treemaps. Crucially, relax the weights, not the seed positions: moving seeds toward their centroids (plain Lloyd / centroidal Voronoi) would erase the coupling-as-proximity the projection encodes ([[encode-let-projection-own-position]]). Keep seeds fixed; adjust weights until the areas match.

**Incorrect (Lloyd relaxation moves seeds to centroids):**

```typescript
for (let i = 0; i < 20; i++) {
  const v = Delaunay.from(seeds).voronoi(bounds);
  seeds = seeds.map((_, j) => centroid(v.cellPolygon(j)));   // positions drift; projection destroyed
}
```

**Correct (seeds stay put; only weights move, until areas hit target):**

```typescript
for (let i = 0; i < 20; i++) {
  const cells = weightedVoronoi(seeds, weights, bounds);     // seeds fixed
  weights = cells.map((c, j) => weights[j] + (targetArea[j] - area(c)) * GAIN);
  if (cells.every((c, j) => closeEnough(area(c), targetArea[j]))) break;
}
```

**When NOT to apply:**
- If cells are already even (files spread uniformly), the relaxation iterations are wasted compute — measure the area variance first.

Reference: [Nocaj & Brandes — Computing Voronoi Treemaps](https://onlinelibrary.wiley.com/doi/10.1111/j.1467-8659.2012.03078.x); [d3-delaunay](https://github.com/d3/d3-delaunay)
