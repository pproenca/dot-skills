---
title: Use Cache Mounts for Package Managers
impact: CRITICAL
impactDescription: eliminates redundant package downloads across builds
tags: cache, cache-mount, package-manager, buildkit
---

## Use Cache Mounts for Package Managers

Without cache mounts, each build that misses the layer cache re-downloads every package from the internet. A `RUN --mount=type=cache` instruction persists a directory across builds so package managers can reuse previously downloaded files, even when the dependency manifest changes. This turns a full download into an incremental update.

**Incorrect (re-downloads everything on cache miss):**

```dockerfile
FROM python:3.13-slim
WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
```

(Adding a single new dependency forces pip to re-download all packages from PyPI.)

**Correct (cache mount preserves downloaded packages):**

```dockerfile
FROM python:3.13-slim
WORKDIR /app
COPY requirements.txt ./
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install -r requirements.txt
```

(Adding a new dependency only downloads that one package. The cached data lives in the mount on the host, not in the image layer — so images stay small without explicit cleanup commands.)

### Package Manager Cache Directories

| Package Manager | Cache Target | Notes |
|----------------|-------------|-------|
| apt (Debian/Ubuntu) | `/var/cache/apt` + `/var/lib/apt` | Requires disabling `docker-clean` hook; use `sharing=locked` |
| pip (Python) | `/root/.cache/pip` | Remove `--no-cache-dir` flag when using cache mounts |
| npm | `/root/.npm` | Works with `npm ci` and `npm install` |
| yarn Classic v1 | `/root/.yarn` | Set `YARN_CACHE_FOLDER=/root/.yarn` |
| yarn Berry v4 | `/root/.yarn/berry/cache` | Use `--immutable` instead of `--frozen-lockfile` |
| pnpm | `/root/.local/share/pnpm/store` | Content-addressable store deduplicates across projects |
| Go modules | `/go/pkg/mod` | Also cache `/root/.cache/go-build` for compiled artifacts |

### Language-Specific Details

For full examples with incorrect/correct patterns and edge cases, see the dedicated rules:

- [`dep-cache-mount-apt`](dep-cache-mount-apt.md) — apt/Debian/Ubuntu (requires `docker-clean` removal)
- [`dep-cache-mount-npm`](dep-cache-mount-npm.md) — npm, yarn Classic, yarn Berry, pnpm
- [`dep-cache-mount-pip`](dep-cache-mount-pip.md) — pip/Python

### Go Modules (Quick Reference)

```dockerfile
FROM golang:1.23
WORKDIR /app
COPY go.mod go.sum ./
RUN --mount=type=cache,target=/go/pkg/mod \
    go mod download
```

(Only new or updated modules are downloaded. The rest are served from the persistent `/go/pkg/mod` cache.)

Reference: [Docker Build Cache - Optimize](https://docs.docker.com/build/cache/optimize/)
