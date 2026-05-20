---
title: Scale Symbol Size by Area, Not Radius
impact: CRITICAL
impactDescription: prevents up to 4x magnitude exaggeration
tags: encode, size, area, scale-sqrt, proportional-symbols
---

## Scale Symbol Size by Area, Not Radius

When a metric drives the *radius* of a circle (or the side of a square), the mark's perceived quantity — its area — grows with the square of the value, so a file with twice the churn renders four times as big. Readers judge symbols by area (Flannery's proportional-symbol research, baked into d3's `scaleSqrt`), so map the value to area and take the square root for the radius. Otherwise every size comparison on the map is exaggerated quadratically.

**Incorrect (value drives radius linearly):**

```typescript
const radius = scaleLinear().domain([0, maxLoc]).range([2, 60]);
getRadius: (c) => radius(c.loc);    // 2x LOC -> 4x area, looks 4x bigger
```

**Correct (value drives area; radius is its square root):**

```typescript
const radius = scaleSqrt().domain([0, maxLoc]).range([2, 60]);
getRadius: (c) => radius(c.loc);    // 2x LOC -> 2x area, read correctly
```

**When NOT to apply:**
- One-dimensional marks (bar length, line height) already encode on a linear channel — only area marks need the square-root correction.

Reference: [d3-scale: scaleSqrt](https://d3js.org/d3-scale/pow#scaleSqrt); [Munzner, Visualization Analysis & Design](https://www.cs.ubc.ca/~tmm/vadbook/)
