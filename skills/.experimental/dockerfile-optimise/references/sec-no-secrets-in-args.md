---
title: Never Pass Secrets via ARG or ENV
impact: HIGH
impactDescription: prevents credential exposure in docker history and image metadata
tags: sec, arg, env, secrets, vulnerability
---

## Never Pass Secrets via ARG or ENV

Both `ARG` and `ENV` persist secret values in the image. `ARG` values are recorded in the build history and can be read with `docker history --no-trunc`. `ENV` values are baked into the image configuration and are visible in every running container via `/proc/1/environ` or `docker inspect`. Docker's built-in build check `SecretsUsedInArgOrEnv` specifically flags this pattern as a security violation.

**Incorrect (secret passed as build argument):**

```dockerfile
FROM python:3.12-slim

# ARG value is recorded in build history in plain text
ARG AWS_SECRET_ACCESS_KEY

WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

# The secret is visible via: docker history --no-trunc <image>
RUN AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
    python manage.py collectstatic --noinput

CMD ["gunicorn", "app.wsgi:application"]
```

(Running `docker history --no-trunc` on the built image displays the full `ARG AWS_SECRET_ACCESS_KEY=AKIA...` value. Anyone who pulls this image can extract the credential.)

**Incorrect (secret persisted via ENV):**

```dockerfile
FROM node:22-slim

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --production
COPY . .

# ENV persists in every layer and in the running container
ENV ADMIN_PASS=s3cret-p@ssw0rd

# Even unsetting it in a later layer does NOT remove it --
# the value is already committed in the ENV instruction's layer
RUN unset ADMIN_PASS

CMD ["node", "server.js"]
```

(The `ENV ADMIN_PASS=s3cret-p@ssw0rd` instruction is permanently recorded in the image metadata. Running `docker inspect` on any container from this image reveals the password. The `unset` in a subsequent `RUN` layer has no effect on the image configuration.)

**Correct (secret mount with environment variable injection):**

```dockerfile
# syntax=docker/dockerfile:1
FROM python:3.12-slim

WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

# Secret is injected as an env var for this RUN instruction only
# It is never written to any layer or image metadata
RUN --mount=type=secret,id=aws-key,env=AWS_SECRET_ACCESS_KEY \
    python manage.py collectstatic --noinput

CMD ["gunicorn", "app.wsgi:application"]
```

Build command (passing secret from host environment variable):

```bash
docker build \
    --secret id=aws-key,env=AWS_SECRET_ACCESS_KEY \
    -t myapp .
```

(The `AWS_SECRET_ACCESS_KEY` environment variable exists only for the duration of the `RUN` instruction. It does not appear in `docker history`, `docker inspect`, or any image layer.)

**Correct (secret mount from file):**

```dockerfile
# syntax=docker/dockerfile:1
FROM node:22-slim

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --production
COPY . .

# Secret mounted as a file, read at build time, never persisted
RUN --mount=type=secret,id=admin-pass \
    ADMIN_PASS=$(cat /run/secrets/admin-pass) \
    node scripts/seed-admin.js

CMD ["node", "server.js"]
```

Build command (passing secret from a file):

```bash
docker build \
    --secret id=admin-pass,src=./admin-password.txt \
    -t myapp .
```

(The secret file is mounted into the build container at `/run/secrets/admin-pass` for a single `RUN` instruction. It is never committed to the image filesystem.)

### Runtime Secrets

For secrets needed at runtime (not just build time), use orchestrator-level secret management instead of `ENV`:

- **Docker Swarm:** `docker service create --secret db_password ...` mounts secrets at `/run/secrets/` inside running containers.
- **Kubernetes:** Use `Secret` resources mounted as volumes or injected via the Secrets Store CSI driver.
- **Docker Compose:** Use the `secrets` top-level key to mount secrets from files or environment into containers at runtime.

Reference: [SecretsUsedInArgOrEnv](https://docs.docker.com/reference/build-checks/secrets-used-in-arg-or-env/)
