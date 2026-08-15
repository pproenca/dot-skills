---
title: Treat logged models as entities, not run artifacts
tags: log, logged-model, model-uri, artifacts
---

## Treat logged models as entities, not run artifacts

Two MLflow 2 habits break in MLflow 3 because models moved out of the run's artifact tree. First, `log_model` no longer needs `mlflow.start_run()` — it creates a LoggedModel with or without an active run (linking to the run when one exists), so training scripts don't have to contort model logging into run scope. Second, model files now live under `models/<model_id>/artifacts/`, not `runs/<run_id>/artifacts/model/` — the run's artifact listing comes back empty and the Artifacts tab in the UI no longer shows the model. A `runs:/<run_id>/<name>` URI still resolves as a compatibility bridge, but only if `<name>` matches what the model was actually logged as — the MLflow 2 habit of hardcoding `runs:/<run_id>/model` breaks the moment the name is anything else. Address models through `model_info.model_uri` (`models:/<model_id>`) instead of composing run paths by hand.

```python
import mlflow

# No run required — log_model stands alone
model_info = mlflow.sklearn.log_model(
    demand_forecaster,
    name="demand_forecaster",
    input_example=features_sample,
)

# Retrieve through the model URI, never through run artifacts
loaded = mlflow.pyfunc.load_model(model_info.model_uri)
mlflow.artifacts.download_artifacts(artifact_uri=model_info.model_uri)
```

Reference: [MLflow 3 migration guide](https://mlflow.org/docs/latest/ml/mlflow-3/)
