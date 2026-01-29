---
title: Make No Distinction Between Local and Third-Party Services
impact: HIGH
impactDescription: ensures code portability, enables seamless service migration
tags: svc, portability, abstraction, services
---

## Make No Distinction Between Local and Third-Party Services

The code for a twelve-factor app treats all backing services identically, whether locally-managed (your own PostgreSQL) or third-party (Amazon RDS, Heroku Postgres). The only difference is the connection URL in config - the application code remains unchanged.

**Incorrect (code branches for service type):**

```python
import os

if os.environ.get('USE_LOCAL_STORAGE') == 'true':
    # Local filesystem storage
    def store_file(data, key):
        with open(f'/uploads/{key}', 'wb') as f:
            f.write(data)

    def get_file(key):
        with open(f'/uploads/{key}', 'rb') as f:
            return f.read()
else:
    # S3 storage
    import boto3
    s3 = boto3.client('s3')

    def store_file(data, key):
        s3.put_object(Bucket='mybucket', Key=key, Body=data)

    def get_file(key):
        response = s3.get_object(Bucket='mybucket', Key=key)
        return response['Body'].read()

# Two code paths to test and maintain
# Bugs in one path might not appear until production
```

**Correct (unified interface, service configured externally):**

```python
import os
import boto3

# S3-compatible interface for all environments
# Production: real AWS S3
# Development: MinIO or LocalStack
# Testing: LocalStack or moto mock

s3 = boto3.client(
    's3',
    endpoint_url=os.environ.get('S3_ENDPOINT_URL'),  # None for real AWS
    aws_access_key_id=os.environ.get('AWS_ACCESS_KEY_ID'),
    aws_secret_access_key=os.environ.get('AWS_SECRET_ACCESS_KEY'),
)

BUCKET = os.environ['S3_BUCKET']

def store_file(data, key):
    s3.put_object(Bucket=BUCKET, Key=key, Body=data)

def get_file(key):
    response = s3.get_object(Bucket=BUCKET, Key=key)
    return response['Body'].read()

# One code path, tested everywhere
```

```bash
# Development with MinIO
S3_ENDPOINT_URL="http://localhost:9000"
S3_BUCKET="dev-uploads"
AWS_ACCESS_KEY_ID="minioadmin"
AWS_SECRET_ACCESS_KEY="minioadmin"

# Production with AWS S3
# S3_ENDPOINT_URL not set (uses real AWS)
S3_BUCKET="prod-uploads"
AWS_ACCESS_KEY_ID="AKIA..."
AWS_SECRET_ACCESS_KEY="..."
```

**Benefits:**
- Development environment mirrors production behavior
- Bugs caught in development, not production
- Easy migration between service providers

Reference: [The Twelve-Factor App - Backing Services](https://12factor.net/backing-services)
