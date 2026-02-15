---
title: Use Cache Mount for pip
impact: MEDIUM-HIGH
impactDescription: reuses wheel cache across builds, 2-5x faster installs
tags: dep, cache-mount, pip, python
---

## Use Cache Mount for pip

pip caches downloaded packages and compiled wheels in `~/.cache/pip` so subsequent installs can skip both the download and the compilation step. Inside Docker this cache is discarded every time the layer rebuilds. Worse, many Dockerfiles explicitly pass `--no-cache-dir` to reduce image size, which disables caching entirely. A `--mount=type=cache` directive preserves the cache outside the image layer, giving you both fast rebuilds and a small image.

**Incorrect (caching explicitly disabled):**

```dockerfile
FROM python:3.13-slim
WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
```

(The `--no-cache-dir` flag forces pip to download and compile every package from scratch on every rebuild. Packages with C extensions like `numpy` or `pandas` take minutes to build each time.)

**Correct (cache mount preserves downloaded wheels):**

```dockerfile
FROM python:3.13-slim
WORKDIR /app
COPY requirements.txt ./
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install -r requirements.txt
```

(pip reuses previously downloaded wheels from the persistent cache. Adding a new dependency only downloads and compiles that one package. The cache lives in the mount, not in the image layer, so image size stays small without needing `--no-cache-dir`.)

> **See also:** [`cache-mount-package`](cache-mount-package.md) for cache mounts across all package managers including Go modules.

Reference: [Docker Build Cache - Optimize](https://docs.docker.com/build/cache/optimize/)
