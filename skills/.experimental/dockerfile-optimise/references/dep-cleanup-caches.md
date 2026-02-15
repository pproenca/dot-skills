---
title: Clean Package Manager Caches in the Same Layer
impact: MEDIUM
impactDescription: reduces image size by removing cached downloads
tags: dep, cleanup, layer-size, apt, pip
---

## Clean Package Manager Caches in the Same Layer

Each `RUN` instruction creates an immutable layer in the image. Files written in one layer cannot be removed by a later layer — the later layer only masks them with a whiteout entry, but the bytes remain in the image. This means cleaning package manager caches in a separate `RUN` instruction has zero effect on image size.

**Incorrect (cleanup in separate layer):**

```dockerfile
FROM ubuntu:24.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    gnupg

RUN rm -rf /var/lib/apt/lists/*
```

(The apt package lists — typically 20-40 MB — are baked into the first layer. The second `RUN` creates a whiteout layer that hides the files but does not reclaim the space. The total image carries the full weight of both layers.)

**Correct (cleanup in same layer):**

```dockerfile
FROM ubuntu:24.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    gnupg \
    && rm -rf /var/lib/apt/lists/*
```

(The package lists are created and removed within the same `RUN` instruction, so they never appear in the final layer. This saves 20-40 MB per image.)

**Better (cache mount eliminates the problem entirely):**

```dockerfile
FROM ubuntu:24.04

# Required: disable the Docker-specific hook that wipes apt's cache after install
RUN rm -f /etc/apt/apt.conf.d/docker-clean; \
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    gnupg
```

(The `docker-clean` removal is required — without it, apt deletes cached `.deb` files before the cache mount can persist them. Cache mounts are not part of the image layer at all — they exist only in the build cache on the host. No cleanup command is needed, and the cached files are reused by subsequent builds. This is the best of both worlds: small images and fast rebuilds.)

> **See also:** [`cache-mount-package`](cache-mount-package.md) (CRITICAL) for full coverage of cache mounts across all package managers.

### pip — same principle applies

**Incorrect (cache persists in layer):**

```dockerfile
RUN pip install flask sqlalchemy requests
RUN rm -rf /root/.cache/pip
```

(The pip cache — which can be hundreds of MB for packages with compiled wheels — is stored in the first layer and cannot be reclaimed by the second.)

**Correct (single layer with cache disabled):**

```dockerfile
RUN pip install --no-cache-dir flask sqlalchemy requests
```

(The `--no-cache-dir` flag prevents pip from writing a cache at all. Simpler than manual cleanup, but rebuilds must re-download everything.)

**Better (cache mount):**

```dockerfile
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install flask sqlalchemy requests
```

(The pip cache persists across builds for fast installs but never appears in the image layer.)

Reference: [Building best practices](https://docs.docker.com/build/building/best-practices/)
