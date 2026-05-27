---
title: Use Only Statistics Admissible for the Scale
impact: HIGH
impactDescription: prevents "20% better" claims the scale cannot support
tags: meas, admissible-statistics, interval-scale, ratio-scale
---

## Use Only Statistics Admissible for the Scale

Each scale is defined by the transformations that preserve its meaning — ordinal by any monotonic transform, interval by affine `ax + b`, ratio by similarity `ax`. A statistic is admissible only if it is invariant under those transformations. Means and standard deviations are fine on interval scales, but *ratios are not*: "20% more" is meaningless when the zero is arbitrary. Ratios and geometric means require a true zero. An inadmissible statistic yields a conclusion that flips when someone harmlessly rescales the metric.

**Incorrect (ratio claim on an interval scale):**

```python
# "quality score" 0-100 with an arbitrary zero → interval, not ratio
improvement = (after - before) / before
report(f"{improvement:.0%} quality improvement")   # rescaling the score changes this number
```

**Correct (differences on interval; ratios only on ratio scales):**

```python
# Interval scale: report the difference, which IS affine-invariant.
report(f"+{after - before} quality points")
# Reserve ratio language ("twice as", "30% fewer") for ratio-scaled metrics like AST nodes removed.
```

Reference: [Stevens, "On the Theory of Scales of Measurement," *Science* 103(2684) (1946)](https://www.science.org/doi/10.1126/science.103.2684.677)
