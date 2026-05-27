---
title: Declare the Scale Type Before Choosing Statistics
impact: HIGH
impactDescription: prevents meaningless means and ratios on ordinal data
tags: meas, scale-type, stevens, statistics
---

## Declare the Scale Type Before Choosing Statistics

A measure's scale type — nominal, ordinal, interval, or ratio (Stevens) — fixes which arithmetic is meaningful. The average of ordinal severity codes, or a "percent improvement" on a scale with an arbitrary zero, are numbers that look quantitative but encode nothing: the gap from low to medium need not equal the gap from medium to high, so their mean is an artifact of the coding. Declaring the scale type *with* the metric tells every consumer which operations are legal before anyone computes a statistic.

**Incorrect (mean of an ordinal scale):**

```python
SEVERITY = {"low": 1, "medium": 2, "high": 3}      # ordinal codes, not quantities
avg = sum(SEVERITY[i.sev] for i in issues) / len(issues)
report(f"average severity = {avg:.1f}")            # "2.3" assumes equal spacing it does not have
```

**Correct (scale declared; order-based summary):**

```python
# Scale: ORDINAL. Admissible summaries: median, mode, percentiles — never the mean.
codes = sorted(SEVERITY[i.sev] for i in issues)            # numeric ranks, ordered
report(median_rank=codes[len(codes) // 2],
       distribution=Counter(i.sev for i in issues))        # the honest summary
```

Reference: [Stevens, "On the Theory of Scales of Measurement," *Science* 103(2684) (1946)](https://www.science.org/doi/10.1126/science.103.2684.677)
