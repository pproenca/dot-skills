---
title: Define HEALTHCHECK for Container Orchestration
impact: MEDIUM
impactDescription: enables orchestrators to detect and replace unhealthy containers
tags: inst, healthcheck, orchestration, reliability
---

## Define HEALTHCHECK for Container Orchestration

Without a HEALTHCHECK instruction, Docker considers a container healthy as long as its main process is running. A deadlocked application, an exhausted connection pool, or an unresponsive web server all report as "healthy" because the process itself has not exited. Orchestrators like Docker Swarm and Docker Compose continue routing traffic to these broken containers, causing user-visible outages that persist until manual intervention.

**Incorrect (no HEALTHCHECK -- container appears healthy even when the application is unresponsive):**

```dockerfile
FROM node:22-slim

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --production
COPY . .

EXPOSE 3000
CMD ["node", "server.js"]
```

(Docker reports this container as "healthy" indefinitely, even if the event loop is blocked, the database connection is lost, or the HTTP server has stopped accepting requests. Docker Swarm will not replace it and Docker Compose `depends_on` with `condition: service_healthy` will hang.)

**Correct (HEALTHCHECK with curl for Debian-based images):**

```dockerfile
FROM node:22-slim

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --production
COPY . .

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD ["curl", "-f", "http://localhost:3000/health"]

CMD ["node", "server.js"]
```

(Docker probes the `/health` endpoint every 30 seconds. After 3 consecutive failures (5-second timeout each), the container is marked `unhealthy`. The 10-second start period gives the application time to initialize before health checks begin counting failures.)

**Correct (HEALTHCHECK with wget for Alpine images that lack curl):**

```dockerfile
FROM node:22-alpine

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --production
COPY . .

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD ["wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:3000/health"]

CMD ["node", "server.js"]
```

(Alpine images include wget by default but not curl. The `--spider` flag performs a HEAD request without downloading the response body, and `--no-verbose` suppresses output to keep container logs clean.)

**Correct (HEALTHCHECK with a zero-dependency custom binary):**

```dockerfile
FROM gcr.io/distroless/static-debian12

COPY --from=build /bin/server /bin/server
COPY --from=build /bin/healthcheck /bin/healthcheck

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD ["/bin/healthcheck"]

ENTRYPOINT ["/bin/server"]
```

(Distroless images have no shell, curl, or wget. A statically compiled healthcheck binary built in the build stage avoids adding runtime dependencies to the production image.)

### HEALTHCHECK Parameters

| Parameter | Default | Purpose |
|-----------|---------|---------|
| `--interval` | 30s | Time between health check probes |
| `--timeout` | 30s | Maximum time a single probe can take before it is considered failed |
| `--start-period` | 0s | Grace period for container initialization (failures during this period do not count toward retries) |
| `--retries` | 3 | Number of consecutive failures required to mark the container as unhealthy |

### When NOT to Use HEALTHCHECK

In Kubernetes deployments, **liveness and readiness probes** defined in the Pod spec are preferred over the Dockerfile HEALTHCHECK instruction. Kubernetes does not use the Docker HEALTHCHECK and its probes offer more granular control (separate liveness, readiness, and startup probes with configurable HTTP, TCP, and exec checks). However, HEALTHCHECK remains essential for **Docker Compose** and **Docker Swarm** environments where Kubernetes probes are not available.

Reference: [Dockerfile reference - HEALTHCHECK](https://docs.docker.com/reference/dockerfile/)
