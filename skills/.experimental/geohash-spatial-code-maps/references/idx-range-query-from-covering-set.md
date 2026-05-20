---
title: Execute a Box Query as Range Scans over the Covering Set
impact: MEDIUM-HIGH
impactDescription: prevents full scans; box query as N indexed range scans
tags: idx, covering-set, range-scan, bounding-box, execution
---

## Execute a Box Query as Range Scans over the Covering Set

The covering ranges from [[qry-bbox-range-decomposition]] are only useful if you execute them as index range scans and merge the results. Issuing one scan per `[start, end]` range against the sorted integer key touches only the rows inside the box; falling back to "scan everything and filter by lat/lon" discards the index you built. Merge the per-range results and refine with exact distance ([[qry-refine-with-haversine]]).

**Incorrect (ignore the ranges, scan and filter):**

```rust
fn box_query_bad(store: &Store, min: (f64, f64), max: (f64, f64)) -> Vec<Record> {
    store.all().into_iter() // full scan
        .filter(|r| in_box(r, min, max))
        .collect()
}
```

**Correct (range-scan each covering range, then merge):**

```rust
fn box_query(store: &Store, min: (f64, f64), max: (f64, f64), bits: u32) -> Vec<Record> {
    let mut out = Vec::new();
    for (lo, hi) in bbox_ranges(min, max, bits) { // covering set from the qry rule
        out.extend(store.range_scan(lo, hi));     // index-served, touches only the box
    }
    out.sort_unstable_by_key(|r| r.id);
    out.dedup_by_key(|r| r.id); // abutting ranges can overlap a row; drop duplicates
    out
}
```

**When NOT to apply:**
- When the box covers most of the dataset, a single full scan can beat many small range scans — estimate selectivity and fall back to a scan above a threshold.

Reference: [Redis Geospatial](https://redis.io/docs/latest/develop/data-types/geospatial/); [Use The Index, Luke](https://use-the-index-luke.com/)
