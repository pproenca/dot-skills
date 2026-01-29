---
title: Never Assume Local Filesystem Persists Between Requests
impact: HIGH
impactDescription: prevents data loss on restart, enables containerized deployment
tags: proc, filesystem, storage, ephemeral
---

## Never Assume Local Filesystem Persists Between Requests

The filesystem of a twelve-factor app process is ephemeral. Any file written will be lost when the process restarts, the container is replaced, or the instance is terminated. Use backing services for all persistent storage.

**Incorrect (persisting to local filesystem):**

```python
import os

UPLOAD_DIR = '/var/uploads'

def save_upload(file):
    # Writing to local filesystem
    path = os.path.join(UPLOAD_DIR, file.filename)
    file.save(path)
    return path
    # File exists only on THIS container/instance
    # Lost on restart, invisible to other instances

def get_upload(filename):
    path = os.path.join(UPLOAD_DIR, filename)
    return open(path, 'rb')
    # If request routes to different instance: FileNotFoundError
```

```dockerfile
# Volume mount doesn't help in orchestrated environments
FROM python:3.11
VOLUME /var/uploads
# This volume is local to the container
# Kubernetes will create a new volume each pod restart
```

**Correct (external persistent storage):**

```python
import boto3
import os

s3 = boto3.client('s3')
BUCKET = os.environ['UPLOAD_BUCKET']

def save_upload(file):
    # Store in S3 (or any object storage)
    key = f"uploads/{file.filename}"
    s3.upload_fileobj(file, BUCKET, key)
    return f"s3://{BUCKET}/{key}"
    # Accessible from any process, survives restarts

def get_upload(filename):
    key = f"uploads/{filename}"
    response = s3.get_object(Bucket=BUCKET, Key=key)
    return response['Body']
    # Works from any instance
```

**Acceptable temporary filesystem use:**

```python
import tempfile
import os

def process_large_file(file):
    # Temporary file for processing within single request
    with tempfile.NamedTemporaryFile(delete=False) as tmp:
        file.save(tmp.name)
        try:
            # Process the file
            result = expensive_operation(tmp.name)
            # Store result in backing service
            s3.upload_file(result, BUCKET, 'results/output.csv')
        finally:
            # Clean up temp file
            os.unlink(tmp.name)
    # Temp file used only during this request
    # Result persisted externally
```

**Benefits:**
- App can run in ephemeral containers (Kubernetes, ECS, etc.)
- Restarts don't lose data
- Horizontal scaling works - all instances see same data
- Disaster recovery is straightforward (backing service handles it)

Reference: [The Twelve-Factor App - Processes](https://12factor.net/processes)
