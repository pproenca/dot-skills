---
title: Use the Interleaved Integer as a Compact Sortable Key
impact: MEDIUM-HIGH
impactDescription: prevents string-walk compares; 8-byte sortable key
tags: idx, integer, sortable, morton, storage
---

## Use the Interleaved Integer as a Compact Sortable Key

The interleaved 64-bit geohash ([[enc-integer-morton-encode]]) sorts in the same order as the base32 string but costs 8 bytes instead of a 10-to-12-character string (the 52-bit integer carries ~length-10 precision), and integer comparison is a single instruction. As a sorted-set score (Redis) or a `bigint` key, it gives the same prefix-range behaviour as the string with less storage and faster comparisons. Coarsening to a parent cell is a bit-shift, not a substring.

**Incorrect (store the string when you only ever range-scan):**

```rust
struct Record { id: u64, geohash: String } // 12+ bytes; every compare walks the string
```

**Correct (store the interleaved integer; coarsen by shifting):**

```rust
struct Record { id: u64, geohash: u64 } // 8 bytes, single-instruction compares

/// Coarsen to `bits` of precision: zero the low (52 - bits) interleaved bits.
fn coarsen(hash: u64, bits: u32) -> u64 {
    let shift = 52 - bits;
    (hash >> shift) << shift // align to the cell boundary
}
/// Half-open range [lo, hi) covering all finer cells under this prefix.
fn prefix_range(hash: u64, bits: u32) -> (u64, u64) {
    let lo = coarsen(hash, bits);
    (lo, lo + (1u64 << (52 - bits)))
}
```

**When NOT to apply:**
- When humans need to read or paste the key (debugging, URLs, logs), the base32 string is worth its size ([[idx-sorted-string-range-scan]]). Many systems store both: integer for the index, string for display.

Reference: [Z-order curve](https://en.wikipedia.org/wiki/Z-order_curve); [Redis Geospatial](https://redis.io/docs/latest/develop/data-types/geospatial/)
