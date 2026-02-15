---
title: Separate Build and Runtime Stages
impact: CRITICAL
impactDescription: 2-10x final image size reduction
tags: stage, multi-stage, image-size, production
---

## Separate Build and Runtime Stages

Including compilers, build tools, and source code in the final image wastes disk space, increases pull times, and expands the attack surface. Multi-stage builds let you compile in a full SDK image and copy only the resulting binary into a minimal runtime image.

**Incorrect (single stage ships compiler and source):**

```dockerfile
FROM golang:1.23

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -o /app/server ./cmd/server

# Final image includes Go toolchain (~800MB), source code, and module cache
EXPOSE 8080
CMD ["/app/server"]
```

**Correct (build stage compiles, runtime stage ships only the binary):**

```dockerfile
# -- Build stage --
FROM golang:1.23 AS build

WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /bin/server ./cmd/server

# -- Runtime stage --
FROM scratch

# If the binary makes outbound HTTPS calls, copy CA certificates
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /bin/server /bin/server
EXPOSE 8080
ENTRYPOINT ["/bin/server"]
# Final image contains only the static binary + CA certs (~12MB vs ~800MB)
```

Reference: [Multi-stage builds](https://docs.docker.com/build/building/multi-stage/)
