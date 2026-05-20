---
title: Crossfade Between Level-of-Detail Tiers
impact: MEDIUM
impactDescription: prevents jarring pops when buckets split or merge
tags: anim, level-of-detail, crossfade, transitions, aggregation
---

## Crossfade Between Level-of-Detail Tiers

Level-of-detail rendering swaps aggregated prefix buckets for individual cells as you zoom ([[nav-level-of-detail-aggregation]]); doing it on a hard threshold makes a cluster suddenly burst into points (or points snap into a blob), a visual pop that breaks continuity and hides the relationship between the aggregate and its members. Crossfade across the threshold — fade the outgoing representation out while the incoming fades in over a short zoom band — so the viewer sees one becoming the other.

**Incorrect (hard threshold):**

```typescript
if (zoom >= SPLIT_ZOOM) drawPoints(cell);   // cluster pops into points in a single frame
else drawBucket(cell);
```

**Correct (crossfade across a zoom band):**

```typescript
const k = clamp01((zoom - (SPLIT_ZOOM - 0.5)) / 1.0); // 0 below the band, 1 above it
if (k < 1) drawBucket(cell, 1 - k);                   // aggregate fades out
if (k > 0) drawPoints(cell, k);                       // members fade in
```

**When NOT to apply:**
- Under a reduced-motion preference ([[access-honor-prefers-reduced-motion]]), or at extreme cell counts where drawing both representations across the band blows the frame budget — then snap.

Reference: [OSM Slippy Map](https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames); [Munzner, Visualization Analysis & Design](https://www.cs.ubc.ca/~tmm/vadbook/)
