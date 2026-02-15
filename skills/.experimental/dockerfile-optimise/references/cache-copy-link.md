---
title: Use COPY --link for Cache-Efficient Layer Copying
impact: HIGH
impactDescription: enables layer cache reuse even when preceding layers change
tags: cache, copy-link, buildkit, multi-stage
---

## Use COPY --link for Cache-Efficient Layer Copying

A regular `COPY` instruction adds files on top of the previous layer, creating a dependency chain -- if any earlier layer changes, the `COPY` layer must be rebuilt even when the copied content is identical. `COPY --link` creates an independent layer that does not depend on its predecessors, so it can be reused from cache even when earlier layers in the same stage have changed. This is especially valuable in multi-stage builds where final images copy artifacts from build stages.

**Incorrect (regular COPY -- cache invalidated by any upstream change):**

```dockerfile
# syntax=docker/dockerfile:1
FROM golang:1.23 AS build
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -o /out/server ./cmd/server

FROM alpine:3.20
RUN apk add --no-cache ca-certificates tzdata
COPY --from=build /out/server /usr/local/bin/server
CMD ["server"]
```

(If the `RUN apk add` layer changes -- say you add a new package -- the `COPY --from=build` layer must be rebuilt even though the copied binary is identical. The `COPY` depends on the layer stack below it.)

**Correct (COPY --link creates independent layer):**

```dockerfile
# syntax=docker/dockerfile:1
FROM golang:1.23 AS build
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -o /out/server ./cmd/server

FROM alpine:3.20
RUN apk add --no-cache ca-certificates tzdata
COPY --link --from=build /out/server /usr/local/bin/server
CMD ["server"]
```

(The `COPY --link` creates a self-contained layer. Changing the `apk add` line does not invalidate the copied binary layer. BuildKit can also resolve this layer without needing the base image to exist locally, enabling faster builds.)

### When to Use --link

Use `COPY --link` by default for all `COPY` instructions unless you depend on symlinks or need files to merge with existing directory contents. The performance is always equal to or better than regular `COPY`.

**Multi-stage artifact copies (highest impact):**

```dockerfile
COPY --link --from=build /out/app /usr/local/bin/app
COPY --link --from=assets /out/static /srv/static
```

**Static file copies into the image:**

```dockerfile
COPY --link package.json package-lock.json ./
COPY --link . .
```

### When NOT to Use --link

- When your `COPY` relies on symlinks in the source or destination (linked copies cannot create symlinks that reference existing content)
- When you need copied files to merge into a directory that must already exist from a prior layer

### Requirements

`COPY --link` requires the `# syntax=docker/dockerfile:1` directive (or BuildKit with Dockerfile frontend 1.4+).

Reference: [Building best practices](https://docs.docker.com/build/building/best-practices/)
