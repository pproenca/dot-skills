---
title: Approximate Apple Smooth Corners with a Superellipse (n≈5), Not Circular Arcs
impact: MEDIUM
impactDescription: prevents visibly "off" corners on Apple-styled UIs; matches iOS/macOS rendering
tags: path, smooth-corners, superellipse, squircle
---

## Approximate Apple Smooth Corners with a Superellipse (n≈5), Not Circular Arcs

When a Sketch rectangle has its "Smooth Corners" toggle enabled, the corner is a *superellipse* (squircle), not a circular arc. CSS `border-radius` only produces circular/elliptical arcs — emitting `border-radius` for a smooth-cornered shape gives you the right radius value but the wrong curvature, which looks subtly bulged and "non-Apple." Approximate the superellipse with an 8-segment cubic Bezier inside an SVG, using exponent n ≈ 5.0 (Apple's empirical value).

**Detect:** a Sketch rectangle's `style.windingRule`/`cornerStyle` exposes a `smooth` flag. In the file format, it appears as `points[i].cornerStyle === 1` (smooth) vs `0` (rounded/circular). When any corner is smooth, fall out of CSS and into SVG.

**The math:** a superellipse with horizontal/vertical radius R and exponent n is the locus `|x/R|^n + |y/R|^n = 1`. For n=2 it's a circle; as n → ∞ it approaches a square. Apple's iOS app icons use n ≈ 5.

**Incorrect (CSS border-radius for smooth corners):**

```css
.appIcon {
  width: 120px;
  height: 120px;
  background: var(--icon-bg);
  border-radius: 26.4px;  /* Apple's official iOS icon corner radius for 120px icon */
}
/* Looks bulged compared to a real iOS icon — corners are too "round" near the apex,
   too "flat" near the straight edges. The difference is small per-pixel but
   instantly recognizable to anyone who's used iOS. */
```

**Correct (SVG superellipse approximation):**

```ts
// Sample N points along one quadrant of a superellipse, mirror to the other 3 quadrants,
// connect with cubic Beziers. 8 segments per corner gives sub-pixel accuracy at sizes up to 1024px.
function squirclePath(width: number, height: number, radius: number, n = 5): string {
  const samples = 8;
  // Parametric superellipse: (R·cos(θ)^(2/n), R·sin(θ)^(2/n)) with sign preservation.
  const point = (θ: number): [number, number] => {
    const c = Math.cos(θ), s = Math.sin(θ);
    return [
      Math.sign(c) * Math.pow(Math.abs(c), 2 / n) * radius,
      Math.sign(s) * Math.pow(Math.abs(s), 2 / n) * radius,
    ];
  };

  // Top-right quadrant samples (θ from 0 to π/2).
  const quadrant: [number, number][] = [];
  for (let i = 0; i <= samples; i++) {
    quadrant.push(point((i * Math.PI) / (2 * samples)));
  }

  // Build a closed path: start at top-mid, go clockwise through 4 corners.
  // (Skipping the per-segment Bezier control-point derivation here — use a
  //  Catmull-Rom-to-Bezier conversion on the sampled points for smooth tangents.)
  return buildClosedPath(quadrant, width, height, radius);
}

function emitSquircleRect(layer: Rectangle): string {
  const r = layer.fixedRadius ?? 0;
  if (!layer.hasSmoothCorners || r === 0) return null;   // not a squircle case

  const d = squirclePath(layer.frame.width, layer.frame.height, r);
  return `
    <svg viewBox="0 0 ${layer.frame.width} ${layer.frame.height}"
         width="${layer.frame.width}" height="${layer.frame.height}">
      <path d="${d}" fill="${fillFromStyle(layer.style)}" />
    </svg>
  `;
}
```

**Why n=5 specifically:** Apple's app icon corners measured from a 1024×1024 render match a superellipse with n ≈ 5.0 to within 0.5px. Values from 4.5 to 5.5 are visually indistinguishable; n=5 is the round number used by Figma's "Corner Smoothing" slider at the standard "60%" preset.

**When to skip the squircle path:** corner radii smaller than 4-6px — the superellipse vs circle difference is sub-pixel and not worth the SVG overhead. Fall back to CSS `border-radius` for small radii, even if the source flag says smooth.

**Tooling alternative:** the `@figma/squircle` npm package produces the same path; using it avoids the Bezier-control-point math. Acceptable as long as you pin the version (squircle formulas vary subtly between implementations).

Reference: [Figma — Corner smoothing and superellipses](https://www.figma.com/blog/desperately-seeking-squircles/)
