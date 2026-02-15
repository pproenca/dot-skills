---
title: Keep Build Context Small
impact: MEDIUM
impactDescription: reduces data transfer to builder and speeds up build initialization
tags: ctx, context-size, performance, build-time
---

## Keep Build Context Small

Docker must serialize and transfer the entire build context to the builder daemon before the first instruction runs. In a monorepo or large project, passing the repository root as context can mean transferring gigabytes of unrelated code, assets, and data -- adding seconds or minutes of overhead to every build even when nothing relevant has changed.

**Incorrect (monorepo root as build context):**

```text
project/
├── services/
│   ├── api/
│   │   ├── Dockerfile
│   │   ├── package.json
│   │   └── src/
│   ├── worker/
│   │   ├── Dockerfile
│   │   ├── package.json
│   │   └── src/
│   └── frontend/
│       ├── Dockerfile
│       ├── package.json
│       └── src/
├── data/            (500 MB of seed data)
├── ml-models/       (2 GB of model weights)
├── docs/
└── scripts/
```

```bash
# Building the API service from monorepo root
docker build -f services/api/Dockerfile .
```

(Docker sends the entire 3+ GB monorepo to the builder, including ML models, seed data, other services, and documentation. This transfer happens on every build regardless of what changed.)

**Correct (scoped context to the service directory):**

```bash
# Pass only the service directory as context
docker build -f services/api/Dockerfile services/api/
```

(Docker sends only the `services/api/` directory -- typically a few MB of source code and configuration. The build starts almost instantly instead of waiting for gigabytes to transfer.)

**Correct (use a dedicated context path with shared dependencies):**

When services share code (e.g. a common library), scope the context to include only what is needed:

```text
project/
├── libs/
│   └── shared/
│       ├── package.json
│       └── src/
└── services/
    └── api/
        ├── Dockerfile
        ├── package.json
        └── src/
```

```bash
# Context includes libs/ and services/api/ but not data/, ml-models/, etc.
docker build -f services/api/Dockerfile services/
```

```dockerfile
# services/api/Dockerfile
FROM node:22-slim
WORKDIR /app

# Copy shared library
COPY libs/shared/package.json libs/shared/
RUN cd libs/shared && npm ci

# Copy API service
COPY api/package.json api/package-lock.json api/
RUN cd api && npm ci --production

COPY libs/shared/src/ libs/shared/src/
COPY api/src/ api/src/

WORKDIR /app/api
RUN npm run build
CMD ["node", "dist/server.js"]
```

(The context is `services/`, which contains only the relevant service code and shared libraries. Multi-gigabyte directories like `data/` and `ml-models/` are never transferred.)

Reference: [Docker Build Cache - Optimize](https://docs.docker.com/build/cache/optimize/)
