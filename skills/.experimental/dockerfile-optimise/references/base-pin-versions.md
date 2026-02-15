---
title: Pin Base Image Versions with Digests
impact: HIGH
impactDescription: guarantees reproducible builds and prevents supply chain attacks
tags: base, version-pinning, digest, reproducibility, security
---

## Pin Base Image Versions with Digests

Mutable tags like `:latest` or `:3.12` can resolve to a completely different image over time. A build that worked yesterday may break today because the base image was silently updated. Worse, a compromised tag could inject malicious code into your supply chain without any change to your Dockerfile.

**Incorrect (mutable tag, non-deterministic builds):**

```dockerfile
FROM python:latest

WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

CMD ["python", "app.py"]
```

(The `python:latest` tag resolves to a different image every time the upstream publishes a new Python release. Builds are non-reproducible and can break without any Dockerfile change.)

**Better (pinned minor version, still mutable):**

```dockerfile
FROM python:3.12-slim

WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

CMD ["python", "app.py"]
```

(The `python:3.12-slim` tag limits drift to patch-level updates within the 3.12 series, but the underlying image still changes when Debian packages are updated or security patches are applied.)

**Correct (immutable digest, fully reproducible):**

```dockerfile
FROM python:3.12-slim@sha256:a866731a6b71c4a194a845d86e06568725e430ed21271324873d91eb9e2a0c81

WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

CMD ["python", "app.py"]
```

(The `@sha256:...` digest is immutable. Every build uses the exact same base image regardless of when or where it runs. The human-readable tag `python:3.12-slim` is kept for readability but the digest takes precedence.)

### The Trade-off: Reproducibility vs. Automatic Updates

Pinning a digest means you opt out of automatic security patches. If the upstream publishes a fix for a critical CVE, your builds will continue using the old, vulnerable image until you manually update the digest.

To manage this trade-off:

- **Use Docker Scout** or a similar tool to monitor pinned images for new vulnerabilities and receive automated remediation pull requests.
- **Automate digest updates** in CI by periodically resolving the latest digest for your pinned tag and opening a PR when it changes.
- **Pin in production Dockerfiles** where reproducibility matters most, and use mutable tags in development or CI images where freshness matters more.

### Finding the Digest

```bash
# Get the digest for a specific tag
docker inspect --format='{{index .RepoDigests 0}}' python:3.12-slim

# Or pull and inspect in one step
docker pull python:3.12-slim
docker images --digests python
```

Reference: [Building best practices](https://docs.docker.com/build/building/best-practices/)
