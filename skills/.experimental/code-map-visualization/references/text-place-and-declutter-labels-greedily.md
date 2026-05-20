---
title: Place and Declutter Labels Greedily by Priority
impact: MEDIUM-HIGH
impactDescription: prevents overlapping, unreadable label pileups
tags: text, label-placement, collision, declutter, priority
---

## Place and Declutter Labels Greedily by Priority

Every region wants a label, but at any zoom only a fraction fit without overlapping; drawing them all produces a pile where no single name is readable. Sort candidate labels by importance (region size, selection, search match), then place greedily — for each label in priority order, reserve its bounding box only if it does not collide with an already-placed box. Lower-priority labels that would overlap are dropped, not stacked. The result is the most important names, always legible.

**Incorrect (a label per region):**

```typescript
for (const region of regions) ctx.fillText(region.name, region.cx, region.cy); // smear
```

**Correct (place by priority; skip any that collide):**

```typescript
const placed: Box[] = [];
for (const region of [...regions].sort((a, b) => b.weight - a.weight)) {
  const box = measure(ctx, region.name, region.cx, region.cy);
  if (placed.some((p) => overlaps(p, box))) continue;   // drop, do not stack
  placed.push(box);
  ctx.fillText(region.name, region.cx, region.cy);
}
```

Gate which tier of labels is even a candidate by zoom first ([[text-show-labels-by-level-of-detail]]) so the collision pass has less to reject.

**When NOT to apply:**
- A sparse map whose labels never collide does not need declutter — measure first, add it when overlap actually appears.

Reference: [MapLibre GL JS (symbol collision)](https://maplibre.org/); [Munzner, Visualization Analysis & Design](https://www.cs.ubc.ca/~tmm/vadbook/)
