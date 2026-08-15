---
title: Pin dependencies through the generated environment files
tags: env, requirements, uv, reproducibility
---

## Pin dependencies through the generated environment files

A hand-rolled serving Dockerfile that `pip install`s a requirements list maintained by humans drifts from what the model was trained with — and it ignores that every `log_model` already writes the authoritative environment (`python_env.yaml`, `requirements.txt`, `conda.yaml`) next to the model, which is exactly what `mlflow models serve`, `build-docker`, and `mlflow.models.predict` rebuild from. Control that generated environment at log time: `pip_requirements=` replaces the inferred list, `extra_pip_requirements=` appends to it, and in a uv project MLflow captures the lockfile automatically (point `uv_project_path=` at it explicitly when logging from outside the project root).

```python
import mlflow

mlflow.sklearn.log_model(
    price_model,
    name="price_model",
    input_example=X_sample,
    extra_pip_requirements=["feature-store-client==2.4.1"],  # inferred deps + this
)
```

Reference: [MLflow model dependencies](https://mlflow.org/docs/latest/ml/model/dependencies/)
