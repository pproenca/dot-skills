---
title: Use Absolute Paths with WORKDIR
impact: LOW-MEDIUM
impactDescription: prevents path confusion and improves Dockerfile readability
tags: inst, workdir, paths, clarity
---

## Use Absolute Paths with WORKDIR

Each RUN instruction executes in a new shell, so `cd /path` within a RUN command does not affect subsequent instructions. Using `RUN cd /path && command` is fragile because forgetting the `&&` chain silently runs the command in the wrong directory. Relative WORKDIR paths (e.g., `WORKDIR src`) resolve against the previous WORKDIR, creating an implicit dependency chain that is hard to follow and easy to break during refactoring.

**Incorrect (cd does not persist across RUN instructions):**

```dockerfile
FROM node:22-slim

RUN mkdir -p /usr/src/app
RUN cd /usr/src/app && npm install
RUN npm run build
```

(The second `RUN npm run build` executes in `/` (the default working directory), not `/usr/src/app`. The `cd` in the previous RUN instruction only affected that instruction's shell. The build fails because there is no `package.json` in `/`.)

**Incorrect (relative WORKDIR creates implicit dependency chain):**

```dockerfile
FROM node:22-slim

WORKDIR app
WORKDIR src
WORKDIR ../config
```

(Each relative WORKDIR resolves against the previous one: `app` becomes `/app`, then `src` becomes `/app/src`, then `../config` becomes `/app/config`. This chain is hard to follow and breaks if any WORKDIR is reordered or removed.)

**Correct (absolute WORKDIR persists across all subsequent instructions):**

```dockerfile
FROM node:22-slim

WORKDIR /usr/src/app

COPY package.json package-lock.json ./
RUN npm ci --production

COPY . .
RUN npm run build

EXPOSE 3000
CMD ["node", "dist/server.js"]
```

(WORKDIR sets the working directory for all subsequent RUN, CMD, ENTRYPOINT, COPY, and ADD instructions. Both `npm ci` and `npm run build` execute in `/usr/src/app` without needing `cd`. The `COPY . .` instruction copies into `/usr/src/app` because the relative `.` destination resolves against WORKDIR.)

**Correct (WORKDIR with multi-stage builds):**

```dockerfile
# -- Build stage --
FROM golang:1.23 AS build

WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o /bin/server ./cmd/server

# -- Runtime stage --
FROM gcr.io/distroless/static-debian12

WORKDIR /app
COPY --from=build /bin/server ./server

ENTRYPOINT ["./server"]
```

(Each stage has its own WORKDIR. The build stage works in `/src` and the runtime stage works in `/app`. Using absolute paths in each stage makes the Dockerfile self-documenting and prevents confusion about which directory is active.)

### Guidelines

- **Always use absolute paths** with WORKDIR (e.g., `WORKDIR /app`, not `WORKDIR app`).
- **Set WORKDIR once per stage** near the top, after the FROM instruction. Avoid changing WORKDIR multiple times within a stage unless there is a clear reason.
- **WORKDIR creates the directory** if it does not exist. There is no need for a preceding `RUN mkdir -p /app`.
- **Use WORKDIR instead of `cd`** in RUN instructions. If a specific directory is needed temporarily, use `cd` within a single chained command: `RUN cd /tmp && wget ... && tar -xzf ...`.

Reference: [Building best practices](https://docs.docker.com/build/building/best-practices/)
