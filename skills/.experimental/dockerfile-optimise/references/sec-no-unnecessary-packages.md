---
title: Avoid Installing Unnecessary Packages
impact: MEDIUM
impactDescription: reduces attack surface and image size
tags: sec, packages, minimal, attack-surface
---

## Avoid Installing Unnecessary Packages

Every package installed in a container is a potential vulnerability vector. Debug utilities, editors, network diagnostic tools, and documentation packages are useful during development but serve no purpose in a production image. They increase the image size, extend build times, and -- critically -- widen the attack surface by introducing binaries an attacker could leverage after gaining initial access.

**Incorrect (debug and convenience tools in a production image):**

```dockerfile
FROM python:3.12-slim

WORKDIR /app

RUN apt-get update && apt-get install -y \
    vim \
    curl \
    wget \
    net-tools \
    iputils-ping \
    htop \
    strace \
    tcpdump \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

CMD ["gunicorn", "app.wsgi:application"]
```

(None of these tools are needed to serve the application. `tcpdump` and `strace` give an attacker network sniffing and process tracing capabilities. `curl` and `wget` enable downloading additional payloads after initial compromise. Installing them adds ~80MB and dozens of additional CVE-trackable packages.)

**Correct (only runtime dependencies, no recommends):**

```dockerfile
FROM python:3.12-slim

WORKDIR /app

# Install only the runtime libraries the application actually needs
# --no-install-recommends prevents apt from pulling suggested packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

USER nobody
CMD ["gunicorn", "app.wsgi:application"]
```

(Only `libpq5` is installed -- the runtime library needed by psycopg2 for PostgreSQL connectivity. The `--no-install-recommends` flag prevents apt from pulling in additional suggested packages that are not strict dependencies.)

**Correct (debug tools isolated in a development stage):**

```dockerfile
# syntax=docker/dockerfile:1

# -- Base stage: shared runtime configuration --
FROM python:3.12-slim AS base

WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

# -- Development stage: includes debug tools --
FROM base AS development

RUN apt-get update && apt-get install -y --no-install-recommends \
    vim \
    curl \
    net-tools \
    strace \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir debugpy ipdb

CMD ["python", "-m", "debugpy", "--listen", "0.0.0.0:5678", "manage.py", "runserver"]

# -- Production stage: minimal runtime only --
FROM base AS production

USER nobody
CMD ["gunicorn", "app.wsgi:application"]
```

Build commands:

```bash
# Development (includes debug tools)
docker build --target development -t myapp:dev .

# Production (no debug tools, minimal attack surface)
docker build --target production -t myapp:prod .
```

(Debug tools exist only in the `development` stage. The `production` target inherits from `base` and contains nothing beyond the application and its runtime dependencies.)

### Audit Checklist

Before shipping an image to production, verify there are no unnecessary packages:

```bash
# List all installed packages in the image
docker run --rm myapp:prod dpkg -l

# Check for common debug tools that should not be present
docker run --rm myapp:prod which curl wget vim strace tcpdump 2>&1
```

Reference: [Building best practices](https://docs.docker.com/build/building/best-practices/)
