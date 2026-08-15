---
title: Build serving images with build-docker for clusters
tags: serve, docker, kubernetes, deployment
---

## Build serving images with build-docker for clusters

The MLflow 2-era Kubernetes story routed through MLServer and KServe/Seldon integrations; with MLServer removed, the supported container path is `mlflow models build-docker`, which bakes the model, its rebuilt environment, and an nginx + uvicorn stack into an image serving on port 8080 — deployable to any cluster or container platform. Use `mlflow models generate-dockerfile` when the image needs customization before build. Scope note: the official MLflow Helm chart (`oci://ghcr.io/mlflow/charts/mlflow`) deploys the **tracking server**, not model serving — don't reach for it to serve models.

```bash
mlflow models build-docker \
  --model-uri "models:/prod.growth.churn_classifier@champion" \
  --name registry.internal.example.com/ml/churn-classifier:v7 \
  --env-manager uv

docker run -p 8080:8080 registry.internal.example.com/ml/churn-classifier:v7
curl -s localhost:8080/ping
```

Reference: [MLflow deployment](https://mlflow.org/docs/latest/ml/deployment/) · [Kubernetes Helm chart (tracking server)](https://mlflow.org/docs/latest/self-hosting/kubernetes-helm/)
