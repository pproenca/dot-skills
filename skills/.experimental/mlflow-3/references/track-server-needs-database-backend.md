---
title: Run the tracking server on a database, never the file store
tags: track, server, file-store, migration
---

## Run the tracking server on a database, never the file store

`mlflow server --backend-store-uri ./mlruns` was the MLflow 2 quickstart; since 3.13 the filesystem backend is in maintenance mode and **raises on any use — client or server, tracking or registry** — unless you set `MLFLOW_ALLOW_FILE_STORE=true`. And the file store never supported the model registry properly anyway. Move existing file-store data losslessly with `mlflow migrate-filestore` — its target is specifically a SQLite URI — then run the server against that SQLite file (single host) or a PostgreSQL/MySQL backend (production). Database schemas are versioned: run `mlflow db upgrade <uri>` when upgrading MLflow across versions.

```bash
# One-time migration of a legacy ./mlruns directory
mlflow migrate-filestore --source ./mlruns --target sqlite:///mlflow.db

# Then serve from the database
mlflow server --backend-store-uri sqlite:///mlflow.db --host 127.0.0.1 --port 5000

# After upgrading the mlflow package
mlflow db upgrade postgresql+psycopg2://mlflow@db.internal.example.com/mlflow
```

Reference: [Migrate from file store](https://mlflow.org/docs/latest/self-hosting/migrate-from-file-store) · [mlflow/store/tracking/file_store.py (v3.15.1)](https://github.com/mlflow/mlflow/blob/v3.15.1/mlflow/store/tracking/file_store.py)
