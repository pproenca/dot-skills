---
title: Sort Multi-Line Arguments Alphabetically
impact: LOW
impactDescription: prevents package duplication and simplifies code review
tags: lint, readability, maintainability, apt-get
---

## Sort Multi-Line Arguments Alphabetically

Unordered package lists in `RUN` instructions make duplicates invisible, diffs noisy, and merge conflicts frequent. When packages are added ad hoc over months of development, the same package can appear two or three times without anyone noticing. Alphabetical ordering turns package lists into a predictable structure where duplicates are immediately obvious and version control diffs show exactly what changed.

**Incorrect (unsorted packages with a hidden duplicate):**

```dockerfile
FROM python:3.12-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    libpq-dev \
    curl \
    build-essential \
    curl \
    wget \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*
```

(`curl` appears twice -- difficult to spot in an unsorted list. Each duplicate adds noise to the install step and signals that the package list is not actively maintained. Reviewers scanning this list cannot quickly verify completeness or spot unrelated additions.)

**Correct (alphabetically sorted, one package per line):**

```dockerfile
FROM python:3.12-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    libffi-dev \
    libpq-dev \
    wget \
    && rm -rf /var/lib/apt/lists/*
```

(Alphabetical order makes duplicates impossible to miss. Diffs show a single added or removed line per package change. The trailing `&& rm -rf /var/lib/apt/lists/*` cleanup is visually separate from the package list.)

### Why This Matters for Code Review

Unsorted lists produce noisy diffs when packages are added or removed:

```diff
 RUN apt-get update && apt-get install -y --no-install-recommends \
-    git \
-    libpq-dev \
     curl \
     build-essential \
+    jq \
+    libpq-dev \
+    git \
     wget \
```

The same change with a sorted list produces a clean, single-line diff:

```diff
 RUN apt-get update && apt-get install -y --no-install-recommends \
     build-essential \
     curl \
     git \
+    jq \
     libpq-dev \
     wget \
```

### Applies Beyond apt-get

The same principle applies to any multi-line argument list:

```dockerfile
# pip packages
RUN pip install --no-cache-dir \
    celery==5.4.0 \
    flask==3.1.0 \
    gunicorn==23.0.0 \
    redis==5.2.1 \
    sqlalchemy==2.0.36

# apk packages (Alpine)
RUN apk add --no-cache \
    curl \
    git \
    openssh-client \
    python3
```

### COPY and Multi-Source Instructions

Sort source files in multi-source COPY instructions for the same readability benefit:

```dockerfile
COPY \
    docker-entrypoint.sh \
    healthcheck.sh \
    migrate.sh \
    /usr/local/bin/
```

Reference: [Building best practices](https://docs.docker.com/build/building/best-practices/)
