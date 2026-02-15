---
title: Use SSH Mounts for Private Repository Access
impact: HIGH
impactDescription: enables private repo cloning without exposing SSH keys in image
tags: sec, ssh, git, private-repo
---

## Use SSH Mounts for Private Repository Access

Cloning private repositories during a Docker build typically requires SSH key access. Copying SSH keys into the image and deleting them later does not remove them from the layer where they were written -- Docker images are append-only, and every layer is independently extractable. BuildKit SSH mounts forward the host's SSH agent into a single `RUN` instruction without ever writing key material to any layer.

**Incorrect (SSH key copied into image layer):**

```dockerfile
FROM node:22-slim

WORKDIR /app

# Key is written into this layer permanently
COPY id_rsa /root/.ssh/id_rsa
RUN chmod 600 /root/.ssh/id_rsa && \
    ssh-keyscan github.com >> /root/.ssh/known_hosts && \
    git clone git@github.com:acme-corp/private-lib.git /app/lib

# Deleting the key does NOT remove it from the COPY layer above
RUN rm -rf /root/.ssh

COPY package.json package-lock.json ./
RUN npm ci --production
COPY . .

CMD ["node", "server.js"]
```

(The `COPY id_rsa /root/.ssh/id_rsa` instruction writes the private key into a layer. Running `docker save` and extracting the layer tarball reveals the key in full, regardless of the subsequent `rm`. Anyone who pulls this image can recover the SSH private key.)

**Correct (SSH agent forwarded via mount):**

```dockerfile
# syntax=docker/dockerfile:1
FROM node:22-slim

WORKDIR /app

# SSH agent is forwarded for this RUN only -- no key touches the filesystem
RUN --mount=type=ssh \
    mkdir -p /root/.ssh && \
    ssh-keyscan github.com >> /root/.ssh/known_hosts && \
    git clone git@github.com:acme-corp/private-lib.git /app/lib && \
    rm -rf /root/.ssh

COPY package.json package-lock.json ./
RUN npm ci --production
COPY . .

CMD ["node", "server.js"]
```

Build command:

```bash
# Ensure the SSH agent is running and has the required key loaded
eval $(ssh-agent -s)
ssh-add ~/.ssh/id_ed25519

# Pass the SSH agent socket to the build
docker build --ssh default -t myapp .
```

(BuildKit forwards the host SSH agent into the `RUN` instruction via a Unix socket. The private key never exists as a file inside the build container. After the instruction completes, the socket is removed and no SSH material persists in any layer.)

**Correct (multi-stage build isolating the clone):**

```dockerfile
# syntax=docker/dockerfile:1

# -- Clone stage: fetches private dependencies --
FROM alpine/git:latest AS source

RUN --mount=type=ssh \
    mkdir -p /root/.ssh && \
    ssh-keyscan github.com >> /root/.ssh/known_hosts && \
    git clone --depth 1 git@github.com:acme-corp/private-lib.git /private-lib && \
    rm -rf /root/.ssh

# -- Build stage: compiles application --
FROM node:22-slim AS build

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
COPY --from=source /private-lib ./lib/private-lib
RUN npm run build

# -- Runtime stage: minimal production image --
FROM node:22-slim

WORKDIR /app
COPY --from=build /app/dist ./dist
COPY --from=build /app/node_modules ./node_modules
COPY package.json ./

USER node
EXPOSE 3000
CMD ["node", "dist/server.js"]
```

(The SSH mount is confined to the `source` stage. The final runtime image contains only the compiled output -- no Git history, no `.ssh` directory, and no reference to the SSH agent.)

### CI/CD Integration

Most CI platforms provide an SSH agent that can be forwarded to Docker builds:

```bash
# GitHub Actions example
docker build --ssh default=$SSH_AUTH_SOCK -t myapp .
```

If using Docker Compose with BuildKit:

```yaml
services:
  app:
    build:
      context: .
      ssh:
        - default
```

Reference: [Build secrets](https://docs.docker.com/build/building/secrets/)
