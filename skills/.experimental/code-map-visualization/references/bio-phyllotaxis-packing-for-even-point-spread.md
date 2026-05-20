---
title: Spread Dense Points with a Golden-Angle Phyllotaxis Spiral
impact: MEDIUM
impactDescription: prevents clumping and grid moiré in dense fills
tags: bio, phyllotaxis, golden-angle, packing, sampling
---

## Spread Dense Points with a Golden-Angle Phyllotaxis Spiral

Placing many markers inside a cell on a square grid produces axis-aligned moiré and obvious rows; placing them at random produces clumps and holes. The golden-angle spiral that sunflowers use (Vogel's model: the nth point at angle n·137.5° and radius c·√n) packs points at near-uniform density with no preferred direction and no clumping — the most efficient even spread on a disc. Use it to lay out leaf markers, sample points, or glyphs within a region where position carries no meaning of its own.

**Incorrect (a grid shows rows and aliases against the cell):**

```typescript
items.forEach((it, i) => {
  const col = i % cols, row = Math.floor(i / cols);
  place(it, cx + col * gap, cy + row * gap);     // visible grid, clumps at edges
});
```

**Correct (Vogel's sunflower spiral — uniform density, no grid, no clumps):**

```typescript
const GOLDEN = Math.PI * (3 - Math.sqrt(5));     // the golden angle, ~137.5 degrees, in radians
items.forEach((it, i) => {
  const r = spacing * Math.sqrt(i), a = i * GOLDEN;
  place(it, cx + r * Math.cos(a), cy + r * Math.sin(a));
});
```

**When NOT to apply:**
- When the data is genuinely gridded (a matrix, a calendar heatmap), a grid is the honest encoding — phyllotaxis is for when only even coverage matters.

Reference: [Vogel — A Better Way to Construct the Sunflower Head (Math. Biosciences 1979)](https://doi.org/10.1016/0025-5564%2879%2990080-4); [Sunflowers and Fibonacci — packing efficiency](https://thatsmaths.com/2014/06/05/sunflowers-and-fibonacci-models-of-efficiency/)
