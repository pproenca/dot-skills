---
title: Execute the Application as Stateless Processes
impact: HIGH
impactDescription: enables horizontal scaling, ensures resilience to process crashes
tags: proc, stateless, processes, scaling
---

## Execute the Application as Stateless Processes

A twelve-factor app runs as one or more stateless processes. Processes are stateless and share-nothing - any data that needs to persist must be stored in a stateful backing service like a database. This enables horizontal scaling and resilience.

**Incorrect (stateful processes):**

```python
# Global state in the application process
user_sessions = {}  # In-memory session storage
upload_cache = {}   # Files waiting to be processed

def login(user_id, session_token):
    # Session stored in process memory
    user_sessions[session_token] = user_id
    # If process restarts, all sessions are lost
    # If load balancer routes to different process, session not found

def start_upload(file_data):
    # File stored in process memory
    upload_id = generate_id()
    upload_cache[upload_id] = file_data
    return upload_id  # User expects to continue this later

def complete_upload(upload_id):
    # May route to different process - upload_cache is empty!
    file_data = upload_cache.get(upload_id)  # KeyError or None
```

**Correct (stateless processes with external state):**

```python
import redis
import boto3

# External backing services for all persistent data
redis_client = redis.from_url(os.environ["REDIS_URL"])
s3 = boto3.client('s3')

def login(user_id, session_token):
    # Session stored in Redis (shared across all processes)
    redis_client.setex(
        f"session:{session_token}",
        timedelta(hours=24),
        user_id
    )

def start_upload(file_data):
    # File stored in S3 (accessible to all processes)
    upload_id = generate_id()
    s3.put_object(
        Bucket=os.environ["UPLOAD_BUCKET"],
        Key=f"pending/{upload_id}",
        Body=file_data
    )
    return upload_id

def complete_upload(upload_id):
    # Any process can complete the upload
    response = s3.get_object(
        Bucket=os.environ["UPLOAD_BUCKET"],
        Key=f"pending/{upload_id}"
    )
    file_data = response['Body'].read()
    # Process the file...
```

**Benefits:**
- Any request can be handled by any process
- Processes can be killed and restarted without data loss
- Horizontal scaling: just add more processes
- Zero-downtime deploys: drain old processes while new ones start

Reference: [The Twelve-Factor App - Processes](https://12factor.net/processes)
