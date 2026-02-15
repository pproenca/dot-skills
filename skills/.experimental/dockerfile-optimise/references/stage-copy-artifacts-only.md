---
title: Copy Only Final Artifacts Between Stages
impact: CRITICAL
impactDescription: prevents build dependencies from leaking into production image
tags: stage, copy-from, artifacts, minimal
---

## Copy Only Final Artifacts Between Stages

Copying entire directories between stages defeats the purpose of multi-stage builds by pulling in source files, build caches, dev dependencies, and test fixtures. Be explicit about exactly which output files the runtime stage needs.

**Incorrect (copies entire /app including source, tests, and dev deps):**

```dockerfile
FROM node:22-alpine AS build
WORKDIR /app
COPY package.json package-lock.json tsconfig.json ./
COPY src/ src/
RUN npm ci
RUN npm run build

FROM node:22-alpine
WORKDIR /app
# Brings along src/, node_modules (with devDependencies), tsconfig.json, .cache
COPY --from=build /app /app
EXPOSE 3000
CMD ["node", "dist/server.js"]
```

**Correct (copies only compiled output and production dependencies):**

```dockerfile
FROM node:22-alpine AS build
WORKDIR /app
COPY package.json package-lock.json tsconfig.json ./
COPY src/ src/
RUN npm ci
RUN npm run build

FROM node:22-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

FROM node:22-alpine
WORKDIR /app
# Only the compiled JavaScript
COPY --from=build /app/dist /app/dist
# Only production dependencies — no devDependencies
COPY --from=deps /app/node_modules /app/node_modules
COPY --from=build /app/package.json /app/package.json
EXPOSE 3000
CMD ["node", "dist/server.js"]
# Final image has no TypeScript source, no tsconfig, no build cache, no dev deps
```

Reference: [Multi-stage builds](https://docs.docker.com/build/building/multi-stage/)
