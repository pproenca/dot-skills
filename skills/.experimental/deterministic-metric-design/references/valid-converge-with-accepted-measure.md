---
title: Establish Convergent Validity Against an Accepted Measure
impact: MEDIUM-HIGH
impactDescription: prevents shipping a metric with no evidence it tracks its construct
tags: valid, convergent-validity, correlation, construct-validity
---

## Establish Convergent Validity Against an Accepted Measure

A new metric should agree with an existing, trusted measure of the *same* construct wherever the two overlap. If your "maintainability" metric correlates with nothing anyone already accepts as maintainability — not expert ratings, not an established index — you have no evidence it measures the construct at all, only an assertion. Convergent validity turns "I designed it carefully" into "it agrees with what we already trust, and here is the coefficient."

**Incorrect (no convergence evidence):**

```python
# Ship the metric; its link to maintainability is argued in prose, never measured.
maintainability = compute_maintainability(module)
```

**Correct (correlate with an accepted measure on a sample):**

```python
# Convergent check: does it track expert maintainability ratings on a labelled sample?
rho, p = spearmanr(
    [compute_maintainability(m) for m in sample],
    [expert_rating[m]            for m in sample],   # the accepted measure
)
assert rho > 0.5 and p < 0.05, f"weak convergence (rho={rho:.2f}) — construct link unproven"
```

Use a rank correlation (Spearman) when either measure is ordinal — do not assume linearity you have not earned.

Reference: [Campbell & Fiske, "Convergent and discriminant validation by the multitrait-multimethod matrix," *Psychological Bulletin* 56(2) (1959)](https://psycnet.apa.org/doi/10.1037/h0046016)
