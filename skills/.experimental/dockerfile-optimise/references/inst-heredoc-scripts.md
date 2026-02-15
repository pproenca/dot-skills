---
title: Use Heredocs for Multi-Line Scripts
impact: MEDIUM
impactDescription: improves readability and eliminates backslash-continuation errors
tags: inst, heredoc, readability, buildkit, run
---

## Use Heredocs for Multi-Line Scripts

Long RUN instructions with backslash continuations are hard to read, easy to break, and do not support inline comments between continued lines. A missing trailing backslash silently splits a single command into two separate commands, causing subtle build failures that are difficult to diagnose. BuildKit heredoc syntax (`RUN <<EOF`) allows writing multi-line scripts in natural shell syntax with full comment support.

**Incorrect (backslash continuation -- fragile and hard to read):**

```dockerfile
FROM python:3.12-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*
```

(A missing `\` after any line silently splits the command. For example, removing the backslash after `ca-certificates` causes `libpq-dev` to run as a standalone command, failing the build with a confusing error. Comments cannot be placed between continued lines without breaking the chain.)

**Correct (heredoc syntax -- readable and resilient):**

```dockerfile
# syntax=docker/dockerfile:1
FROM python:3.12-slim

RUN <<EOF
apt-get update
apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    libpq-dev
rm -rf /var/lib/apt/lists/*
EOF
```

(Each command is a standalone line within the heredoc. Missing a backslash within the `apt-get install` list still fails clearly because the next line is a separate command. Comments can be added freely between lines without breaking the script.)

**Correct (heredoc with explicit shell and error handling):**

```dockerfile
# syntax=docker/dockerfile:1
FROM node:22-slim

RUN <<EOF
set -eux
apt-get update
apt-get install -y --no-install-recommends tini
rm -rf /var/lib/apt/lists/*
# Verify tini was installed correctly
tini --version
EOF
```

(The `set -eux` flags enable strict error handling: `-e` exits on any failure, `-u` treats unset variables as errors, and `-x` prints each command for build log debugging. Inline comments document intent without breaking the script.)

**Correct (COPY heredoc for creating configuration files inline):**

```dockerfile
# syntax=docker/dockerfile:1
FROM nginx:1.27-alpine

COPY <<EOF /etc/nginx/conf.d/default.conf
server {
    listen 8080;
    server_name _;

    location / {
        root /usr/share/nginx/html;
        index index.html;
        try_files \$uri \$uri/ /index.html;
    }

    location /health {
        access_log off;
        return 200 "ok";
    }
}
EOF
```

(The COPY heredoc creates a configuration file inline without needing a separate file in the build context. This keeps simple configs co-located with the Dockerfile for self-contained builds.)

**Correct (multiple files in a single layer with heredocs):**

```dockerfile
# syntax=docker/dockerfile:1
FROM python:3.12-slim

COPY <<requirements.txt <<gunicorn.conf.py /app/
Flask==3.0.3
gunicorn==22.0.0
psycopg2-binary==2.9.9
requirements.txt
import multiprocessing

bind = "0.0.0.0:8000"
workers = multiprocessing.cpu_count() * 2 + 1
timeout = 120
gunicorn.conf.py
```

(Multiple heredocs in a single COPY instruction create several files in one layer. Each heredoc is terminated by its own delimiter -- `requirements.txt` and `gunicorn.conf.py` respectively.)

### Requirements

Heredoc syntax requires BuildKit and the `# syntax=docker/dockerfile:1` directive at the top of the Dockerfile. BuildKit is the default builder in Docker Engine 23.0+ and Docker Desktop 4.0+. For older Docker versions, enable BuildKit by setting `DOCKER_BUILDKIT=1`.

Reference: [Building best practices](https://docs.docker.com/build/building/best-practices/)
