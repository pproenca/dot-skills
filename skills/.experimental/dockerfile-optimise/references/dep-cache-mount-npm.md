---
title: Use Cache Mount for npm, yarn, and pnpm
impact: MEDIUM-HIGH
impactDescription: reuses downloaded packages across builds, 2-5x faster installs
tags: dep, cache-mount, npm, yarn, pnpm, node
---

## Use Cache Mount for npm, yarn, and pnpm

Node package managers maintain a local cache of downloaded tarballs so repeated installs can skip the network round-trip. Inside Docker, this cache is lost every time the install layer rebuilds because the filesystem is ephemeral. A `--mount=type=cache` directive persists the cache directory across builds, so only new or updated packages are fetched from the registry.

**Incorrect (re-downloads everything on cache miss):**

```dockerfile
FROM node:22-slim
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
```

(Every rebuild fetches the entire dependency tree from the npm registry. A project with 800 transitive dependencies re-downloads all 800 tarballs even when only one package changed.)

**Correct (cache mount preserves npm tarball cache):**

```dockerfile
FROM node:22-slim
WORKDIR /app
COPY package.json package-lock.json ./
RUN --mount=type=cache,target=/root/.npm \
    npm ci
```

(npm checks its persistent cache before hitting the registry. Only new or updated packages are downloaded.)

**Correct — yarn Classic v1 (cache mount with explicit cache folder):**

```dockerfile
FROM node:22-slim
WORKDIR /app
COPY package.json yarn.lock ./
RUN --mount=type=cache,target=/root/.yarn \
    YARN_CACHE_FOLDER=/root/.yarn \
    yarn install --frozen-lockfile
```

(The `YARN_CACHE_FOLDER` environment variable redirects yarn's cache into the mounted directory. The `--frozen-lockfile` flag ensures the lockfile is not modified during install. **Note:** This pattern applies to Yarn Classic (v1) only. In Yarn Berry/v4, `YARN_CACHE_FOLDER` is ignored when `enableGlobalCache: true` (the default), and `--frozen-lockfile` was replaced by `--immutable`.)

**Correct — yarn Berry v4 (cache mount with project-local cache):**

```dockerfile
FROM node:22-slim
RUN corepack enable
WORKDIR /app
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn/ .yarn/
RUN --mount=type=cache,target=/root/.yarn/berry/cache \
    yarn install --immutable
```

(Yarn Berry uses a project-local cache by default. The `--immutable` flag replaces `--frozen-lockfile` in v4.)

**Correct — pnpm (cache mount preserves content-addressable store):**

```dockerfile
FROM node:22-slim
RUN corepack enable
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN --mount=type=cache,target=/root/.local/share/pnpm/store \
    pnpm install --frozen-lockfile
```

(pnpm's content-addressable store deduplicates packages across projects. The cache mount preserves the store so identical package versions are never downloaded twice across builds.)

> **See also:** [`cache-mount-package`](cache-mount-package.md) for a general overview of cache mounts across all package managers.

Reference: [Docker Build Cache - Optimize](https://docs.docker.com/build/cache/optimize/)
