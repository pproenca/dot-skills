---
title: Design Color Choices for Color-Vision Deficiency
impact: CRITICAL
impactDescription: prevents red/green confusion for ~8% of male users
tags: color, color-vision-deficiency, accessibility, palettes, okabe-ito
---

## Design Color Choices for Color-Vision Deficiency

Roughly 8% of men and 0.5% of women cannot distinguish red from green, so a red/green "regressed/improved" map is unreadable for them — and confirming it requires simulating the deficiency, not eyeballing. Choose CVD-safe palettes (viridis and ColorBrewer's flagged-safe schemes are designed for this), prefer blue/orange over red/green for diverging contrasts, and verify by running the palette through a simulator. Colour that fails here fails silently — the chart looks fine to its author.

**Incorrect (red/green pair, unverified):**

```typescript
const status = scaleOrdinal<string>()
  .domain(["regressed", "improved"])
  .range(["#e41a1c", "#4daf4a"]);   // indistinguishable under deuteranopia
```

**Correct (CVD-safe pair, verified in tests):**

```typescript
const status = scaleOrdinal<string>()
  .domain(["regressed", "improved"])
  .range(["#d55e00", "#0072b2"]);   // Okabe-Ito orange/blue, CVD-safe
// CI guard: simulate("deuteranopia", status("regressed")) must differ from status("improved")
```

Pair colour with a second channel so it is never load-bearing alone ([[encode-redundant-encoding-for-key-signals]], [[access-encode-redundantly-never-color-alone]]).

**When NOT to apply:**
- Brand-mandated colours you cannot change still need the redundant second channel — if you cannot fix the hue, you must add shape or label.

Reference: [Okabe & Ito, Color Universal Design](https://jfly.uni-koeln.de/color/); [ColorBrewer (colorblind-safe filter)](https://colorbrewer2.org/)
