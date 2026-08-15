---
title: Disable telemetry deliberately in production images
tags: track, telemetry, privacy, configuration
---

## Disable telemetry deliberately in production images

Code and infra written against MLflow 2 assume MLflow phones home nothing; since 3.2, OSS MLflow collects anonymized usage telemetry by default. It carries no model data, but regulated or air-gapped environments typically must not emit it at all — and the flag will not appear in any MLflow 2-era Dockerfile or Helm values you copy from. Set `MLFLOW_DISABLE_TELEMETRY=true` (or `DO_NOT_TRACK=true`) in baked images, CI runners, and server deployments where telemetry is unwanted.

```dockerfile
FROM python:3.12-slim
RUN pip install mlflow==3.15.1
ENV MLFLOW_DISABLE_TELEMETRY=true
```

Reference: [MLflow telemetry](https://mlflow.org/docs/latest/community/usage-tracking/) · [mlflow/environment_variables.py (v3.15.1)](https://github.com/mlflow/mlflow/blob/v3.15.1/mlflow/environment_variables.py)
