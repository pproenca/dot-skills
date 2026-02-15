---
title: Use Bind Mounts Instead of COPY for Build-Only Files
impact: HIGH
impactDescription: eliminates large source files from build cache layers
tags: ctx, bind-mount, buildkit, cache-efficiency
---

## Use Bind Mounts Instead of COPY for Build-Only Files

`COPY` instructions persist every copied file into an image layer, even when the files are only needed during compilation and the final artifact is a single binary. For compiled languages like Go, C, C++, or Rust, this means the entire source tree and all intermediate object files are stored in the layer cache permanently. A `RUN --mount=type=bind` instruction makes files available to a single `RUN` step without writing them into any layer -- only the build output remains.

### Go

**Incorrect (entire source tree persisted in layer):**

```dockerfile
FROM golang:1.23
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -o /app/server ./cmd/server
```

(The `COPY . .` layer permanently stores every `.go` file, test file, and internal package in the build cache. For a large Go project this can be 50-200 MB of source that is never used after compilation.)

**Correct (source mounted temporarily via bind mount):**

```dockerfile
FROM golang:1.23 AS build
RUN --mount=type=bind,target=. \
    --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    go build -o /out/server ./cmd/server

FROM gcr.io/distroless/static-debian12
COPY --from=build /out/server /server
CMD ["/server"]
```

(The source tree is mounted read-only into the build step and disappears when the `RUN` instruction finishes. The Go module cache and build cache are persisted across builds via cache mounts. Only the compiled binary is written to the layer.)

### C / C++

**Incorrect (source and object files persisted in layer):**

```dockerfile
FROM gcc:14
WORKDIR /build
COPY . .
RUN make -j$(nproc) && make install
```

(The `COPY . .` layer stores all source files, headers, and Makefiles. The `RUN make` layer stores all intermediate `.o` files alongside the final binary. Both layers persist in the cache indefinitely.)

**Correct (bind mount keeps source out of layers):**

```dockerfile
FROM gcc:14 AS build
RUN --mount=type=bind,target=/src \
    cd /src && make -j$(nproc) DESTDIR=/out install

FROM debian:bookworm-slim
COPY --from=build /out/ /
CMD ["/usr/local/bin/myapp"]
```

(Source files and object files exist only during the `RUN` step. The final image contains only the installed binaries and libraries from the `DESTDIR`.)

Reference: [Docker Build Cache - Optimize](https://docs.docker.com/build/cache/optimize/)
