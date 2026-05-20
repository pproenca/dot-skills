---
name: geohash-spatial-code-maps
description: Use this skill whenever implementing, reviewing, or debugging geohash encoding/decoding in TypeScript or Rust — bit interleaving, the base32 alphabet, precision and cell geometry, neighbour/adjacency computation, proximity and bounding-box queries, and geohash-backed spatial indexing. Also use it for the "codebase as a navigable 2D map" pattern — projecting a codebase into a coordinate plane, geohashing it so prefixes become business-domain regions, and navigating it like Google Maps (zoom, tiles, level-of-detail, clustering, deep links). Trigger even when the user does not say "geohash" — if the work involves spatial hashing, Morton/Z-order codes, proximity search on lat/lon, or mapping and visualising code structure spatially, this is the skill. Contains 42 impact-ordered rules with TypeScript and Rust examples.
---

# Geohash & Spatial Code Maps Best Practices

How to implement geohashes correctly in TypeScript and Rust, how to query and index them at scale, and how to apply them to the "codebase as a navigable 2D map" pattern — projecting code into a plane so geohash prefixes become domain regions you can fly through like Google Maps. Contains 42 rules across 8 categories, prioritised by impact.

## When to Apply

Reference these guidelines when:

- Implementing or reviewing a geohash encoder/decoder in TypeScript or Rust (bit interleaving, base32, precision, neighbours)
- Building proximity / radius / bounding-box search on lat/lon data, or storing geohashes as index keys (SQL B-tree, Redis sorted sets)
- Debugging the classic geohash bugs — swapped axes, wrong alphabet, border false negatives, off-by-one cells at high precision
- Projecting a codebase (or any abstract graph) into a 2D plane and geohashing it so prefixes name business domains or features
- Navigating a geohashed dataset like a slippy map: zoom-to-precision, viewport tile loading, level-of-detail aggregation, prefix clustering, deep links

## A note on scope

Categories 1–4, 6, and 7 are textbook geohashing, drawn from authoritative sources (the geohash spec, the `davetroy/geohash-js` neighbour tables, Redis, Elasticsearch). Categories 5 (`map-`) and 8 (`nav-`) are a **novel synthesis** — there is no canonical "geohash your codebase" library, so those rules derive design principles from established techniques (deterministic graph layout, Morton/Z-order keys, slippy-map tiling, software cartography). They are honest about when the pattern is overkill.

## Rule Categories by Priority

| Priority | Category | Impact | Prefix | Rules |
|----------|----------|--------|--------|-------|
| 1 | Encoding & Bit Interleaving | CRITICAL | `enc-` | 6 |
| 2 | Precision & Cell Geometry | CRITICAL | `prec-` | 5 |
| 3 | Neighbours & Adjacency | HIGH | `nbr-` | 5 |
| 4 | Proximity & Range Queries | HIGH | `qry-` | 5 |
| 5 | Codebase-as-Map Spatial Layout | HIGH | `map-` | 7 |
| 6 | Decoding & Bounding Boxes | MEDIUM-HIGH | `dec-` | 4 |
| 7 | Spatial Indexing & Storage | MEDIUM-HIGH | `idx-` | 5 |
| 8 | Navigation & Rendering | MEDIUM | `nav-` | 5 |

## Quick Reference

### 1. Encoding & Bit Interleaving (CRITICAL)

- [`enc-interleave-longitude-first`](references/enc-interleave-longitude-first.md) — Interleave longitude on even bits, latitude on odd
- [`enc-base32-alphabet`](references/enc-base32-alphabet.md) — Use the geohash base32 alphabet, not RFC 4648
- [`enc-integer-morton-encode`](references/enc-integer-morton-encode.md) — Encode to an interleaved 64-bit integer for speed and sortable keys
- [`enc-binary-chop-no-float-drift`](references/enc-binary-chop-no-float-drift.md) — Recompute interval midpoints; never accumulate a float step
- [`enc-normalize-input-domain`](references/enc-normalize-input-domain.md) — Clamp latitude, wrap longitude, reject non-finite input
- [`enc-five-bit-char-boundary`](references/enc-five-bit-char-boundary.md) — Accumulate exactly five bits per character

### 2. Precision & Cell Geometry (CRITICAL)

- [`prec-choose-from-error-radius`](references/prec-choose-from-error-radius.md) — Choose geohash length from the required error radius
- [`prec-cells-are-not-square`](references/prec-cells-are-not-square.md) — Treat cells as rectangles whose aspect flips with length
- [`prec-error-is-half-cell`](references/prec-error-is-half-cell.md) — Report decoded accuracy as half the cell, not the full cell
- [`prec-cells-shrink-toward-poles`](references/prec-cells-shrink-toward-poles.md) — Scale longitude metres by cos(latitude)
- [`prec-avoid-mixed-precision`](references/prec-avoid-mixed-precision.md) — Normalise to one precision before comparing or storing

### 3. Neighbours & Adjacency (HIGH)

- [`nbr-canonical-lookup-tables`](references/nbr-canonical-lookup-tables.md) — Compute neighbours with the canonical border/neighbour tables
- [`nbr-antimeridian-wrap`](references/nbr-antimeridian-wrap.md) — Wrap east/west neighbours across the antimeridian
- [`nbr-pole-handling`](references/nbr-pole-handling.md) — Return no neighbour past the poles
- [`nbr-integer-level-neighbors`](references/nbr-integer-level-neighbors.md) — Compute neighbours on the de-interleaved integer
- [`nbr-eight-neighbor-set`](references/nbr-eight-neighbor-set.md) — Build the full eight-neighbour set for proximity

### 4. Proximity & Range Queries (HIGH)

- [`qry-search-cell-plus-neighbors`](references/qry-search-cell-plus-neighbors.md) — Query the cell plus its eight neighbours, never the prefix alone
- [`qry-precision-from-radius`](references/qry-precision-from-radius.md) — Match query precision to the search radius
- [`qry-bbox-range-decomposition`](references/qry-bbox-range-decomposition.md) — Decompose a bounding box into covering geohash ranges
- [`qry-refine-with-haversine`](references/qry-refine-with-haversine.md) — Refine geohash candidates with true distance
- [`qry-expand-precision-when-sparse`](references/qry-expand-precision-when-sparse.md) — Widen the search by dropping a prefix character on sparse cells

### 5. Codebase-as-Map Spatial Layout (HIGH)

- [`map-deterministic-projection`](references/map-deterministic-projection.md) — Project code into 2D from a structural signal, not arbitrary layout
- [`map-stable-coordinates`](references/map-stable-coordinates.md) — Make coordinates reproducible and incremental-stable
- [`map-normalize-to-geohash-domain`](references/map-normalize-to-geohash-domain.md) — Normalise the code plane into the geohash lat/lon domain
- [`map-coupling-implies-proximity`](references/map-coupling-implies-proximity.md) — Validate that coupled code lands in the same region
- [`map-prefix-as-domain-region`](references/map-prefix-as-domain-region.md) — Treat a geohash prefix as a named domain region
- [`map-precision-as-architectural-level`](references/map-precision-as-architectural-level.md) — Map prefix length to architectural level
- [`map-persist-coordinate-sidecar`](references/map-persist-coordinate-sidecar.md) — Persist the file-to-geohash assignment as a committed sidecar

### 6. Decoding & Bounding Boxes (MEDIUM-HIGH)

- [`dec-decode-to-bbox`](references/dec-decode-to-bbox.md) — Decode to a bounding box, then derive the centre
- [`dec-symmetric-interval-reconstruction`](references/dec-symmetric-interval-reconstruction.md) — Decode by mirroring the encoder's interval halving
- [`dec-avoid-roundtrip-reencode`](references/dec-avoid-roundtrip-reencode.md) — Keep the original hash; don't decode-then-re-encode
- [`dec-precompute-reverse-alphabet`](references/dec-precompute-reverse-alphabet.md) — Decode with a precomputed reverse-alphabet table

### 7. Spatial Indexing & Storage (MEDIUM-HIGH)

- [`idx-sorted-string-range-scan`](references/idx-sorted-string-range-scan.md) — Store geohashes as sorted strings for prefix range scans
- [`idx-integer-sortable-key`](references/idx-integer-sortable-key.md) — Use the interleaved integer as a compact sortable key
- [`idx-db-prefix-index`](references/idx-db-prefix-index.md) — Make prefix queries sargable in Postgres and Redis
- [`idx-range-query-from-covering-set`](references/idx-range-query-from-covering-set.md) — Execute a box query as range scans over the covering set
- [`idx-trie-hierarchical-bucketing`](references/idx-trie-hierarchical-bucketing.md) — Aggregate by region with a geohash trie

### 8. Navigation & Rendering (MEDIUM)

- [`nav-precision-to-zoom-levels`](references/nav-precision-to-zoom-levels.md) — Map geohash precision to zoom levels
- [`nav-level-of-detail-aggregation`](references/nav-level-of-detail-aggregation.md) — Render aggregated prefix buckets when zoomed out
- [`nav-tile-lazy-loading`](references/nav-tile-lazy-loading.md) — Load only the geohash cells in the viewport
- [`nav-cluster-by-prefix`](references/nav-cluster-by-prefix.md) — Cluster overlapping markers by shared prefix
- [`nav-breadcrumb-prefix-path`](references/nav-breadcrumb-prefix-path.md) — Use the geohash prefix as navigation state and deep link

## How to Use

Read individual reference files for detailed explanations, code examples, and "when NOT to apply" guidance:

- [Section definitions](references/_sections.md) — Category structure and impact levels
- [Rule template](assets/templates/_template.md) — Template for adding new rules

Rules cross-link via `[[other-rule-slug]]`; follow them when a related pattern is referenced. To build a code map end to end, the spine is: [`map-deterministic-projection`](references/map-deterministic-projection.md) → [`map-normalize-to-geohash-domain`](references/map-normalize-to-geohash-domain.md) → encode (category 1) → [`map-prefix-as-domain-region`](references/map-prefix-as-domain-region.md) → navigate (category 8).

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
| [metadata.json](metadata.json) | Version and reference information |
