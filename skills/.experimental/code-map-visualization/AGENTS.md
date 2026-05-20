# Code-as-Geohash-Map Rendering (TypeScript, Canvas2D + WebGL/deck.gl)

**Version 0.1.0**  
Code Map Visualization  
May 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Rendering and perception guide for visualising a codebase that has been projected and geohashed into a navigable 2D map. Contains 47 rules across 9 categories, prioritised by impact from critical (visual-channel encoding and perceptually honest colour scales) through the GPU render pipeline and frame-budget performance, down to label placement, interaction and picking, camera animation, accessibility, and a situational toolbox of nature- and cell-inspired layout (Voronoi tessellation, centroidal relaxation, circle packing, golden-angle phyllotaxis, metaball membranes, hierarchical edge bundling, flow-field animation). Each rule explains why it matters and shows production-realistic incorrect vs. correct TypeScript examples (Canvas2D + WebGL/deck.gl, d3-scale/d3-color), with explicit when-NOT-to-apply guidance. It draws on established visualisation and rendering knowledge — graphical-perception research (Cleveland & McGill, Bertin, Munzner, Tufte), perceptual colour science (viridis, ColorBrewer, OKLCH, the rainbow-considered-harmful literature), cartographic label placement, the WebGL/Canvas rendering pipeline, biologically-inspired layout (Voronoi treemaps and edge bundling, both invented for software visualisation), and WCAG — and is the rendering layer on top of the geohash-spatial-code-maps skill, which owns the geohash encoding, projection, tiling, and navigation math.

---

## Table of Contents

1. [Visual Encoding & Perceptual Channels](references/_sections.md#1-visual-encoding-&-perceptual-channels) — **CRITICAL**
   - 1.1 [Encode Category and Magnitude on Different Channel Types](references/encode-separate-categorical-from-quantitative.md) — CRITICAL (prevents false ordering of nominal domains)
   - 1.2 [Encode Critical Signals Redundantly Across Channels](references/encode-redundant-encoding-for-key-signals.md) — HIGH (prevents total signal loss under CVD or greyscale)
   - 1.3 [Let the Projection Own the Position Channel](references/encode-let-projection-own-position.md) — CRITICAL (prevents erasing coupling-as-proximity)
   - 1.4 [Maximize Data-Ink and Drop Chartjunk](references/encode-maximize-data-ink-drop-chartjunk.md) — HIGH (reduces non-data pixels competing with the map)
   - 1.5 [Rank Visual Channels by Perceptual Accuracy](references/encode-rank-channels-by-perceptual-accuracy.md) — CRITICAL (prevents systematic misreading of the primary metric)
   - 1.6 [Scale Symbol Size by Area, Not Radius](references/encode-size-by-area-not-radius.md) — CRITICAL (prevents up to 4x magnitude exaggeration)
2. [Color & Perceptual Color Scales](references/_sections.md#2-color-&-perceptual-color-scales) — **CRITICAL**
   - 2.1 [Control Cell Contrast Against the Basemap](references/color-control-contrast-against-basemap.md) — HIGH (prevents cells washing out against the background)
   - 2.2 [Design Color Choices for Color-Vision Deficiency](references/color-design-for-color-vision-deficiency.md) — CRITICAL (prevents red/green confusion for ~8% of male users)
   - 2.3 [Limit Categorical Hues to What the Eye Can Separate](references/color-limit-categorical-hues.md) — HIGH (prevents indistinguishable domains past ~8-12 hues)
   - 2.4 [Match the Color Scale Type to the Data's Shape](references/color-match-scale-type-to-data.md) — CRITICAL (prevents hiding the zero crossing in diverging data)
   - 2.5 [Use a Perceptually Uniform Sequential Ramp, Not Rainbow](references/color-perceptually-uniform-sequential-ramp.md) — CRITICAL (prevents false boundaries the data does not contain)
3. [GPU Render Pipeline — Canvas2D + WebGL](references/_sections.md#3-gpu-render-pipeline-—-canvas2d-+-webgl) — **HIGH**
   - 3.1 [Batch by State to Cut Draw Calls and GPU State Changes](references/gpu-batch-to-cut-draw-calls-and-state-changes.md) — HIGH (prevents a pipeline flush per domain group)
   - 3.2 [Draw Cells with Instanced Rendering, Not One Draw Call Each](references/gpu-instance-cells-not-per-quad-draw.md) — HIGH (O(n) draw calls to O(1); 10-100x more marks)
   - 3.3 [Layer Canvas2D Over WebGL for Crisp Overlays](references/gpu-layer-canvas2d-over-webgl.md) — HIGH (prevents blurry text and per-frame GPU label cost)
   - 3.4 [Pack Per-Cell Attributes into Typed Arrays](references/gpu-pack-attributes-into-typed-arrays.md) — HIGH (prevents per-frame GC pauses from object churn)
   - 3.5 [Pack Tiles and Glyphs into a Texture Atlas](references/gpu-atlas-tiles-and-glyphs.md) — HIGH (prevents a texture rebind per tile or glyph)
   - 3.6 [Size the Canvas to devicePixelRatio](references/gpu-size-canvas-to-devicepixelratio.md) — HIGH (prevents blurry output or 4x overdraw on HiDPI)
4. [Render Performance & Frame Budget](references/_sections.md#4-render-performance-&-frame-budget) — **HIGH**
   - 4.1 [Bound the Tile and Geometry Cache](references/perf-bound-the-tile-cache.md) — HIGH (prevents unbounded memory growth over a long session)
   - 4.2 [Debounce Viewport-to-Cell Recomputation](references/perf-debounce-viewport-recompute.md) — HIGH (prevents recomputing the covering set per mouse move)
   - 4.3 [Offload Layout and Heavy Draw to a Worker](references/perf-offload-to-worker-and-offscreencanvas.md) — HIGH (prevents main-thread freezes beyond the 16ms budget)
   - 4.4 [Redraw Only Dirty Layers and Regions](references/perf-redraw-only-dirty-regions.md) — HIGH (prevents repainting static layers every frame)
   - 4.5 [Render in a Single requestAnimationFrame Loop](references/perf-render-in-a-single-raf-loop.md) — HIGH (reduces redraws to one per frame)
5. [Labels & Text Rendering](references/_sections.md#5-labels-&-text-rendering) — **MEDIUM-HIGH**
   - 5.1 [Add a Halo So Labels Stay Legible Over Busy Fills](references/text-add-halo-for-legibility.md) — MEDIUM (prevents text disappearing into varied cell colours)
   - 5.2 [Anchor Region Labels at the Visual Centroid](references/text-anchor-region-labels-at-centroid.md) — MEDIUM (prevents labels drifting outside their region)
   - 5.3 [Place and Declutter Labels Greedily by Priority](references/text-place-and-declutter-labels-greedily.md) — MEDIUM-HIGH (prevents overlapping, unreadable label pileups)
   - 5.4 [Render Label Text on Canvas2D, Not Per-Glyph GL Textures](references/text-render-glyphs-on-canvas2d-not-per-glyph-textures.md) — MEDIUM-HIGH (prevents per-glyph texture uploads and blur)
   - 5.5 [Reveal Labels by Level of Detail](references/text-show-labels-by-level-of-detail.md) — MEDIUM-HIGH (prevents leaf labels flooding a zoomed-out view)
6. [Interaction, Picking & Camera](references/_sections.md#6-interaction,-picking-&-camera) — **MEDIUM-HIGH**
   - 6.1 [Drive the Camera and Selection from the Keyboard](references/interact-support-keyboard-pan-zoom-and-focus.md) — MEDIUM (prevents a pointer-only, unnavigable map)
   - 6.2 [Keep Hover Feedback Under One Frame](references/interact-keep-hover-feedback-under-one-frame.md) — MEDIUM (prevents hover lag behind the cursor)
   - 6.3 [Model the Camera as View-State, Not DOM Scroll](references/interact-model-the-camera-not-the-dom.md) — MEDIUM-HIGH (prevents drift between zoom, data, and URL)
   - 6.4 [Pick With a GPU Color ID or Spatial Index, Not a Linear Scan](references/interact-pick-with-gpu-color-id-or-spatial-index.md) — MEDIUM-HIGH (O(n) hit-test to O(1) or O(log n))
   - 6.5 [Sync View-State to the URL for Deep Links](references/interact-sync-view-state-to-the-url.md) — MEDIUM (prevents losing the view on reload or share)
7. [Animation & Transitions](references/_sections.md#7-animation-&-transitions) — **MEDIUM**
   - 7.1 [Crossfade Between Level-of-Detail Tiers](references/anim-crossfade-between-lod-levels.md) — MEDIUM (prevents jarring pops when buckets split or merge)
   - 7.2 [Ease Camera Transitions Instead of Jumping](references/anim-ease-camera-transitions-not-jumps.md) — MEDIUM (prevents loss of spatial context on view changes)
   - 7.3 [Keep Transitions Interruptible and Budgeted](references/anim-keep-transitions-interruptible-and-budgeted.md) — MEDIUM (prevents queued animations from lagging input)
   - 7.4 [Preserve Object Constancy on Data Updates](references/anim-preserve-object-constancy-on-data-update.md) — MEDIUM (prevents cells teleporting when data refreshes)
8. [Accessibility & Inclusive Rendering](references/_sections.md#8-accessibility-&-inclusive-rendering) — **MEDIUM**
   - 8.1 [Honor prefers-reduced-motion](references/access-honor-prefers-reduced-motion.md) — MEDIUM (prevents motion sickness from camera animation)
   - 8.2 [Make Every Map Action Keyboard-Operable](references/access-make-the-map-keyboard-operable.md) — MEDIUM (prevents locking out non-pointer users)
   - 8.3 [Never Let Color Be the Only Encoding](references/access-encode-redundantly-never-color-alone.md) — MEDIUM (prevents state being lost without colour)
   - 8.4 [Provide a Text Alternative for the Canvas](references/access-provide-a-text-alternative-for-the-canvas.md) — MEDIUM (prevents the map being invisible to screen readers)
9. [Nature- & Cell-Inspired Layout & Rendering](references/_sections.md#9-nature--&-cell-inspired-layout-&-rendering) — **MEDIUM**
   - 9.1 [Animate Dependency Load with a Bio-Inspired Flow Field](references/bio-flow-fields-for-animated-dependency-load.md) — MEDIUM (prevents static edges hiding direction and volume)
   - 9.2 [Bundle Dependency Edges Along the Hierarchy](references/bio-edge-bundling-for-dependency-overlays.md) — MEDIUM (prevents a straight-line dependency hairball)
   - 9.3 [Outline Regions with Metaball Hulls via Marching Squares](references/bio-metaball-hulls-for-region-membranes.md) — MEDIUM (prevents jagged or ambiguous region outlines)
   - 9.4 [Pack Files as Nested Circles to Show Hierarchy and Counts](references/bio-circle-packing-for-nested-counts.md) — MEDIUM (prevents losing hierarchy in a flat scatter)
   - 9.5 [Relax Voronoi Weights for Even Cell Areas, Not Seed Positions](references/bio-relax-weights-for-even-cell-areas.md) — MEDIUM (prevents unreadable slivers and oversized cells)
   - 9.6 [Spread Dense Points with a Golden-Angle Phyllotaxis Spiral](references/bio-phyllotaxis-packing-for-even-point-spread.md) — MEDIUM (prevents clumping and grid moiré in dense fills)
   - 9.7 [Tessellate Regions with a Voronoi Diagram, Not Scattered Marks](references/bio-voronoi-regions-for-space-filling-tessellation.md) — MEDIUM (prevents gaps and ambiguous region boundaries)

---

## References

1. [https://www.cs.ubc.ca/~tmm/vadbook/](https://www.cs.ubc.ca/~tmm/vadbook/)
2. [https://www.jstor.org/stable/2288400](https://www.jstor.org/stable/2288400)
3. [https://doi.org/10.1109/MCG.2007.323435](https://doi.org/10.1109/MCG.2007.323435)
4. [https://bids.github.io/colormap/](https://bids.github.io/colormap/)
5. [https://colorbrewer2.org/](https://colorbrewer2.org/)
6. [https://www.w3.org/TR/css-color-4/](https://www.w3.org/TR/css-color-4/)
7. [https://jfly.uni-koeln.de/color/](https://jfly.uni-koeln.de/color/)
8. [https://d3js.org/](https://d3js.org/)
9. [https://deck.gl/](https://deck.gl/)
10. [https://developer.mozilla.org/en-US/docs/Web/API/WebGL_API/WebGL_best_practices](https://developer.mozilla.org/en-US/docs/Web/API/WebGL_API/WebGL_best_practices)
11. [https://developer.mozilla.org/en-US/docs/Web/API/Canvas_API/Tutorial/Optimizing_canvas](https://developer.mozilla.org/en-US/docs/Web/API/Canvas_API/Tutorial/Optimizing_canvas)
12. [https://vanwijk.win.tue.nl/zoompan.pdf](https://vanwijk.win.tue.nl/zoompan.pdf)
13. [https://maplibre.org/](https://maplibre.org/)
14. [https://www.w3.org/WAI/WCAG22/](https://www.w3.org/WAI/WCAG22/)
15. [https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames](https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames)
16. [https://wettel.github.io/codecity.html](https://wettel.github.io/codecity.html)
17. [https://graphics.uni-konstanz.de/publikationen/Balzer2005VoronoiTreemapsVisualization/index.html](https://graphics.uni-konstanz.de/publikationen/Balzer2005VoronoiTreemapsVisualization/index.html)
18. [https://github.com/d3/d3-delaunay](https://github.com/d3/d3-delaunay)
19. [https://d3js.org/d3-hierarchy/pack](https://d3js.org/d3-hierarchy/pack)
20. [https://github.com/d3/d3-contour](https://github.com/d3/d3-contour)
21. [https://www.cs.jhu.edu/~misha/ReadingSeminar/Papers/Holten06.pdf](https://www.cs.jhu.edu/~misha/ReadingSeminar/Papers/Holten06.pdf)
22. [https://www.red3d.com/cwr/boids/](https://www.red3d.com/cwr/boids/)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |