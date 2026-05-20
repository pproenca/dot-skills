# Geohash (TypeScript & Rust)

**Version 0.1.0**  
Geohash & Spatial Code Maps  
May 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Geohash implementation and applied spatial-indexing guide for TypeScript and Rust, plus a novel 'codebase as a navigable 2D map' pattern. Contains 42 rules across 8 categories, prioritised by impact from critical (encoding correctness and precision/cell geometry) through neighbours, proximity queries, and the codebase-map projection, down to decoding, storage indexing, and slippy-map navigation. Each rule explains why it matters and shows production-realistic incorrect vs. correct examples in TypeScript or Rust, with explicit when-NOT-to-apply guidance. The geohash fundamentals are drawn from authoritative sources (the geohash spec, the davetroy/geohash-js neighbour tables, Redis, Elasticsearch); the codebase-map categories synthesise established techniques (deterministic graph layout, Morton/Z-order keys, slippy-map tiling, software cartography) into an architectural pattern for navigating a codebase like Google Maps.

---

## Table of Contents

1. [Encoding & Bit Interleaving](references/_sections.md#1-encoding-&-bit-interleaving) — **CRITICAL**
   - 1.1 [Accumulate Exactly Five Bits per Character](references/enc-five-bit-char-boundary.md) — CRITICAL (prevents truncated or misaligned hashes)
   - 1.2 [Clamp and Validate Coordinates Before Encoding](references/enc-normalize-input-domain.md) — CRITICAL (prevents silent garbage hashes from out-of-range input)
   - 1.3 [Encode to an Interleaved 64-bit Integer for Speed and Sortable Keys](references/enc-integer-morton-encode.md) — CRITICAL (5-20x faster encode; yields a directly sortable key)
   - 1.4 [Interleave Longitude on Even Bits, Latitude on Odd](references/enc-interleave-longitude-first.md) — CRITICAL (prevents 100% of swapped-axis hashes)
   - 1.5 [Recompute Interval Midpoints; Never Accumulate a Float Step](references/enc-binary-chop-no-float-drift.md) — CRITICAL (prevents off-by-one cell errors at precision >= 9)
   - 1.6 [Use the Geohash Base32 Alphabet, Not RFC 4648](references/enc-base32-alphabet.md) — CRITICAL (prevents unshareable, non-interoperable hashes)
2. [Precision & Cell Geometry](references/_sections.md#2-precision-&-cell-geometry) — **CRITICAL**
   - 2.1 [Account for Longitude Metres Shrinking with Latitude](references/prec-cells-shrink-toward-poles.md) — CRITICAL (prevents up to 2x metric error above 60° latitude)
   - 2.2 [Choose Geohash Length from the Required Error Radius](references/prec-choose-from-error-radius.md) — CRITICAL (prevents 10-100x oversized or undersized cells)
   - 2.3 [Normalise to One Precision Before Comparing or Storing](references/prec-avoid-mixed-precision.md) — CRITICAL (prevents incorrect prefix-containment results)
   - 2.4 [Report Decoded Accuracy as Half the Cell, Not the Full Cell](references/prec-error-is-half-cell.md) — CRITICAL (prevents 2x overstated accuracy)
   - 2.5 [Treat Cells as Rectangles Whose Aspect Flips with Length](references/prec-cells-are-not-square.md) — CRITICAL (prevents up to 2x error on one axis)
3. [Neighbors & Adjacency](references/_sections.md#3-neighbors-&-adjacency) — **HIGH**
   - 3.1 [Build the Full Eight-Neighbour Set for Proximity](references/nbr-eight-neighbor-set.md) — HIGH (prevents missing diagonal-cell matches)
   - 3.2 [Compute Neighbours on the De-interleaved Integer](references/nbr-integer-level-neighbors.md) — HIGH (O(1) neighbour vs O(len) string recursion)
   - 3.3 [Compute Neighbours with the Canonical Border and Neighbour Tables](references/nbr-canonical-lookup-tables.md) — HIGH (prevents wrong-cell adjacency at all 4 edges)
   - 3.4 [Return No Neighbour Past the Poles](references/nbr-pole-handling.md) — HIGH (prevents phantom cells at the top and bottom rows)
   - 3.5 [Wrap East/West Neighbours Across the Antimeridian](references/nbr-antimeridian-wrap.md) — HIGH (prevents missing neighbours at ±180° longitude)
4. [Proximity & Range Queries](references/_sections.md#4-proximity-&-range-queries) — **HIGH**
   - 4.1 [Decompose a Bounding Box into Covering Geohash Ranges](references/qry-bbox-range-decomposition.md) — HIGH (prevents missing interior cells that corner queries drop)
   - 4.2 [Match Query Precision to the Search Radius](references/qry-precision-from-radius.md) — HIGH (prevents the 9-cell block being smaller than the radius)
   - 4.3 [Query the Cell Plus Its Eight Neighbours, Never the Prefix Alone](references/qry-search-cell-plus-neighbors.md) — HIGH (eliminates border false negatives)
   - 4.4 [Refine Geohash Candidates with True Distance](references/qry-refine-with-haversine.md) — HIGH (prevents square-corner false positives in results)
   - 4.5 [Widen the Search by Dropping a Prefix Character on Sparse Cells](references/qry-expand-precision-when-sparse.md) — HIGH (prevents empty results in sparse regions)
5. [Codebase-as-Map Spatial Layout](references/_sections.md#5-codebase-as-map-spatial-layout) — **HIGH**
   - 5.1 [Make Coordinates Reproducible and Incremental-Stable](references/map-stable-coordinates.md) — HIGH (prevents the whole map reshuffling on every commit)
   - 5.2 [Map Prefix Length to Architectural Level](references/map-precision-as-architectural-level.md) — HIGH (prevents inconsistent prefix semantics across call sites)
   - 5.3 [Normalise the Code Plane into the Geohash Lat/Lon Domain](references/map-normalize-to-geohash-domain.md) — HIGH (prevents out-of-range coordinates colliding at a corner)
   - 5.4 [Persist the File-to-Geohash Assignment as a Committed Sidecar](references/map-persist-coordinate-sidecar.md) — HIGH (prevents non-reproducible, unreviewable maps)
   - 5.5 [Project Code into 2D from a Structural Signal, Not Arbitrary Layout](references/map-deterministic-projection.md) — HIGH (prevents random regions that group unrelated files)
   - 5.6 [Treat a Geohash Prefix as a Named Domain Region](references/map-prefix-as-domain-region.md) — HIGH (prevents brittle path-based domain heuristics)
   - 5.7 [Validate That Coupled Code Lands in the Same Region](references/map-coupling-implies-proximity.md) — HIGH (prevents incoherent regions that mix unrelated domains)
6. [Decoding & Bounding Boxes](references/_sections.md#6-decoding-&-bounding-boxes) — **MEDIUM-HIGH**
   - 6.1 [Decode by Mirroring the Encoder's Interval Halving](references/dec-symmetric-interval-reconstruction.md) — MEDIUM-HIGH (prevents decode drifting to a neighbour cell)
   - 6.2 [Decode to a Bounding Box, Then Derive the Centre](references/dec-decode-to-bbox.md) — MEDIUM-HIGH (preserves the cell extent and its error margin)
   - 6.3 [Decode with a Precomputed Reverse-Alphabet Table](references/dec-precompute-reverse-alphabet.md) — MEDIUM-HIGH (O(1) per character and rejects invalid input)
   - 6.4 [Keep the Original Hash; Don't Decode-then-Re-encode to "Normalise"](references/dec-avoid-roundtrip-reencode.md) — MEDIUM-HIGH (prevents cell drift from round-trip conversions)
7. [Spatial Indexing & Storage](references/_sections.md#7-spatial-indexing-&-storage) — **MEDIUM-HIGH**
   - 7.1 [Aggregate by Region with a Geohash Trie](references/idx-trie-hierarchical-bucketing.md) — MEDIUM-HIGH (O(prefix-length) region rollups without rescanning)
   - 7.2 [Execute a Box Query as Range Scans over the Covering Set](references/idx-range-query-from-covering-set.md) — MEDIUM-HIGH (prevents full scans; box query as N indexed range scans)
   - 7.3 [Make Prefix Queries Sargable in Postgres and Redis](references/idx-db-prefix-index.md) — MEDIUM-HIGH (prevents full-table scans on proximity queries)
   - 7.4 [Store Geohashes as Sorted Strings for Prefix Range Scans](references/idx-sorted-string-range-scan.md) — MEDIUM-HIGH (prevents full scans; proximity becomes a range scan)
   - 7.5 [Use the Interleaved Integer as a Compact Sortable Key](references/idx-integer-sortable-key.md) — MEDIUM-HIGH (prevents string-walk compares; 8-byte sortable key)
8. [Navigation & Rendering](references/_sections.md#8-navigation-&-rendering) — **MEDIUM**
   - 8.1 [Cluster Overlapping Markers by Shared Prefix](references/nav-cluster-by-prefix.md) — MEDIUM (prevents marker overdraw at low zoom)
   - 8.2 [Load Only the Geohash Cells in the Viewport](references/nav-tile-lazy-loading.md) — MEDIUM (loads the viewport, not the whole dataset)
   - 8.3 [Map Geohash Precision to Zoom Levels](references/nav-precision-to-zoom-levels.md) — MEDIUM (prevents drawing millions of off-scale cells per frame)
   - 8.4 [Render Aggregated Prefix Buckets When Zoomed Out](references/nav-level-of-detail-aggregation.md) — MEDIUM (prevents O(n) render cost; bounded by visible cells)
   - 8.5 [Use the Geohash Prefix as Navigation State and Deep Link](references/nav-breadcrumb-prefix-path.md) — MEDIUM (prevents fragile coordinate links; enables region deep links)

---

## References

1. [https://en.wikipedia.org/wiki/Geohash](https://en.wikipedia.org/wiki/Geohash)
2. [https://github.com/davetroy/geohash-js](https://github.com/davetroy/geohash-js)
3. [https://github.com/georust/geohash](https://github.com/georust/geohash)
4. [https://github.com/sunng87/node-geohash](https://github.com/sunng87/node-geohash)
5. [https://redis.io/docs/latest/develop/data-types/geospatial/](https://redis.io/docs/latest/develop/data-types/geospatial/)
6. [https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-bucket-geohashgrid-aggregation.html](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-bucket-geohashgrid-aggregation.html)
7. [https://en.wikipedia.org/wiki/Z-order_curve](https://en.wikipedia.org/wiki/Z-order_curve)
8. [https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames](https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames)
9. [https://wettel.github.io/codecity.html](https://wettel.github.io/codecity.html)
10. [https://use-the-index-luke.com/](https://use-the-index-luke.com/)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |