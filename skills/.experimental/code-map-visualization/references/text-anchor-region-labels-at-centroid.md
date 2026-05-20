---
title: Anchor Region Labels at the Visual Centroid
impact: MEDIUM
impactDescription: prevents labels drifting outside their region
tags: text, centroid, labeling, regions, anchoring
---

## Anchor Region Labels at the Visual Centroid

A region's geohash prefix covers an irregular set of cells ([[map-prefix-as-domain-region]]); anchoring its label at the bounding-box centre, or at the arithmetic mean of cell positions, can land the text in a gap or outside the region entirely for L- or U-shaped domains. Anchor at the visual centre — the pole of inaccessibility (the point furthest from any edge, what cartographers use for country labels), or at least the centroid of the largest contiguous part — so the name sits inside the shape it names.

**Incorrect (bbox centre can fall in a hole):**

```typescript
const [cx, cy] = bboxCenter(region.cells);
ctx.fillText(region.name, cx, cy);   // for an L-shaped region the text lands outside it
```

**Correct (anchor at the point furthest inside the polygon):**

```typescript
const [cx, cy] = poleOfInaccessibility(region.polygon); // e.g. polylabel()
ctx.fillText(region.name, cx, cy);   // always within the shape it names
```

**When NOT to apply:**
- Compact, convex regions where the centroid is already well inside — the pole-of-inaccessibility computation is overkill there.

Reference: [Mapbox polylabel (pole of inaccessibility)](https://github.com/mapbox/polylabel); [MapLibre GL JS](https://maplibre.org/)
