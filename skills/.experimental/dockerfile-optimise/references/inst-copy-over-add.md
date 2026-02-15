---
title: Prefer COPY Over ADD
impact: LOW-MEDIUM
impactDescription: prevents unintended archive extraction and unverified remote fetches in 100% of cases
tags: inst, copy, add, clarity, security
---

## Prefer COPY Over ADD

ADD has two implicit behaviors beyond simple file copying: it automatically extracts recognized archive formats (tar, gzip, bzip2, xz) and supports fetching files from remote URLs. These hidden behaviors make the Dockerfile harder to reason about -- a reader cannot tell whether `ADD archive.tar.gz /app/` is intentionally extracting the archive or accidentally triggering auto-extraction. COPY does exactly one thing: copy files from the build context into the image. Explicit is better than implicit.

**Incorrect (ADD auto-extracts archives -- intent is ambiguous):**

```dockerfile
FROM python:3.12-slim

WORKDIR /app
ADD ./app.tar.gz /app/
ADD ./config.yaml /app/
```

(The `ADD ./app.tar.gz /app/` instruction silently extracts the archive into `/app/`. Was this intentional? A future maintainer cannot tell. The `ADD ./config.yaml /app/` instruction does a plain copy because YAML is not a recognized archive format. Using the same instruction for two fundamentally different operations makes the Dockerfile misleading.)

**Correct (COPY for files, explicit extraction when needed):**

```dockerfile
FROM python:3.12-slim

WORKDIR /app
COPY ./app.tar.gz /staging/
RUN tar -xzf /staging/app.tar.gz -C /app/ && rm /staging/app.tar.gz
COPY ./config.yaml /app/
```

(Every operation is explicit. COPY moves the archive into the image, RUN extracts it with visible flags, and the archive is cleaned up in the same layer. A reader immediately understands that extraction is intentional.)

**Incorrect (ADD for remote URLs -- no checksum verification, no caching control):**

```dockerfile
FROM debian:bookworm-slim

ADD https://example.com/bin/tool-v1.2.3 /usr/local/bin/tool
RUN chmod +x /usr/local/bin/tool
```

(ADD fetches the remote file at build time but provides no checksum verification. A compromised or changed file at the URL would be silently incorporated into the image. The downloaded file also cannot benefit from Docker layer caching effectively because ADD always checks the remote URL.)

**Correct (curl/wget with explicit checksum verification):**

```dockerfile
FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends curl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN curl -fsSL -o /usr/local/bin/tool https://example.com/bin/tool-v1.2.3 && \
    echo "a]b3c4d5e6f7... /usr/local/bin/tool" | sha256sum -c - && \
    chmod +x /usr/local/bin/tool
```

(The download, checksum verification, and permission setting are explicit. A tampered file fails the sha256sum check and aborts the build.)

### When ADD is Appropriate

ADD is the right choice when auto-extraction is intentional and the context makes this clear:

```dockerfile
# ADD with checksum for remote files (BuildKit feature)
ADD --checksum=sha256:24454f830cdb571e2c4ad15481119c43b3cafd48dd869a9b2015d0c6e5c848e4 \
    https://example.com/releases/app-v2.1.0.tar.gz /tmp/

# ADD for intentional local archive extraction in a build stage
FROM debian:bookworm-slim AS extract
ADD rootfs.tar.gz /
```

(The `--checksum` flag (requires BuildKit) provides verified remote file fetching in a single instruction. Local archive extraction in a dedicated build stage is also a valid use of ADD when the intent is unambiguous.)

### Quick Reference

| Operation | Use | Instruction |
|-----------|-----|-------------|
| Copy local files | Always | `COPY` |
| Copy and extract local archive | Prefer explicit | `COPY` + `RUN tar` |
| Fetch remote file | Prefer explicit | `RUN curl` / `RUN wget` |
| Fetch remote file with checksum | Acceptable | `ADD --checksum=...` |
| Extract local archive (build stage) | Acceptable | `ADD archive.tar.gz /` |

Reference: [Building best practices](https://docs.docker.com/build/building/best-practices/)
