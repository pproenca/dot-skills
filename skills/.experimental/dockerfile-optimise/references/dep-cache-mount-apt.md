---
title: Use Cache Mount for apt Package Manager
impact: MEDIUM-HIGH
impactDescription: eliminates repeated package downloads on layer rebuilds
tags: dep, cache-mount, apt, debian, ubuntu
---

## Use Cache Mount for apt Package Manager

Standard `apt-get install` downloads every package from the archive each time the layer rebuilds, even when only one dependency changed. A `--mount=type=cache` directive persists both the package index and downloaded `.deb` files across builds, turning a full re-download into an incremental update. This is especially valuable when installing many system-level libraries for C extension compilation.

**Incorrect (full re-download on any change):**

```dockerfile
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    libxml2-dev \
    libxslt1-dev \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*
```

(Every rebuild re-downloads the full package index and all six `.deb` files plus their transitive dependencies from the Debian mirror. Adding a seventh package forces a complete re-download of all packages.)

**Correct (cache mount preserves apt data across builds):**

```dockerfile
FROM debian:bookworm-slim

# Required: official Debian/Ubuntu Docker images delete cached .deb files
# after every install via a DPkg post-invoke hook. Remove it first.
RUN rm -f /etc/apt/apt.conf.d/docker-clean; \
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    libxml2-dev \
    libxslt1-dev \
    curl \
    ca-certificates
```

(The `docker-clean` removal is essential — without it, apt deletes cached `.deb` files before the cache mount can persist them. The `sharing=locked` flag serializes concurrent access to the shared cache, preventing database corruption when parallel builds run. Downloaded `.deb` files and the package index persist in the mount — not in the image layer — so no `rm -rf /var/lib/apt/lists/*` cleanup is needed. Adding a seventh package only downloads that one new package.)

> **See also:** [`cache-mount-package`](cache-mount-package.md) for a general overview of cache mounts across all package managers.

Reference: [Docker Build Cache - Optimize](https://docs.docker.com/build/cache/optimize/)
