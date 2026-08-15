---
title: Pass an input example and let the signature infer
tags: log, signature, input-example, schema-enforcement
---

## Pass an input example and let the signature infer

The MLflow 2 boilerplate calls `infer_signature(X, y)` by hand — or skips the signature entirely because nothing forces one. In MLflow 3, passing `input_example=` does the whole job: the signature is inferred from the example when `signature=None`, and by default MLflow also validates the example against the model through the local pyfunc serving path at log time, so a model that would fail in the scoring server fails at `log_model` instead. The signature matters at serving: when present, the scoring server enforces it (missing columns are an error, extra columns are dropped, types are safely converted), and inference-time `params` are only honored if the signature declares them. `infer_signature` remains available for cases needing explicit control, such as declaring optional columns or a params schema.

```python
import mlflow

model_info = mlflow.sklearn.log_model(
    fraud_scorer,
    name="fraud_scorer",
    input_example=transactions.head(5),  # signature inferred + serving-validated here
)
```

**When NOT to use this pattern:** models whose input can't be represented as an example (custom pyfunc taking exotic types) — build a signature with `mlflow.models.infer_signature` and pass it explicitly, or pass `signature=False` to opt out knowingly.

Reference: [MLflow model signatures](https://mlflow.org/docs/latest/ml/model/signatures/) · [mlflow/sklearn (v3.15.1)](https://github.com/mlflow/mlflow/blob/v3.15.1/mlflow/sklearn/__init__.py)
