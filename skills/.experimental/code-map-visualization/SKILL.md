---
name: code-map-visualization
description: Use this skill whenever rendering, styling, or making interactive a visualisation of a codebase projected as a geohash map — choosing what to encode on colour/size/position, picking perceptually honest colour scales (viridis/OKLCH, not rainbow), drawing tens of thousands of cells on Canvas2D + WebGL/deck.gl inside a 16ms frame budget, placing and decluttering labels, GPU or spatial-index picking, camera animation and level-of-detail crossfades, and keyboard plus screen-reader accessibility for the canvas. Trigger even when the user does not say "visualisation" — if the work involves drawing, colouring, labelling, animating, or making navigable a code map, spatial heatmap, or large cell/point layer on the web, this is the skill. It is the rendering and perception layer on top of geohash-spatial-code-maps, which owns the geohash encoding, projection, tiling, and navigation math. Also covers nature-inspired rendering — Voronoi, circle packing, phyllotaxis, metaball hulls, edge bundling.
metadata:
  internal: true
---
# Code Map Visualization Best Practices

How to render and visually navigate a codebase that has been projected and geohashed into a 2D map — making it honest, fast, legible, interactive, animated, and accessible. This is the rendering and perception craft on top of the spatial structure: it draws on decades of information-visualisation, cartography, computer-graphics, and nature-/biology-inspired layout knowledge so a code map reads correctly and runs at interactive rates. Contains 47 rules across 9 categories, prioritised by impact.

## When to Apply

Reference these guidelines when:

- Deciding what code attribute to put on which visual channel (position, size, colour) and which colour scale tells the truth
- Drawing tens of thousands to millions of cells on the web with Canvas2D, WebGL, or deck.gl, and keeping the render loop inside the frame budget
- Placing and decluttering region/file labels, and rendering legible text over a busy map
- Wiring up interaction — hover, picking, selection, a camera/view-state model, deep links, keyboard control
- Animating camera moves, level-of-detail transitions, and data updates without disorienting the viewer
- Making the canvas accessible to color-vision-deficient, motion-sensitive, keyboard-only, and screen-reader users

## A note on scope

This skill is the **rendering and perception layer**. The companion skill `geohash-spatial-code-maps` owns the **spatial math** — geohash encoding, the code→plane projection, bbox/covering-set queries, tiling, and the precision↔zoom navigation model. Rules here cross-link into that skill (e.g. [`map-deterministic-projection`](../geohash-spatial-code-maps/references/map-deterministic-projection.md), [`nav-level-of-detail-aggregation`](../geohash-spatial-code-maps/references/nav-level-of-detail-aggregation.md)) rather than re-deriving it. Examples target TypeScript with Canvas2D + WebGL/deck.gl and d3-scale/d3-color; the perceptual reasoning generalises to any rendering stack.

## Rule Categories by Priority

| Priority | Category | Impact | Prefix | Rules |
|----------|----------|--------|--------|-------|
| 1 | Visual Encoding & Perceptual Channels | CRITICAL | `encode-` | 6 |
| 2 | Color & Perceptual Color Scales | CRITICAL | `color-` | 5 |
| 3 | GPU Render Pipeline (Canvas2D + WebGL) | HIGH | `gpu-` | 6 |
| 4 | Render Performance & Frame Budget | HIGH | `perf-` | 5 |
| 5 | Labels & Text Rendering | MEDIUM-HIGH | `text-` | 5 |
| 6 | Interaction, Picking & Camera | MEDIUM-HIGH | `interact-` | 5 |
| 7 | Animation & Transitions | MEDIUM | `anim-` | 4 |
| 8 | Accessibility & Inclusive Rendering | MEDIUM | `access-` | 4 |
| 9 | Nature- & Cell-Inspired Layout & Rendering | MEDIUM | `bio-` | 7 |

## Quick Reference

### 1. Visual Encoding & Perceptual Channels (CRITICAL)

- [`encode-rank-channels-by-perceptual-accuracy`](references/encode-rank-channels-by-perceptual-accuracy.md) — Put the decision metric on position/length, not hue
- [`encode-let-projection-own-position`](references/encode-let-projection-own-position.md) — The geohash projection owns x/y; don't re-layout
- [`encode-size-by-area-not-radius`](references/encode-size-by-area-not-radius.md) — Map value to area; take the square root for radius
- [`encode-separate-categorical-from-quantitative`](references/encode-separate-categorical-from-quantitative.md) — Hue for category, ordered channels for magnitude
- [`encode-redundant-encoding-for-key-signals`](references/encode-redundant-encoding-for-key-signals.md) — Double-encode the few signals that must never be missed
- [`encode-maximize-data-ink-drop-chartjunk`](references/encode-maximize-data-ink-drop-chartjunk.md) — Strip shadows, bevels, heavy grids that fight the data

### 2. Color & Perceptual Color Scales (CRITICAL)

- [`color-perceptually-uniform-sequential-ramp`](references/color-perceptually-uniform-sequential-ramp.md) — Viridis/OKLCH, never rainbow/jet
- [`color-match-scale-type-to-data`](references/color-match-scale-type-to-data.md) — Sequential vs diverging vs categorical, matched to the data
- [`color-design-for-color-vision-deficiency`](references/color-design-for-color-vision-deficiency.md) — CVD-safe palettes, verified by simulation
- [`color-limit-categorical-hues`](references/color-limit-categorical-hues.md) — Cap at ~8–12 hues; bucket the long tail
- [`color-control-contrast-against-basemap`](references/color-control-contrast-against-basemap.md) — Keep cells legible on light or dark backgrounds

### 3. GPU Render Pipeline — Canvas2D + WebGL (HIGH)

- [`gpu-layer-canvas2d-over-webgl`](references/gpu-layer-canvas2d-over-webgl.md) — Bulk cells in GL, crisp labels/overlays in Canvas2D
- [`gpu-instance-cells-not-per-quad-draw`](references/gpu-instance-cells-not-per-quad-draw.md) — One instanced draw call, not one per cell
- [`gpu-batch-to-cut-draw-calls-and-state-changes`](references/gpu-batch-to-cut-draw-calls-and-state-changes.md) — Group by program/texture to avoid pipeline flushes
- [`gpu-pack-attributes-into-typed-arrays`](references/gpu-pack-attributes-into-typed-arrays.md) — A reusable Float32Array, zero per-frame allocation
- [`gpu-atlas-tiles-and-glyphs`](references/gpu-atlas-tiles-and-glyphs.md) — One atlas bound once, addressed by UV offset
- [`gpu-size-canvas-to-devicepixelratio`](references/gpu-size-canvas-to-devicepixelratio.md) — Size the backing store to DPR for crisp, non-overdrawn output

### 4. Render Performance & Frame Budget (HIGH)

- [`perf-render-in-a-single-raf-loop`](references/perf-render-in-a-single-raf-loop.md) — Coalesce input into one redraw per frame
- [`perf-redraw-only-dirty-regions`](references/perf-redraw-only-dirty-regions.md) — Repaint the overlay, not the static cell layer
- [`perf-debounce-viewport-recompute`](references/perf-debounce-viewport-recompute.md) — Throttle the covering-set recompute; draw every frame
- [`perf-offload-to-worker-and-offscreencanvas`](references/perf-offload-to-worker-and-offscreencanvas.md) — Heavy projection/packing off the main thread
- [`perf-bound-the-tile-cache`](references/perf-bound-the-tile-cache.md) — LRU-cap the tile cache; free GPU buffers on eviction

### 5. Labels & Text Rendering (MEDIUM-HIGH)

- [`text-place-and-declutter-labels-greedily`](references/text-place-and-declutter-labels-greedily.md) — Greedy collision placement by priority
- [`text-show-labels-by-level-of-detail`](references/text-show-labels-by-level-of-detail.md) — Domain labels low-zoom, file labels only when big
- [`text-render-glyphs-on-canvas2d-not-per-glyph-textures`](references/text-render-glyphs-on-canvas2d-not-per-glyph-textures.md) — Native fillText, not GL glyph uploads
- [`text-add-halo-for-legibility`](references/text-add-halo-for-legibility.md) — A halo keeps labels readable over any fill
- [`text-anchor-region-labels-at-centroid`](references/text-anchor-region-labels-at-centroid.md) — Pole of inaccessibility, not the bbox centre

### 6. Interaction, Picking & Camera (MEDIUM-HIGH)

- [`interact-pick-with-gpu-color-id-or-spatial-index`](references/interact-pick-with-gpu-color-id-or-spatial-index.md) — O(1)/O(log n) picking, not a linear scan
- [`interact-keep-hover-feedback-under-one-frame`](references/interact-keep-hover-feedback-under-one-frame.md) — Instant overlay highlight, async details
- [`interact-model-the-camera-not-the-dom`](references/interact-model-the-camera-not-the-dom.md) — One view-state object as the source of truth
- [`interact-sync-view-state-to-the-url`](references/interact-sync-view-state-to-the-url.md) — Deep-linkable, shareable views
- [`interact-support-keyboard-pan-zoom-and-focus`](references/interact-support-keyboard-pan-zoom-and-focus.md) — Arrow and +/- keys drive the camera

### 7. Animation & Transitions (MEDIUM)

- [`anim-ease-camera-transitions-not-jumps`](references/anim-ease-camera-transitions-not-jumps.md) — Ease centre and zoom so the eye can follow
- [`anim-crossfade-between-lod-levels`](references/anim-crossfade-between-lod-levels.md) — Dissolve aggregates into points, don't pop
- [`anim-preserve-object-constancy-on-data-update`](references/anim-preserve-object-constancy-on-data-update.md) — Key by geohash; animate only real changes
- [`anim-keep-transitions-interruptible-and-budgeted`](references/anim-keep-transitions-interruptible-and-budgeted.md) — Cancel and retarget in-flight tweens

### 8. Accessibility & Inclusive Rendering (MEDIUM)

- [`access-encode-redundantly-never-color-alone`](references/access-encode-redundantly-never-color-alone.md) — Pair colour with shape or label (WCAG 1.4.1)
- [`access-honor-prefers-reduced-motion`](references/access-honor-prefers-reduced-motion.md) — Collapse animation for motion-sensitive users
- [`access-make-the-map-keyboard-operable`](references/access-make-the-map-keyboard-operable.md) — Focusable, focus-visible, no keyboard trap
- [`access-provide-a-text-alternative-for-the-canvas`](references/access-provide-a-text-alternative-for-the-canvas.md) — A synced DOM/ARIA outline for screen readers

### 9. Nature- & Cell-Inspired Layout & Rendering (MEDIUM)

A situational toolbox for rendering the map organically; two of these were invented for software visualisation.

- [`bio-voronoi-regions-for-space-filling-tessellation`](references/bio-voronoi-regions-for-space-filling-tessellation.md) — Gapless Voronoi cells seeded by projected points
- [`bio-relax-weights-for-even-cell-areas`](references/bio-relax-weights-for-even-cell-areas.md) — Lloyd/CVT on weights; keep seed positions fixed
- [`bio-circle-packing-for-nested-counts`](references/bio-circle-packing-for-nested-counts.md) — Packed circles for hierarchy and counts
- [`bio-phyllotaxis-packing-for-even-point-spread`](references/bio-phyllotaxis-packing-for-even-point-spread.md) — Golden-angle spiral for dense, even fills
- [`bio-metaball-hulls-for-region-membranes`](references/bio-metaball-hulls-for-region-membranes.md) — Marching-squares organic region outlines
- [`bio-edge-bundling-for-dependency-overlays`](references/bio-edge-bundling-for-dependency-overlays.md) — Holten bundling vs a straight-line hairball
- [`bio-flow-fields-for-animated-dependency-load`](references/bio-flow-fields-for-animated-dependency-load.md) — Physarum/boids flow when motion encodes load

## How to Use

Read individual reference files for detailed explanations, code examples, and "when NOT to apply" guidance:

- [Section definitions](references/_sections.md) — Category structure and impact levels
- [Rule template](assets/templates/_template.md) — Template for adding new rules

Rules cross-link via `[[other-rule-slug]]`; follow them when a related pattern is referenced. Cross-links to `enc-`, `prec-`, `dec-`, `qry-`, `nbr-`, `idx-`, `map-`, and `nav-` rules point into the companion `geohash-spatial-code-maps` skill — read them there for the spatial math.

To build a renderer end to end, the spine is: decide the encoding (category 1) → choose colour (category 2) → stand up the GPU pipeline (category 3) → hold the frame budget (category 4) → add labels, interaction, animation, and accessibility (categories 5–8); reach for organic, cell-based rendering — Voronoi regions, packing, membranes, edge bundling — when it suits the map (category 9). The upstream projection and tiling come from `geohash-spatial-code-maps`.

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
| [metadata.json](metadata.json) | Version and reference information |
| [AGENTS.md](AGENTS.md) | Auto-built TOC navigation |

## Related Skills

- `geohash-spatial-code-maps` — The spatial layer this renders: geohash encoding, the code→plane projection, tiling, and the precision↔zoom navigation model
- `computer-science-algorithms` — The spatial-index, sorting, and complexity primitives behind fast picking, declutter, and the render loop
