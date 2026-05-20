---
title: Match the Color Scale Type to the Data's Shape
impact: CRITICAL
impactDescription: prevents hiding the zero crossing in diverging data
tags: color, sequential, diverging, categorical, scale-type
---

## Match the Color Scale Type to the Data's Shape

Sequential, diverging, and categorical data each need their own scale type. A sequential ramp on diverging data (a coverage *delta* that can be positive or negative) buries the all-important zero crossing somewhere mid-ramp, so "improved" and "regressed" look similar. A diverging ramp on purely one-ended data invents a meaningless midpoint. Pick the scale whose structure matches the data: one-ended → sequential, signed around a midpoint → diverging, unordered → categorical ([[encode-separate-categorical-from-quantitative]]).

**Incorrect (sequential ramp on signed data):**

```typescript
const ramp = scaleSequential(interpolateViridis).domain([-30, 30]);
getFillColor: (c) => rgb(ramp(c.coverageDelta)); // zero hidden; sign of change unclear
```

**Correct (diverging ramp pinned at the meaningful midpoint):**

```typescript
const ramp = scaleDiverging(interpolateRdBu).domain([-30, 0, 30]);
getFillColor: (c) => rgb(ramp(c.coverageDelta)); // red regress, white zero, blue improve
```

**When NOT to apply:**
- If the data has no meaningful midpoint, forcing a diverging ramp invents one — keep it sequential.

Reference: [d3-scale: scaleDiverging](https://d3js.org/d3-scale/diverging); [ColorBrewer](https://colorbrewer2.org/)
