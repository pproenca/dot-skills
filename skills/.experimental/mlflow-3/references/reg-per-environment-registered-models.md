---
title: Create one registered model per environment
tags: reg, environments, copy-model-version, promotion
---

## Create one registered model per environment

An MLflow 2-era design puts dev, staging, and prod on one registered model and moves versions between stages — but stages are deprecated, and one shared model gives every environment the same access-control surface. The official OSS pattern is one registered model per environment and problem — `dev.growth.churn_classifier`, `staging.growth.churn_classifier`, `prod.growth.churn_classifier` — with promotion as `copy_model_version`, which copies a version (artifacts and lineage included) from the source model to the target. The source URI must use the `models:/` scheme, and copying from an alias means you promote exactly the version the alias points at. Per-environment models are also the unit registered-model permissions bind to — grants are per model name (no glob patterns in OSS auth), so give the CI principal EDIT on each `prod.`-named model while humans keep READ.

```python
from mlflow import MlflowClient

client = MlflowClient()

# Promotion = copy the staged candidate into the prod-scoped model
prod_version = client.copy_model_version(
    src_model_uri="models:/staging.growth.churn_classifier@candidate",
    dst_name="prod.growth.churn_classifier",
)
client.set_registered_model_alias(
    "prod.growth.churn_classifier", alias="champion", version=prod_version.version
)
```

Reference: [Model Registry workflow — promoting across environments](https://mlflow.org/docs/latest/ml/model-registry/workflow/)
