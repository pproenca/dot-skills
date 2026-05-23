---
title: Aggregate Only in Ways the Scale Permits
impact: LOW-MEDIUM
impactDescription: prevents means of ordinal data and naive averaging of ratios
tags: agg, aggregation, scale-type, distribution
---

## Aggregate Only in Ways the Scale Permits

Rolling per-unit values into one number must respect the scale (see `meas-`): you cannot mean an ordinal scale, and averaging per-module ratios weights a 10-line file the same as a 10,000-line one. Choose the aggregation the scale and the question allow — medians and full distributions for ordinal or skewed data, size-weighted aggregation for ratios you want at the system level, geometric means for multiplicative rates. A single arithmetic mean over the wrong scale hides exactly the signal you aggregated to find.

**Incorrect (unweighted mean of per-module ratios):**

```python
dup = mean(duplication_ratio(m) for m in modules)   # a tiny file and a huge file count equally
```

**Correct (aggregate the way the quantity demands):**

```python
# System duplication = total cloned nodes / total nodes — a real, size-weighted ratio.
dup = sum(cloned_nodes(m) for m in modules) / sum(total_nodes(m) for m in modules)
# Ordinal severities cannot be meaned — report the distribution.
severity_dist = Counter(i.sev for m in modules for i in m.issues)
```

Reference: [Stevens, "On the Theory of Scales of Measurement," *Science* 103(2684) (1946)](https://www.science.org/doi/10.1126/science.103.2684.677)
