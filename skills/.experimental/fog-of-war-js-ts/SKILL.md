---
name: fog-of-war-js-ts
description: Fog of war, field of view, line of sight, and tile visibility in JavaScript or TypeScript games — roguelikes, RTS, top-down, or strategy maps. Covers efficient FOV algorithms (recursive and symmetric shadowcasting, DDA raycasting, 2D visibility polygons), update scheduling and multi-viewer reference counting, typed-array and bitset state, canvas and WebGL fog rendering, memory and large-map scaling, hot-loop geometry math, and visibility correctness. Trigger when implementing, reviewing, or optimizing such code — even when the user only says "fog of war", "reveal the map", "what can this unit see", "shadowcasting", or "visibility grid" without mentioning performance — the naive raycast-per-cell-every-frame approach is usually what needs replacing. Prefer these patterns when writing new visibility code or refactoring slow or buggy fog.
---
# dot-skills Fog of War (JavaScript/TypeScript) Best Practices

Performance and correctness guide for fog of war and field-of-view systems in JS/TS games, distilled from the canonical FOV literature (Björn Bergström, Albert Ford, Adam Milazzo), Red Blob Games, rot.js, and the MDN/WebGL rendering APIs. Contains 44 rules across 8 categories, ordered by impact, to guide writing, reviewing, and refactoring visibility code.

## When to Apply

Reference these guidelines when:
- Implementing field of view, line of sight, or tile visibility for a grid or continuous map
- Building or refactoring a fog-of-war display (unexplored / explored / visible layers)
- Diagnosing slow fog (recompute every frame), visual artifacts (flicker, light leaks), or memory blowups on large maps
- Scaling visibility to many units (RTS) or to large/streaming worlds
- Choosing how to store and render the visibility/explored state

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | FOV / Visibility Algorithm | CRITICAL | `fov-` |
| 2 | Update Scheduling & Incremental Recompute | CRITICAL | `update-` |
| 3 | State Representation & Data Structures | HIGH | `state-` |
| 4 | Rendering the Fog Layer | HIGH | `render-` |
| 5 | Memory & Allocation | MEDIUM-HIGH | `mem-` |
| 6 | Multi-Viewer & Map Scaling | MEDIUM | `scale-` |
| 7 | Geometry & Hot-Loop Math | MEDIUM | `geo-` |
| 8 | Correctness & Visual Artifacts | LOW-MEDIUM | `correct-` |

## Quick Reference

### 1. FOV / Visibility Algorithm (CRITICAL)

- [`fov-recursive-shadowcasting`](references/fov-recursive-shadowcasting.md) - Use recursive shadowcasting, not ray-per-cell FOV
- [`fov-symmetric-shadowcasting`](references/fov-symmetric-shadowcasting.md) - Prefer symmetric shadowcasting for consistent visibility
- [`fov-octant-transforms`](references/fov-octant-transforms.md) - Transform octants with a lookup table, not eight loops
- [`fov-radius-bounded-scan`](references/fov-radius-bounded-scan.md) - Bound the scan to the sight radius and map edges
- [`fov-single-ray-los`](references/fov-single-ray-los.md) - Use a single line-of-sight ray for point-to-point checks
- [`fov-dda-continuous`](references/fov-dda-continuous.md) - Traverse continuous space with a DDA grid walk
- [`fov-visibility-polygon`](references/fov-visibility-polygon.md) - Compute a visibility polygon for smooth 2D fog

### 2. Update Scheduling & Incremental Recompute (CRITICAL)

- [`update-recompute-on-move`](references/update-recompute-on-move.md) - Recompute field of view only when the viewer moves
- [`update-dirty-flag`](references/update-dirty-flag.md) - Track a dirty flag per viewer and a map version stamp
- [`update-refcount-visibility`](references/update-refcount-visibility.md) - Count viewers per tile for incremental multi-viewer updates
- [`update-delta-not-clear`](references/update-delta-not-clear.md) - Emit visibility deltas instead of clear-all-recompute
- [`update-debounce-map-edits`](references/update-debounce-map-edits.md) - Batch map edits and recompute affected viewers once
- [`update-merge-explored`](references/update-merge-explored.md) - Merge visible into explored as you reveal, never rebuild it

### 3. State Representation & Data Structures (HIGH)

- [`state-typed-arrays`](references/state-typed-arrays.md) - Store fog state in typed arrays, not arrays of objects
- [`state-flat-1d-index`](references/state-flat-1d-index.md) - Index a flat buffer with y*width+x, not nested arrays
- [`state-three-state-encoding`](references/state-three-state-encoding.md) - Encode the three fog states as bit flags in one byte
- [`state-bitset-layers`](references/state-bitset-layers.md) - Use a bitset for boolean visibility layers
- [`state-row-major-iteration`](references/state-row-major-iteration.md) - Iterate row-major to match the buffer's memory layout
- [`state-no-string-keys`](references/state-no-string-keys.md) - Avoid string-keyed maps for per-tile visibility

### 4. Rendering the Fog Layer (HIGH)

- [`render-offscreen-fog-layer`](references/render-offscreen-fog-layer.md) - Render fog to a separate offscreen layer
- [`render-dirty-region-only`](references/render-dirty-region-only.md) - Repaint only the dirty fog region
- [`render-imagedata-not-fillrect`](references/render-imagedata-not-fillrect.md) - Build fog as one ImageData, not per-tile fillRect
- [`render-lowres-soft-upscale`](references/render-lowres-soft-upscale.md) - Render soft fog at tile resolution and upscale on the GPU
- [`render-webgl-texsubimage`](references/render-webgl-texsubimage.md) - Upload only the dirty rect of the fog texture in WebGL
- [`render-fade-alpha-lerp`](references/render-fade-alpha-lerp.md) - Animate fog reveal by lerping alpha, not recomputing FOV

### 5. Memory & Allocation (MEDIUM-HIGH)

- [`mem-reuse-buffers`](references/mem-reuse-buffers.md) - Allocate fog buffers once and reuse them
- [`mem-clear-with-fill`](references/mem-clear-with-fill.md) - Clear the visible buffer with fill, not reallocation or a loop
- [`mem-generation-stamp`](references/mem-generation-stamp.md) - Use a generation stamp to skip the per-frame clear
- [`mem-bitpack-explored`](references/mem-bitpack-explored.md) - Pack the explored layer into bits for memory and saves
- [`mem-no-hot-loop-closures`](references/mem-no-hot-loop-closures.md) - Hoist allocations out of the FOV scan loop

### 6. Multi-Viewer & Map Scaling (MEDIUM)

- [`scale-chunk-large-maps`](references/scale-chunk-large-maps.md) - Chunk large maps and keep only active chunks resident
- [`scale-shared-team-visibility`](references/scale-shared-team-visibility.md) - Share one refcounted visibility buffer per team
- [`scale-spatial-partition-edits`](references/scale-spatial-partition-edits.md) - Find edit-affected viewers with a spatial index
- [`scale-gameplay-vs-render-culling`](references/scale-gameplay-vs-render-culling.md) - Separate gameplay visibility from on-screen render culling
- [`scale-cap-recompute-budget`](references/scale-cap-recompute-budget.md) - Cap FOV recomputes per frame with a time budget

### 7. Geometry & Hot-Loop Math (MEDIUM)

- [`geo-squared-distance`](references/geo-squared-distance.md) - Compare squared distances to avoid per-cell sqrt
- [`geo-avoid-modulo-deindex`](references/geo-avoid-modulo-deindex.md) - Track x and y directly instead of modulo-deindexing
- [`geo-integer-slope-shadows`](references/geo-integer-slope-shadows.md) - Use rational slopes to avoid floating-point drift
- [`geo-avoid-trig-in-loop`](references/geo-avoid-trig-in-loop.md) - Precompute directions instead of calling trig per cell
- [`geo-radius-shape-choice`](references/geo-radius-shape-choice.md) - Choose the radius metric for the shape you want

### 8. Correctness & Visual Artifacts (LOW-MEDIUM)

- [`correct-symmetric-walls`](references/correct-symmetric-walls.md) - Light wall tiles consistently to avoid flickering faces
- [`correct-corner-peeking`](references/correct-corner-peeking.md) - Handle diagonal wall corners deliberately
- [`correct-permissiveness-model`](references/correct-permissiveness-model.md) - Pick one permissiveness model and apply it everywhere
- [`correct-explored-not-overwritten`](references/correct-explored-not-overwritten.md) - Never let the visible pass overwrite the explored layer

## How to Use

Read individual reference files for the full explanation and incorrect/correct code:

- Start with `fov-` and `update-` for the two biggest wins: a correct algorithm and recomputing only on change.
- [Section definitions](references/_sections.md) - Category structure, impact levels, and the execution-lifecycle ordering.
- [Rule template](assets/templates/_template.md) - Template for adding new rules.

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
| [metadata.json](metadata.json) | Version and reference information |
