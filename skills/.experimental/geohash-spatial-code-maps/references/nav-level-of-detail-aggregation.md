---
title: Render Aggregated Prefix Buckets When Zoomed Out
impact: MEDIUM
impactDescription: prevents O(n) render cost; bounded by visible cells
tags: nav, level-of-detail, aggregation, rendering, performance
---

## Render Aggregated Prefix Buckets When Zoomed Out

Drawing every point at a low zoom both blows the frame budget and produces an unreadable smear. Level-of-detail rendering draws *aggregates* when zoomed out — one shape per geohash prefix bucket, labelled with its count — and switches to individual points only when a bucket is large on screen. With a geohash trie ([[idx-trie-hierarchical-bucketing]]) the bucket counts are already computed, so render cost depends on the number of visible cells, not the dataset size.

**Incorrect (draw every point at every zoom):**

```typescript
function render(points: Point[], zoom: number) {
  for (const p of points) drawDot(p); // 1e6 dots at zoom 3 -> dropped frames, smear
}
```

**Correct (aggregate by prefix; drill down on zoom):**

```typescript
function render(trie: GeoTrie, zoom: number, viewport: BBox) {
  const len = precisionForZoom(zoom);
  for (const cell of coverBbox(viewport, len)) {
    const n = trie.count(cell);
    if (n === 0) continue;
    if (n <= POINT_THRESHOLD) drawPoints(trie.pointsUnder(cell)); // few enough -> real points
    else drawBucket(cell, n);                                     // many -> one labelled cell
  }
}
```

**When NOT to apply:**
- Small datasets that always fit the frame budget can draw raw points at every zoom — aggregation earns its keep once visible points exceed what a frame can paint.

Reference: [OSM Slippy Map](https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames); [Elasticsearch geohash_grid](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-bucket-geohashgrid-aggregation.html)
