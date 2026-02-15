---
title: Use External Cache for CI/CD Builds
impact: HIGH
impactDescription: shares cache across ephemeral CI runners, eliminating cold builds
tags: cache, ci-cd, registry-cache, github-actions
---

## Use External Cache for CI/CD Builds

CI/CD runners are typically ephemeral -- each job starts with no local Docker cache, forcing a full rebuild of every layer from scratch. By exporting the build cache to an external backend (like a container registry) and importing it on subsequent builds, layers that have not changed are reused across different runners and pipeline runs.

**Incorrect (no cache sharing in CI):**

```yaml
# .github/workflows/build.yml
name: Build
on: push

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Build image
        run: docker build -t myapp:${{ github.sha }} .
```

(Every CI run starts cold. A 5-minute build runs in full on every push, even when only a README changed.)

**Correct (registry-backed cache with GitHub Actions):**

```yaml
# .github/workflows/build.yml
name: Build
on: push

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Log in to GitHub Container Registry
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and push
        uses: docker/build-push-action@v6
        with:
          context: .
          push: true
          tags: ghcr.io/${{ github.repository }}:${{ github.sha }}
          cache-from: type=registry,ref=ghcr.io/${{ github.repository }}:buildcache
          cache-to: type=registry,ref=ghcr.io/${{ github.repository }}:buildcache,mode=max
```

(The `mode=max` flag exports cache for all intermediate layers, not just the final image. Subsequent builds on any runner pull cached layers from the registry, reducing a 5-minute build to under 30 seconds when only source code changed.)

**Direct docker build equivalent:**

```bash
# Build with external cache (CLI usage)
docker buildx build \
  --cache-from type=registry,ref=ghcr.io/myorg/myapp:buildcache \
  --cache-to type=registry,ref=ghcr.io/myorg/myapp:buildcache,mode=max \
  --tag ghcr.io/myorg/myapp:latest \
  --push .
```

(The same `--cache-from` and `--cache-to` flags work with any CI system -- GitLab CI, CircleCI, Jenkins -- by pointing to an accessible registry.)

Reference: [Docker Build Cache - Optimize](https://docs.docker.com/build/cache/optimize/)
