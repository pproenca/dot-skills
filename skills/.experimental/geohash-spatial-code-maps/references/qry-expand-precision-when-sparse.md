---
title: Widen the Search by Dropping a Prefix Character on Sparse Cells
impact: HIGH
impactDescription: prevents empty results in sparse regions
tags: qry, adaptive, sparse, precision, fallback
---

## Widen the Search by Dropping a Prefix Character on Sparse Cells

A fixed-precision proximity query returns nothing when the 3×3 block happens to be empty — common in sparse regions (rural areas, or thinly populated parts of a code map). Instead of returning "no results", drop the last character of the query geohash to zoom out one level (each step covers ~32x the area) and retry until you have enough candidates or hit a minimum precision. This yields graceful "nearest anything" behaviour rather than a hard empty.

**Incorrect (single fixed precision, empty on miss):**

```rust
fn nearby(hash: u64, bits: u32, store: &Store) -> Vec<Record> {
    let block: Vec<u64> = std::iter::once(hash).chain(neighbors8(hash, bits)).collect();
    store.fetch(&block) // returns [] in a sparse area, with no fallback
}
```

**Correct (expand precision until enough candidates):**

```rust
fn nearby_adaptive(lat: f64, lon: f64, store: &Store, want: usize, min_bits: u32) -> Vec<Record> {
    let mut bits = 30; // start fine
    loop {
        let hash = encode_u64_at(lat, lon, bits);
        let block: Vec<u64> = std::iter::once(hash).chain(neighbors8(hash, bits)).collect();
        let hits = store.fetch(&block);
        if hits.len() >= want || bits <= min_bits {
            return hits;
        }
        bits -= 5; // zoom out one base32 character (~32x larger area) and retry
    }
}
```

**When NOT to apply:**
- Strict-radius queries ("only within 500 m") must return empty when nothing qualifies — do not expand past the requested radius, or you return points that are genuinely too far.

Reference: [Redis Geospatial](https://redis.io/docs/latest/develop/data-types/geospatial/); [Wikipedia — Geohash](https://en.wikipedia.org/wiki/Geohash)
