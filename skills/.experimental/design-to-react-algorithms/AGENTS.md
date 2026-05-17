# Design-to-React Conversion

**Version 0.1.0**  
dot-skills  
May 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Mathematical and computer-science algorithms for converting Sketch files into pixel-perfect React + CSS code. 46 rules across 8 categories ordered by cascade impact: from the iteration strategy and regression-gate mental model, through tree reconstruction, layout inference (flex/grid/freeform), geometry, visual-regression diffing (SSIM, pHash, pixelmatch), to style/typography/path translation. The skill is designed for AI agents building or improving design-to-code pipelines and emphasizes regression-safe incremental improvement.

---

## Table of Contents

1. [Reverse-Engineering Iteration Strategy](references/_sections.md#1-reverse-engineering-iteration-strategy) — **CRITICAL**
   - 1.1 [Convert One Component Family Per Iteration](references/iter-one-family-per-pr.md) — HIGH (shrinks regression blame radius from O(n) families to 1; keeps PR diffs reviewable)
   - 1.2 [Convert Symbol Masters Before Any Instance References Them](references/iter-convert-symbols-before-instances.md) — CRITICAL (prevents N copies of the same component diverging across the codebase)
   - 1.3 [Convert Top-Down, Bisect Bottom-Up](references/iter-bisect-from-root.md) — CRITICAL (localizes regressions in O(log n) instead of O(n) subtree walks)
   - 1.4 [Extract Design Tokens Before Any Component Conversion](references/iter-freeze-design-tokens-first.md) — CRITICAL (prevents 200+ hardcoded color literals scattered across components)
   - 1.5 [Gate Every Improvement Behind a Baseline Snapshot](references/iter-baseline-snapshot-gate.md) — CRITICAL (prevents silent regressions across the entire previously-converted surface)
   - 1.6 [Maintain a Known-Good Baseline Branch](references/iter-keep-known-good-branch.md) — HIGH (enables instant rollback in 1 command vs hand-reconstructing the last-known-good state; cuts triage time by ~10x)
2. [Tree Reconstruction & Symbol Resolution](references/_sections.md#2-tree-reconstruction-&-symbol-resolution) — **CRITICAL**
   - 2.1 [Collapse Pass-Through Groups Before Emit](references/tree-collapse-passthrough-groups.md) — CRITICAL (removes 30-60% of emitted <div> wrappers; restores meaningful nesting depth)
   - 2.2 [Hash Subtrees to Detect Componentization Opportunities](references/tree-hash-subtrees-for-componentization.md) — HIGH (identifies repeated structure missed by symbol authors (typically 20-40% extra components))
   - 2.3 [Hoist Shared Styles by Subtree Equivalence, Not Property Equality](references/tree-hoist-shared-style-via-subtree-equivalence.md) — HIGH (produces 3-10x fewer CSS classes; survives single-property design tweaks)
   - 2.4 [Map foreignSymbols to Shared Library Imports, Not Duplicates](references/tree-foreign-symbols-become-library-imports.md) — HIGH (prevents the same external symbol being re-emitted in every consuming file (10-100x duplication))
   - 2.5 [Resolve symbolInstance Overrides Against the Master Before Emit](references/tree-resolve-overrides-before-emit.md) — CRITICAL (prevents instance/master divergence; reduces emitted JSX by 5-50x for repeated symbols)
   - 2.6 [Treat hasClippingMask as a New Stacking Context](references/tree-clipping-mask-is-stacking-context.md) — CRITICAL (prevents overflow bugs and broken z-index ordering in clipped regions)
3. [Layout Algorithms (Flex / Freeform Inference)](references/_sections.md#3-layout-algorithms-(flex-/-freeform-inference)) — **CRITICAL**
   - 3.1 [Detect CSS Grid via 2D Coordinate Clustering with Epsilon Tolerance](references/layout-detect-grid-via-2d-coordinate-clustering.md) — HIGH (emits grid for true MxN layouts; avoids 2-level nested flex with synthetic wrappers (which break source-to-DOM mapping))
   - 3.2 [Extract Parent Padding from Frame Insets, Not Child Margin](references/layout-reverse-engineer-padding-not-margin.md) — CRITICAL (prevents 100% of margin-collapse bugs and :first/:last-child fragility under conditional render)
   - 3.3 [Infer Flex from 1D Axis-Projection Overlap of Sibling Bounding Boxes](references/layout-infer-flex-from-axis-projection-overlap.md) — CRITICAL (replaces absolute positioning for 60-90% of freeform groups (huge maintainability win))
   - 3.4 [Map ignoreLayout to position: absolute as a Flex Escape Hatch](references/layout-ignore-layout-is-absolute-escape.md) — CRITICAL (prevents 100% of badge/overlay misplacement when designer marks a child as out-of-flow)
   - 3.5 [Map MSImmutableFlexGroupLayout Enums Directly to CSS Flexbox](references/layout-flex-group-enum-mapping.md) — CRITICAL (prevents 100% of layout-intent loss for auto-layout groups; eliminates re-inference work)
   - 3.6 [Preserve `wrappingEnabled` as `flex-wrap`, Not a Width Hack](references/layout-preserve-wrapping-enabled.md) — HIGH (preserves responsive intent at non-design widths; eliminates fixed-width breakpoints on row containers)
   - 3.7 [Promote Freeform to Flex with `gap` When Sibling Gaps Are Equal Within Tolerance](references/layout-promote-freeform-when-equal-gaps.md) — HIGH (replaces N-1 hard-coded margins with one `gap` value; O(N) → O(1) maintenance cost)
4. [Coordinate & Geometry Math](references/_sections.md#4-coordinate-&-geometry-math) — **HIGH**
   - 4.1 [Carry Floats Through the Pipeline, Round Only at the Leaf](references/geom-round-only-at-leaves.md) — HIGH (prevents 1-5px cumulative drift in 10-level nested trees)
   - 4.2 [Compose Parent Transforms Before Emitting Coordinates](references/geom-compose-parent-transforms-before-emit.md) — HIGH (prevents 10-1000px positioning errors when children sit inside rotated/scaled parents)
   - 4.3 [Compute shapeGroup Bounds as the Union of Children, Not Sum or First-Child](references/geom-shape-group-bounds-via-union.md) — HIGH (prevents 5-50% width/height truncation or inflation on compound shapes)
   - 4.4 [Emit Rotation as CSS transform, Not a Pre-Rotated Bounding Box](references/geom-rotation-is-css-transform.md) — HIGH (prevents 5-30% width/height inflation on rotated layers; keeps text legible)
   - 4.5 [Intersect Nested Clipping Regions, Don't Union or Replace](references/geom-clipping-bounds-intersect-not-union.md) — HIGH (prevents content escaping nested clips; matches Sketch's clip-stacking semantics)
5. [Visual Regression & Diff Algorithms](references/_sections.md#5-visual-regression-&-diff-algorithms) — **HIGH**
   - 5.1 [Bisect via Subtree Disable to Localize Snapshot Regressions](references/diff-subtree-bisection-to-localize-regression.md) — HIGH (localizes regression cause in O(log n) renders vs O(n) manual inspection)
   - 5.2 [Budget Diff Tolerances Per Region Type (Text vs Gradient vs Image)](references/diff-region-budgeted-tolerances.md) — HIGH (cuts false-positive snapshot failures by 70%+ vs a global threshold)
   - 5.3 [Snapshot Per Component, Not Per Page](references/diff-baseline-per-component-not-per-page.md) — HIGH (localizes regression scope by 10-50x; enables parallel re-baselining)
   - 5.4 [Use Perceptual Hash to Distinguish "Wrong Component" from "Off by a Pixel"](references/diff-perceptual-hash-for-wrong-component-detection.md) — HIGH (routes 90%+ of regressions to the correct triage path (component vs layout bug))
   - 5.5 [Use Pixelmatch with includeAA=false at Threshold 0.1 for Icon Diff](references/diff-antialias-aware-pixelmatch-threshold.md) — HIGH (catches single-pixel icon defects with ~0% false positive rate from AA jitter)
   - 5.6 [Use SSIM for Antialiased Content, Not Raw Pixel Diff](references/diff-use-ssim-for-aa-content.md) — HIGH (reduces false-positive snapshot failures by 90%+ on text-heavy components)
6. [Style Translation (Color, Gradient, Shadow, Border)](references/_sections.md#6-style-translation-(color,-gradient,-shadow,-border)) — **MEDIUM-HIGH**
   - 6.1 [Convert Gradient Vectors to CSS Angles via atan2 with Axis Reframing](references/style-gradient-angle-via-atan2.md) — MEDIUM-HIGH (prevents 90° rotation errors and mirrored gradients (the #1 design-to-CSS gradient bug))
   - 6.2 [Convert Sketch sRGB Floats to Hex Without Linearizing](references/style-srgb-float-to-hex-via-gamma-correct-path.md) — MEDIUM-HIGH (prevents color shifts of 5-30 perceptual units when interpolating gradients)
   - 6.3 [Map MSImmutableStyleCorners to border-radius 4-Value Shorthand](references/style-per-corner-radii-shorthand.md) — MEDIUM-HIGH (emits 1 declaration instead of 4 separate corner properties; preserves designer per-corner intent)
   - 6.4 [Preserve Display P3 with color(display-p3 …), Don't Gamut-Clip to sRGB](references/style-preserve-display-p3.md) — MEDIUM-HIGH (prevents 5-15% saturation loss on wide-gamut displays for vivid accents)
   - 6.5 [Reconcile Border Position (Center/Inside/Outside) into Width Offsets](references/style-reconcile-border-position.md) — MEDIUM-HIGH (prevents 1-2px sibling overlap or gap from misinterpreted border position)
   - 6.6 [Reverse Multi-Shadow Order — Sketch Paints Last-First, CSS Paints First-Last](references/style-stack-multi-shadow-in-paint-order.md) — MEDIUM-HIGH (prevents 100% of multi-shadow z-order inversions (a frequent silent regression))
7. [Typography Math](references/_sections.md#7-typography-math) — **MEDIUM**
   - 7.1 [Apply paragraphSpacing Between Siblings, Never After the Last](references/type-paragraph-spacing-between-not-after.md) — MEDIUM (prevents 8-24px ghost space at the bottom of text blocks)
   - 7.2 [Build a Font Fallback Ladder from fontDescriptor.name to Web Stack](references/type-build-font-fallback-ladder.md) — MEDIUM (prevents fallback-font shifts (FOUT) and platform inconsistency on missing fonts)
   - 7.3 [Convert Sketch kerning (pt) to letter-spacing in em, Not px](references/type-kerning-pt-to-em-letter-spacing.md) — MEDIUM (prevents kerning drift at non-design font sizes; preserves typographic intent across breakpoints)
   - 7.4 [Convert Sketch lineHeight (pt) to CSS Unitless via lineHeight / fontSize](references/type-pt-lineheight-to-unitless.md) — MEDIUM (prevents 5-30% line-spacing drift when font-size scales (rem, em, parent-driven))
   - 7.5 [Split attributedString into Spans Only When Attributes Differ](references/type-split-attributed-string-runs-only-when-differ.md) — MEDIUM (reduces emitted text-span DOM nodes by 5-20x; preserves accessibility text nodes)
8. [Path & Shape Rendering](references/_sections.md#8-path-&-shape-rendering) — **MEDIUM**
   - 8.1 [Approximate Apple Smooth Corners with a Superellipse (n≈5), Not Circular Arcs](references/path-apple-smooth-corners-via-superellipse.md) — MEDIUM (prevents visibly "off" corners on Apple-styled UIs; matches iOS/macOS rendering)
   - 8.2 [Convert curvePoint Arrays to SVG Cubic Beziers (M then C per segment)](references/path-curve-point-to-svg-cubic-bezier.md) — MEDIUM (lossless path conversion; prevents kinked or smoothed-incorrectly curves)
   - 8.3 [Detect Rectangle + fixedRadius Early; Emit CSS Not SVG](references/path-rectangle-with-fixed-radius-is-css.md) — MEDIUM (replaces 6-12 line SVG paths with 2-line CSS for the most common shape (~40% of all layers))
   - 8.4 [Flatten Boolean Operations at Parse Time, Not Render Time](references/path-flatten-boolean-ops-at-parse-time.md) — MEDIUM (removes runtime path-boolean dependency; produces a single shippable SVG path per shapeGroup)
   - 8.5 [Honor windingRule When Mapping to SVG fill-rule](references/path-honor-winding-rule.md) — MEDIUM (prevents 100% mis-fill on shapes with holes (rings, hollow text, donut charts))

---

## References

1. [https://developer.sketch.com/file-format/](https://developer.sketch.com/file-format/)
2. [https://www.w3.org/TR/css-flexbox-1/](https://www.w3.org/TR/css-flexbox-1/)
3. [https://www.w3.org/TR/css-grid-1/](https://www.w3.org/TR/css-grid-1/)
4. [https://www.w3.org/TR/css-color-4/](https://www.w3.org/TR/css-color-4/)
5. [https://www.w3.org/TR/css-transforms-1/](https://www.w3.org/TR/css-transforms-1/)
6. [https://www.w3.org/TR/css-masking-1/](https://www.w3.org/TR/css-masking-1/)
7. [https://www.w3.org/TR/css-backgrounds-3/](https://www.w3.org/TR/css-backgrounds-3/)
8. [https://www.w3.org/TR/SVG2/paths.html](https://www.w3.org/TR/SVG2/paths.html)
9. [https://ece.uwaterloo.ca/~z70wang/publications/ssim.pdf](https://ece.uwaterloo.ca/~z70wang/publications/ssim.pdf)
10. [https://github.com/mapbox/pixelmatch](https://github.com/mapbox/pixelmatch)
11. [https://www.hackerfactor.com/blog/index.php?/archives/432-Looks-Like-It.html](https://www.hackerfactor.com/blog/index.php?/archives/432-Looks-Like-It.html)
12. [https://www.figma.com/blog/desperately-seeking-squircles/](https://www.figma.com/blog/desperately-seeking-squircles/)
13. [https://bottosson.github.io/posts/oklab/](https://bottosson.github.io/posts/oklab/)
14. [https://developer.apple.com/design/human-interface-guidelines/typography](https://developer.apple.com/design/human-interface-guidelines/typography)
15. [https://storybook.js.org/docs/writing-tests/visual-testing](https://storybook.js.org/docs/writing-tests/visual-testing)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |