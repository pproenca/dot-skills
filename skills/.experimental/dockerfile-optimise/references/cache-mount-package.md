---
title: Use Cache Mounts for Package Managers
impact: CRITICAL
impactDescription: eliminates redundant package downloads across builds
tags: cache, cache-mount, package-manager, buildkit
---

## Use Cache Mounts for Package Managers

Without cache mounts, each build that misses the layer cache re-downloads every package from the internet. A `RUN --mount=type=cache` instruction persists a directory across builds so package managers can reuse previously downloaded files, even when the dependency manifest changes. This turns a full download into an incremental update.

### pip (Python)

**Incorrect (re-downloads everything on cache miss):**

```dockerfile
FROM python:3.13-slim
WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
```

(Adding a single new dependency forces pip to re-download all 47 packages from PyPI.)

**Correct (cache mount preserves downloaded wheels):**

```dockerfile
FROM python:3.13-slim
WORKDIR /app
COPY requirements.txt ./
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install -r requirements.txt
```

(Adding a new dependency only downloads that one package. The other 47 are served from the persistent cache.)

### npm (Node.js)

**Incorrect (clean npm cache on every build):**

```dockerfile
FROM node:22-slim
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
```

(Every cache miss downloads the full dependency tree from the npm registry.)

**Correct (cache mount preserves npm store):**

```dockerfile
FROM node:22-slim
WORKDIR /app
COPY package.json package-lock.json ./
RUN --mount=type=cache,target=/root/.npm \
    npm ci
```

(npm reuses tarballs from the persistent cache directory, only fetching new or updated packages.)

### apt (Debian/Ubuntu)

**Incorrect (re-downloads package lists and .deb files every build):**

```dockerfile
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*
```

(Every build re-downloads the full package index and all .deb files from scratch.)

**Correct (cache mount preserves apt data):**

```dockerfile
FROM debian:bookworm-slim

# Official Debian/Ubuntu Docker images ship a post-invoke hook that deletes
# /var/cache/apt/archives after every install. Remove it so the cache mount
# actually persists downloaded .deb files across builds.
RUN rm -f /etc/apt/apt.conf.d/docker-clean; \
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates
```

(The `sharing=locked` flag prevents concurrent builds from corrupting the shared cache. The `docker-clean` removal is required — without it, apt deletes cached `.deb` files before the cache mount can persist them. Downloaded `.deb` files and package lists persist across builds.)

### Go modules

**Incorrect (re-downloads modules on every build):**

```dockerfile
FROM golang:1.23
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
```

(A module update re-downloads every dependency from proxy.golang.org.)

**Correct (cache mount preserves module cache):**

```dockerfile
FROM golang:1.23
WORKDIR /app
COPY go.mod go.sum ./
RUN --mount=type=cache,target=/go/pkg/mod \
    go mod download
```

(Only new or updated modules are downloaded. The rest are served from the persistent `/go/pkg/mod` cache.)

Reference: [Docker Build Cache - Optimize](https://docs.docker.com/build/cache/optimize/)
