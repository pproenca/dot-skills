---
title: Use Distroless or Scratch Images for Production
impact: MEDIUM-HIGH
impactDescription: eliminates shell, package managers, and all non-essential binaries from production
tags: base, distroless, scratch, minimal, security
---

## Use Distroless or Scratch Images for Production

Even slim images include a shell (`/bin/sh`), a package manager (`apt`/`apk`), and dozens of system utilities. If an attacker gains code execution inside a container, these tools become their toolkit for privilege escalation, data exfiltration, and lateral movement. Distroless and scratch images remove everything except the application and its runtime dependencies, leaving nothing for an attacker to exploit.

**Incorrect (slim image for a compiled binary):**

```dockerfile
FROM golang:1.23 AS build
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /bin/server ./cmd/server

FROM python:3.12-slim
COPY --from=build /bin/server /bin/server
EXPOSE 8080
CMD ["/bin/server"]
```

(A statically-linked Go binary is copied into a Python slim image that includes 150MB+ of Python runtime, apt, bash, and hundreds of utilities the binary never uses. The final image is ~170MB instead of ~12MB.)

**Correct (scratch for statically-linked Go binaries):**

```dockerfile
FROM golang:1.23 AS build
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /bin/server ./cmd/server

FROM scratch
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /bin/server /bin/server
EXPOSE 8080
ENTRYPOINT ["/bin/server"]
```

(The `scratch` image is completely empty. The final image contains only the static binary and CA certificates for TLS. No shell, no package manager, no OS -- approximately 12MB total.)

**Correct (distroless for Java applications):**

```dockerfile
FROM eclipse-temurin:21-jdk AS build
WORKDIR /src
COPY . .
RUN ./gradlew bootJar --no-daemon

FROM gcr.io/distroless/java21-debian12
COPY --from=build /src/build/libs/app.jar /app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app.jar"]
```

(The `gcr.io/distroless/java21-debian12` image contains only the JRE and its dependencies. No shell, no package manager, no coreutils. The image is ~220MB compared to ~450MB for a slim JDK image.)

**Correct (distroless for Node.js applications):**

```dockerfile
FROM node:22-slim AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --production
COPY . .

FROM gcr.io/distroless/nodejs22-debian12
WORKDIR /app
COPY --from=build /app /app
EXPOSE 3000
CMD ["server.js"]
```

(The distroless Node.js image ships only the Node.js runtime. There is no npm, no shell, and no OS utilities in the final image.)

### Choosing the Right Minimal Base

| Base Image | Contents | Best For | Size |
|------------|----------|----------|------|
| `scratch` | Nothing at all | Statically-linked binaries (Go, Rust) | Binary size only |
| `gcr.io/distroless/static-debian12` | CA certs, timezone data, `/etc/passwd` | Static binaries needing TLS + user IDs | ~2MB |
| `gcr.io/distroless/base-debian12` | Above + glibc | Dynamically-linked C/C++ binaries | ~20MB |
| `gcr.io/distroless/java21-debian12` | Above + JRE 21 | Java applications | ~220MB |
| `gcr.io/distroless/nodejs22-debian12` | Above + Node.js 22 | Node.js applications | ~170MB |
| `gcr.io/distroless/python3-debian12` | Above + Python 3 | Python applications | ~50MB |

### When NOT to Use Distroless or Scratch

When you need to exec into running containers for debugging, distroless images make troubleshooting difficult because there is no shell. Use a multi-stage approach with a debug target instead:

```dockerfile
FROM golang:1.23 AS build
# ... build steps ...

# Debug target with shell access
FROM alpine:3.20 AS debug
COPY --from=build /bin/server /bin/server
ENTRYPOINT ["/bin/server"]

# Production target without shell
FROM scratch AS production
COPY --from=build /bin/server /bin/server
ENTRYPOINT ["/bin/server"]
```

Build with `--target debug` during development and `--target production` for deployment.

Reference: [Building best practices](https://docs.docker.com/build/building/best-practices/)
