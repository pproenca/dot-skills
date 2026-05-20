---
title: Map Geohash Precision to Zoom Levels
impact: MEDIUM
impactDescription: prevents drawing millions of off-scale cells per frame
tags: nav, zoom, precision, slippy-map, level-of-detail
---

## Map Geohash Precision to Zoom Levels

A slippy map (Google/OSM style) renders different detail at each zoom level; a geohashed dataset should pick the precision whose cells are about the size of a screen tile at the current zoom. Render full-precision hashes when zoomed out and you draw millions of overlapping cells; render a short prefix when zoomed in and you show a few giant blocks. Define an explicit zoom→precision table — roughly every ~2.5 web-map zoom levels corresponds to one extra geohash character — so each zoom queries and draws the right granularity.

**Incorrect (fixed precision at every zoom):**

```typescript
function cellsForViewport(zoom: number, bbox: BBox) {
  return coverBbox(bbox, 9); // always length 9 — millions of cells when zoomed out
}
```

**Correct (precision chosen from zoom):**

```typescript
// Web-map zoom 0..21 -> geohash length. ~2-3 zoom levels per character.
function precisionForZoom(zoom: number): number {
  return Math.max(1, Math.min(12, Math.round(zoom / 2.5) + 1));
}
function cellsForViewport(zoom: number, bbox: BBox) {
  return coverBbox(bbox, precisionForZoom(zoom)); // detail matched to the view
}
```

This rendering-zoom mapping is distinct from the semantic prefix-length mapping in [[map-precision-as-architectural-level]] — one decides what to draw, the other what a prefix means.

**When NOT to apply:**
- A non-zoomable, single-scale view (one fixed overview) needs only one precision — the table is for interactive pan/zoom.

Reference: [OSM Slippy Map](https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames); [Wikipedia — Geohash](https://en.wikipedia.org/wiki/Geohash)
