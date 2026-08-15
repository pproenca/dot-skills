---
title: Point clients at one tracking URI with proxied artifacts
tags: track, server, artifact-store, credentials
---

## Point clients at one tracking URI with proxied artifacts

The MLflow 2-era topology hands object-store credentials to every training client (`--default-artifact-root s3://...` with each client writing to S3 directly). The current server proxies artifact traffic by default — `--serve-artifacts` is on, artifacts are addressed as `mlflow-artifacts:/` and flow through the server to the `--artifacts-destination` — so only the server holds S3/GCS/Azure credentials and clients need exactly one setting: `MLFLOW_TRACKING_URI`. Since 3.15 the server can also hand out presigned URLs so large artifact bytes move client-to-store directly, falling back to proxied transfer automatically; `--default-artifact-root` only matters if you turn proxying off.

```bash
mlflow server \
  --backend-store-uri postgresql+psycopg2://mlflow@db.internal.example.com/mlflow \
  --artifacts-destination s3://ml-artifacts/mlflow \
  --host 0.0.0.0 --port 5000 --workers 4
```

```bash
# The complete artifact-store configuration on a client (auth creds aside):
export MLFLOW_TRACKING_URI=https://mlflow.internal.example.com
```

Reference: [Self-hosting architecture overview](https://mlflow.org/docs/latest/self-hosting/architecture/overview/) · [Artifact store](https://mlflow.org/docs/latest/self-hosting/architecture/artifact-store/) · [MLflow 3.15.0 release notes — presigned URLs](https://github.com/mlflow/mlflow/releases/tag/v3.15.0)
