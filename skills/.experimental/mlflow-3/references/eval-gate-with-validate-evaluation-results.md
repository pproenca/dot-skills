---
title: Gate promotions with validate_evaluation_results
tags: eval, thresholds, baseline, promotion
---

## Gate promotions with validate_evaluation_results

The MLflow 2 promotion gate passed `baseline_model=` and `custom_metrics=` to `mlflow.evaluate` — both are **removed** in MLflow 3 (and `MetricThreshold`'s `higher_is_better` was renamed `greater_is_better`). Baseline comparison is now explicit: evaluate the candidate and the baseline separately, then assert with `mlflow.validate_evaluation_results`, which raises `ModelValidationFailedException` when a threshold is not met — the natural CI gate before a `copy_model_version` promotion. Custom metrics moved to `extra_metrics` (built with `mlflow.models.make_metric`).

```python
import mlflow
from mlflow.models import MetricThreshold

candidate = mlflow.models.evaluate(model=candidate_uri, data=holdout_df,
                                   targets="churned", model_type="classifier")
baseline = mlflow.models.evaluate(model=champion_uri, data=holdout_df,
                                  targets="churned", model_type="classifier")

mlflow.validate_evaluation_results(
    candidate_result=candidate,
    baseline_result=baseline,
    validation_thresholds={
        "f1_score": MetricThreshold(min_absolute_change=0.01, greater_is_better=True),
    },
)  # raises if the candidate does not beat the champion by ≥ 0.01 F1
```

Reference: [MLflow 3 migration guide — evaluate changes](https://mlflow.org/docs/latest/ml/mlflow-3/)
