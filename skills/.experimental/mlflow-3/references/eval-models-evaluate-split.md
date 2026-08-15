---
title: Evaluate classic models with mlflow.models.evaluate
tags: eval, evaluate, genai, deprecation
---

## Evaluate classic models with mlflow.models.evaluate

Top-level `mlflow.evaluate(...)` — the MLflow 2 idiom — now emits a `FutureWarning` and forwards to a split API, and picking the wrong branch is the new trap: `mlflow.models.evaluate` keeps the classic API (model or URI, `data`, `targets`, `model_type="classifier"|"regressor"`, plus `model_id=` for LoggedModel linkage) for traditional ML and deep learning, while `mlflow.genai.evaluate` is a different API built on scorers and traces for LLM applications. Pointing a classifier at `genai.evaluate`, or an LLM app at `models.evaluate`, fails or measures the wrong thing.

```python
import mlflow

result = mlflow.models.evaluate(
    model=model_info.model_uri,
    data=holdout_df,
    targets="churned",
    model_type="classifier",
    model_id=model_info.model_id,
)
print(result.metrics["f1_score"])
```

Reference: [MLflow 3 migration guide](https://mlflow.org/docs/latest/ml/mlflow-3/) · [mlflow/models/evaluation (v3.15.1)](https://github.com/mlflow/mlflow/blob/v3.15.1/mlflow/models/evaluation/deprecated.py)
