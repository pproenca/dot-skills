---
name: design-to-react-algorithms
description: Use this skill whenever reverse-engineering a Sketch file (or Figma export with similar shape) into pixel-perfect React + CSS — covers the iteration mental model, tree reconstruction, layout inference algorithms, geometry math, visual-regression diffing, and the style/typography/path conversions that make "improvement without regression" enforceable. Trigger even if the user doesn't explicitly mention "algorithms" but is converting a design source into web code, building a design-to-code pipeline, or struggling to make incremental fidelity improvements without breaking previously-converted output.
---

# dot-skills Design-to-React Conversion Best Practices

The reverse-engineering pipeline that converts Sketch files into pixel-perfect React + CSS, **with regression-safe iteration as the load-bearing constraint**. The skill is organized around the cascade effect of design-to-code conversion: a wrong call in stage N corrupts every output from stage N+1 onward, so categories are ordered by how much downstream they own.

The user's primary requirement — *"each improvement doesn't cause regressions"* — is enforceable only if the iteration loop, the layer tree, and the layout solver are correct *before* you start polishing styles. Read the rules in priority order.

## When to Apply

- Building a converter that ingests a `.sketch` file (or equivalent design source) and emits React + CSS
- Iterating on an existing converter where each improvement risks breaking other components
- Diagnosing why a converted component "almost matches" the design but visual-regression fails
- Designing the snapshot-gate / baseline strategy for a design-to-code pipeline
- Choosing between flexbox vs grid vs absolute positioning when the source is freeform geometry
- Translating Sketch-specific primitives (`MSImmutableFlexGroupLayout`, `attributedString`, `curvePoint`, `MSImmutableStyleCorners`) into idiomatic CSS

## Rule Categories by Priority

The ordering is the cascade — fix earlier stages first; later-stage fixes are wasted if the upstream tree is wrong.

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Reverse-Engineering Iteration Strategy | CRITICAL | `iter-` |
| 2 | Tree Reconstruction & Symbol Resolution | CRITICAL | `tree-` |
| 3 | Layout Algorithms (Flex/Freeform Inference) | CRITICAL | `layout-` |
| 4 | Coordinate & Geometry Math | HIGH | `geom-` |
| 5 | Visual Regression & Diff Algorithms | HIGH | `diff-` |
| 6 | Style Translation (Color, Gradient, Shadow, Border) | MEDIUM-HIGH | `style-` |
| 7 | Typography Math | MEDIUM | `type-` |
| 8 | Path & Shape Rendering | MEDIUM | `path-` |

## Quick Reference

### 1. Reverse-Engineering Iteration Strategy (CRITICAL)

- [`iter-bisect-from-root`](references/iter-bisect-from-root.md) — Convert top-down, bisect bottom-up to localize regressions in O(log n)
- [`iter-baseline-snapshot-gate`](references/iter-baseline-snapshot-gate.md) — Every change must pass committed baselines before merge
- [`iter-convert-symbols-before-instances`](references/iter-convert-symbols-before-instances.md) — Topologically sort symbols → instances; never inline duplicates
- [`iter-freeze-design-tokens-first`](references/iter-freeze-design-tokens-first.md) — Extract sharedSwatches/layerStyles to CSS variables BEFORE any component
- [`iter-one-family-per-pr`](references/iter-one-family-per-pr.md) — Scope conversions to one component family per iteration
- [`iter-keep-known-good-branch`](references/iter-keep-known-good-branch.md) — Maintain a baseline branch as a three-way regression triage anchor

### 2. Tree Reconstruction & Symbol Resolution (CRITICAL)

- [`tree-resolve-overrides-before-emit`](references/tree-resolve-overrides-before-emit.md) — Apply `overrideValues` against master into named props
- [`tree-hash-subtrees-for-componentization`](references/tree-hash-subtrees-for-componentization.md) — Structural hashing finds repetition designers missed
- [`tree-collapse-passthrough-groups`](references/tree-collapse-passthrough-groups.md) — Drop no-style single-child groups; preserve world coords
- [`tree-hoist-shared-style-via-subtree-equivalence`](references/tree-hoist-shared-style-via-subtree-equivalence.md) — Subtree equivalence + modifier classes, not per-property dedup
- [`tree-clipping-mask-is-stacking-context`](references/tree-clipping-mask-is-stacking-context.md) — `hasClippingMask` requires `isolation: isolate` + clip-path
- [`tree-foreign-symbols-become-library-imports`](references/tree-foreign-symbols-become-library-imports.md) — Foreign symbols are package imports, not duplicates

### 3. Layout Algorithms (CRITICAL)

- [`layout-flex-group-enum-mapping`](references/layout-flex-group-enum-mapping.md) — Map `MSImmutableFlexGroupLayout` enums 1:1 to CSS flex properties
- [`layout-infer-flex-from-axis-projection-overlap`](references/layout-infer-flex-from-axis-projection-overlap.md) — 1D separating-axis test for freeform → flex row/column
- [`layout-detect-grid-via-2d-coordinate-clustering`](references/layout-detect-grid-via-2d-coordinate-clustering.md) — Cluster edge coordinates with ε to detect CSS Grid
- [`layout-promote-freeform-when-equal-gaps`](references/layout-promote-freeform-when-equal-gaps.md) — Equal gaps within tolerance → `display: flex; gap: Npx`
- [`layout-reverse-engineer-padding-not-margin`](references/layout-reverse-engineer-padding-not-margin.md) — Insets become parent padding; rebase children
- [`layout-preserve-wrapping-enabled`](references/layout-preserve-wrapping-enabled.md) — `wrappingEnabled` is the only way the source signals responsive intent
- [`layout-ignore-layout-is-absolute-escape`](references/layout-ignore-layout-is-absolute-escape.md) — `flexItem.ignoreLayout: true` → `position: absolute` over `position: relative` parent

### 4. Coordinate & Geometry Math (HIGH)

- [`geom-compose-parent-transforms-before-emit`](references/geom-compose-parent-transforms-before-emit.md) — Compose 2D affine matrices, don't concatenate raw x/y
- [`geom-round-only-at-leaves`](references/geom-round-only-at-leaves.md) — Carry floats through; round once at the CSS boundary
- [`geom-rotation-is-css-transform`](references/geom-rotation-is-css-transform.md) — Frame is unrotated AABB; emit `transform: rotate()`
- [`geom-shape-group-bounds-via-union`](references/geom-shape-group-bounds-via-union.md) — Bounds = axis-aligned union of children, rebase to origin
- [`geom-clipping-bounds-intersect-not-union`](references/geom-clipping-bounds-intersect-not-union.md) — Nested clips intersect; never union or replace

### 5. Visual Regression & Diff Algorithms (HIGH)

- [`diff-use-ssim-for-aa-content`](references/diff-use-ssim-for-aa-content.md) — SSIM for antialiased content; raw pixel diff false-positives on every retest
- [`diff-region-budgeted-tolerances`](references/diff-region-budgeted-tolerances.md) — Per-region SSIM floors (text 0.99, gradient 0.95, image 1.0)
- [`diff-antialias-aware-pixelmatch-threshold`](references/diff-antialias-aware-pixelmatch-threshold.md) — Pixelmatch `includeAA: false` for icon defect detection
- [`diff-perceptual-hash-for-wrong-component-detection`](references/diff-perceptual-hash-for-wrong-component-detection.md) — Hamming distance buckets route triage automatically
- [`diff-subtree-bisection-to-localize-regression`](references/diff-subtree-bisection-to-localize-regression.md) — Disable subtrees in binary search to find the offending node
- [`diff-baseline-per-component-not-per-page`](references/diff-baseline-per-component-not-per-page.md) — Storybook per-story snapshots; scope = blast radius

### 6. Style Translation (MEDIUM-HIGH)

- [`style-srgb-float-to-hex-via-gamma-correct-path`](references/style-srgb-float-to-hex-via-gamma-correct-path.md) — Sketch sRGB floats are already gamma-encoded; direct conversion only
- [`style-preserve-display-p3`](references/style-preserve-display-p3.md) — `colorSpace: 1` → emit `color(display-p3 …)` with sRGB fallback
- [`style-gradient-angle-via-atan2`](references/style-gradient-angle-via-atan2.md) — `atan2(dx, -dy)` reframes Sketch vector to CSS gradient angle
- [`style-stack-multi-shadow-in-paint-order`](references/style-stack-multi-shadow-in-paint-order.md) — Reverse shadow array — Sketch paints last-first, CSS first-last
- [`style-reconcile-border-position`](references/style-reconcile-border-position.md) — Border position 0/1/2 → frame expansion or `outline` for outside
- [`style-per-corner-radii-shorthand`](references/style-per-corner-radii-shorthand.md) — Per-corner radii map to `TL TR BR BL` clockwise (not Sketch's row order)

### 7. Typography Math (MEDIUM)

- [`type-split-attributed-string-runs-only-when-differ`](references/type-split-attributed-string-runs-only-when-differ.md) — Coalesce identical adjacent attribute runs; single-run case needs no inner span
- [`type-pt-lineheight-to-unitless`](references/type-pt-lineheight-to-unitless.md) — `lineHeight / fontSize` → CSS unitless that scales with the font
- [`type-kerning-pt-to-em-letter-spacing`](references/type-kerning-pt-to-em-letter-spacing.md) — `kerning / fontSize` → em-relative `letter-spacing`
- [`type-build-font-fallback-ladder`](references/type-build-font-fallback-ladder.md) — Sketch family → web stack; SF Pro needs `-apple-system, BlinkMacSystemFont, …`
- [`type-paragraph-spacing-between-not-after`](references/type-paragraph-spacing-between-not-after.md) — Use `gap` on the parent, not `margin-bottom` with `:last-child`

### 8. Path & Shape Rendering (MEDIUM)

- [`path-curve-point-to-svg-cubic-bezier`](references/path-curve-point-to-svg-cubic-bezier.md) — `M` + per-segment `C` from `curveFrom`/`curveTo`
- [`path-rectangle-with-fixed-radius-is-css`](references/path-rectangle-with-fixed-radius-is-css.md) — Detect axis-aligned rounded rects early; emit `<div>` not `<svg>`
- [`path-apple-smooth-corners-via-superellipse`](references/path-apple-smooth-corners-via-superellipse.md) — Apple smooth corners are superellipses (n≈5), not circular arcs
- [`path-flatten-boolean-ops-at-parse-time`](references/path-flatten-boolean-ops-at-parse-time.md) — Resolve union/subtract via paper.js in Node; ship one flat path
- [`path-honor-winding-rule`](references/path-honor-winding-rule.md) — `windingRule` 0/1 → SVG `fill-rule` nonzero/evenodd; explicit, not default

## How to Use

1. **Read [`references/_sections.md`](references/_sections.md)** for category definitions and the cascade rationale
2. **Start with the iteration strategy (`iter-*`)** — without the regression gate, every other rule is just techniques
3. **Then tree (`tree-*`) and layout (`layout-*`)** — these are the load-bearing structural decisions
4. **Then geometry (`geom-*`) and diff (`diff-*`)** — these are the precision and validation layers
5. **Style, type, and path** are the polish layer — high fidelity but mostly local impact

For a brand-new converter, follow the rules in priority order. For an existing converter, identify which stage owns the regression you're seeing (use [[diff-subtree-bisection-to-localize-regression]] + [[diff-perceptual-hash-for-wrong-component-detection]] to triage) and fix at the highest stage that owns it.

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions, impact levels, cascade rationale |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for adding new rules to this skill |
| [metadata.json](metadata.json) | Version, discipline, references |
| [AGENTS.md](AGENTS.md) | Auto-built TOC (regenerate via `scripts/build-agents-md.js`) |
