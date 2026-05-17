---
title: Preserve Display P3 with color(display-p3 …), Don't Gamut-Clip to sRGB
impact: MEDIUM-HIGH
impactDescription: prevents 5-15% saturation loss on wide-gamut displays for vivid accents
tags: style, display-p3, color-space, wide-gamut
---

## Preserve Display P3 with color(display-p3 …), Don't Gamut-Clip to sRGB

When `document.colorSpace === 1`, Sketch is in Display P3 mode and color values are P3 floats — many of which are *outside* the sRGB gamut. Converting them with the standard `r*255` formula silently clips them into sRGB, producing duller colors on every wide-gamut display (every iPhone since 2016, every MacBook since 2016, modern iPads, recent Pixel devices). Emit the `color(display-p3 r g b)` CSS function instead, which preserves the wider gamut and gracefully falls back on non-P3 displays.

**Detect:**

```ts
const isP3 = doc.colorSpace === 1;
// Sketch's colorSpace enum: 0 = unmanaged/sRGB, 1 = Display P3.
```

**Incorrect (gamut-clip to sRGB):**

```ts
function sketchColorToCss(c: SketchColor): string {
  return `rgb(${c.red * 255} ${c.green * 255} ${c.blue * 255})`;
  // Sketch P3 accent: (1.0, 0.18, 0.18) — vivid red beyond sRGB.
  // Emit: rgb(255 46 46) — clipped to sRGB. Looks duller on P3 displays
  // because the browser cannot reach the original color from this notation.
}
```

**Correct (preserve P3, fall back to sRGB for legacy):**

```ts
function sketchColorToCss(c: SketchColor, colorSpace: 0 | 1): string {
  if (colorSpace === 1) {
    // CSS Color 4 — keeps floats, preserves wide gamut.
    return `color(display-p3 ${c.red} ${c.green} ${c.blue}${c.alpha < 1 ? ` / ${c.alpha}` : ''})`;
  }
  // sRGB path (gamma-encoded floats → bytes).
  const r = Math.round(c.red * 255);
  const g = Math.round(c.green * 255);
  const b = Math.round(c.blue * 255);
  return c.alpha < 1
    ? `rgb(${r} ${g} ${b} / ${c.alpha})`
    : `rgb(${r} ${g} ${b})`;
}

// For older-browser fallback, emit a 2-line declaration:
function emitWithFallback(prop: string, c: SketchColor, colorSpace: 0 | 1): string {
  if (colorSpace !== 1) return `${prop}: ${sketchColorToCss(c, 0)};`;
  // Fallback (sRGB-clipped) for browsers without display-p3 support.
  const fallback = sketchColorToCss(clampToSrgb(c), 0);
  const wideGamut = sketchColorToCss(c, 1);
  return `${prop}: ${fallback};\n${prop}: ${wideGamut};`;
  // CSS cascade: browsers that parse the second line use it; others ignore.
}

function clampToSrgb(c: SketchColor): SketchColor {
  return {
    red:   Math.max(0, Math.min(1, c.red)),
    green: Math.max(0, Math.min(1, c.green)),
    blue:  Math.max(0, Math.min(1, c.blue)),
    alpha: c.alpha,
  };
}
```

**Why fallback isn't optional:** Safari has supported `color(display-p3 …)` since 2017, Chrome since version 111 (2023), Firefox since 113 (2023). Older browsers ignore the entire declaration if they don't understand the value type — without a fallback, an unsupported browser shows the *initial* value (often transparent or black), not a clipped color.

**When to skip P3:** for components destined for export to non-color-managed contexts (PNG icons going into emails), keep sRGB. The P3 round-trip through unmanaged renderers produces unpredictable shifts.

Reference: [W3C CSS Color Module Level 4 — color() function](https://www.w3.org/TR/css-color-4/#color-function)
