---
title: Use Syntax Directive for Latest BuildKit Features
impact: MEDIUM
impactDescription: unlocks cache mounts, secret mounts, heredocs, and other BuildKit features
tags: ctx, syntax-directive, buildkit, parser
---

## Use Syntax Directive for Latest BuildKit Features

The syntax directive tells BuildKit to pull a specific Dockerfile parser image from a registry instead of using whatever version is bundled with the local Docker daemon. Without it, available features depend entirely on the daemon version installed on the build machine -- meaning builds may silently fail or behave differently across environments. Adding the directive ensures every build environment has access to the same set of features regardless of the installed Docker version.

**Incorrect (no syntax directive -- limited to local daemon parser):**

```dockerfile
FROM golang:1.23 AS build
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -o /app/server ./cmd/server

FROM gcr.io/distroless/static-debian12
COPY --from=build /app/server /server
CMD ["/server"]
```

(This Dockerfile cannot use `RUN --mount=type=cache`, `RUN --mount=type=secret`, `RUN --mount=type=bind`, heredoc syntax, or other BuildKit-specific features if the Docker daemon is older than the version that introduced them. The build may work on a developer's machine but fail in CI with a different Docker version.)

**Correct (syntax directive pins the latest stable parser):**

```dockerfile
# syntax=docker/dockerfile:1
FROM golang:1.23 AS build
WORKDIR /app

COPY go.mod go.sum ./
RUN --mount=type=cache,target=/go/pkg/mod \
    go mod download

RUN --mount=type=bind,target=. \
    --mount=type=cache,target=/root/.cache/go-build \
    go build -o /out/server ./cmd/server

FROM gcr.io/distroless/static-debian12
COPY --from=build /out/server /server
CMD ["/server"]
```

(The `# syntax=docker/dockerfile:1` directive pulls the latest `1.x` parser from Docker Hub on every build. This guarantees access to cache mounts, bind mounts, secret mounts, heredocs, and all other stable BuildKit features regardless of the local Docker daemon version.)

### Features Unlocked by the Syntax Directive

| Feature | Syntax | Purpose |
|---------|--------|---------|
| Cache mounts | `RUN --mount=type=cache,target=/path` | Persist package manager caches across builds |
| Bind mounts | `RUN --mount=type=bind,target=/path` | Mount context files without creating a layer |
| Secret mounts | `RUN --mount=type=secret,id=mysecret` | Inject secrets without leaking them into layers |
| SSH mounts | `RUN --mount=type=ssh` | Forward SSH agent for private repo access |
| Heredocs | `RUN <<EOF` | Multi-line scripts without backslash continuation |

### Important Notes

The syntax directive is a parser directive, not a comment. It **must** be the very first line of the Dockerfile -- before any comments, `ARG` instructions, or blank lines. Any content before it causes Docker to treat it as a regular comment and ignore it:

```dockerfile
# This comment causes the syntax directive below to be ignored!
# syntax=docker/dockerfile:1
FROM node:22-slim
```

The tag `docker/dockerfile:1` follows semver: it always resolves to the latest stable `1.x.x` release, so you get bug fixes and new features automatically without changing your Dockerfile.

Reference: [Dockerfile frontend](https://docs.docker.com/build/dockerfile/frontend/)
