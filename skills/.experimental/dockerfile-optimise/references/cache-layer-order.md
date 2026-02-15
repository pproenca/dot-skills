---
title: Order Layers by Change Frequency
impact: CRITICAL
impactDescription: prevents full rebuilds on every code change
tags: cache, layer-ordering, build-time, invalidation
---

## Order Layers by Change Frequency

Docker caches each layer and reuses it as long as the instruction and its inputs have not changed. When a layer's cache is invalidated, every subsequent layer is also invalidated and must be rebuilt. Placing frequently-changing instructions (like copying application source code) before stable instructions (like installing system packages) forces Docker to redo all the stable work on every build.

**Incorrect (frequently-changing layer before stable layers):**

```dockerfile
FROM node:22-slim

WORKDIR /app

# Copying source code first means ANY file edit invalidates
# the npm install layer below, triggering a full reinstall
COPY . .

RUN npm install --production

RUN npm run build

EXPOSE 3000
CMD ["node", "dist/server.js"]
```

(Any change to a source file, README, or test invalidates the `npm install` layer and every layer after it.)

**Correct (layers ordered from least to most frequently changing):**

```dockerfile
FROM node:22-slim

WORKDIR /app

# 1. System-level setup (rarely changes)
RUN apt-get update && apt-get install -y --no-install-recommends \
    tini \
    && rm -rf /var/lib/apt/lists/*

# 2. Dependency manifest (changes only when deps change)
COPY package.json package-lock.json ./

# 3. Dependency install (cached until manifests change)
RUN npm ci --production

# 4. Application source (changes most frequently)
COPY . .

RUN npm run build

EXPOSE 3000
ENTRYPOINT ["tini", "--"]
CMD ["node", "dist/server.js"]
```

(Source code changes only invalidate the `COPY . .` layer and the build step. Dependency installation remains cached.)

Reference: [Docker Build Cache - Optimize](https://docs.docker.com/build/cache/optimize/)
