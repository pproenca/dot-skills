---
title: Bundle custom code with code_paths or infer_code_paths
tags: env, code-paths, pyfunc, module-not-found
---

## Bundle custom code with code_paths or infer_code_paths

A model whose pipeline references project code — a custom transformer, a feature module, a pyfunc wrapper class — loads fine on the training machine because the module is importable there, then dies with `ModuleNotFoundError` in the serving container, where only the model artifact exists. The part a model won't reach for on its own: `mlflow.pyfunc.log_model(..., infer_code_paths=True)` detects the needed modules automatically (pyfunc only), instead of hand-maintaining the `code_paths=[...]` list that goes stale as imports move. Either way the import graph ships inside the artifact and is prepended to `sys.path` at load. This failure is invisible until serving unless log-time validation runs — one more reason to pass `input_example` and pre-deploy with `mlflow.models.predict`.

```python
import mlflow

model_info = mlflow.pyfunc.log_model(
    name="churn_scorer",
    python_model=ChurnScorer(sk_model=churn_model),
    input_example=X_sample,
    code_paths=["src/features", "src/scoring_utils.py"],
)
```

Reference: [Models from code and code_paths](https://mlflow.org/docs/latest/ml/model/dependencies/) · [mlflow/pyfunc (v3.15.1)](https://github.com/mlflow/mlflow/blob/v3.15.1/mlflow/pyfunc/__init__.py)
