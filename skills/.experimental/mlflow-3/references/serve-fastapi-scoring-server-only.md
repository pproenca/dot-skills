---
title: Serve with the built-in FastAPI scoring server
tags: serve, scoring-server, mlserver, uvicorn
---

## Serve with the built-in FastAPI scoring server

Serving advice from the MLflow 2 era targets stacks that no longer exist: the Flask/gunicorn scoring server was replaced by FastAPI on uvicorn, and the MLServer backend (`--enable-mlserver`, the old KServe/Seldon path) was **removed** in 3.13 — `mlflow models serve` always uses the built-in server now, and the flag is gone. Tuning happens through uvicorn workers (`-w`), and inside `build-docker` images through `MLFLOW_MODELS_WORKERS` and the bundled nginx (disable with `DISABLE_NGINX=true`). Gunicorn worker-class flags and WSGI middleware patterns have nothing to attach to.

```bash
mlflow models serve \
  -m "models:/prod.growth.churn_classifier@champion" \
  -p 5001 -w 2 \
  --env-manager uv
```

Reference: [Deploy model locally](https://mlflow.org/docs/latest/ml/deployment/deploy-model-locally/) · [MLflow 3.13.0 changelog — MLServer removal](https://github.com/mlflow/mlflow/blob/v3.15.1/CHANGELOG.md)
