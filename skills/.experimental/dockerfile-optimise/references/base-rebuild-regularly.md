---
title: Rebuild Images Regularly with --pull
impact: MEDIUM
impactDescription: prevents running images with known vulnerabilities
tags: base, rebuild, pull, security-patches
---

## Rebuild Images Regularly with --pull

When Docker builds an image, it caches the base image locally. Subsequent builds reuse that cached copy even if the upstream publisher has released security patches, OS updates, or critical bug fixes. Over time, a locally cached base image accumulates unpatched vulnerabilities that were fixed months ago.

**Incorrect (building without --pull):**

```bash
docker build -t myapp:latest .
```

(Docker uses the locally cached `node:22-alpine` base image, which was pulled three months ago and is missing twelve security patches published since then.)

**Correct (force-pull latest base image on every build):**

```bash
docker build --pull -t myapp:latest .
```

(The `--pull` flag instructs Docker to check the registry for a newer version of every `FROM` image in the Dockerfile and download it before building. This ensures the base image includes the latest security patches.)

**Correct (full freshness for security-critical builds):**

```bash
docker build --pull --no-cache -t myapp:latest .
```

(Adding `--no-cache` forces Docker to re-execute every layer from scratch, ensuring that `apt-get update`, `apk upgrade`, and similar commands fetch the latest package lists instead of reusing a cached layer with stale package metadata.)

### Recommended Rebuild Strategy

| Environment     | Frequency          | Flags                    |
|-----------------|--------------------|--------------------------|
| Development     | On dependency change | `--pull`                |
| CI / Staging    | Every build         | `--pull`                |
| Production      | Weekly or on CVE    | `--pull --no-cache`     |

### Automating Rebuilds in CI

Schedule a weekly CI pipeline that rebuilds and redeploys your production images with `--pull`. This catches base image updates without requiring manual intervention:

```yaml
# Example: GitHub Actions scheduled rebuild
on:
  schedule:
    - cron: '0 3 * * 1'  # Every Monday at 03:00 UTC
jobs:
  rebuild:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: docker build --pull -t myapp:latest .
      - run: docker push myapp:latest
```

(The scheduled workflow pulls fresh base images weekly, ensuring production containers never run on base images more than seven days old.)

Reference: [Building best practices](https://docs.docker.com/build/building/best-practices/)
