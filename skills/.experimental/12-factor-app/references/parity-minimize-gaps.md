---
title: Minimize Gaps Between Development and Production Environments
impact: MEDIUM
impactDescription: prevents "works on my machine" bugs, enables continuous deployment
tags: parity, environments, consistency, deployment
---

## Minimize Gaps Between Development and Production Environments

A twelve-factor app minimizes the gap between development and production in three dimensions: time (deploy frequently), personnel (developers are involved in deploys), and tools (use the same backing services everywhere).

**The three gaps:**

| Gap | Traditional App | Twelve-Factor App |
|-----|-----------------|-------------------|
| **Time** | Weeks between deploys | Hours or minutes |
| **Personnel** | Devs write, ops deploy | Same person does both |
| **Tools** | SQLite dev, PostgreSQL prod | PostgreSQL everywhere |

**Incorrect (large gaps):**

```python
# Different databases per environment
if os.environ.get('ENV') == 'development':
    # SQLite for development - "easier"
    DATABASE_URL = 'sqlite:///dev.db'
else:
    # PostgreSQL for production
    DATABASE_URL = os.environ['DATABASE_URL']

# Code that works in SQLite but fails in PostgreSQL:
# - Different SQL syntax
# - Different type handling
# - Different transaction behavior
# - Missing features (JSON operators, array types)

# Deploy process:
# 1. Developer finishes feature
# 2. Waits for code review (days)
# 3. Waits for QA (days)
# 4. Ops team deploys (weekend)
# 5. Bug found in production (SQLite vs Postgres difference)
```

**Correct (minimal gaps):**

```python
# Same database type everywhere
DATABASE_URL = os.environ['DATABASE_URL']
# Development: postgresql://localhost:5432/myapp_dev
# Production: postgresql://prod-db:5432/myapp

# Same backing services
REDIS_URL = os.environ['REDIS_URL']
# Development: redis://localhost:6379
# Production: redis://prod-redis:6379
```

```yaml
# docker-compose.yml for development
# Mirrors production stack
services:
  db:
    image: postgres:15  # Same version as production
  redis:
    image: redis:7      # Same version as production
  app:
    environment:
      - DATABASE_URL=postgresql://db:5432/myapp
      - REDIS_URL=redis://redis:6379
```

```yaml
# CI/CD - deploy frequently
# Every merge to main deploys to staging
# One-click promotion to production
deploy:
  stage: deploy
  script:
    - deploy-to-staging
  only:
    - main

promote:
  stage: promote
  script:
    - promote-staging-to-production
  when: manual  # But still same day
```

**Benefits:**
- Bugs caught in development, not production
- Developers understand deployment
- Continuous deployment becomes possible
- Faster feedback loops

Reference: [The Twelve-Factor App - Dev/prod parity](https://12factor.net/dev-prod-parity)
