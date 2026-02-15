---
title: Enable Docker Build Checks
impact: MEDIUM
impactDescription: prevents 20+ categories of silent Dockerfile defects from reaching production
tags: lint, build-checks, validation, buildkit
---

## Enable Docker Build Checks

Docker build checks analyze your Dockerfile for common anti-patterns -- shell-form CMD, secrets leaked through ARG, duplicate stage names, and more. Without checks enabled, these issues silently pass through the build and surface as runtime failures or security vulnerabilities in production.

**Incorrect (building without checks -- anti-patterns silently pass):**

```dockerfile
# No check directive -- build proceeds even with issues
FROM ubuntu:24.04

ARG DB_PASSWORD
ENV DB_PASSWORD=$DB_PASSWORD

RUN apt-get update && apt-get install -y curl

# Shell form CMD -- PID 1 runs as /bin/sh -c wrapper, breaks signal handling
CMD node server.js
```

(Anti-patterns like secrets in `ARG`, missing cleanup of apt lists, and shell-form `CMD` go completely undetected. The build succeeds and the image ships with all of these issues intact.)

**Correct (build checks enabled to catch anti-patterns before build):**

Validation-only mode from the CLI -- checks the Dockerfile without producing an image:

```bash
docker build --check .
```

Or embed the check directive directly in the Dockerfile to enforce checks on every build:

```dockerfile
# syntax=docker/dockerfile:1
# check=error=true

FROM ubuntu:24.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

CMD ["node", "server.js"]
```

(The `# check=error=true` directive causes the build to fail if any check violations are found. This turns warnings into hard errors, preventing non-compliant images from being built.)

### Skipping Specific Checks

Some checks may not apply to your use case. Skip individual checks with the `skip` parameter:

```dockerfile
# check=error=true;skip=JSONArgsRecommended
# syntax=docker/dockerfile:1

FROM ubuntu:24.04

# Shell form is intentional here -- we need variable expansion
CMD echo "Starting $APP_NAME" && exec node server.js
```

Skip multiple checks with a comma-separated list:

```dockerfile
# check=error=true;skip=JSONArgsRecommended,SecretsUsedInArgOrEnv
```

### Using the Build Arg

Enable checks via the `BUILDKIT_DOCKERFILE_CHECK` build argument without modifying the Dockerfile:

```bash
# Run checks only (no image output)
docker build --check --build-arg BUILDKIT_DOCKERFILE_CHECK=error=true .

# Build normally but fail on check violations
docker build --build-arg BUILDKIT_DOCKERFILE_CHECK=error=true -t myapp .
```

### Requirements

Docker build checks require Docker Engine 27.0+ or Docker Desktop 4.33+. Older versions silently ignore the `# check` directive and `--check` flag.

Reference: [Docker Build Checks](https://docs.docker.com/build/checks/)
