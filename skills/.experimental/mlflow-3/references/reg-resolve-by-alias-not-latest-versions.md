---
title: Resolve versions by alias, not get_latest_versions
tags: reg, aliases, lookup, deployment
---

## Resolve versions by alias, not get_latest_versions

`client.get_latest_versions(name, stages=["Production"])` is the MLflow 2 lookup idiom and is deprecated together with stages. Its stage-free cousin — resolving `models:/<name>/latest` — is also a trap for deployment code: "latest" means highest version number, which is whatever was registered most recently, not whatever passed review. Deployment and inference code should resolve through an explicitly assigned alias, which only moves when someone (or some pipeline) moves it.

```python
from mlflow import MlflowClient

client = MlflowClient()
champion = client.get_model_version_by_alias("prod.growth.churn_classifier", "champion")
print(champion.version, champion.tags)

# or directly in a load
model = mlflow.pyfunc.load_model("models:/prod.growth.churn_classifier@champion")
```

**When NOT to use this pattern:** ad-hoc notebook exploration of the newest candidate — `models:/<name>/latest` is fine when "most recently registered" is genuinely what you mean.

Reference: [Model Registry workflow — aliases and tags](https://mlflow.org/docs/latest/ml/model-registry/workflow/)
