---
title: Use ARG Before FROM to Parameterize Base Images
impact: MEDIUM
impactDescription: enables CI matrix builds and centralized version management
tags: base, arg, from, parameterization, ci
---

## Use ARG Before FROM to Parameterize Base Images

Hardcoding the base image version in `FROM` means updating it requires editing the Dockerfile. In CI/CD pipelines that test against multiple language versions, this forces maintaining separate Dockerfiles or complex sed-based substitutions. An `ARG` instruction before `FROM` parameterizes the version so it can be set at build time without modifying the Dockerfile.

**Incorrect (hardcoded version requires Dockerfile edit to change):**

```dockerfile
FROM python:3.12-slim

WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["python", "app.py"]
```

(Testing against Python 3.13 requires editing the Dockerfile. CI matrix builds cannot vary the Python version without maintaining multiple Dockerfiles or using build-time string replacement.)

**Correct (ARG before FROM enables build-time version selection):**

```dockerfile
ARG PYTHON_VERSION=3.12
FROM python:${PYTHON_VERSION}-slim

WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["python", "app.py"]
```

Build commands:

```bash
# Use the default version (3.12)
docker build -t myapp .

# Override for CI matrix testing
docker build --build-arg PYTHON_VERSION=3.13 -t myapp:py313 .
docker build --build-arg PYTHON_VERSION=3.11 -t myapp:py311 .
```

(The same Dockerfile works for all Python versions. CI pipelines can define a version matrix without duplicating Dockerfiles.)

### Important: ARG Scope with FROM

An `ARG` declared before `FROM` is only available in the `FROM` instruction itself. To use it inside the build stage, re-declare it after `FROM`:

```dockerfile
ARG NODE_VERSION=22
FROM node:${NODE_VERSION}-slim

# Re-declare to use inside the stage
ARG NODE_VERSION
RUN echo "Building with Node.js ${NODE_VERSION}"
```

(Without the re-declaration after `FROM`, `${NODE_VERSION}` inside the stage resolves to an empty string.)

Reference: [Dockerfile reference - ARG](https://docs.docker.com/reference/dockerfile/#arg)
