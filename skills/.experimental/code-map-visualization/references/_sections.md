# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Visual Encoding & Perceptual Channels (encode)

**Impact:** CRITICAL  
**Description:** Which visual channel carries which code attribute is the decision every later pixel inherits — get the channel ranking wrong (quantity on hue, magnitude on area, position spent on a force layout instead of the projection) and the map misleads no matter how beautifully it renders. This is the foundation: a perceptually wrong encoding cannot be fixed by faster GPU code or nicer animation.

## 2. Color & Perceptual Color Scales (color)

**Impact:** CRITICAL  
**Description:** Color is the channel most often used and most often abused. A rainbow/jet ramp invents boundaries that aren't in the data, a sequential ramp used for diverging data hides the zero crossing, and color-only encoding vanishes for the ~8% of users with color-vision deficiency. The ramp is chosen once and recolours every cell on every frame, so a wrong scale is a global, permanent lie.

## 3. GPU Render Pipeline — Canvas2D + WebGL (gpu)

**Impact:** HIGH  
**Description:** A code map is tens of thousands to millions of cells; the only way to draw that at interactive rates is to push geometry to the GPU in large instanced batches and reserve Canvas2D for the crisp overlay layer. Per-cell draw calls, per-frame object allocation, and redundant state changes are what turn a correct visualization into an unusable slideshow.

## 4. Render Performance & Frame Budget (perf)

**Impact:** HIGH  
**Description:** Interactivity lives or dies inside a 16 ms frame. Recomputing the covering set on every mousemove, redrawing static layers each frame, doing layout on the main thread, or letting tile caches grow unbounded all blow the budget and produce jank, dropped input, and eventual out-of-memory crashes during a long panning session.

## 5. Labels & Text Rendering (text)

**Impact:** MEDIUM-HIGH  
**Description:** Text is the most expensive layer to draw and the hardest to place — labels collide, overflow their cells, and pile up illegibly when every region wants a name at once. Level-of-detail label selection, greedy collision declutter, and legible glyph rendering are what make a code map readable rather than a wall of overlapping text.

## 6. Interaction, Picking & Camera (interact)

**Impact:** MEDIUM-HIGH  
**Description:** A map you cannot hover, select, deep-link, or drive from the keyboard is just a picture. Hit-testing by looping over every cell, coupling the camera to DOM scroll, and losing view state on reload are the mistakes that make interaction laggy or impossible; GPU/ spatial-index picking and a single camera view-state model fix them.

## 7. Animation & Transitions (anim)

**Impact:** MEDIUM  
**Description:** Motion either aids comprehension or destroys it. Jumping the camera instead of easing it, popping between level-of-detail tiers, and re-keying objects on every data update break the viewer's sense of where things are. Smooth, interruptible, object-constant transitions preserve the mental map; gratuitous animation just burns frames.

## 8. Accessibility & Inclusive Rendering (access)

**Impact:** MEDIUM  
**Description:** A canvas is opaque to assistive technology and indifferent to motion sensitivity and color vision by default. Redundant (non-color) encoding, honouring prefers-reduced-motion, full keyboard operability, and a real text alternative for the canvas are what make the map usable by everyone — and they are cheap to add up front, expensive to retrofit.

## 9. Nature- & Cell-Inspired Layout & Rendering (bio)

**Impact:** MEDIUM  
**Description:** A situational toolbox of algorithms from biology and nature for rendering the map organically — Voronoi tessellation (how living cells partition space), centroidal weight relaxation, circle packing, golden-angle phyllotaxis, metaball membranes, hierarchical edge bundling, and flow-field animation. Lower, optional cascade impact — rectangles and dots also work — but decisive when you want a gapless, cell-like map whose regions, fills, and dependency overlays read as living structure rather than scattered marks. Two of these (Voronoi treemaps, edge bundling) were invented for software visualisation.
