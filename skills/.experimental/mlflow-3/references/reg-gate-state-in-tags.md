---
title: Track approval gates with model version tags
tags: reg, tags, gates, validation
---

## Track approval gates with model version tags

Stage transitions used to carry review semantics implicitly ("it's in Staging, so it's under review"). With aliases, that state needs an explicit home, and the official pattern is model-version tags — `validation_status: pending` set at registration, flipped to `approved` by the evaluation gate, checked before any alias flip. Without this, the only registry state is the alias itself, and a promotion script cannot distinguish "evaluated and approved" from "just registered".

```python
from mlflow import MlflowClient

client = MlflowClient()
client.set_model_version_tag(
    "staging.growth.churn_classifier", version.version,
    key="validation_status", value="pending",
)

# ... evaluation gate passes ...
client.set_model_version_tag(
    "staging.growth.churn_classifier", version.version,
    key="validation_status", value="approved",
)
client.set_registered_model_alias(
    "staging.growth.churn_classifier", alias="candidate", version=version.version
)
```

Reference: [Model Registry workflow — aliases and tags](https://mlflow.org/docs/latest/ml/model-registry/workflow/)
