---
title: Decode to a Bounding Box, Then Derive the Centre
impact: MEDIUM-HIGH
impactDescription: preserves the cell extent and its error margin
tags: dec, bounding-box, decoding, error-margin, centre
---

## Decode to a Bounding Box, Then Derive the Centre

A geohash represents a cell, not a point. Decoding straight to a single latitude/longitude throws away the only uncertainty information you have — the cell's extent — so downstream code treats an approximate region as an exact pin. Decode to the bounding box `[latMin, lonMin, latMax, lonMax]` and derive the centre and ±half-cell error from it ([[prec-error-is-half-cell]]); callers that want a point still get one, and callers that need the extent are not lied to.

**Incorrect (decode to a bare point):**

```rust
fn decode_point(hash: &str) -> (f64, f64) {
    // returns the centre only; the cell size is lost
    let (lat_iv, lon_iv) = decode_intervals(hash);
    ((lat_iv.0 + lat_iv.1) / 2.0, (lon_iv.0 + lon_iv.1) / 2.0)
}
```

**Correct (decode to a box; centre is derived):**

```rust
struct BBox { lat_min: f64, lon_min: f64, lat_max: f64, lon_max: f64 }

fn decode_bbox(hash: &str) -> BBox {
    let (lat, lon) = decode_intervals(hash); // ((lat_min,lat_max),(lon_min,lon_max))
    BBox { lat_min: lat.0, lat_max: lat.1, lon_min: lon.0, lon_max: lon.1 }
}

impl BBox {
    fn center(&self) -> (f64, f64) {
        ((self.lat_min + self.lat_max) / 2.0, (self.lon_min + self.lon_max) / 2.0)
    }
    fn error(&self) -> (f64, f64) { // ± half-cell
        ((self.lat_max - self.lat_min) / 2.0, (self.lon_max - self.lon_min) / 2.0)
    }
}
```

**When NOT to apply:**
- If a consumer only ever needs an approximate pin (dropping a marker), a thin `center()` helper over the bbox is fine — just compute the box first so the extent is available.

Reference: [Wikipedia — Geohash](https://en.wikipedia.org/wiki/Geohash)
