---
title: Wrap East/West Neighbours Across the Antimeridian
impact: HIGH
impactDescription: prevents missing neighbours at ±180° longitude
tags: nbr, antimeridian, wraparound, longitude, edge-case
---

## Wrap East/West Neighbours Across the Antimeridian

A cell touching +180° longitude has an east neighbour at -180° — they are physically adjacent across the dateline. The string lookup-table algorithm handles this through its carry recursion, but if you compute neighbours on the de-interleaved integer by adding one to the longitude column, the column overflows and either wraps incorrectly or names an out-of-range cell unless you mask to the valid bit width. Always wrap longitude modulo `2^bits`; never wrap latitude (the poles are hard edges — see [[nbr-pole-handling]]).

**Incorrect (overflow past the last column):**

```rust
fn east_bad(lon_col: u32, lat_col: u32, _bits: u32) -> (u32, u32) {
    (lon_col + 1, lat_col) // at the max column this exceeds 2^bits -> invalid cell
}
```

**Correct (wrap the longitude column modulo the grid width):**

```rust
fn east(lon_col: u32, lat_col: u32, bits: u32) -> (u32, u32) {
    let width = 1u32 << bits;
    ((lon_col + 1) & (width - 1), lat_col) // +180 wraps to -180
}
fn west(lon_col: u32, lat_col: u32, bits: u32) -> (u32, u32) {
    let width = 1u32 << bits;
    ((lon_col + width - 1) & (width - 1), lat_col)
}
```

**When NOT to apply:**
- For the synthetic codebase plane ([[map-normalize-to-geohash-domain]]) there is no dateline — leave the east/west edges unwrapped so regions do not wrap around the map, which is usually what you want for code.

Reference: [davetroy/geohash-js](https://github.com/davetroy/geohash-js); [Wikipedia — Geohash](https://en.wikipedia.org/wiki/Geohash)
