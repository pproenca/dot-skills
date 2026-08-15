---
title: Use registry webhooks for CI triggers in OSS MLflow
tags: reg, webhooks, ci, databricks
---

## Use registry webhooks for CI triggers in OSS MLflow

Two symmetric scoping mistakes here. First, webhooks are assumed Databricks-only — but OSS MLflow has registry webhooks since 3.3: `client.create_webhook` with HMAC-signed payloads, firing on `model_version.created`, `model_version_tag.set`, `model_version_alias.created` and friends — exactly the events a promotion pipeline needs to trigger CI. (They require a database-backed registry, and CRUD is admin-only under basic-auth.) Second, the reverse: **Deployment Jobs are a Databricks/Unity Catalog feature**, not OSS — the OSS store accepts `deployment_job_id` in its API surface but never persists or uses it, so scaffolding deployment jobs against a self-hosted server builds against a no-op.

```python
import os

from mlflow import MlflowClient

client = MlflowClient()
client.create_webhook(
    name="promote-on-approval",
    url="https://ci.internal.example.com/hooks/mlflow",
    events=["model_version_tag.set", "model_version_alias.created"],
    secret=os.environ["MLFLOW_WEBHOOK_SECRET"],  # payloads arrive HMAC-signed
)
```

Reference: [MLflow 3.3.0 changelog — registry webhooks](https://github.com/mlflow/mlflow/blob/v3.15.1/CHANGELOG.md) · [mlflow/tracking/client.py (v3.15.1)](https://github.com/mlflow/mlflow/blob/v3.15.1/mlflow/tracking/client.py)
