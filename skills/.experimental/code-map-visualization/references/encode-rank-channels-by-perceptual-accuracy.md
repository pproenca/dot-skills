---
title: Rank Visual Channels by Perceptual Accuracy
impact: CRITICAL
impactDescription: prevents systematic misreading of the primary metric
tags: encode, channels, perception, cleveland-mcgill, magnitude
---

## Rank Visual Channels by Perceptual Accuracy

People decode visual channels with very different accuracy: position and length are read precisely, while area, angle, and especially colour are read approximately (Cleveland & McGill's ranking, formalised in Munzner's effectiveness order). Put the attribute readers most need to *compare* — the metric that drives decisions — on the highest-accuracy channel still free, not on whatever is convenient. Encoding code churn or complexity on hue means a cell twice as risky as its neighbour looks merely "a different colour," and the map silently loses its ability to rank.

**Incorrect (the decision metric lives on the least accurate channel):**

```typescript
new ScatterplotLayer({
  data: cells,
  getPosition: (c) => c.xy,
  getRadius: () => 40,                          // size carries nothing
  getFillColor: (c) => rainbow(c.complexity),   // magnitude on hue -> unrankable
});
```

**Correct (decision metric on a high-accuracy channel; hue freed for category):**

```typescript
const r = scaleSqrt().domain([0, maxComplexity]).range([4, 40]);
new ScatterplotLayer({
  data: cells,
  getPosition: (c) => c.xy,
  getRadius: (c) => r(c.complexity),            // magnitude on size (area) -> comparable
  getFillColor: (c) => domainColor(c.domain),   // hue now means "which domain"
});
```

Size is itself only mid-ranked, so scale it by area not radius ([[encode-size-by-area-not-radius]]); reserve hue for nominal data ([[encode-separate-categorical-from-quantitative]]).

**When NOT to apply:**
- If the metric only needs a coarse "hot vs cold" read rather than precise ranking, a sequential colour ramp ([[color-perceptually-uniform-sequential-ramp]]) is enough and frees size for another attribute.

Reference: [Cleveland & McGill, Graphical Perception (JASA 1984)](https://www.jstor.org/stable/2288400); [Munzner, Visualization Analysis & Design](https://www.cs.ubc.ca/~tmm/vadbook/)
