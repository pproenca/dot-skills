---
title: Convert Sketch sRGB Floats to Hex Without Linearizing
impact: MEDIUM-HIGH
impactDescription: prevents color shifts of 5-30 perceptual units when interpolating gradients
tags: style, color-conversion, srgb, gamma
---

## Convert Sketch sRGB Floats to Hex Without Linearizing

Sketch's color `{red, green, blue}` channels are floats in [0, 1] in **gamma-encoded sRGB** — the same space CSS uses. The direct conversion to CSS is `round(channel * 255)`; do *not* linearize to linear-RGB then back, which is what naïve color libraries do when chaining `rgb→linear→rgb` for any reason. Gradient interpolation in linear-RGB shifts midpoint colors by 5-30 perceptual units versus the gamma-space gradient Sketch shows. Stay in sRGB unless you're going through OKLCH.

**Incorrect (round-trip via linear RGB):**

```ts
import { rgb, linearRgb } from 'some-color-lib';

function sketchColorToCss(c: SketchColor): string {
  // Round-tripping through linear to "normalize" — DESTROYS the encoded value.
  const linear = rgb(c.red, c.green, c.blue).toLinearRgb();
  const back   = linear.toRgb();
  return `rgb(${back.r * 255} ${back.g * 255} ${back.b * 255})`;
  // Sketch shows #FF8800; this emits #FE8700. Designer says "wrong."
}
```

**Correct (direct gamma-space conversion):**

```ts
function sketchColorToCss(c: SketchColor): string {
  const r = Math.round(c.red   * 255);
  const g = Math.round(c.green * 255);
  const b = Math.round(c.blue  * 255);
  if (c.alpha < 1) {
    // CSS Color 4: alpha as a number 0..1, slash separator.
    return `rgb(${r} ${g} ${b} / ${c.alpha})`;
  }
  return `rgb(${r} ${g} ${b})`;
}

// For hex output (smaller in CSS, no alpha mixing surprises):
function sketchColorToHex(c: SketchColor): string {
  const h = (n: number) => Math.round(n * 255).toString(16).padStart(2, '0');
  const base = `#${h(c.red)}${h(c.green)}${h(c.blue)}`;
  // Alpha as the 8th hex pair quantizes to 1/255 — fine for opaque-ish (>0.9)
  // and most translucency, but if the design uses sub-byte alpha precision
  // (animated fades, near-zero overlay), emit `rgb(r g b / a)` instead.
  return c.alpha < 1 ? `${base}${h(c.alpha)}` : base;
}
```

**When to linearize ANYWAY (and how):** when blending two colors in code (computing a midpoint for an inferred gradient, or alpha-compositing for diff visualization), do it in linear-light space and convert back — gamma-space blending produces the dirty mid-tones Sketch designers explicitly avoid. But for *storing* and *emitting* the Sketch value, stay in gamma sRGB.

**Common pitfall — float vs byte rounding asymmetry:** `0.498 * 255 = 127.0` rounds down to 127, but `0.502 * 255 = 128.01` rounds up to 128. Two adjacent grey swatches differing by 0.004 in float space become a visible 1-byte step in hex. This is correct behavior — but if your diff reports flag it as a regression, the rounding direction (not the conversion) is the problem.

Reference: [W3C CSS Color Module Level 4 — sRGB](https://www.w3.org/TR/css-color-4/#predefined-sRGB)
