---
title: Encode to an Interleaved 64-bit Integer for Speed and Sortable Keys
impact: CRITICAL
impactDescription: 5-20x faster encode; yields a directly sortable key
tags: enc, morton, integer, bit-manipulation, performance
---

## Encode to an Interleaved 64-bit Integer for Speed and Sortable Keys

Building a geohash by pushing bits into an array and indexing a string per 5 bits allocates and branches on every step. Interleaving the two coordinates directly into a single integer with bit-spreading ("Morton code" / Z-order) is branch-free, allocation-free, and — when longitude takes the high bit of each pair, matching the string convention — the integer sorts in the **same order** as the base32 string, so it doubles as a sortable index key. Convert to the base32 string only at the boundary where a human or another system needs it. (This is the same 52-bit budget Redis uses internally for its geospatial type.)

**Incorrect (string built bit-by-bit in the hot path):**

```rust
// Allocates a String and does per-bit work; ~5-20x slower in tight loops.
fn encode_slow(lat: f64, lon: f64, len: usize) -> String {
    let mut bits = Vec::with_capacity(len * 5);
    // ... binary chop pushing 0/1 into `bits` ...
    let mut s = String::new();
    for chunk in bits.chunks(5) {
        let v = chunk.iter().fold(0u8, |acc, &b| (acc << 1) | b);
        s.push(BASE32[v as usize] as char);
    }
    s
}
```

**Correct (spread coordinates into a Morton integer, stringify lazily):**

```rust
/// Quantise a value in [min,max] to `bits`, then spread it across even positions.
fn spread(value: f64, min: f64, max: f64, bits: u32) -> u64 {
    let norm = ((value - min) / (max - min)).clamp(0.0, 0.999_999_999);
    let q = (norm * (1u64 << bits) as f64) as u64 & ((1 << bits) - 1);
    // Classic bit-spreading: insert a zero between every bit (interleave64).
    let mut x = q;
    x = (x | (x << 16)) & 0x0000_FFFF_0000_FFFF;
    x = (x | (x << 8))  & 0x00FF_00FF_00FF_00FF;
    x = (x | (x << 4))  & 0x0F0F_0F0F_0F0F_0F0F;
    x = (x | (x << 2))  & 0x3333_3333_3333_3333;
    x = (x | (x << 1))  & 0x5555_5555_5555_5555;
    x
}

/// 26 bits per axis = 52-bit geohash integer. Longitude on the high bit of each
/// pair so the integer's numeric order matches the base32 string order.
fn encode_u64(lat: f64, lon: f64) -> u64 {
    (spread(lon, -180.0, 180.0, 26) << 1) | spread(lat, -90.0, 90.0, 26)
}
```

The integer sorts identically to the base32 string, so one key serves comparisons, range scans, and storage — see [[idx-integer-sortable-key]].

**When NOT to apply:**
- If you only encode a handful of points (e.g. one per request) the string encoder's overhead is irrelevant.
- Reach for the integer path when encoding runs in a hot loop, or when you need the value as a database / sorted-set key.

Reference: [Z-order curve (Morton code)](https://en.wikipedia.org/wiki/Z-order_curve); [Redis Geospatial](https://redis.io/docs/latest/develop/data-types/geospatial/)
