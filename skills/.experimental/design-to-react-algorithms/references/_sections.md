# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

The ordering reflects the cascade effect of the design-to-code pipeline: a mistake
in stage N corrupts every output from stage N+1 onward. Always fix at the highest
stage that owns the regression — patching downstream is how skills accumulate technical debt.

---

## 1. Reverse-Engineering Iteration Strategy (iter)

**Impact:** CRITICAL  
**Description:** The meta-algorithm that gates every other category — slice the file into convertible units, snapshot a known-good baseline, and ratchet forward under a regression gate. Without this loop, "improvements" produce unreviewable churn and silently break previously-correct output.

## 2. Tree Reconstruction & Symbol Resolution (tree)

**Impact:** CRITICAL  
**Description:** Build the true layer hierarchy before emitting code: resolve `symbolInstance` overrides against masters, detect repeated subtrees as component candidates, collapse pass-through groups, and treat clipping masks as new stacking contexts. A wrong tree means every downstream stage operates on a lie.

## 3. Layout Algorithms (Flex / Freeform Inference) (layout)

**Impact:** CRITICAL  
**Description:** Map `MSImmutableFlexGroupLayout` directly to CSS flexbox, and for freeform groups infer flex/grid via geometric clustering before falling back to absolute positioning. Layout is non-local — a wrong layout misaligns the entire subtree and cannot be repaired by per-element tweaks.

## 4. Coordinate & Geometry Math (geom)

**Impact:** HIGH  
**Description:** Compose parent transforms before emitting coordinates, defer rounding to the leaf to avoid cumulative drift, treat rotation as CSS `transform` not a pre-rotated bounding box, and intersect (not union) clipping bounds. Coordinate errors compound multiplicatively through nested groups.

## 5. Visual Regression & Diff Algorithms (diff)

**Impact:** HIGH  
**Description:** The validation loop that makes "no improvement causes a regression" enforceable — SSIM for antialiased content, region-budgeted tolerances (text vs gradient vs image), perceptual hashing to distinguish "wrong component" from "off by a pixel," and subtree-bisection to localize failures.

## 6. Style Translation (Color, Gradient, Shadow, Border) (style)

**Impact:** MEDIUM-HIGH  
**Description:** High-fidelity but largely local — convert sRGB float channels via gamma-correct paths, preserve Display P3 with `color(display-p3 …)`, derive gradient angles from vector geometry, stack multiple shadows in declared paint order, and reconcile border `position` (center / inside / outside) into width offsets.

## 7. Typography Math (type)

**Impact:** MEDIUM  
**Description:** Sketch `attributedString` runs map to nested spans only when attributes differ; `lineHeight` (pt) becomes CSS unitless via `lh / fontSize`; `kerning` (pt) becomes `letter-spacing` em via `kerning / fontSize`. Typography errors are small per-element but propagate across every text block on the page.

## 8. Path & Shape Rendering (path)

**Impact:** MEDIUM  
**Description:** Convert `curvePoint[]` to SVG path data using `curveFrom`/`curveTo` as cubic Bezier control points, approximate Apple smooth corners with a superellipse (n≈5) rather than circular arcs, flatten boolean operations at parse time, and honor `windingRule` for `fill-rule`. Specific to vector content but visually conspicuous when wrong.
