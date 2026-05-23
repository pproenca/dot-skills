---
title: Beat the Trivial Baseline, Explicitly
impact: MEDIUM
impactDescription: prevents shipping a metric that fails to beat a trivial baseline
tags: valid, baseline, lift, evaluation
---

## Beat the Trivial Baseline, Explicitly

Every metric competes against a dumb baseline for its decision task — predict the majority class, use LOC, pick at random. If the elaborate metric does not measurably beat that baseline on the actual decision, its sophistication is cost without benefit. Report the baseline's performance next to the metric's and quote the lift; a metric that ties the baseline should be replaced by the baseline, which is cheaper and more transparent.

**Incorrect (accuracy reported in isolation):**

```python
report(f"risk model accuracy = {accuracy:.2f}")   # 0.82 — but the base rate is 0.80
```

**Correct (lift over an explicit baseline):**

```python
from sklearn.dummy import DummyClassifier
baseline = DummyClassifier(strategy="most_frequent").fit(X_train, y_train).score(X_test, y_test)
lift = model.score(X_test, y_test) - baseline
assert lift > 0.0, f"metric does not beat the trivial baseline ({baseline:.2f}) — drop it"
report(f"metric {model_score:.2f} vs. baseline {baseline:.2f} (lift {lift:+.2f})")
```

Reference: [scikit-learn — Dummy estimators as baselines](https://scikit-learn.org/stable/modules/model_evaluation.html#dummy-estimators)
