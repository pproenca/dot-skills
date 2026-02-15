---
title: Pin Package Versions for Reproducibility
impact: MEDIUM
impactDescription: prevents unexpected breakage from upstream package updates
tags: dep, version-pinning, reproducibility, deterministic
---

## Pin Package Versions for Reproducibility

Unpinned packages resolve to whatever version is current at build time. A new major or minor release of a system dependency can introduce breaking API changes, binary incompatibilities, or subtle behaviour differences without any change to your Dockerfile. Pinning versions ensures that every build produces the same result regardless of when it runs.

**Incorrect (unpinned, non-deterministic installs):**

```dockerfile
FROM ubuntu:24.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    nginx \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*
```

(Installs whatever version the Ubuntu mirror resolves today. A build on Monday may get `nginx 1.24` while the same Dockerfile on Friday gets `nginx 1.26` after an archive update — silently breaking reverse-proxy configuration.)

**Correct (pinned to major.minor with wildcard patch):**

```dockerfile
FROM ubuntu:24.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3=3.12.* \
    nginx=1.24.* \
    postgresql-client=16.* \
    && rm -rf /var/lib/apt/lists/*
```

(Pins each package to a specific major.minor series while still accepting patch-level security updates. Builds are reproducible across machines and time, and upstream minor bumps cannot silently break your image.)

### pip — use a locked requirements file

**Incorrect (loose constraints allow version drift):**

```text
# requirements.txt
flask>=3.0
sqlalchemy
requests
```

(Every build may resolve to a different combination of versions. A breaking release of `sqlalchemy` can fail your application without any code change.)

**Correct (exact versions pinned):**

```text
# requirements.txt
flask==3.0.2
sqlalchemy==2.0.29
requests==2.31.0
```

(Use `pip freeze > requirements.txt` or a tool like `pip-compile` to generate exact pins. Every build installs the identical dependency tree.)

### Discovering Available Versions

To find available versions for apt packages in your target base image, run:

```bash
docker run --rm ubuntu:24.04 apt-cache policy nginx
```

Version availability varies by distribution release. Always verify against the specific base image you are using.

Reference: [Building best practices](https://docs.docker.com/build/building/best-practices/)
