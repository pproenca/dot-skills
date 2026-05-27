---
title: Avoid Ad-Hoc Weighted Sums Across Incommensurable Scales
impact: MEDIUM-HIGH
impactDescription: prevents unfalsifiable weighted sums across incommensurable scales
tags: meas, composite-metric, weighting, validity
---

## Avoid Ad-Hoc Weighted Sums Across Incommensurable Scales

Combining sub-measures with different units and scales into one weighted sum (`0.4·LOC + 0.3·cyclomatic + 0.3·comment_ratio`) has no measurement-theoretic meaning: the weights are unfalsifiable, the result's scale is undefined, and a change in one component's units silently rebalances everything. Either keep the components as a vector and report them, or learn the weights by fitting against a real, measured outcome — then the composite inherits that outcome's scale and can actually be validated.

**Incorrect (arbitrary weights across incommensurable scales):**

```python
health = 0.4*norm(loc) + 0.3*norm(cyclomatic) + 0.3*norm(comment_ratio)   # why these weights?
# Change how `norm` scales any one input and every "health" number shifts — yet nothing is falsifiable.
```

**Correct (fit to an outcome, or keep the vector):**

```python
# Option A — learn weights against a measured outcome; the composite is calibrated to it.
risk = fitted_model.predict([loc, cyclomatic, comment_ratio])   # weights = fitted coefficients
# Option B — don't collapse; report the component vector and let the decision rule combine it.
return {"loc": loc, "cyclomatic": cyclomatic, "comment_ratio": comment_ratio}
```

Reference: [Fenton & Bieman, *Software Metrics* — combining and validating measures](https://www.routledge.com/Software-Metrics-A-Rigorous-and-Practical-Approach-Third-Edition/Fenton-Bieman/p/book/9781439838228)
