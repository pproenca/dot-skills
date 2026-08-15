---
title: Expect skops and torch.export defaults, not pickle
tags: log, serialization, skops, security
---

## Expect skops and torch.export defaults, not pickle

Since MLflow 3.14, `mlflow.sklearn` and `mlflow.lightgbm` serialize with **skops** by default (not cloudpickle), `mlflow.pytorch` uses **torch.export** (`"pt2"`), and `mlflow.xgboost` has written UBJSON (`"ubj"`) since 3.6 — pickle-based formats now trigger a security warning when saving. This breaks two MLflow 2-era assumptions: any consumer that side-loads the artifact bytes directly (`joblib.load(".../model.pkl")`) reads a format that is no longer there, and loading models saved with pickle by older MLflow versions is gated by `MLFLOW_ALLOW_PICKLE_DESERIALIZATION` (currently defaulting to true) and may need `skops_trusted_types` for non-standard estimator internals. Load through `mlflow.pyfunc.load_model` / `mlflow.sklearn.load_model` and the format is handled for you.

```python
import mlflow

# Default in 3.14+: skops — no code change needed for the normal path
model_info = mlflow.sklearn.log_model(price_model, name="price_model", input_example=X_sample)

# Only if a downstream consumer genuinely requires pickle bytes:
mlflow.sklearn.log_model(
    price_model,
    name="price_model_legacy",
    serialization_format="cloudpickle",  # emits a security warning by design
)
```

Reference: [MLflow 3.14.0 changelog](https://github.com/mlflow/mlflow/blob/v3.15.1/CHANGELOG.md) · [mlflow/sklearn (v3.15.1)](https://github.com/mlflow/mlflow/blob/v3.15.1/mlflow/sklearn/__init__.py)
