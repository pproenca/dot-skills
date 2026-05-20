---
title: Decompose a Bounding Box into Covering Geohash Ranges
impact: HIGH
impactDescription: prevents missing interior cells that corner queries drop
tags: qry, bounding-box, range-scan, covering-set, decomposition
---

## Decompose a Bounding Box into Covering Geohash Ranges

To find everything inside a rectangle, a common mistake is to hash the four corners and query those four prefixes — but the interior and edges contain many cells the corners do not name. The correct approach enumerates the grid of cells covering the box at a chosen precision and collapses runs of consecutive integer geohashes into `[start, end]` ranges, which a B-tree or sorted set serves as range scans (see [[idx-integer-sortable-key]]).

**Incorrect (four corner prefixes):**

```rust
fn bbox_query_bad(min: (f64, f64), max: (f64, f64)) -> Vec<u64> {
    vec![ // misses everything not under a corner cell
        encode_u64(min.0, min.1), encode_u64(min.0, max.1),
        encode_u64(max.0, min.1), encode_u64(max.0, max.1),
    ]
}
```

**Correct (enumerate covering cells, merge into ranges):**

```rust
fn bbox_ranges(min: (f64, f64), max: (f64, f64), bits: u32) -> Vec<(u64, u64)> {
    let mut cells: Vec<u64> = grid_cells_covering(min, max, bits).collect();
    cells.sort_unstable();
    // Collapse consecutive integers into [start, end] ranges for range scans.
    let mut ranges = Vec::new();
    let (mut start, mut prev) = (cells[0], cells[0]);
    for &c in &cells[1..] {
        if c == prev + 1 { prev = c; } else { ranges.push((start, prev)); start = c; prev = c; }
    }
    ranges.push((start, prev));
    ranges
}
```

**When NOT to apply:**
- For tiny boxes that fit within a 3×3 cell block, the cell-plus-neighbours approach ([[qry-search-cell-plus-neighbors]]) is simpler and just as correct.

Reference: [Redis Geospatial](https://redis.io/docs/latest/develop/data-types/geospatial/); [Z-order curve](https://en.wikipedia.org/wiki/Z-order_curve)
