---
title: Use the Same Type and Version of Backing Services in All Environments
impact: MEDIUM
impactDescription: eliminates environment-specific bugs, ensures production behavior in development
tags: parity, backing-services, consistency, testing
---

## Use the Same Type and Version of Backing Services in All Environments

The twelve-factor developer resists the urge to use different backing services between development and production. Using SQLite locally and PostgreSQL in production, or mocking Redis in tests, creates subtle bugs that only appear in production.

**Incorrect (different backing services):**

```python
# settings.py
if os.environ.get('ENV') == 'development':
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.sqlite3',  # Easy to set up
            'NAME': 'db.sqlite3',
        }
    }
    CACHES = {
        'default': {
            'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',
        }
    }
else:
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.postgresql',
            'NAME': os.environ['DB_NAME'],
            # ...
        }
    }
    CACHES = {
        'default': {
            'BACKEND': 'django_redis.cache.RedisCache',
            'LOCATION': os.environ['REDIS_URL'],
        }
    }
# Bugs from:
# - SQLite vs PostgreSQL query differences
# - In-memory cache vs Redis behavior differences
# - Different transaction semantics
```

**Correct (same backing services):**

```python
# settings.py - same services everywhere
DATABASES = {
    'default': dj_database_url.config(default='postgresql://localhost/myapp')
}

CACHES = {
    'default': {
        'BACKEND': 'django_redis.cache.RedisCache',
        'LOCATION': os.environ.get('REDIS_URL', 'redis://localhost:6379/0'),
    }
}
```

```yaml
# docker-compose.yml - production stack locally
version: '3.8'
services:
  db:
    image: postgres:15.4  # Same version as production
    volumes:
      - pgdata:/var/lib/postgresql/data
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: myapp
      POSTGRES_PASSWORD: localdev

  redis:
    image: redis:7.2  # Same version as production

  elasticsearch:
    image: elasticsearch:8.10.2  # Same version as production

  app:
    build: .
    environment:
      - DATABASE_URL=postgresql://myapp:localdev@db:5432/myapp
      - REDIS_URL=redis://redis:6379/0
      - ELASTICSEARCH_URL=http://elasticsearch:9200
    depends_on:
      - db
      - redis
      - elasticsearch

volumes:
  pgdata:
```

**Modern tools make this easy:**

```bash
# Docker makes running real services trivial
docker run -d -p 5432:5432 postgres:15
docker run -d -p 6379:6379 redis:7

# Package managers have database packages
brew install postgresql@15
brew install redis

# Cloud emulators for cloud services
# LocalStack for AWS
docker run -d -p 4566:4566 localstack/localstack
# Firebase emulator for Google services
firebase emulators:start
```

**Benefits:**
- Same query behavior in development and production
- Same caching semantics everywhere
- No "it works in SQLite" production bugs
- Tests reflect real production behavior

Reference: [The Twelve-Factor App - Dev/prod parity](https://12factor.net/dev-prod-parity)
