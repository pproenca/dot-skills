---
title: Tessellate Regions with a Voronoi Diagram, Not Scattered Marks
impact: MEDIUM
impactDescription: prevents gaps and ambiguous region boundaries
tags: bio, voronoi, tessellation, regions, delaunay
---

## Tessellate Regions with a Voronoi Diagram, Not Scattered Marks

Drawing each file as a dot leaves the plane mostly empty and makes domain boundaries guesswork; drawing rectangular region boxes overlaps and wastes space. A Voronoi diagram seeded by the projected file positions partitions the whole plane into gapless convex cells — the way living cells fill tissue — so every pixel belongs to its nearest file and region edges become explicit polygon borders. This is the basis of Voronoi treemaps, introduced for visualising software metrics. Seed the diagram with the projected coordinates and leave them where the projection put them ([[encode-let-projection-own-position]]); compute with d3-delaunay.

**Incorrect (a dot per file):**

```typescript
for (const f of files) drawDot(ctx, f.projectedXY, domainColor(f.domain)); // empty plane, unclear regions
```

**Correct (Voronoi cells fill the plane; borders make regions explicit):**

```typescript
const points = files.flatMap((f) => f.projectedXY);            // seeds = projected positions
const voronoi = Delaunay.from(points).voronoi([0, 0, w, h]);
files.forEach((f, i) => fillPolygon(ctx, voronoi.cellPolygon(i), domainColor(f.domain)));
```

**When NOT to apply:**
- When individual files must read as discrete, countable marks (a sparse overview), dots or packed circles ([[bio-circle-packing-for-nested-counts]]) communicate count better than a space-filling tessellation.

Reference: [Balzer, Deussen & Lewerentz — Voronoi Treemaps for the Visualization of Software Metrics (SoftVis '05)](https://dl.acm.org/doi/10.1145/1056018.1056041); [d3-delaunay](https://github.com/d3/d3-delaunay)
