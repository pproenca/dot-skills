---
title: Register at log time through the model URI
tags: log, registry, register-model, model-uri
---

## Register at log time through the model URI

The MLflow 2 idiom registers in a second step with a hand-built run URI — `mlflow.register_model(f"runs:/{run.info.run_id}/model", ...)` — which couples registration to run internals and to the legacy URI scheme. In MLflow 3, `registered_model_name=` on `log_model` registers the version in the same call, keyed on the LoggedModel's `models:/<model_id>` URI; when registration must be a separate decision (for example, only after an evaluation gate), register `model_info.model_uri`, never a composed `runs:/` path.

```python
import mlflow

# Register in the same call
model_info = mlflow.sklearn.log_model(
    churn_model,
    name="churn_classifier",
    input_example=X_sample,
    registered_model_name="dev.growth.churn_classifier",
)

# Or as a separate, gated step
version = mlflow.register_model(model_info.model_uri, "dev.growth.churn_classifier")
```

Reference: [MLflow Model Registry](https://mlflow.org/docs/latest/ml/model-registry/) · [mlflow/models/model.py (v3.15.1)](https://github.com/mlflow/mlflow/blob/v3.15.1/mlflow/models/model.py)
