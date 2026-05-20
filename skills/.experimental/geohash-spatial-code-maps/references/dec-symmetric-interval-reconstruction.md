---
title: Decode by Mirroring the Encoder's Interval Halving
impact: MEDIUM-HIGH
impactDescription: prevents decode drifting to a neighbour cell
tags: dec, symmetry, intervals, binary-search, correctness
---

## Decode by Mirroring the Encoder's Interval Halving

Decoding must reverse encoding exactly: same bit order (longitude on even bits), same recomputed midpoints, same `[-90,90]` / `[-180,180]` start. If the decoder uses a different convention — adding a precomputed step, or assuming latitude-first — the reconstructed interval is offset and the centre lands in the wrong cell, so encode∘decode is no longer the identity on the cell. Walk the bits in the same order and narrow the same intervals.

**Incorrect (decoder uses a different bit order than the encoder):**

```rust
fn decode_intervals_bad(bits: &[u8]) -> ((f64, f64), (f64, f64)) {
    let (mut lat, mut lon) = ((-90.0, 90.0), (-180.0, 180.0));
    for (i, &b) in bits.iter().enumerate() {
        if i % 2 == 0 { narrow(&mut lat, b); } // even -> latitude: WRONG; encoder used longitude
        else { narrow(&mut lon, b); }
    }
    (lat, lon)
}
```

**Correct (mirror the encoder: even bit = longitude):**

```rust
fn narrow(iv: &mut (f64, f64), bit: u8) {
    let mid = (iv.0 + iv.1) / 2.0;
    if bit == 1 { iv.0 = mid; } else { iv.1 = mid; }
}
fn decode_intervals(bits: &[u8]) -> ((f64, f64), (f64, f64)) {
    let (mut lat, mut lon) = ((-90.0, 90.0), (-180.0, 180.0));
    for (i, &b) in bits.iter().enumerate() {
        if i % 2 == 0 { narrow(&mut lon, b); } // even -> longitude (matches encoder)
        else { narrow(&mut lat, b); }
    }
    (lat, lon)
}
```

**When NOT to apply:**
- Never — decode must be the exact inverse of encode ([[enc-interleave-longitude-first]], [[enc-binary-chop-no-float-drift]]). Sharing one `narrow` helper between encode and decode is the surest way to keep them symmetric.

Reference: [Wikipedia — Geohash](https://en.wikipedia.org/wiki/Geohash)
