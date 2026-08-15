---
title: Log models with name, not artifact_path
tags: log, log-model, logged-model, deprecation
---

## Log models with name, not artifact_path

Every MLflow 2 tutorial writes `log_model(model, "model")` — the second positional argument is `artifact_path`, which is deprecated in MLflow 3 and emits a warning on every call; passing both `artifact_path` and `name` raises an `MlflowException`. `name=` is not a rename — it creates a first-class LoggedModel entity that is searchable by name and addressable as `models:/<model_id>`, while `artifact_path` merely placed files under the run.

**Incorrect (MLflow 2 idiom — deprecated, warns on every call):**

```python
import mlflow

with mlflow.start_run():
    mlflow.sklearn.log_model(churn_model, "model")
```

**Correct (MLflow 3 — named LoggedModel):**

```python
import mlflow

model_info = mlflow.sklearn.log_model(
    churn_model,
    name="churn_classifier",
    input_example=X_train.head(5),
)
print(model_info.model_uri)  # models:/<model_id>
```

Reference: [MLflow 3 migration guide](https://mlflow.org/docs/latest/ml/mlflow-3/) · [mlflow/models/model.py (v3.15.1)](https://github.com/mlflow/mlflow/blob/v3.15.1/mlflow/models/model.py)
