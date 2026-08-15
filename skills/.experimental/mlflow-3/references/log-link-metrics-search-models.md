---
title: Link metrics to models and search logged models
tags: log, metrics, search-logged-models, datasets
---

## Link metrics to models and search logged models

In MLflow 2, metrics attach only to runs, so comparing candidate models means joining runs to artifacts by hand. MLflow 3's `mlflow.log_metric` takes `model_id=` and `dataset=`, attaching the measurement to the model it describes (and the data it was measured on), and `mlflow.search_logged_models` then ranks models directly by those metrics — no run bookkeeping. Metrics logged during an active run with a model logged in that run are back-filled onto the LoggedModel automatically; explicit linkage matters when one run produces several candidate models or when evaluating outside the training run.

```python
import mlflow

eval_data = mlflow.data.from_pandas(holdout_df, name="holdout_2026q3")
mlflow.log_metric("rmse", rmse, model_id=model_info.model_id, dataset=eval_data)

best = mlflow.search_logged_models(
    experiment_ids=[exp.experiment_id],
    filter_string="metrics.rmse < 4.5",
    order_by=[{"field_name": "metrics.rmse", "ascending": True}],
    output_format="list",
)[0]
```

Reference: [MLflow 3 — logged models](https://mlflow.org/docs/latest/ml/mlflow-3/) · [mlflow/tracking/fluent.py (v3.15.1)](https://github.com/mlflow/mlflow/blob/v3.15.1/mlflow/tracking/fluent.py)
