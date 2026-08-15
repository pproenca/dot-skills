---
title: Expect sqlite as the local default, not mlruns
tags: track, tracking-uri, sqlite, defaults
---

## Expect sqlite as the local default, not mlruns

The MLflow 2 mental model — "no tracking URI configured means everything lands in `./mlruns`" — is stale twice over. The client default is now `sqlite:///mlflow.db` in the working directory. A pre-existing `./mlruns` directory is still *detected* as the default URI, but constructing that file store then raises (maintenance mode) unless `MLFLOW_ALLOW_FILE_STORE=true` — so an old project does not keep working; it must be migrated (see `track-server-needs-database-backend`). Anything that assumed the filesystem layout — globbing `mlruns/` in CI, `.gitignore` entries, "just delete mlruns to reset" advice — needs updating, and a fresh project that suddenly grows an `mlflow.db` file is behaving correctly, not misconfigured.

```python
import mlflow

# Explicit is better than default in anything shared:
mlflow.set_tracking_uri("http://mlflow.internal.example.com")  # team server
# or for deliberate local work:
mlflow.set_tracking_uri("sqlite:///mlflow.db")

mlflow.set_experiment("churn-classifier")
```

Reference: [MLflow tracking — backend stores](https://mlflow.org/docs/latest/self-hosting/architecture/backend-store/) · [mlflow/store/tracking (v3.15.1)](https://github.com/mlflow/mlflow/blob/v3.15.1/mlflow/store/tracking/__init__.py)
