---
title: Combine apt-get update with install
impact: HIGH
impactDescription: prevents stale package index causing install failures
tags: cache, apt-get, debian, ubuntu
---

## Combine apt-get update with install

Running `apt-get update` and `apt-get install` in separate `RUN` instructions means the update layer gets cached independently. When a new package is added to the install instruction, Docker reuses the stale cached package index, which can resolve to deleted or outdated package versions and cause build failures.

**Incorrect (separate RUN instructions):**

```dockerfile
FROM ubuntu:24.04

# This layer gets cached with today's package index
RUN apt-get update

# Weeks later, adding "jq" uses the stale index from the cached layer above.
# The referenced package versions may no longer exist on the mirror.
RUN apt-get install -y \
    curl \
    ca-certificates \
    jq
```

(The cached `apt-get update` layer contains a stale package index. Adding or changing packages in the install layer triggers `E: Unable to locate package` or version mismatch errors.)

**Correct (single RUN with cleanup):**

```dockerfile
FROM ubuntu:24.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    jq \
    && rm -rf /var/lib/apt/lists/*
```

(The update and install always run together, ensuring a fresh package index. The `--no-install-recommends` flag avoids pulling in unnecessary suggested packages. Removing `/var/lib/apt/lists/*` reduces the layer size by 20-40 MB.)

**Alternative (cache mount approach for faster rebuilds):**

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
    jq
```

(The `docker-clean` removal is required — without it, apt deletes cached `.deb` files before the cache mount can persist them. Cache mounts persist the downloaded `.deb` files and package lists outside the image layer. No `rm -rf` cleanup needed because the cached data lives in the mount, not the image. The `sharing=locked` flag prevents parallel builds from corrupting the shared package database.)

Reference: [Docker Build - Best Practices](https://docs.docker.com/build/building/best-practices/)
