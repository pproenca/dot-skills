---
title: Use Lockfiles for Deterministic Dependency Resolution
impact: HIGH
impactDescription: guarantees identical builds, prevents "it worked yesterday" bugs
tags: dep, lockfile, reproducibility, ci-cd
---

## Use Lockfiles for Deterministic Dependency Resolution

While a manifest declares acceptable version ranges, a lockfile pins exact versions including all transitive dependencies. This ensures that `pip install` today produces identical results to `pip install` six months from now.

**Incorrect (version ranges without lockfile):**

```toml
# pyproject.toml - only specifies ranges
[project]
dependencies = [
    "requests>=2.28.0",
    "boto3>=1.26.0",
]
# Today: installs requests 2.31.0, boto3 1.34.0
# Next month: installs requests 2.32.0, boto3 1.35.0
# Subtle breaking changes cause production bugs
```

**Correct (lockfile pins exact versions):**

```bash
# Generate lockfile with pip-compile (pip-tools)
pip-compile pyproject.toml -o requirements.lock

# Or use poetry
poetry lock
```

```text
# requirements.lock (generated)
requests==2.31.0
    # via myapp (pyproject.toml)
urllib3==2.1.0
    # via requests
certifi==2023.11.17
    # via requests
boto3==1.34.14
    # via myapp (pyproject.toml)
botocore==1.34.14
    # via boto3
# Every transitive dependency pinned
```

```bash
# Install from lockfile for reproducible builds
pip install -r requirements.lock

# CI/CD uses the same lockfile
# Production uses the same lockfile
# All environments are identical
```

**When to update the lockfile:**
- When intentionally upgrading dependencies
- When adding new dependencies
- As part of regular security update cycles

**Benefits:**
- Yesterday's build == Today's build == Tomorrow's build
- Security patches can be precisely tracked
- Debugging is easier when you know exact versions
- Rollbacks restore exact dependency state

Reference: [The Twelve-Factor App - Dependencies](https://12factor.net/dependencies)
