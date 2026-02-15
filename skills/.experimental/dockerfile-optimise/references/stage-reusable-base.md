---
title: Create Reusable Base Stages
impact: MEDIUM
impactDescription: eliminates duplicate setup across multiple build stages
tags: stage, base, reusable, dry
---

## Create Reusable Base Stages

When multiple stages need the same tools, environment variables, or configuration, repeating that setup in each stage wastes build time and creates a maintenance burden. Extract common setup into a shared base stage that other stages inherit from via `FROM ... AS`.

**Incorrect (each stage independently installs the same tools):**

```dockerfile
FROM rust:1.78-slim AS service-auth
RUN apt-get update && apt-get install -y pkg-config libssl-dev protobuf-compiler
WORKDIR /src/auth
COPY services/auth/ .
RUN cargo build --release

FROM rust:1.78-slim AS service-gateway
# Duplicates the exact same apt-get install — wastes time and risks version drift
RUN apt-get update && apt-get install -y pkg-config libssl-dev protobuf-compiler
WORKDIR /src/gateway
COPY services/gateway/ .
RUN cargo build --release

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y libssl3 && rm -rf /var/lib/apt/lists/*
COPY --from=service-auth /src/auth/target/release/auth /usr/local/bin/auth
COPY --from=service-gateway /src/gateway/target/release/gateway /usr/local/bin/gateway
```

**Correct (shared base stage installs common dependencies once):**

```dockerfile
FROM rust:1.78-slim AS builder-base
RUN apt-get update && apt-get install -y pkg-config libssl-dev protobuf-compiler \
    && rm -rf /var/lib/apt/lists/*

FROM builder-base AS service-auth
WORKDIR /src/auth
COPY services/auth/ .
RUN cargo build --release

FROM builder-base AS service-gateway
WORKDIR /src/gateway
COPY services/gateway/ .
RUN cargo build --release

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y libssl3 && rm -rf /var/lib/apt/lists/*
COPY --from=service-auth /src/auth/target/release/auth /usr/local/bin/auth
COPY --from=service-gateway /src/gateway/target/release/gateway /usr/local/bin/gateway
# Common tools installed once, both service stages build in parallel from the shared base
```

Reference: [Multi-stage builds](https://docs.docker.com/build/building/multi-stage/)
