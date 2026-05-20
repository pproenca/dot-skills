---
title: Account for Longitude Metres Shrinking with Latitude
impact: CRITICAL
impactDescription: prevents up to 2x metric error above 60° latitude
tags: prec, latitude, metric-distance, cosine, projection
---

## Account for Longitude Metres Shrinking with Latitude

A geohash cell has constant width in *degrees* of longitude, but a degree of longitude is ~111 km at the equator and shrinks by `cos(latitude)` toward the poles — only ~55 km at 60°. Convert a cell's degree-width to metres with a fixed factor and your metric size is correct only at the equator and overstated everywhere else, which throws off radius queries and any "metres per cell" assumption at high latitude. Latitude degrees, by contrast, stay roughly constant.

**Incorrect (fixed metres-per-degree on both axes):**

```rust
const M_PER_DEG: f64 = 111_320.0; // only true near the equator
fn cell_width_m(width_deg: f64) -> f64 {
    width_deg * M_PER_DEG // overstates east-west extent at high latitude
}
```

**Correct (scale longitude by cos(latitude)):**

```rust
const M_PER_DEG_LAT: f64 = 111_320.0;

fn cell_width_m(width_deg: f64, centre_lat_deg: f64) -> f64 {
    let scale = centre_lat_deg.to_radians().cos();
    width_deg * M_PER_DEG_LAT * scale // ~half the equatorial width at 60°
}

fn cell_height_m(height_deg: f64) -> f64 {
    height_deg * M_PER_DEG_LAT // latitude degrees are ~constant
}
```

**When NOT to apply:**
- Near the equator (`|lat| < ~10°`) the cosine term is within a few percent and can be dropped for rough work.
- Never drop it for global datasets that include high latitudes, or for the synthetic coordinate plane in [[map-normalize-to-geohash-domain]] where you control the projection and can keep cells square instead.

Reference: [Wikipedia — Geohash](https://en.wikipedia.org/wiki/Geohash); [Haversine / great-circle distance](https://en.wikipedia.org/wiki/Haversine_formula)
