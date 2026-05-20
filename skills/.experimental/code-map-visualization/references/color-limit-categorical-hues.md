---
title: Limit Categorical Hues to What the Eye Can Separate
impact: HIGH
impactDescription: prevents indistinguishable domains past ~8-12 hues
tags: color, categorical, palette, qualitative, grouping
---

## Limit Categorical Hues to What the Eye Can Separate

People can reliably tell apart only a handful of categorical colours at once — qualitative palettes top out around 8–12 distinct hues, and beyond that adjacent categories become guesses. A code map often has dozens of domains; assigning each a unique colour produces a palette where half the regions are "some kind of teal." Cap the palette: colour the top N domains explicitly, fold the rest into a neutral "other," and lean on position (the projection already groups them) plus labels ([[text-anchor-region-labels-at-centroid]]) to carry the long tail.

**Incorrect (a unique hue per domain):**

```typescript
const hue = scaleOrdinal(quantize(interpolateRainbow, domains.length)) // 40 near-identical hues
  .domain(domains);
```

**Correct (cap to a qualitative palette; bucket the tail):**

```typescript
const top = domainsBySize.slice(0, 10);
const hue = scaleOrdinal<string>()
  .domain([...top, "other"])
  .range([...schemeTableau10, "#bdbdbd"])       // 10 separable hues + neutral
  .unknown("#bdbdbd");
getFillColor: (c) => hue(top.includes(c.domain) ? c.domain : "other");
```

**When NOT to apply:**
- If categories are never compared across the whole map at once — only within a zoomed-in region of a few — a larger palette can work because only a few are ever on screen together.

Reference: [ColorBrewer (qualitative schemes)](https://colorbrewer2.org/); [d3-scale-chromatic: categorical](https://d3js.org/d3-scale-chromatic/categorical)
