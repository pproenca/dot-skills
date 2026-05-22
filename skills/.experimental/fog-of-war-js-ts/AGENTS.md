# Fog of War (JavaScript/TypeScript)

**Version 0.1.0**  
dot-skills  
May 2026

> **Note:** This document is mainly for agents and LLMs to follow when maintaining, generating, or refactoring Fog of War (JavaScript/TypeScript) code. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Performance and correctness guide for implementing fog of war and field of view in JavaScript/TypeScript games, designed for AI agents and LLMs. Contains 44 rules across 8 categories, ordered by impact from critical (visibility algorithm choice, update scheduling) through high (state representation, fog rendering) to incremental (hot-loop geometry, visual-artifact correctness). Each rule explains why it matters and pairs a production-realistic incorrect example with a minimal-diff correct one in TypeScript. Covers recursive and symmetric shadowcasting, single-ray and DDA line of sight, 2D visibility polygons, recompute-on-move and refcounted multi-viewer updates, typed-array/bitset/generation-stamp state, offscreen-canvas and WebGL dirty-rect rendering, chunked large-map and team-shared scaling, and a consistent visibility model that avoids flicker and light leaks.

---

## Table of Contents

1. [FOV / Visibility Algorithm](references/_sections.md#1-fov-/-visibility-algorithm) — **CRITICAL**
   - 1.1 [Bound the Scan to the Sight Radius and Map Edges](references/fov-radius-bounded-scan.md) — HIGH (O(width by height) to O(radius squared))
   - 1.2 [Compute a Visibility Polygon for Smooth 2D Fog](references/fov-visibility-polygon.md) — MEDIUM-HIGH (O(n log n) for n wall endpoints)
   - 1.3 [Prefer Symmetric Shadowcasting for Consistent Visibility](references/fov-symmetric-shadowcasting.md) — CRITICAL (prevents asymmetric visibility artifacts)
   - 1.4 [Transform Octants With a Lookup Table, Not Eight Loops](references/fov-octant-transforms.md) — HIGH (eliminates eight duplicated scan loops)
   - 1.5 [Traverse Continuous Space With a DDA Grid Walk](references/fov-dda-continuous.md) — MEDIUM-HIGH (prevents missed thin walls)
   - 1.6 [Use a Single Line-of-Sight Ray for Point-to-Point Checks](references/fov-single-ray-los.md) — HIGH (O(radius squared) to O(radius))
   - 1.7 [Use Recursive Shadowcasting, Not Ray-Per-Cell FOV](references/fov-recursive-shadowcasting.md) — CRITICAL (eliminates redundant ray overlap)
2. [Update Scheduling & Incremental Recompute](references/_sections.md#2-update-scheduling-&-incremental-recompute) — **CRITICAL**
   - 2.1 [Batch Map Edits and Recompute Affected Viewers Once](references/update-debounce-map-edits.md) — MEDIUM-HIGH (reduces N edits to 1 recompute)
   - 2.2 [Count Viewers Per Tile for Incremental Multi-Viewer Updates](references/update-refcount-visibility.md) — CRITICAL (O(viewers) to O(1) per tile hide)
   - 2.3 [Emit Visibility Deltas Instead of Clear-All-Recompute](references/update-delta-not-clear.md) — HIGH (reduces redraw to changed tiles)
   - 2.4 [Merge Visible Into Explored as You Reveal, Never Rebuild It](references/update-merge-explored.md) — HIGH (maintains O(1) explored updates)
   - 2.5 [Recompute Field of View Only When the Viewer Moves](references/update-recompute-on-move.md) — CRITICAL (prevents per-frame recompute)
   - 2.6 [Track a Dirty Flag Per Viewer and a Map Version Stamp](references/update-dirty-flag.md) — HIGH (avoids clean viewer recomputes)
3. [State Representation & Data Structures](references/_sections.md#3-state-representation-&-data-structures) — **HIGH**
   - 3.1 [Avoid String-Keyed Maps for Per-Tile Visibility](references/state-no-string-keys.md) — MEDIUM (eliminates per-tile string hashing)
   - 3.2 [Encode the Three Fog States as Bit Flags in One Byte](references/state-three-state-encoding.md) — HIGH (reduces three layers to one byte)
   - 3.3 [Index a Flat Buffer With y times width plus x, Not Nested Arrays](references/state-flat-1d-index.md) — HIGH (eliminates per-row array indirection)
   - 3.4 [Iterate Row-Major to Match the Buffer's Memory Layout](references/state-row-major-iteration.md) — MEDIUM (reduces cache misses)
   - 3.5 [Store Fog State in Typed Arrays, Not Arrays of Objects](references/state-typed-arrays.md) — HIGH (eliminates per-cell object overhead)
   - 3.6 [Use a Bitset for Boolean Visibility Layers](references/state-bitset-layers.md) — MEDIUM-HIGH (reduces boolean-layer memory 8x)
4. [Rendering the Fog Layer](references/_sections.md#4-rendering-the-fog-layer) — **HIGH**
   - 4.1 [Animate Fog Reveal by Lerping Alpha, Not Recomputing FOV](references/render-fade-alpha-lerp.md) — MEDIUM (avoids sub-frame FOV recompute)
   - 4.2 [Build Fog as One ImageData, Not Per-Tile fillRect](references/render-imagedata-not-fillrect.md) — HIGH (reduces thousands of draws to one blit)
   - 4.3 [Render Fog to a Separate Offscreen Layer](references/render-offscreen-fog-layer.md) — HIGH (avoids per-frame fog rasterisation)
   - 4.4 [Render Soft Fog at Tile Resolution and Upscale on the GPU](references/render-lowres-soft-upscale.md) — MEDIUM-HIGH (eliminates per-pixel CPU blur)
   - 4.5 [Repaint Only the Dirty Fog Region](references/render-dirty-region-only.md) — HIGH (O(map) to O(changed tiles))
   - 4.6 [Upload Only the Dirty Rect of the Fog Texture in WebGL](references/render-webgl-texsubimage.md) — MEDIUM-HIGH (reduces upload to the dirty rect)
5. [Memory & Allocation](references/_sections.md#5-memory-&-allocation) — **MEDIUM-HIGH**
   - 5.1 [Allocate Fog Buffers Once and Reuse Them](references/mem-reuse-buffers.md) — MEDIUM-HIGH (prevents per-frame GC pauses)
   - 5.2 [Clear the Visible Buffer With fill, Not Reallocation or a Loop](references/mem-clear-with-fill.md) — MEDIUM (avoids per-frame allocation)
   - 5.3 [Hoist Allocations Out of the FOV Scan Loop](references/mem-no-hot-loop-closures.md) — MEDIUM (eliminates per-cell allocation)
   - 5.4 [Pack the Explored Layer Into Bits for Memory and Saves](references/mem-bitpack-explored.md) — MEDIUM (reduces explored memory 8x)
   - 5.5 [Use a Generation Stamp to Skip the Per-Frame Clear](references/mem-generation-stamp.md) — MEDIUM (O(n) clear to O(1))
6. [Multi-Viewer & Map Scaling](references/_sections.md#6-multi-viewer-&-map-scaling) — **MEDIUM**
   - 6.1 [Cap FOV Recomputes Per Frame With a Time Budget](references/scale-cap-recompute-budget.md) — MEDIUM (maintains a fixed frame budget)
   - 6.2 [Chunk Large Maps and Keep Only Active Chunks Resident](references/scale-chunk-large-maps.md) — MEDIUM (reduces resident memory to active chunks)
   - 6.3 [Find Edit-Affected Viewers With a Spatial Index](references/scale-spatial-partition-edits.md) — MEDIUM (O(viewers) to O(nearby viewers))
   - 6.4 [Separate Gameplay Visibility From On-Screen Render Culling](references/scale-gameplay-vs-render-culling.md) — MEDIUM (prevents culling gameplay state)
   - 6.5 [Share One Refcounted Visibility Buffer Per Team](references/scale-shared-team-visibility.md) — MEDIUM (O(units) to O(1) per tile query)
7. [Geometry & Hot-Loop Math](references/_sections.md#7-geometry-&-hot-loop-math) — **MEDIUM**
   - 7.1 [Choose the Radius Metric for the Shape You Want](references/geo-radius-shape-choice.md) — MEDIUM (reduces radius test to an integer compare)
   - 7.2 [Compare Squared Distances to Avoid Per-Cell sqrt](references/geo-squared-distance.md) — MEDIUM (eliminates per-cell sqrt)
   - 7.3 [Precompute Directions Instead of Calling Trig Per Cell](references/geo-avoid-trig-in-loop.md) — MEDIUM (eliminates per-cell trig)
   - 7.4 [Track x and y Directly Instead of Modulo-Deindexing](references/geo-avoid-modulo-deindex.md) — MEDIUM (eliminates per-cell modulo)
   - 7.5 [Use Rational Slopes to Avoid Floating-Point Drift](references/geo-integer-slope-shadows.md) — MEDIUM (prevents float-drift artifacts)
8. [Correctness & Visual Artifacts](references/_sections.md#8-correctness-&-visual-artifacts) — **LOW-MEDIUM**
   - 8.1 [Handle Diagonal Wall Corners Deliberately](references/correct-corner-peeking.md) — LOW-MEDIUM (prevents diagonal light leaks)
   - 8.2 [Light Wall Tiles Consistently to Avoid Flickering Faces](references/correct-symmetric-walls.md) — LOW-MEDIUM (prevents flickering wall faces)
   - 8.3 [Never Let the Visible Pass Overwrite the Explored Layer](references/correct-explored-not-overwritten.md) — LOW-MEDIUM (preserves remembered tiles)
   - 8.4 [Pick One Permissiveness Model and Apply It Everywhere](references/correct-permissiveness-model.md) — LOW-MEDIUM (prevents inconsistent visibility)

---

## References

1. [https://www.albertford.com/shadowcasting/](https://www.albertford.com/shadowcasting/)
2. [https://www.roguebasin.com/index.php/FOV_using_recursive_shadowcasting](https://www.roguebasin.com/index.php/FOV_using_recursive_shadowcasting)
3. [http://www.adammil.net/blog/v125_Roguelike_Vision_Algorithms.html](http://www.adammil.net/blog/v125_Roguelike_Vision_Algorithms.html)
4. [https://www.redblobgames.com/articles/visibility/](https://www.redblobgames.com/articles/visibility/)
5. [https://www.redblobgames.com/grids/line-drawing/](https://www.redblobgames.com/grids/line-drawing/)
6. [https://ondras.github.io/rot.js/manual/#fov](https://ondras.github.io/rot.js/manual/#fov)
7. [https://developer.mozilla.org/en-US/docs/Web/API/OffscreenCanvas](https://developer.mozilla.org/en-US/docs/Web/API/OffscreenCanvas)
8. [https://webgl2fundamentals.org/webgl/lessons/webgl-data-textures.html](https://webgl2fundamentals.org/webgl/lessons/webgl-data-textures.html)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |