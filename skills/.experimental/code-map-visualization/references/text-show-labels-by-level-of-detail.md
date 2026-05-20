---
title: Reveal Labels by Level of Detail
impact: MEDIUM-HIGH
impactDescription: prevents leaf labels flooding a zoomed-out view
tags: text, level-of-detail, zoom, labels, hierarchy
---

## Reveal Labels by Level of Detail

A code map has a label hierarchy that mirrors the geohash prefix hierarchy ([[map-prefix-as-domain-region]]): top-level domain names at low zoom, sub-domains as you zoom in, individual file names only when a cell is large on screen. Showing leaf labels when zoomed out floods the view; showing only domain labels when zoomed in starves it. Gate each label by the zoom range where its cell is big enough to read, reusing the precision-to-zoom mapping the navigation layer already computes ([[nav-precision-to-zoom-levels]], [[nav-level-of-detail-aggregation]]).

**Incorrect (file labels at every zoom):**

```typescript
for (const f of files) ctx.fillText(f.name, f.cx, f.cy); // thousands of names when zoomed out
```

**Correct (pick the label tier from zoom; only that tier draws):**

```typescript
const tier = labelTierForZoom(zoom);   // "domain" | "module" | "file"
for (const node of nodes) {
  if (node.tier !== tier) continue;    // others stay hidden until their zoom
  ctx.fillText(node.name, node.cx, node.cy);
}
```

**When NOT to apply:**
- A small map with a single, naturally non-overlapping label tier does not need tiering.

Reference: [OSM Slippy Map](https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames); [MapLibre GL JS](https://maplibre.org/)
