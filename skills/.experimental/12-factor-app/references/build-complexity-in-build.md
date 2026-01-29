---
title: Push Complexity Into Build Stage Keep Run Stage Minimal
impact: HIGH
impactDescription: reduces runtime failures, faster recovery from crashes
tags: build, runtime, compilation, optimization
---

## Push Complexity Into Build Stage Keep Run Stage Minimal

The run stage should have as few moving parts as possible. Complex operations like compilation, asset bundling, dependency resolution, and code generation happen in the build stage. The run stage simply starts processes from a pre-built artifact.

**Incorrect (complexity at runtime):**

```dockerfile
# Dockerfile that does too much at runtime
FROM python:3.11

WORKDIR /app
COPY . .

# This happens at container start
CMD pip install -r requirements.txt && \
    python manage.py migrate && \
    python manage.py collectstatic && \
    python manage.py compilemessages && \
    gunicorn app:application
# If pip install fails at 3AM, app doesn't start
# Migration failure brings down the whole deploy
# Slow startup, unpredictable timing
```

**Correct (complexity in build stage):**

```dockerfile
# Multi-stage build - complexity in build
FROM python:3.11 AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --user -r requirements.txt
COPY . .
RUN python manage.py collectstatic --noinput
RUN python manage.py compilemessages

# Runtime stage - minimal
FROM python:3.11-slim
WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY --from=builder /app /app
ENV PATH=/root/.local/bin:$PATH

# Simple, fast startup
CMD ["gunicorn", "app:application", "--bind", "0.0.0.0:8000"]
```

```bash
# Migrations run separately, not at startup
# Either as a release task or admin process
kubectl exec -it deployment/myapp -- python manage.py migrate
# Or in CI/CD pipeline before deployment completes
```

**What belongs in build stage:**
- Dependency installation
- Compilation (TypeScript, Sass, etc.)
- Asset bundling and minification
- Static file collection
- Translation compilation
- Code generation

**What belongs in run stage:**
- Starting the application process
- Reading environment config
- Binding to port

**Benefits:**
- App starts in seconds, not minutes
- Failures happen in CI, not at 3AM restart
- Crashed processes can restart immediately
- Horizontal scaling is fast (new instances ready quickly)

Reference: [The Twelve-Factor App - Build, Release, Run](https://12factor.net/build-release-run)
