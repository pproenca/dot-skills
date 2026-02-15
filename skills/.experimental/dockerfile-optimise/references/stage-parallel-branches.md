---
title: Exploit Parallel Stage Execution
impact: HIGH
impactDescription: reduces total build time from sum(stages) to max(stages) — 2× or more speedup with parallel branches
tags: stage, parallel, buildkit, concurrency
---

## Exploit Parallel Stage Execution

When stages do not depend on each other, BuildKit automatically executes them in parallel. Structuring your Dockerfile with independent branches lets the builder saturate available CPU cores instead of waiting for sequential stages to finish one by one.

**Incorrect (linear chain forces sequential execution):**

```dockerfile
FROM ubuntu:24.04 AS base
RUN apt-get update && apt-get install -y build-essential cmake

# Backend builds first, blocking frontend
FROM base AS backend
WORKDIR /src/backend
COPY backend/ .
RUN cmake -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build

# Frontend waits for backend even though they are independent
FROM backend AS frontend
WORKDIR /src/frontend
COPY frontend/ .
RUN cmake -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build

FROM ubuntu:24.04
COPY --from=frontend /src/backend/build/server /usr/local/bin/server
COPY --from=frontend /src/frontend/build/webapp /usr/local/bin/webapp
# Total time = backend build + frontend build (sequential)
```

**Correct (independent branches build in parallel):**

```dockerfile
FROM ubuntu:24.04 AS builder-base
RUN apt-get update && apt-get install -y build-essential cmake

# Backend branch — runs independently
FROM builder-base AS backend
WORKDIR /src/backend
COPY backend/ .
RUN cmake -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build

# Frontend branch — runs independently and in parallel with backend
FROM builder-base AS frontend
WORKDIR /src/frontend
COPY frontend/ .
RUN cmake -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build

# Final stage pulls artifacts from both parallel branches
FROM ubuntu:24.04
COPY --from=backend /src/backend/build/server /usr/local/bin/server
COPY --from=frontend /src/frontend/build/webapp /usr/local/bin/webapp
EXPOSE 8080
CMD ["server"]
# Total time = max(backend build, frontend build) — both run at once
```

Reference: [Multi-stage builds](https://docs.docker.com/build/building/multi-stage/)
