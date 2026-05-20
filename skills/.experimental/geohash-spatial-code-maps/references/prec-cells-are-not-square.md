---
title: Treat Cells as Rectangles Whose Aspect Flips with Length
impact: CRITICAL
impactDescription: prevents up to 2x error on one axis
tags: prec, cell-geometry, aspect-ratio, latitude, longitude
---

## Treat Cells as Rectangles Whose Aspect Flips with Length

A geohash cell is almost never square. Each character adds 5 bits split 3/2 between longitude and latitude, so odd-length cells are wider than tall and even-length cells are nearer square — the width-to-height ratio alternates with every character added. Code that assumes a square cell (one "cell size" used for both axes) is off by up to 2x on one dimension, corrupting radius checks and rendering.

**Incorrect (one size for both axes):**

```rust
fn cell_size_m(len: u32) -> f64 {
    // single number used for width AND height -> wrong on one axis
    40_000_000.0 / 2f64.powi((len * 5 / 2) as i32)
}
```

**Correct (separate width/height from per-axis bit counts):**

```rust
/// Longitude gets the extra bit at odd total bit counts.
fn axis_bits(len: u32) -> (u32, u32) {
    let total = len * 5;
    let lon = total / 2 + total % 2; // longitude: ceil(total/2)
    let lat = total / 2;             // latitude:  floor(total/2)
    (lon, lat)
}

fn cell_deg(len: u32) -> (f64, f64) {
    let (lon_bits, lat_bits) = axis_bits(len);
    let width_deg = 360.0 / 2f64.powi(lon_bits as i32);
    let height_deg = 180.0 / 2f64.powi(lat_bits as i32);
    (width_deg, height_deg) // len 5 -> wider than tall; len 6 -> nearer square
}
```

**When NOT to apply:**
- Rough single-length visualisations can sometimes tolerate a square approximation.
- Never use a square approximation for distance thresholds or hit-testing.

Reference: [Wikipedia — Geohash](https://en.wikipedia.org/wiki/Geohash); [Elasticsearch geohash_grid](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-bucket-geohashgrid-aggregation.html)
