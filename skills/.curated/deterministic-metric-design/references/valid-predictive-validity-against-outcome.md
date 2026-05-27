---
title: Show Predictive Validity Against the Outcome You Care About
impact: MEDIUM-HIGH
impactDescription: prevents acting on an assumed, unmeasured metric-outcome link
tags: valid, predictive-validity, criterion, outcome
---

## Show Predictive Validity Against the Outcome You Care About

Construct validity ultimately rests on criterion validity: the metric must predict the real-world outcome it is supposed to be a leading indicator of. "High complexity means more bugs" is a hypothesis, not a fact, until you measure whether the metric actually forecasts defects, change effort, or incidents on data the metric never saw. A metric that explains nothing about the outcome it was built to anticipate is a number without a job.

**Incorrect (assumed predictive power):**

```python
# We assume complexity → defects and act on it; the link is never measured.
if cyclomatic(module) > 10:
    flag_as_risky(module)
```

**Correct (measure prediction on held-out outcomes):**

```python
# Does the metric forecast post-release defects on modules it was not tuned on?
auc = roc_auc_score(
    y_true=[had_post_release_defect[m] for m in holdout],
    y_score=[cyclomatic(m)            for m in holdout],
)
assert auc > 0.65, f"weak predictive validity (AUC={auc:.2f}) — the construct link does not hold"
```

Reference: [Cronbach & Meehl, "Construct Validity in Psychological Tests" (1955) — criterion and predictive validity](https://psychclassics.yorku.ca/Cronbach/construct.htm)
