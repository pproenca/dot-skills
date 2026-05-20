---
title: Outline Regions with Metaball Hulls via Marching Squares
impact: MEDIUM
impactDescription: prevents jagged or ambiguous region outlines
tags: bio, metaball, marching-squares, isocontour, hull
---

## Outline Regions with Metaball Hulls via Marching Squares

A region made of scattered cells needs an outline to read as one thing, but a convex hull swallows neighbouring regions and a concave hull looks jagged and arbitrary. Treat each file as a blob of "charge," sum them into a density field, and trace the isocontour at a threshold with marching squares — the metaball technique — to get a smooth, organic membrane that hugs the region like a cell wall and merges nearby members naturally. d3-contour computes the marching-squares polygons. Keep the outline contrasting with the basemap ([[color-control-contrast-against-basemap]]) and label at the centroid ([[text-anchor-region-labels-at-centroid]]).

**Incorrect (a convex hull bridges gaps and engulfs other regions):**

```typescript
const outline = convexHull(region.cells.map((c) => c.xy));
strokePolygon(ctx, outline);                      // swallows cells that belong elsewhere
```

**Correct (density field plus a marching-squares isocontour):**

```typescript
const density = splatToGrid(region.cells, w, h, RADIUS);      // each cell a soft blob
const [membrane] = contours().size([w, h]).thresholds([ISO])(density);
strokeMultiPolygon(ctx, membrane.coordinates);                // smooth organic hull
```

**When NOT to apply:**
- At low zoom where a region is only a few pixels, a lightweight marker or bounding shape is cheaper and reads as clearly — reserve the density-field pass for regions large on screen.

Reference: [d3-contour (marching squares)](https://github.com/d3/d3-contour); [Jamie Wong — Metaballs and Marching Squares](https://jamie-wong.com/2014/08/19/metaballs-and-marching-squares/)
