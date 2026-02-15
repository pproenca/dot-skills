---
title: Use Standard Labels for Image Metadata
impact: LOW-MEDIUM
impactDescription: enables automated image management, licensing compliance, and debugging
tags: lint, labels, metadata, oci, organization
---

## Use Standard Labels for Image Metadata

Without labels, container images are opaque blobs -- you cannot determine which commit built them, who maintains them, what license applies, or which version of the application they contain without pulling and inspecting the application itself. Standard OCI labels make images self-describing, enabling automated vulnerability scanning, license auditing, garbage collection policies, and faster incident triage.

**Incorrect (no labels -- image metadata is empty):**

```dockerfile
FROM node:22-slim

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --production
COPY . .

EXPOSE 3000
CMD ["node", "server.js"]
```

(`docker inspect` shows no useful metadata. When a CVE alert fires at 2 AM, you cannot determine which repository, commit, or team owns this image without tracing deployment configs backward.)

**Correct (OCI standard labels for complete image provenance):**

```dockerfile
FROM node:22-slim

LABEL org.opencontainers.image.title="payment-service"
LABEL org.opencontainers.image.description="Handles payment processing and webhook delivery"
LABEL org.opencontainers.image.source="https://github.com/acme/payment-service"
LABEL org.opencontainers.image.version="1.2.3"
LABEL org.opencontainers.image.created="2025-01-15T10:30:00Z"
LABEL org.opencontainers.image.revision="a1b2c3d4e5f6"
LABEL org.opencontainers.image.authors="platform-team@acme.com"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.vendor="Acme Corp"

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --production
COPY . .

EXPOSE 3000
CMD ["node", "server.js"]
```

(Every label follows the OCI `org.opencontainers.image.*` namespace. These are recognized by Docker Hub, GitHub Container Registry, and vulnerability scanners. `docker inspect` now returns actionable metadata for any image consumer.)

### Single-Line Multi-Label Syntax

Combine multiple labels into a single instruction to reduce layers (though this has negligible impact with BuildKit):

```dockerfile
LABEL org.opencontainers.image.source="https://github.com/acme/payment-service" \
      org.opencontainers.image.version="1.2.3" \
      org.opencontainers.image.licenses="MIT"
```

### Dynamic Labels with Build Args

Inject values from CI at build time instead of hardcoding them:

```dockerfile
ARG GIT_SHA
ARG BUILD_DATE
ARG APP_VERSION

LABEL org.opencontainers.image.revision=$GIT_SHA
LABEL org.opencontainers.image.created=$BUILD_DATE
LABEL org.opencontainers.image.version=$APP_VERSION
```

```bash
docker build \
  --build-arg GIT_SHA=$(git rev-parse HEAD) \
  --build-arg BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ") \
  --build-arg APP_VERSION=1.2.3 \
  -t acme/payment-service:1.2.3 .
```

### OCI Standard Label Keys

| Label Key | Purpose | Example Value |
|-----------|---------|---------------|
| `org.opencontainers.image.title` | Human-readable name | `payment-service` |
| `org.opencontainers.image.description` | Short description | `Handles payments` |
| `org.opencontainers.image.source` | Repository URL | `https://github.com/acme/repo` |
| `org.opencontainers.image.version` | Semver or tag | `1.2.3` |
| `org.opencontainers.image.created` | RFC 3339 timestamp | `2025-01-15T10:30:00Z` |
| `org.opencontainers.image.revision` | VCS commit SHA | `a1b2c3d4e5f6` |
| `org.opencontainers.image.authors` | Contact information | `team@example.com` |
| `org.opencontainers.image.licenses` | SPDX expression | `MIT` |
| `org.opencontainers.image.vendor` | Organization name | `Acme Corp` |
| `org.opencontainers.image.url` | Image homepage | `https://hub.docker.com/r/acme/repo` |

### Querying Labels

```bash
# Inspect labels for a running container
docker inspect --format '{{json .Config.Labels}}' payment-service | jq .

# Filter images by label
docker images --filter "label=org.opencontainers.image.vendor=Acme Corp"
```

Reference: [Building best practices](https://docs.docker.com/build/building/best-practices/)
