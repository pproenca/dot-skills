---
title: Use a Perceptually Uniform Sequential Ramp, Not Rainbow
impact: CRITICAL
impactDescription: prevents false boundaries the data does not contain
tags: color, sequential, viridis, oklch, rainbow
---

## Use a Perceptually Uniform Sequential Ramp, Not Rainbow

The rainbow/jet ramp is not perceptually uniform: equal steps in the data produce wildly unequal perceived steps, so the bright cyan and yellow bands read as sharp boundaries that exist only in the colormap, while large changes inside the green stretch read as flat. For a sequential metric (churn, complexity, age) use a perceptually uniform ramp — viridis, magma, or an OKLCH-interpolated scale where lightness increases monotonically — so equal data differences look equal. This single choice decides whether the map's colour tells the truth.

**Incorrect (rainbow invents banding):**

```typescript
const ramp = (t: number) => interpolateRainbow(t);   // non-uniform; fake cyan/yellow edges
getFillColor: (c) => rgb(ramp(norm(c.complexity)));
```

**Correct (perceptually uniform, monotonic lightness):**

```typescript
const ramp = scaleSequential(interpolateViridis).domain([0, maxComplexity]);
getFillColor: (c) => rgb(ramp(c.complexity));        // equal steps look equal
```

Match the ramp *shape* to the data's shape — sequential here, diverging when there is a meaningful midpoint ([[color-match-scale-type-to-data]]).

**When NOT to apply:**
- Cyclic data (e.g. hour-of-day of last commit) genuinely wraps, so a cyclic uniform colormap (`interpolateSinebow`, twilight) is correct — the harm is using rainbow for non-cyclic magnitude.

Reference: [Borland & Taylor, Rainbow Color Map (Still) Considered Harmful (IEEE CG&A 2007)](https://doi.org/10.1109/MCG.2007.323435); [viridis / matplotlib colormaps](https://bids.github.io/colormap/)
