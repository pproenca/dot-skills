---
title: Deploy with serve.run and config files, not Deployment.deploy
tags: serve, deployment, serve-build, production
---

## Deploy with serve.run and config files, not Deployment.deploy

The 1.x/early-2.x deployment lifecycle — `serve.start(detached=True)`, `ChurnScorer.deploy()`, `serve.get_deployment(...)` — is removed. Development runs `serve.run(app, name="churn", route_prefix="/churn")` — it returns the app handle and is non-blocking by default; pass `blocking=True` when the script *is* the entrypoint and must stay alive. Production goes through the config artifact: `serve build module:app -o serve_config.yaml` generates the declarative config, `serve deploy serve_config.yaml` applies it to a running cluster, and on Kubernetes the same config inlines into a RayService. `serve.start()` still exists but is only for cluster-scoped `http_options`/`grpc_options` — normal code never calls it.

```bash
# Development
serve run churn_service:app

# Production: config file is the deploy artifact — review it, commit it
serve build churn_service:app -o serve_config.yaml
serve deploy serve_config.yaml
```

Reference: [Ray Serve — Production guide](https://docs.ray.io/en/latest/serve/production-guide/index.html) · [ray/serve/api.py (ray-2.57.0)](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/serve/api.py)
