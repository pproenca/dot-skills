---
title: Bound the Approximation Gap, Don't Leave It Implicit
impact: HIGH
impactDescription: prevents an unquantified proxy from being trusted as exact
tags: comp, approximation, error-bound, mdl
---

## Bound the Approximation Gap, Don't Leave It Implicit

Once you accept that the proxy differs from the ideal, the size of that gap is itself information consumers need. A lower bound that recovers 95% of the ideal is a different tool from one that recovers 30%, and a reader given only the bare number will treat it as exact. Quantify the gap — analytically as an approximation ratio when you can, empirically as recovery rate against a labeled corpus otherwise — and ship that number with the metric.

**Incorrect (proxy shipped with no statement of looseness):**

```python
return removable_lower_bound(module, T, O)   # within 5% of truth, or 80%? unknown to the caller
```

**Correct (gap quantified and reported alongside the value):**

```python
value = removable_lower_bound(module, T, O)
# Calibration on labeled corpus L (expert-verified removable nodes):
#   recall vs. truth = 0.78; false-positive rate = 0.0 by construction (sound lower bound).
return Measurement(value=value, recall_vs_truth=0.78, direction="lower_bound")
```

Recording the gap also tells you where to invest: 78% recall says enlarging the transform set `T` is the highest-leverage next improvement, not retuning weights.

Reference: [Grünwald, *The Minimum Description Length Principle*, MIT Press](https://mitpress.mit.edu/9780262072816/the-minimum-description-length-principle/)
