---
title: Use Secret Mounts for Sensitive Data
impact: HIGH
impactDescription: prevents credentials from persisting in image layers
tags: sec, secrets, mount, buildkit
---

## Use Secret Mounts for Sensitive Data

Secrets passed via `COPY` or `ARG` are written into image layers and become permanently visible through `docker history` or by extracting the layer tarballs. Anyone with access to the image -- including registries, CI caches, and downstream consumers -- can recover the plaintext credentials. BuildKit secret mounts inject sensitive data into a single `RUN` instruction without ever writing it to a layer.

**Incorrect (secret baked into image layer via COPY):**

```dockerfile
FROM python:3.12-slim

WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Secret is written into a layer and persists forever
COPY credentials.json /app/credentials.json

COPY . .
CMD ["python", "app.py"]
```

(The `credentials.json` file is embedded in a layer. Even if a subsequent `RUN rm credentials.json` deletes it, the file remains in the earlier layer and can be extracted with `docker save`.)

**Incorrect (secret passed via build argument):**

```dockerfile
FROM node:22-slim

# ARG values are recorded in docker history
ARG DB_PASSWORD
ENV DB_PASSWORD=${DB_PASSWORD}

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --production
COPY . .

CMD ["node", "server.js"]
```

(Running `docker history` on the built image reveals the `DB_PASSWORD` value in plain text. The `ENV` instruction also persists it into every running container.)

**Correct (file-based secret mount):**

```dockerfile
# syntax=docker/dockerfile:1
FROM python:3.12-slim

WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

# Secret is mounted at /run/secrets/db_password for this RUN only
# It never appears in any image layer
RUN --mount=type=secret,id=db_password \
    cat /run/secrets/db_password | python manage.py migrate

CMD ["python", "app.py"]
```

Build command:

```bash
docker build --secret id=db_password,src=./db_password.txt -t myapp .
```

(The secret file is available only during the `RUN` instruction and is never committed to a layer. After the instruction completes, `/run/secrets/db_password` no longer exists.)

**Correct (environment variable-based secret mount):**

```dockerfile
# syntax=docker/dockerfile:1
FROM node:22-slim

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --production
COPY . .

# Secret injected as an environment variable for this RUN only
RUN --mount=type=secret,id=api-key,env=API_KEY \
    node scripts/validate-api-key.js

CMD ["node", "server.js"]
```

Build command:

```bash
API_KEY=sk-live-abc123 docker build --secret id=api-key,env=API_KEY -t myapp .
```

(The `API_KEY` environment variable exists only for the duration of the `RUN` instruction. It is not recorded in `docker history` and does not persist in the image metadata.)

Reference: [Build secrets](https://docs.docker.com/build/building/secrets/)
