---
title: Strictly Separate Configuration from Code
impact: CRITICAL
impactDescription: enables deployment to any environment without code changes
tags: config, separation, security, deployment
---

## Strictly Separate Configuration from Code

A twelve-factor app strictly separates config from code. Configuration is anything likely to vary between deploys (database URLs, credentials, feature flags). A litmus test: could you open-source your codebase right now without exposing credentials?

**Incorrect (config hardcoded in code):**

```python
# settings.py
DATABASE_URL = "postgresql://admin:secretpass@prod-db.company.com:5432/myapp"
STRIPE_API_KEY = "sk_live_abc123xyz"
DEBUG = False

# This file is committed to git
# Anyone with repo access sees production credentials
# Deploying to staging requires code changes
```

**Correct (config externalized):**

```python
# settings.py
import os

DATABASE_URL = os.environ["DATABASE_URL"]
STRIPE_API_KEY = os.environ["STRIPE_API_KEY"]
DEBUG = os.environ.get("DEBUG", "false").lower() == "true"

# Code is safe to open-source
# Each deploy sets its own environment variables
```

```bash
# Development
export DATABASE_URL="postgresql://dev:dev@localhost:5432/myapp_dev"
export STRIPE_API_KEY="sk_test_xxx"
export DEBUG="true"

# Production (set by deployment platform)
DATABASE_URL="postgresql://admin:xxx@prod-db:5432/myapp"
STRIPE_API_KEY="sk_live_xxx"
DEBUG="false"
```

**What IS configuration (externalize):**
- Database connection strings
- Credentials for external services (APIs, S3, etc.)
- Per-deploy values (hostnames, feature flags)

**What is NOT configuration (keep in code):**
- Internal routing (e.g., `config/routes.rb`)
- Dependency injection wiring
- Code structure decisions

Reference: [The Twelve-Factor App - Config](https://12factor.net/config)
