---
title: Budget Diff Tolerances Per Region Type (Text vs Gradient vs Image)
impact: HIGH
impactDescription: cuts false-positive snapshot failures by 70%+ vs a global threshold
tags: diff, tolerance-budgets, regions, ssim
---

## Budget Diff Tolerances Per Region Type (Text vs Gradient vs Image)

A single global SSIM threshold either rejects real text rendering jitter (too strict) or accepts visible gradient banding (too loose). Different content types have different inherent jitter — text rasterizes within ±0.5px of subpixel position across runs; gradients banding shifts a few quantization steps; bitmap images are byte-identical. Segment each snapshot into regions by content type and apply per-region tolerances.

**Recommended region budgets:**

| Region type | SSIM floor | Pixelmatch threshold | Rationale |
|---|---|---|---|
| Bitmap image | 1.000 | 0.0 | Byte-identical or it's wrong |
| Solid color | 0.999 | 0.01 | Tiny GPU compositing drift only |
| Text | 0.990 | 0.10 | AA + subpixel hinting jitter |
| Gradient | 0.950 | 0.15 | 8-bit quantization + dither |
| Shadow | 0.970 | 0.10 | Gaussian blur kernel quantization |

**Incorrect (one global threshold):**

```ts
const GLOBAL_THRESHOLD = 0.99;
if (ssim(baseline, actual).mssim < GLOBAL_THRESHOLD) fail();
// Text snapshots fail intermittently; gradient regressions slip through silently.
```

**Correct (per-region budgets from the Sketch source):**

```ts
type RegionType = 'image' | 'solid' | 'text' | 'gradient' | 'shadow';
type Region = { x: number; y: number; width: number; height: number; type: RegionType };

const BUDGETS: Record<RegionType, number> = {
  image: 1.000, solid: 0.999, text: 0.990, gradient: 0.950, shadow: 0.970,
};

// Derive region boxes from the Sketch tree — every layer becomes a region,
// classified by its dominant style/content.
function classifyLayer(l: Layer): RegionType {
  if (l._class === 'bitmap')                         return 'image';
  if (l._class === 'text')                           return 'text';
  if (l.style?.fills?.some(f => f.fillType === 1))   return 'gradient';
  if (l.style?.shadows?.length)                      return 'shadow';
  return 'solid';
}

function gatedDiff(baseline: PNG, actual: PNG, regions: Region[]): DiffReport {
  const failures: Region[] = [];
  for (const r of regions) {
    const score = ssimRegion(baseline, actual, r).mssim;
    if (score < BUDGETS[r.type]) failures.push(r);
  }
  return { passed: failures.length === 0, failures };
}
```

**Why per-region beats global thresholds:** a snapshot that is 60% gradient and 40% text needs a *blended* threshold under global SSIM — which is exactly the threshold no single number satisfies. Per-region budgets evaluate each part against the tolerance appropriate to its content, then aggregate by AND, not by average.

**Implementation tip — overlap order:** when regions overlap (a text label inside a card with a gradient background), the *most specific* region wins. Sort regions smallest-area-first when classifying pixels.

Reference: [Pixelmatch — Pixel-level image comparison library](https://github.com/mapbox/pixelmatch)
