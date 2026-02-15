---
title: One Concern per Container
impact: MEDIUM
impactDescription: enables independent scaling, updates, and failure isolation per service
tags: lint, single-concern, architecture, decoupling
---

## One Concern per Container

Running multiple services in a single container -- such as a web server, application process, and background worker managed by supervisord -- prevents each service from being scaled, updated, restarted, or monitored independently. When one service crashes, it takes down the others. When one service needs more capacity, you must scale the entire bundle. Logs from multiple processes interleave, making debugging harder and structured logging pipelines unreliable.

**Incorrect (multiple services in one container via supervisord):**

```dockerfile
FROM python:3.12-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

COPY supervisord.conf /etc/supervisord.conf
COPY nginx.conf /etc/nginx/nginx.conf
COPY . /app

RUN pip install --no-cache-dir -r /app/requirements.txt

EXPOSE 80

CMD ["supervisord", "-c", "/etc/supervisord.conf"]
```

(This container runs nginx, gunicorn, and a celery worker under supervisord. If the celery worker OOMs, supervisord restarts it but the nginx/gunicorn processes may drop requests during the restart cycle. Scaling requires tripling resources for all three services even if only the worker needs more capacity. Container health is ambiguous -- the container is "running" even if two of three processes have crashed.)

**Correct (separate containers for each concern):**

Web server container:

```dockerfile
# web.Dockerfile
FROM python:3.12-slim

WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

USER nobody
EXPOSE 8000
CMD ["gunicorn", "app:create_app()", "--bind", "0.0.0.0:8000", "--workers", "4"]
```

Background worker container:

```dockerfile
# worker.Dockerfile
FROM python:3.12-slim

WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

USER nobody
CMD ["celery", "-A", "tasks", "worker", "--loglevel=info", "--concurrency=2"]
```

Connected via Docker Compose:

```yaml
services:
  web:
    build:
      dockerfile: web.Dockerfile
    ports:
      - "8000:8000"
    deploy:
      replicas: 2

  worker:
    build:
      dockerfile: worker.Dockerfile
    deploy:
      replicas: 4

  nginx:
    image: nginx:1.27-alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - web
```

(Each service scales independently. The worker can be scaled to 4 replicas while the web server stays at 2. If the worker crashes, web requests continue uninterrupted. Each container produces a single log stream, making log aggregation straightforward.)

### Not a Hard Rule

"One concern per container" is a guideline, not a strict "one process per container" rule. Helper processes that directly support the main process are acceptable:

- A log rotation sidecar that manages the main process's log files
- An init process like `tini` that reaps zombie processes
- A startup script that runs migrations before handing off to the application

The distinction is between **tightly coupled helpers** (acceptable) and **independent services** (should be separate containers). If a process could reasonably have its own scaling policy, deployment lifecycle, or health check, it belongs in its own container.

### Signals and Health

Separate containers also simplify signal handling and health checks:

```dockerfile
# Each container has a clear health check for its single concern
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1
```

With multiple services in one container, a single `HEALTHCHECK` cannot accurately represent the state of all services. One healthy process masks failures in the others.

Reference: [Building best practices](https://docs.docker.com/build/building/best-practices/)
