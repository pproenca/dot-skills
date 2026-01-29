---
title: Design Services to Be Detachable and Attachable Without Code Changes
impact: HIGH
impactDescription: enables zero-downtime migrations, disaster recovery, and scaling
tags: svc, resilience, migration, operations
---

## Design Services to Be Detachable and Attachable Without Code Changes

A twelve-factor app can detach a backing service and attach a replacement without deploying new code. This capability is essential for disaster recovery, performance migrations, and operational flexibility.

**Scenario: Database failing due to hardware issues**

**Incorrect (requires code changes to switch):**

```python
# config.py
PRIMARY_DB = "postgresql://primary.example.com/app"
REPLICA_DB = "postgresql://replica.example.com/app"

# Code decides which to use
def get_connection():
    if USE_REPLICA:  # Must deploy code change to flip this
        return connect(REPLICA_DB)
    return connect(PRIMARY_DB)
```

**Correct (switch via config only):**

```python
# config.py
import os
DATABASE_URL = os.environ["DATABASE_URL"]

def get_connection():
    return connect(DATABASE_URL)
```

```bash
# Disaster recovery procedure (no code deployment needed):

# 1. Current production config
DATABASE_URL="postgresql://primary.example.com/app"

# 2. Primary DB failing - spin up replacement from backup
# ... restore backup to new-primary.example.com ...

# 3. Update config and restart
DATABASE_URL="postgresql://new-primary.example.com/app"

# App connects to new database immediately
# Downtime limited to restart time, not deploy time
```

**Other scenarios this enables:**

```bash
# Upgrade to managed database
# Before: self-hosted PostgreSQL
DATABASE_URL="postgresql://db.internal:5432/app"

# After: AWS RDS (just change URL)
DATABASE_URL="postgresql://user:pass@myapp.xxx.us-east-1.rds.amazonaws.com:5432/app"

# Scale up cache
# Before: single Redis
REDIS_URL="redis://redis-1:6379/0"

# After: Redis cluster
REDIS_URL="redis://redis-cluster.example.com:6379/0"

# Switch email provider
# Before: self-hosted Postfix
SMTP_URL="smtp://mail.internal:25"

# After: SendGrid
SMTP_URL="smtp://apikey:SG.xxx@smtp.sendgrid.net:587"
```

**Benefits:**
- Disaster recovery without emergency deploys
- Migrate services during low-traffic windows via config change
- A/B test different service providers

Reference: [The Twelve-Factor App - Backing Services](https://12factor.net/backing-services)
