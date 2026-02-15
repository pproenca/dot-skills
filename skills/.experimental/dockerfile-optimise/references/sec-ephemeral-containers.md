---
title: Design Ephemeral, Stateless Containers
impact: MEDIUM
impactDescription: enables safe container replacement and horizontal scaling
tags: sec, ephemeral, stateless, twelve-factor
---

## Design Ephemeral, Stateless Containers

Containers that store application state, user uploads, or logs on their local filesystem cannot be safely stopped, replaced, or horizontally scaled. If the container crashes or is rescheduled, the data is lost. If multiple replicas are running, each has a different view of the state. This creates data loss risks, prevents zero-downtime deployments, and blocks horizontal scaling. Following the Twelve-Factor App methodology, containers should be disposable processes that can be started and stopped at any moment.

**Incorrect (state written to the container filesystem):**

```dockerfile
FROM node:22-slim

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --production
COPY . .

# Application writes uploads, sessions, and logs to local directories
# All data is lost when the container stops or is replaced
RUN mkdir -p /app/uploads /app/sessions /app/logs

EXPOSE 3000
CMD ["node", "server.js"]
```

(Uploads, sessions, and logs directories are created inside the container filesystem. Scaling to two replicas means half the requests see different uploads and different sessions. A container restart loses all accumulated data.)

**Correct (state externalized, container is disposable):**

```dockerfile
# syntax=docker/dockerfile:1
FROM node:22-slim

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --production
COPY . .

# /data/uploads is expected to be provided as an external mount
# at runtime (docker run -v or compose volumes). Do not use
# the VOLUME instruction — it creates anonymous volumes that
# are hard to track and prevents downstream images from
# modifying this directory.
RUN mkdir -p /data/uploads && chown node:node /data/uploads

USER node
EXPOSE 3000
CMD ["node", "server.js"]
```

(The `/data/uploads` directory is created and owned by the `node` user. It is expected to be mounted at runtime via `docker run -v` or compose volumes — never via the `VOLUME` Dockerfile instruction, which creates untracked anonymous volumes. The application should store uploads in object storage (S3, GCS, MinIO), sessions in Redis or a database, and write logs to stdout for collection by the container runtime.)

**Correct (Docker Compose with externalized state):**

```yaml
services:
  app:
    build: .
    environment:
      - S3_BUCKET=myapp-uploads
      - REDIS_URL=redis://cache:6379
      - DATABASE_URL=postgres://db:5432/myapp
    volumes:
      # Named volume for data that must persist locally (e.g., processing queue)
      - upload-queue:/data/uploads
    deploy:
      replicas: 3

  cache:
    image: redis:7-alpine

  db:
    image: postgres:16-alpine
    volumes:
      - pgdata:/var/lib/postgresql/data

volumes:
  upload-queue:
  pgdata:
```

(The application service can scale to 3 replicas because no state lives inside the containers. PostgreSQL and Redis handle persistence, and the named volume provides a shared staging area for upload processing.)

### Ephemeral Container Checklist

| Pattern | Incorrect | Correct |
|---------|-----------|---------|
| File uploads | Write to container filesystem | Object storage (S3, GCS, MinIO) |
| Sessions | In-memory or filesystem store | Redis, Memcached, or database |
| Application logs | Write to file inside container | Stdout/stderr (12-factor logging) |
| Cache | Local filesystem | Redis, Memcached, or CDN |
| Scheduled state | Cron job writing to local file | Database or message queue |

Reference: [Building best practices](https://docs.docker.com/build/building/best-practices/)
