---
title: Cluster Overlapping Markers by Shared Prefix
impact: MEDIUM
impactDescription: prevents marker overdraw at low zoom
tags: nav, clustering, markers, prefix, overdraw
---

## Cluster Overlapping Markers by Shared Prefix

At a given zoom, many points fall within a few pixels of each other and draw as an illegible pile. Grouping markers that share a geohash prefix at the zoom's precision collapses each cluster into one marker sized or labelled by its member count, which both declutters the view and cuts draw calls. Because clustering reuses the same prefix the renderer already computed for the zoom, it costs almost nothing extra.

**Incorrect (draw a marker per point):**

```typescript
function drawMarkers(points: Point[]) {
  for (const p of points) drawMarker(p.lat, p.lon); // overlapping pile at low zoom
}
```

**Correct (one marker per prefix cluster):**

```typescript
function drawMarkers(points: Point[], zoom: number) {
  const len = precisionForZoom(zoom);
  const clusters = new Map<string, Point[]>();
  for (const p of points) {
    const key = p.geohash.slice(0, len);
    let bucket = clusters.get(key);
    if (!bucket) { bucket = []; clusters.set(key, bucket); }
    bucket.push(p);
  }
  for (const [cell, members] of clusters) {
    if (members.length === 1) drawMarker(members[0].lat, members[0].lon);
    else drawCluster(centerOf(cell), members.length); // one sized marker
  }
}
```

**When NOT to apply:**
- When every individual marker must stay clickable (a small curated set), clustering hides targets — keep points distinct and rely on zoom instead.

Reference: [OSM Slippy Map](https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames); [Wikipedia — Geohash](https://en.wikipedia.org/wiki/Geohash)
