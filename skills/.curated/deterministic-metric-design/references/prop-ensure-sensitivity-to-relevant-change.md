---
title: Ensure Sensitivity to the Changes That Should Matter
impact: HIGH
impactDescription: prevents a metric that saturates and stops discriminating
tags: prop, sensitivity, discrimination, saturation
---

## Ensure Sensitivity to the Changes That Should Matter

Invariance has a twin: the metric must *change* when the construct genuinely changes. Weyuker's non-coarseness properties capture this — a useful measure must assign different values to programs that genuinely differ. A measure that saturates (pinned near 1.0 for everything past a trivial size, or floored to 0 across a wide range) cannot discriminate the cases you care about, so optimizing it does nothing once you are in the flat region. Match the dynamic range to the population and verify the metric separates anchor cases that truly differ.

**Incorrect (saturates across the interesting range):**

```python
def coupling(module):
    return 1 - 1 / (1 + crossing_edges(module))   # any module past a few edges reads ~1.0
# 12 cross-edges and 1,200 cross-edges both score ~1.0 — no discrimination where it matters.
```

**Correct (range matched to the population; discrimination verified):**

```python
def coupling(module):
    x = crossing_edges(module)
    return x / (x + internal_edges(module) + 1)    # spreads across the real population

assert coupling("layered_service") < coupling("god_object")   # actually separates distinct cases
```

Reference: [Weyuker, "Evaluating Software Complexity Measures," *IEEE TSE* 14(9) (1988) — non-coarseness](https://doi.org/10.1109/32.6178)
