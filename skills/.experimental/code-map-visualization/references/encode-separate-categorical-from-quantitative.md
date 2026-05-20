---
title: Encode Category and Magnitude on Different Channel Types
impact: CRITICAL
impactDescription: prevents false ordering of nominal domains
tags: encode, categorical, quantitative, channels, hue
---

## Encode Category and Magnitude on Different Channel Types

Nominal data (which domain a file belongs to) and quantitative data (how much churn it has) need different *kinds* of channel: hue is identity-preserving and unordered, so it suits categories; luminance, size, and length are ordered, so they suit magnitudes. Encoding a category on an ordered ramp invents a ranking that does not exist ("Billing > Search" because it is darker), and encoding magnitude on categorical hue destroys ordering. Keep one channel per data type so each reads correctly.

**Incorrect (domain on a sequential ramp implies an order):**

```typescript
const ramp = scaleSequential(interpolateViridis).domain([0, domainCount]);
getFillColor: (c) => rgb(ramp(c.domainIndex));   // categories look ranked by darkness
```

**Correct (domain on categorical hue; magnitude on the ordered channel):**

```typescript
const hue = scaleOrdinal(schemeTableau10).domain(domainNames);
getFillColor: (c) => hue(c.domain);              // identity, no implied order
getRadius:   (c) => r(c.complexity);             // magnitude on size, which is ordered
```

Cap the number of distinct hues so they stay distinguishable ([[color-limit-categorical-hues]]).

**When NOT to apply:**
- Ordinal categories with a genuine order (severity: low/medium/high) *should* use an ordered channel — that is encoding the order that really exists.

Reference: [Bertin, Semiology of Graphics](https://press.uchicago.edu/ucp/books/book/distributed/S/bo24856059.html); [d3-scale-chromatic: categorical schemes](https://d3js.org/d3-scale-chromatic/categorical)
