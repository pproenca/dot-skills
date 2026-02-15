---
title: Use Target Builds for Development and Production
impact: HIGH
impactDescription: single Dockerfile serves multiple environments
tags: stage, target, development, production, debug
---

## Use Target Builds for Development and Production

Maintaining separate Dockerfiles for each environment leads to drift, duplication, and inconsistent behaviour between dev and prod. A single Dockerfile with named stages lets you build to a specific target, keeping all environments defined in one place.

**Incorrect (separate Dockerfiles diverge over time):**

```dockerfile
# Dockerfile.dev
FROM python:3.12
WORKDIR /app
COPY requirements.txt requirements-dev.txt ./
RUN pip install -r requirements.txt -r requirements-dev.txt
COPY . .
CMD ["flask", "run", "--debug", "--reload"]

# Dockerfile.prod (duplicates base setup, easily drifts)
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:8000", "app:create_app()"]
```

**Correct (single Dockerfile with targeted stages):**

```dockerfile
# -- Base stage shared by all environments --
FROM python:3.12-slim AS base
WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

# -- Development stage --
FROM base AS development
RUN pip install --no-cache-dir -r requirements-dev.txt
ENV FLASK_DEBUG=1
CMD ["flask", "run", "--debug", "--reload", "--host=0.0.0.0"]

# -- Testing stage --
FROM development AS testing
RUN pip install --no-cache-dir -r requirements-test.txt
CMD ["pytest", "--cov=app", "--cov-report=term-missing"]

# -- Production stage --
FROM base AS production
RUN addgroup --system app && adduser --system --ingroup app app
USER app
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:8000", "app:create_app()"]
```

```bash
# Build for a specific environment
docker build --target development -t myapp:dev .
docker build --target testing -t myapp:test .
docker build --target production -t myapp:prod .
```

Reference: [Multi-stage builds](https://docs.docker.com/build/building/multi-stage/)
