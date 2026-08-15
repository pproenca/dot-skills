---
title: Validate with mlflow.models.predict before deploying
tags: serve, validation, predict, env-manager
---

## Validate with mlflow.models.predict before deploying

The MLflow 2-era pre-deploy check — `mlflow.models.validate_serving_input` — is deprecated since 3.13, and the older habit of "just call `model.predict` in the notebook" validates nothing about the serving environment, because the notebook already has every dependency installed. `mlflow.models.predict` rebuilds the model's environment from its generated requirement files in an isolated env (`env_manager="uv"` is the fast option) and runs the same pyfunc path the scoring server uses, so dependency gaps, schema mismatches, and serialization problems surface before a container ever ships.

```python
import mlflow

mlflow.models.predict(
    model_uri="models:/staging.growth.churn_classifier@candidate",
    input_data=holdout_df.head(5),
    env_manager="uv",
)
```

Reference: [Deploy model locally — validating before deployment](https://mlflow.org/docs/latest/ml/deployment/deploy-model-locally/) · [mlflow/models/python_api.py (v3.15.1)](https://github.com/mlflow/mlflow/blob/v3.15.1/mlflow/models/python_api.py)
