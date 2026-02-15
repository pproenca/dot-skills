---
title: Copy Dependency Files Before Source Code
impact: CRITICAL
impactDescription: 2-10× build time reduction when only source code changes (the common case)
tags: cache, dependencies, copy, layer-ordering
---

## Copy Dependency Files Before Source Code

Copying the entire source tree before installing dependencies means any source file change triggers a full dependency reinstall. By copying only the dependency manifest files (lock files) first, Docker can cache the expensive install step and only re-run it when dependencies actually change.

### Node.js

**Incorrect (full source copy before install):**

```dockerfile
FROM node:22-slim
WORKDIR /app

# Every source file change invalidates the install layer
COPY . .
RUN npm ci --production
```

(Editing `src/api/routes.ts` forces a complete `npm ci`, re-downloading and installing all packages.)

**Correct (copy manifests, install, then copy source):**

```dockerfile
FROM node:22-slim
WORKDIR /app

# Only changes to package.json or lock file invalidate install
COPY package.json package-lock.json ./
RUN npm ci --production

# Source changes only affect this layer and below
COPY . .
```

(Editing `src/api/routes.ts` skips the `npm ci` layer entirely since `package-lock.json` has not changed.)

### Python

**Incorrect (full source copy before install):**

```dockerfile
FROM python:3.13-slim
WORKDIR /app

# Any source change reinstalls all dependencies
COPY . .
RUN pip install --no-cache-dir -r requirements.txt
```

(Editing `app/views.py` forces a full `pip install` of every package in `requirements.txt`.)

**Correct (copy requirements first, then source):**

```dockerfile
FROM python:3.13-slim
WORKDIR /app

# Only changes to requirements.txt invalidate the install layer
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Source changes only affect this layer
COPY . .
```

(Editing `app/views.py` reuses the cached pip install layer. Dependencies only reinstall when `requirements.txt` changes.)

Reference: [Docker Build Cache - Optimize](https://docs.docker.com/build/cache/optimize/)
