---
title: Reference All Backing Services via Connection URLs in Config
impact: HIGH
impactDescription: standardized format, easy to swap services, works across all platforms
tags: svc, connection-string, url, config
---

## Reference All Backing Services via Connection URLs in Config

Every backing service should be referenced by a URL or connection string stored in an environment variable. This standardized approach makes services truly interchangeable and keeps the app portable across deployment environments.

**Incorrect (fragmented connection parameters):**

```python
import os

# Database connection spread across multiple variables
DB_HOST = os.environ.get('DB_HOST', 'localhost')
DB_PORT = os.environ.get('DB_PORT', '5432')
DB_NAME = os.environ.get('DB_NAME', 'myapp')
DB_USER = os.environ.get('DB_USER', 'postgres')
DB_PASSWORD = os.environ.get('DB_PASSWORD', '')

# Hard to manage, easy to misconfigure
connection = psycopg2.connect(
    host=DB_HOST,
    port=DB_PORT,
    dbname=DB_NAME,
    user=DB_USER,
    password=DB_PASSWORD
)
```

**Correct (single connection URL):**

```python
import os
from sqlalchemy import create_engine

# One URL contains all connection information
DATABASE_URL = os.environ["DATABASE_URL"]
# postgresql://user:password@host:5432/dbname?sslmode=require

engine = create_engine(DATABASE_URL)
```

```bash
# Environment variables are clean and consistent
DATABASE_URL="postgresql://admin:secret@db.example.com:5432/myapp"
REDIS_URL="redis://:password@redis.example.com:6379/0"
AMQP_URL="amqp://user:pass@rabbitmq.example.com:5672/vhost"
ELASTICSEARCH_URL="https://user:pass@es.example.com:9200"
SMTP_URL="smtp://user:pass@smtp.example.com:587"
```

**URL format benefits:**

```python
from urllib.parse import urlparse

# URLs are easy to parse programmatically if needed
url = urlparse(os.environ["DATABASE_URL"])
print(url.scheme)    # postgresql
print(url.hostname)  # db.example.com
print(url.port)      # 5432
print(url.path)      # /myapp
print(url.username)  # admin
```

**Benefits:**
- Copy-paste a URL from any provider's dashboard
- Managed database services provide connection URLs directly
- One variable to change when swapping services
- Standard format across all service types

Reference: [The Twelve-Factor App - Backing Services](https://12factor.net/backing-services)
