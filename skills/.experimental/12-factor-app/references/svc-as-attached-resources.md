---
title: Treat Backing Services as Attached Resources
impact: HIGH
impactDescription: enables swapping services without code changes, improves resilience
tags: svc, backing-services, resources, loose-coupling
---

## Treat Backing Services as Attached Resources

A twelve-factor app treats backing services (databases, caches, message queues, SMTP servers) as attached resources, accessed via URLs or credentials stored in config. The app makes no distinction between local and third-party services - both are resources that can be attached or detached at will.

**Incorrect (hardcoded service assumptions):**

```python
import mysql.connector

# Assumes specific database is always available
# Tightly coupled to MySQL, can't swap for PostgreSQL
db = mysql.connector.connect(
    host="localhost",
    user="root",
    password="password",
    database="myapp"
)

# Different code path for "local" vs "external" S3
if IS_PRODUCTION:
    s3 = boto3.client('s3', region_name='us-east-1')
else:
    # Local development uses filesystem
    def upload_file(path, key):
        shutil.copy(path, f'./uploads/{key}')
```

**Correct (services as attached resources):**

```python
import os
from sqlalchemy import create_engine
import boto3

# Database is just a URL - could be local, cloud, managed
# Same code works with PostgreSQL, MySQL, SQLite
engine = create_engine(os.environ["DATABASE_URL"])

# S3 is configured via standard AWS env vars
# Works with real S3, MinIO, LocalStack - no code changes
s3 = boto3.client(
    's3',
    endpoint_url=os.environ.get("S3_ENDPOINT_URL"),  # Optional override
    # AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY from environment
)

def upload_file(path, key):
    bucket = os.environ["S3_BUCKET"]
    s3.upload_file(path, bucket, key)
```

**Benefits:**
- Swap a misbehaving database with a restored backup: just change the URL
- Move from self-hosted Redis to AWS ElastiCache: just change the URL
- Use LocalStack/MinIO in development, real AWS in production: same code

Reference: [The Twelve-Factor App - Backing Services](https://12factor.net/backing-services)
