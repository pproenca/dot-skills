---
title: Promote with aliases, not registry stages
tags: reg, aliases, stages, promotion
---

## Promote with aliases, not registry stages

`transition_model_version_stage` and the fixed `Staging`/`Production` stage vocabulary are deprecated since 2.9 and scheduled for removal in a future major release — a promotion pipeline built on them is built on a countdown. Aliases replace stages as mutable named pointers: `set_registered_model_alias` retargets `@champion` to a new version atomically, a version can hold several aliases (enabling champion/challenger side by side), and deployments load `models:/<name>@<alias>` so a promotion is an alias flip with no redeploy. Alias names `latest` and `v<number>` (for example `v9`) are reserved and rejected — they collide with the version-URI grammar.

**Incorrect (deprecated stage API — removal scheduled):**

```python
client.transition_model_version_stage(
    name="churn_classifier", version=7, stage="Production"
)
model = mlflow.pyfunc.load_model("models:/churn_classifier/Production")
```

**Correct (alias as the deployment pointer):**

```python
client.set_registered_model_alias("churn_classifier", alias="champion", version=7)
model = mlflow.pyfunc.load_model("models:/churn_classifier@champion")
```

Reference: [Model Registry workflow — aliases and tags](https://mlflow.org/docs/latest/ml/model-registry/workflow/) · [mlflow/tracking/client.py (v3.15.1)](https://github.com/mlflow/mlflow/blob/v3.15.1/mlflow/tracking/client.py)
