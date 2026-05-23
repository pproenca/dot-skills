---
title: Report Uncertainty, Not a False-Precision Point Estimate
impact: LOW-MEDIUM
impactDescription: prevents over-trusting a number the sampling can't support
tags: agg, uncertainty, confidence-interval, reporting
---

## Report Uncertainty, Not a False-Precision Point Estimate

A lone "72.8%" implies a precision the sampling, approximation, or proxy gap does not have, and consumers will set fine-grained thresholds against digits that are noise. Report the uncertainty — a bootstrap confidence interval for a sampled estimate, or the proven bound band for an approximate proxy — so decisions account for the slack. A number without an error bar is a claim of perfect knowledge you cannot back.

**Incorrect (false precision):**

```python
report(f"technical debt = {debt:.1f}%")   # 72.8% — to a tenth of a percent, from a 30-repo sample?
```

**Correct (estimate with an interval):**

```python
lo, hi = bootstrap_ci(debt_samples, confidence=0.95)
report(f"technical debt ≈ {debt:.0f}%  (95% CI {lo:.0f}–{hi:.0f}%)")
# For a sound lower-bound proxy, report the band: "≥ {value} removable nodes (recall ≈ 0.78)".
```

Reference: [Efron, "Bootstrap Methods: Another Look at the Jackknife," *Annals of Statistics* 7(1) (1979)](https://doi.org/10.1214/aos/1176344552)
