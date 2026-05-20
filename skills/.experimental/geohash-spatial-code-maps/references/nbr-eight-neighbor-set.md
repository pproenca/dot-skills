---
title: Build the Full Eight-Neighbour Set for Proximity
impact: HIGH
impactDescription: prevents missing diagonal-cell matches
tags: nbr, eight-neighbors, diagonals, proximity, composition
---

## Build the Full Eight-Neighbour Set for Proximity

A point near a cell corner has close neighbours in the diagonal cells, not just the four cardinal ones. Proximity that checks only N/S/E/W misses up to four of the eight surrounding cells, dropping matches that sit just across a corner. Compose the diagonals from the cardinal operations (north-then-east, north-then-west, etc.) and skip any that fall off a pole.

**Incorrect (four cardinal cells only):**

```rust
fn neighbors4(hash: u64, bits: u32) -> Vec<u64> {
    [north(hash, bits), south(hash, bits)].into_iter().flatten()
        .chain([east(hash, bits), west(hash, bits)])
        .collect() // misses NE, NW, SE, SW — corner-adjacent points are lost
}
```

**Correct (all eight, pole-safe):**

```rust
// north/south return None at the poles; east/west always wrap.
fn neighbors8(hash: u64, bits: u32) -> Vec<u64> {
    let mut out = vec![east(hash, bits), west(hash, bits)];
    for vertical in [north(hash, bits), south(hash, bits)] {
        if let Some(v) = vertical {
            out.push(v);
            out.push(east(v, bits)); // NE / SE
            out.push(west(v, bits)); // NW / SW
        }
    }
    out // up to 8; fewer next to a pole
}
```

**When NOT to apply:**
- A strictly axis-constrained search (e.g. "same row only") legitimately needs a subset of directions.
- For any radius/proximity search, always use all eight — see [[qry-search-cell-plus-neighbors]].

Reference: [davetroy/geohash-js](https://github.com/davetroy/geohash-js); [Redis Geospatial](https://redis.io/docs/latest/develop/data-types/geospatial/)
