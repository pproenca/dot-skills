---
title: Avoid Unnecessary Cache Invalidation
impact: HIGH
impactDescription: prevents cascading rebuilds from irrelevant file changes
tags: cache, invalidation, dockerignore, bind-mount
---

## Avoid Unnecessary Cache Invalidation

Docker's `COPY` and `ADD` instructions compute a checksum of the copied files to determine cache validity. When `COPY . .` is used without a `.dockerignore` file, every file in the build context -- including READMEs, test suites, IDE configurations, and git history -- becomes part of the checksum. Changing any of these files invalidates the layer and forces a rebuild of everything below it.

**Incorrect (no .dockerignore, broad COPY):**

```dockerfile
FROM node:22-slim
WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci --production

# Copies everything: .git/, node_modules/, README.md, docs/, tests/, .env
COPY . .
RUN npm run build
```

(Editing `README.md` or adding a test file invalidates the `COPY . .` layer, triggering a full `npm run build` even though the application source has not changed.)

**Correct (use .dockerignore to exclude irrelevant files):**

```dockerfile
FROM node:22-slim
WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci --production

COPY . .
RUN npm run build
```

With a `.dockerignore` file:

```dockerfile
# .dockerignore
.git
node_modules
npm-debug.log*
Dockerfile
docker-compose*.yml
.dockerignore
README.md
CHANGELOG.md
LICENSE
docs/
tests/
__tests__/
coverage/
.env
.env.*
.vscode/
.idea/
*.swp
*.swo
```

(Now only production-relevant source files are included in the checksum. Changes to documentation, tests, or editor config do not invalidate any build layers.)

**Alternative (use specific COPY paths instead of broad wildcard):**

```dockerfile
FROM node:22-slim
WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci --production

# Copy only the directories that matter for the build
COPY src/ ./src/
COPY public/ ./public/
COPY tsconfig.json ./

RUN npm run build
```

(Explicitly naming source directories provides even tighter control. Only changes inside `src/`, `public/`, or `tsconfig.json` invalidate the build layer.)

Reference: [Docker Build Cache](https://docs.docker.com/build/cache/)
