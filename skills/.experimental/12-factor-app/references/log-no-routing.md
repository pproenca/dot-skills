---
title: Never Route or Store Logs from Within the Application
impact: MEDIUM
impactDescription: simplifies app code, enables flexible log infrastructure
tags: log, routing, storage, separation
---

## Never Route or Store Logs from Within the Application

A twelve-factor app does not attempt to write to or manage logfiles. It does not configure log shipping, rotation, or aggregation. The execution environment handles capturing stdout, collating streams, and routing to destinations.

**Incorrect (app routes logs):**

```python
import logging
import requests
from logging.handlers import HTTPHandler

# App sends logs to external service
datadog_handler = HTTPHandler(
    host='http-intake.logs.datadoghq.com',
    url='/v1/input/YOUR_API_KEY',
    method='POST'
)
logger.addHandler(datadog_handler)

# Also write to file
file_handler = logging.FileHandler('/var/log/app.log')
logger.addHandler(file_handler)

# Also send to Sentry
sentry_sdk.init(dsn="https://xxx@sentry.io/xxx")

# Problems:
# - App knows about infrastructure (Datadog, Sentry URLs)
# - Credentials in app config
# - Network failures affect app
# - Different handlers per environment
# - Complex logging setup
```

**Correct (app writes to stdout, platform routes):**

```python
import logging
import sys

# Simple: just stdout
logging.basicConfig(
    stream=sys.stdout,
    level=os.environ.get('LOG_LEVEL', 'INFO'),
    format='%(asctime)s %(levelname)s %(message)s'
)

logger = logging.getLogger(__name__)
logger.info("Application started")

# App doesn't know or care where logs go
# Could be: file, Datadog, Elasticsearch, CloudWatch
# Decided by platform, not app
```

**Platform handles routing:**

```yaml
# Kubernetes with Fluentd sidecar
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: app
    # App writes to stdout
  - name: fluentd
    image: fluent/fluentd
    volumeMounts:
    - name: varlog
      mountPath: /var/log
    # Fluentd routes to Elasticsearch, S3, etc.
```

```yaml
# Docker with logging driver
services:
  app:
    logging:
      driver: fluentd
      options:
        fluentd-address: "fluentd:24224"
        tag: "app.{{.Name}}"
    # App just writes to stdout
    # Docker routes to Fluentd
    # Fluentd routes to Elasticsearch
```

```bash
# Heroku - logs automatically routed
heroku logs --tail
# Drains: heroku drains:add https://logs.papertrailapp.com/...

# AWS ECS - logs to CloudWatch automatically
# No app config needed
```

**Benefits:**
- App code is simple
- Same app works with any log infrastructure
- Change log destination without changing app
- No credentials or infrastructure URLs in app

Reference: [The Twelve-Factor App - Logs](https://12factor.net/logs)
