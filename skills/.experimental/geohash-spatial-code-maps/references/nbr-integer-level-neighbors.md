---
title: Compute Neighbours on the De-interleaved Integer
impact: HIGH
impactDescription: O(1) neighbour vs O(len) string recursion
tags: nbr, integer, deinterleave, performance, morton
---

## Compute Neighbours on the De-interleaved Integer

The string lookup-table algorithm is O(length) per neighbour and recurses on every border carry. If you already store geohashes as interleaved integers ([[enc-integer-morton-encode]]), neighbours are far cheaper: de-interleave into the longitude and latitude columns, add or subtract one on the relevant axis, and re-interleave. This is constant work with no table indirection or allocation, which matters when computing the eight-neighbour set for millions of points.

**Incorrect (round-trip through strings to reuse the table algorithm):**

```rust
fn east_int_bad(hash: u64, bits: u32) -> u64 {
    let s = to_base32_string(hash, bits);   // allocate
    let n = adjacent_string(&s, Dir::East); // O(len) table recursion
    from_base32_string(&n)                  // parse back
}
```

**Correct (de-interleave, step the axis, re-interleave):**

```rust
fn deinterleave(hash: u64) -> (u32, u32) { /* inverse of `spread`: gather even/odd bits */ }
fn interleave(lon_col: u32, lat_col: u32) -> u64 { /* spread(lon) << 1 | spread(lat) */ }

fn east_int(hash: u64, bits: u32) -> u64 {
    let (lon, lat) = deinterleave(hash);
    let width = 1u32 << bits;
    interleave((lon + 1) & (width - 1), lat) // O(1), no allocation
}
```

**When NOT to apply:**
- If your storage is string geohashes and you need only the occasional neighbour, converting to integers just for adjacency is not worth it — use the table algorithm ([[nbr-canonical-lookup-tables]]) directly on the string.

Reference: [Z-order curve](https://en.wikipedia.org/wiki/Z-order_curve); [Redis Geospatial](https://redis.io/docs/latest/develop/data-types/geospatial/)
