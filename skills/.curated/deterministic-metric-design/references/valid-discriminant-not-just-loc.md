---
title: Prove Discriminant Validity — It Isn't Just Size in Disguise
impact: MEDIUM-HIGH
impactDescription: prevents shipping a metric that is ~0.9 correlated with LOC
tags: valid, discriminant-validity, confound, partial-correlation
---

## Prove Discriminant Validity — It Isn't Just Size in Disguise

The canonical metric failure is cyclomatic complexity correlating around 0.9 with raw lines of code: it feels like a distinct "complexity" signal but is mostly a length count wearing a graph-theory costume. A metric that correlates near-perfectly with a trivial baseline (LOC, token count) adds nothing over that baseline. Control for the baseline and show the metric carries *incremental* signal — variance the cheap measure does not already explain.

**Incorrect (reported as a distinct signal, confound unchecked):**

```python
report("complexity risk", cyclomatic(module))   # never checked against LOC
```

**Correct (partial out the baseline; show incremental signal):**

```python
# Does cyclomatic predict defects BEYOND what LOC already predicts?
full   = fit(defects ~ loc + cyclomatic, data)
base   = fit(defects ~ loc,             data)
delta_r2 = full.r2 - base.r2
assert delta_r2 > 0.05, f"cyclomatic adds only {delta_r2:.3f} R² over LOC — not discriminant"
```

If the metric collapses into the baseline, either drop it or redefine the construct so it captures what size cannot.

Reference: [Campbell & Fiske, "Convergent and discriminant validation by the multitrait-multimethod matrix," *Psychological Bulletin* 56(2) (1959)](https://psycnet.apa.org/doi/10.1037/h0046016)
