---
title: Use SSIM for Antialiased Content, Not Raw Pixel Diff
impact: HIGH
impactDescription: reduces false-positive snapshot failures by 90%+ on text-heavy components
tags: diff, ssim, antialiasing, perceptual-metric
---

## Use SSIM for Antialiased Content, Not Raw Pixel Diff

Raw pixel-by-pixel diff (`abs(a.r - b.r) + abs(a.g - b.g) + abs(a.b - b.b)`) flags every retest of text-heavy components because text rasterization is non-deterministic across font cache states, GPU drivers, and headless browser versions. SSIM (Structural Similarity Index) compares luminance, contrast, and structure over small windows and is robust to antialiasing jitter while still catching real defects. Use SSIM for any component containing text, gradients, or shadows; raw pixel diff is acceptable only for solid-color shape primitives.

**Incorrect (raw pixel diff on text):**

```ts
import { PNG } from 'pngjs';

function pixelDiff(a: PNG, b: PNG): number {
  let diff = 0;
  for (let i = 0; i < a.data.length; i++) {
    diff += Math.abs(a.data[i] - b.data[i]);
  }
  return diff;
}

// Threshold: diff > 0 → fail.
// Result: every snapshot of a text label flickers between green and red
// because subpixel hinting drifted by 0.4 of a pixel.
```

**Correct (SSIM with windowed structural comparison):**

```ts
import { ssim } from 'image-ssim';   // or ssim.js
import { PNG } from 'pngjs';

interface DiffReport {
  ssim: number;            // 1.0 = identical, decreases with perceptual difference
  windowFailures: number;  // count of 8x8 windows below threshold (locality info)
  worst: { x: number; y: number; score: number };
}

function ssimDiff(baseline: PNG, actual: PNG): DiffReport {
  const result = ssim(baseline, actual, {
    windowSize: 8,         // 8×8 window — small enough to localize, large enough to absorb AA noise
    K1: 0.01, K2: 0.03,    // standard SSIM stabilization constants
  });
  return {
    ssim: result.mssim,
    windowFailures: result.windows.filter(w => w.score < 0.97).length,
    worst: result.windows.reduce((min, w) => w.score < min.score ? w : min),
  };
}

// Pass condition: mssim ≥ 0.99 (see diff-region-budgeted-tolerances for per-region tuning).
```

**Why 0.99 not 1.0:** identical rasterizations of the same DOM frequently score 0.999x rather than 1.0 due to floating-point in the SSIM computation itself. A 0.99 floor catches all real visual regressions while ignoring this baseline jitter.

**When raw pixel diff IS correct:** for components that are pure geometric shapes with no text and no AA (e.g., solid backgrounds, single-color icons rendered as SVG with `shape-rendering: crispEdges`), raw pixel diff is both faster and stricter. Reserve it for that case.

**Localization advantage:** SSIM's per-window score (`worst` above) tells you WHERE in the image the difference is, which feeds directly into [[diff-subtree-bisection-to-localize-regression]] — bisect toward the React subtree that renders into the failing window.

Reference: [Wang, Bovik, Sheikh & Simoncelli 2004 — Image Quality Assessment: From Error Visibility to Structural Similarity](https://ece.uwaterloo.ca/~z70wang/publications/ssim.pdf)
