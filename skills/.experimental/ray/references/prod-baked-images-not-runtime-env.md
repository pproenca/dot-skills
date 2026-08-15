---
title: Bake images for production; runtime_env is for iteration
tags: prod, runtime-env, images, dependencies
---

## Bake images for production; runtime_env is for iteration

`runtime_env={"pip": [...], "working_dir": "."}` is how every tutorial ships dependencies, so it becomes the production pattern by default — but it installs packages at task/job start on every node, adding startup latency and a network dependency to each run. Production clusters bake dependencies into the container image (the KubeRay pod spec), pinning the Ray version identically across head, workers, and clients; `runtime_env` stays what it is good at — fast dev iteration on code (`working_dir`, `py_modules`) and per-job tweaks. The 2.5x additions are worth knowing: `uv` joins `pip`/`conda` (mutually exclusive), and `image_uri` can swap the container per task/actor.

```bash
# Dev iteration: ship local code changes without rebuilding the image
ray job submit --address http://dev-cluster:8265 \
  --working-dir . \
  --runtime-env-json '{"uv": ["scikit-learn==1.5.2"]}' \
  -- python train.py
```

Reference: [Ray Serve — Production guide](https://docs.ray.io/en/latest/serve/production-guide/index.html) · [ray/runtime_env/runtime_env.py (ray-2.57.0)](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/runtime_env/runtime_env.py)
