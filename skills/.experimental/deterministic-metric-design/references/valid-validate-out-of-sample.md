---
title: Validate Out-of-Sample to Avoid Overfitting the Corpus
impact: MEDIUM
impactDescription: prevents overfit validity inflated by tuning on the test set
tags: valid, overfitting, cross-validation, holdout
---

## Validate Out-of-Sample to Avoid Overfitting the Corpus

Tuning a metric's weights or threshold on the same data you then report validity against inflates every number — you are grading the metric on the answers it was fitted to. Validity must be measured on data the tuning never touched: cross-validation, or better for code that evolves over time, a temporal holdout (fit on last year, test on this year) so you measure prediction, not memorization. A metric that looks strong in-sample and collapses out-of-sample was overfit, and will fail in production.

**Incorrect (fit and evaluate on the same repos):**

```python
weights = fit_weights(all_repos)                 # tuned on everything
auc = evaluate(all_repos, weights)               # ...then scored on the same everything → inflated
```

**Correct (temporal holdout; report out-of-sample):**

```python
train = repos_snapshot(year=2025)
test  = repos_snapshot(year=2026)                # strictly later — no leakage from the future
weights = fit_weights(train)
auc = evaluate(test, weights)                    # the number you are allowed to quote
```

Reference: [scikit-learn — Cross-validation: evaluating estimator performance](https://scikit-learn.org/stable/modules/cross_validation.html)
