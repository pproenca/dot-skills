---
title: Use Pixelmatch with includeAA=false at Threshold 0.1 for Icon Diff
impact: HIGH
impactDescription: catches single-pixel icon defects with ~0% false positive rate from AA jitter
tags: diff, pixelmatch, antialias-detection, icon-fidelity
---

## Use Pixelmatch with includeAA=false at Threshold 0.1 for Icon Diff

Pixelmatch's killer feature is `includeAA: false` — it heuristically detects antialiased pixels (those that differ from baseline in a way consistent with AA, not with content change) and excludes them from the diff. For small SVG icons where SSIM's window size is too large to localize, pixelmatch at `threshold: 0.1, includeAA: false` is the sharpest tool: it flags the single offset pixel that broke a chevron while ignoring AA noise on its edges.

**Incorrect (default pixelmatch, AA pixels counted as failures):**

```ts
import pixelmatch from 'pixelmatch';

const diff = pixelmatch(
  baseline.data, actual.data,
  null,
  width, height,
  { threshold: 0.1 },   // missing includeAA: false → every AA edge fails
);
if (diff > 0) fail();
// 16×16 icon: 47 "failures", all on the icon's antialiased outline.
```

**Correct (AA-aware diff for icons):**

```ts
import pixelmatch from 'pixelmatch';
import { PNG } from 'pngjs';

function iconDiff(baseline: PNG, actual: PNG, width: number, height: number): number {
  const diffOutput = new PNG({ width, height });
  const failingPixels = pixelmatch(
    baseline.data,
    actual.data,
    diffOutput.data,
    width,
    height,
    {
      threshold: 0.1,        // perceptual color-distance threshold (YIQ space)
      includeAA: false,      // skip pixels heuristically classified as AA
      alpha: 0.1,            // dim the unchanged regions in the diff output for visual inspection
      diffColor: [255, 0, 0],
    },
  );
  return failingPixels;
}

// Pass condition: 0 failing pixels (excluding AA).
// This catches: stroke-width change, missing path segment, wrong icon ID.
// This ignores: subpixel AA shifts, font rasterizer cache state.
```

**Why threshold 0.1 (not 0 or 0.5):** Pixelmatch's threshold is in YIQ color-distance space normalized 0..1. 0.1 catches color shifts of ~12 perceptual units (visible to a designer) while ignoring the ~3-5 units of typical GPU compositing drift. 0 over-fires, 0.5 misses genuine 1-bit color changes (e.g., #888 → #999 in a divider).

**Generate a visible diff PNG:** the `diffOutput` parameter renders failing pixels in `diffColor` over a dimmed copy of baseline. Save this on test failure and link from the CI report — designers can review failures by eye without reproducing the test locally.

**When to combine with SSIM:** for full-component snapshots, run *both*: pixelmatch with `includeAA: false` for hard defect detection (must be 0), SSIM for overall structural similarity (must be ≥ 0.99). They catch different classes of regression.

Reference: [Pixelmatch — README: how it works](https://github.com/mapbox/pixelmatch#how-it-works)
