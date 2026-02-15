---
title: Run as Non-Root User
impact: HIGH
impactDescription: reduces container escape blast radius from full root access to unprivileged user scope
tags: sec, user, non-root, privilege
---

## Run as Non-Root User

By default, processes inside a container run as root (UID 0). If an attacker exploits a vulnerability in the application and escapes the container, they gain root access on the host. Running as a non-root user confines the process to an unprivileged account, significantly limiting the damage from container escape, path traversal, or arbitrary file write vulnerabilities.

**Incorrect (no USER instruction -- container runs as root):**

```dockerfile
FROM node:22-slim

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --production
COPY . .

EXPOSE 3000
CMD ["node", "server.js"]
```

(Every process in this container runs as UID 0. A path traversal vulnerability in the application could read or overwrite any file in the container, including `/etc/shadow` and mounted volumes.)

**Correct (dedicated non-root user with explicit UID/GID):**

```dockerfile
FROM node:22-slim

# Create a dedicated group and user with fixed IDs for consistency
# across rebuilds and environments
RUN groupadd -r -g 1001 appuser && \
    useradd --no-log-init -r -u 1001 -g appuser appuser

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci --production

COPY --chown=appuser:appuser . .

# Switch to non-root user for all subsequent instructions and CMD
USER appuser

EXPOSE 3000
CMD ["node", "server.js"]
```

(The application runs as `appuser` (UID 1001). Fixed UID/GID values ensure consistent file ownership across builds and make log attribution predictable in orchestrated environments.)

**Correct (multi-stage build with non-root runtime user):**

```dockerfile
# -- Build stage (root is acceptable here) --
FROM golang:1.23 AS build

WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o /bin/server ./cmd/server

# -- Runtime stage --
FROM gcr.io/distroless/static-debian12

COPY --from=build /bin/server /bin/server

# Distroless includes a nonroot user at UID 65532
USER nonroot:nonroot

EXPOSE 8080
ENTRYPOINT ["/bin/server"]
```

(Distroless images ship with a built-in `nonroot` user. No package installation or user creation is required.)

### Guidelines

- **Assign explicit UID/GID** rather than relying on auto-assignment. This prevents UID drift between image rebuilds and ensures volume permissions are predictable.
- **Avoid installing `sudo`** inside the container. If a process needs elevated privileges at startup (e.g., binding to port 80), use [`gosu`](https://github.com/tianon/gosu) to drop privileges after initialization instead of keeping `sudo` available at runtime.
- **Set `USER` as late as possible** in the Dockerfile so that earlier `RUN` instructions that need root (like `apt-get install`) execute without permission errors.
- **Use `--chown` on COPY instructions** to assign files directly to the non-root user, avoiding a separate `chown` layer.

Reference: [Building best practices](https://docs.docker.com/build/building/best-practices/)
