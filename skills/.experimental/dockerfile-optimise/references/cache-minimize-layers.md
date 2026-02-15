---
title: Consolidate Related RUN Instructions
impact: MEDIUM
impactDescription: reduces image layer count and total size
tags: cache, layers, run, consolidation
---

## Consolidate Related RUN Instructions

Each `RUN` instruction creates a new layer in the image. Files created in one layer and deleted in a subsequent layer still occupy space in the image because layers are additive. Consolidating related operations into a single `RUN` instruction ensures that temporary files, caches, and build artifacts are cleaned up within the same layer they were created in.

**Incorrect (separate RUN instructions -- cleanup does not reduce size):**

```dockerfile
FROM ubuntu:24.04

# Layer 1: downloads ~35MB of .deb files into /var/cache/apt
RUN apt-get update

# Layer 2: installs packages, adds ~120MB
RUN apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    curl

# Layer 3: removes lists, but Layer 1 still contains the 35MB
RUN rm -rf /var/lib/apt/lists/*
```

(The `rm -rf` in Layer 3 creates a whiteout entry that hides the files but does not reclaim the 35 MB from Layer 1. The image carries all three layers at their full size.)

**Correct (single RUN with chained commands):**

```dockerfile
FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        libpq-dev \
        curl \
    && rm -rf /var/lib/apt/lists/*
```

(All operations happen in a single layer. The package lists are downloaded, used, and deleted before the layer is committed. The final layer only contains the installed packages.)

**Alternative (heredoc syntax for readability):**

```dockerfile
FROM ubuntu:24.04

RUN <<EOF
set -e
apt-get update
apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    curl
rm -rf /var/lib/apt/lists/*
EOF
```

(Heredoc syntax, available since Docker BuildKit, improves readability for multi-command operations while keeping everything in a single layer. **Always include `set -e`** at the top of heredocs — unlike `&&` chaining, heredoc runs commands sequentially but does not stop on failure by default. Without `set -e`, a failed `apt-get update` silently continues to `apt-get install` with a stale index.)

**When NOT to consolidate:** Keep layers separate when they change at different frequencies and you want to preserve cache granularity. For example, system package installation and application dependency installation should be separate layers because they change at different rates.

Reference: [Docker Build - Best Practices](https://docs.docker.com/build/building/best-practices/)
